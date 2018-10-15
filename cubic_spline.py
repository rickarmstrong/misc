#!/usr/bin/env python
# BSD 3-Clause License
#
# Copyright (c) 2012, Rick Armstrong
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

""" A set of cubic spline interpolation classes """

from numpy import append, arange, array, diag, eye, linalg, ones, pi, sqrt, \
    zeros
from numpy.random.mtrand import rand

from pdb import set_trace

class SplineFitter1DUniformSpacing():
    """ 1D SplineFitter.

    Given a set of m evenly-spaced control points, creates n third-degree
    interpolation polynomials, where n = m - 1. Code uses notation from here
    http://mathworld.wolfram.com/CubicSpline.html
    """
    
    def __init__(self, x_i, y_i):
        """Generate n interpolation polynomials."""
        self.x_i = x_i
        self.y_i = y_i
    
        # number of control points == equations in the system
        self.m = len(x_i)
        m = self.m
        
        # number of interpolation polynomials
        self.n = self.m - 1
        n = self.n
        
        # create the system mmatrix A
        A = 4.0 * eye(self.m)
        A = A + diag(ones(m-1), k=1) + diag(ones(m-1), k=-1)
        A[0, 0] = 2.0
        A[m-1, m-1] = 2.0
        
        # Create the constant vector for the system.
        # The vector is of this form:
        #   3 * (y_1 - y_0)
        #       (y_2 - y_0)
        #       (y_3 - y_1)
        #           ...
        #       (y_n-1 - y_n-3)
        #       (y_n - y_n-2)
        #       (y_n - y_n-1)
        #
        # This is like performing 3 * (y_i - y_i-2), a central-difference, on a 
        # 'padded' y_i where the last and first control points are tacked onto
        # the end to make indexing easier. We'll call the 'padded' set of points
        # 'y', and the constant vector 'ycd':
        y = y_i.copy()
        y = append(y, y_i[-1])
        y = append(y, y_i[0])
                        
        x = x_i.copy()
        x = append(x, 2 * x_i[-1] - x_i[-2])
        x = append(x, 2 * x_i[0] - x_i[1])
        
        ycd = []
        for i in range(1, m+1):
            ycd.append(3.0 * (y[i] - y[i-2]))
        
        # solve for the vector of derivatives at each control point
        D = linalg.solve(A, ycd)
        
        # store coefficents for later interpolation using
        # Y_i(t) = a_i + (b_i * t) + (c_i * t^2) + (d_i * t^3)
        self.a = []
        self.b = []
        self.c = []
        self.d = []
        for i in range(n):
            self.a.append(y_i[i])
            self.b.append(D[i])
            self.c.append(3 * (y_i[i+1] - y_i[i]) - 2 * D[i] - D[i+1])
            self.d.append(2 * (y[i] - y_i[i+1]) + D[i] + D[i+1])
        
    def interpolate(self, x):
        
        x_i = self.x_i
        
        # figure out which interpolation polynomial we want
        poly_idx = 0
        for i in range(self.n):
            if x_i[i] <= x and x_i[i+1] > x:
                break            
        poly_idx = i

        t = (x - x_i[i]) / (x_i[i+1] - x_i[i])
        y = self.a[i] + self.b[i] * t + self.c[i] * t*t + self.d[i] * t*t*t
        return y
 
class SplineFitter1D():
    """ 1D SplineFitter.

    Given a set of n control points with arbitrary spacing between x-values,
    creates a piecewise-linear spline composed of a set of n - 1
    third-degree interpolation polynomials, one for each interval.
    The polynomials meet at the control points, are smooth in the first
    derivative, and continuous in the second.
    At the endpoints, the second derivative is chosen to be zero, creating
    a 'natural' cubic spline.
    The formulae we use are from Numerical Recipes in C, except that we
    use zero-based indexing here.
    """
    
    def __init__(self, x, y):
        """ Set up and solve the system of equations to find
        n-2 second derivatives.
        
        Note: we only need a (n-2)x(n-2) system, since we'll set the second
        derivatives of the endpoints to zero.
        """
        
        # control points
        self.x = x
        self.y = y
        n = len(x)
        self.n = n
        
        # the main diagonal on A
        A_d0= []
        for j in range(1, len(x) - 1):
            A_d0.append((x[j+1] - x[j-1]) / 3.0)
        A_d0 = array(A_d0)
            
        # off-diagonals on A
        A_d1 = []
        for j in range(1, len(x) - 2):
            A_d1.append((x[j+1] - x[j]) / 6.0)
        A_d1 = array(A_d1)

        # the complete coefficient matrix A        
        A = diag(A_d0) + diag(A_d1, k=1) + diag(A_d1, k=-1)
        A = A
        print 'A = \n', A
        
        # the right-hand side vector
        b = []
        for j in range(1, len(x) - 1):
            b.append(((y[j+1] - y[j])/(x[j+1] - x[j])) - \
                ((y[j] - y[j-1])/(x[j] - x[j-1])))
        b = array(b)
        print 'b = ', b
        
        # solve for second derivatives at interior control points, and add
        # zeros at either end
        y_d2 = linalg.solve(A, b)
        y_d2 = append([0.0], y_d2)
        self.y_d2 = append(y_d2, [0.0])
        print 'y_d2 = ', self.y_d2
        
    def interpolate(self, t):
        """ return the interpolated value between control points. """
     
        # for brevity later
        x = self.x
        y = self.y
        y_d2 = self.y_d2
        
        # figure out which interpolation polynomial we want
        poly_idx = 0
        for j in range(self.n - 1):
            if self.x[j] <= t and self.x[j+1] > t:
                break
        
        # interpolate
        A = (x[j+1] - t) / (x[j+1] - x[j])
        B = 1.0 - A
        C = (A*A*A - A) * (x[j+1] - x[j]) * (x[j+1] - x[j]) / 6.0
        D = (B*B*B - B) * (x[j+1] - x[j]) * (x[j+1] - x[j]) / 6.0
        return A * y[j] + B * y[j+1] + C * y_d2[j] + D * y_d2[j+1]

class SplineFitter2D:
    """ 2D SplineFitter.

    Given a set of n distinct control points with arbitrary spacing,
    creates a plane curve from a piecewise-linear spline composed of a
    set of n - 1 third-degree interpolation polynomials, one for each interval.
    The polynomials meet at the control points, are smooth in the first
    derivative, and continuous in the second.
    At the endpoints, the second derivative is chosen to be zero, creating
    a 'natural' cubic spline.
    The formulae we use are from Numerical Recipes in C, except that we
    use zero-based indexing.
    """

    def __init__(self, points):
        """ Given a numpy array of ordered points
        
            [[x_0, y_0], [x_1, y_1],...[x_n-1, y_n-1]]
            
        create an array of inter-point distances d_i[].
        Then, construct 
        
                 n-2
        u_i[i] = sum (d_i[i])
                 i=0
 
        which represents the sum of the lengths of the line segments joining
        the points from 0 to i. Then create two sets of parameterized control
        points (u_i[i], x[u_i[i]]) and (u_i[i], y[u_i[i]]) to construct a
        SplineFitter for each dimension.
        """
        
        # create u_i
        d_i = zeros(len(points) - 1)
        for i in range(0, len(points) - 1):
            d_i[i] = self._dist(points[i+1], points[i])
        u_i = zeros(len(points))
        for i in range(1, len(points)):
            u_i[i] = u_i[i-1] + d_i[i-1]
        self.u_max = max(u_i)
        
        self.fitter_x = SplineFitter1D(u_i, points[:, 0])
        self.fitter_y = SplineFitter1D(u_i, points[:, 1])
                
    def _dist(self, v0, v1):
        """ Return the Euclidian distance between two vectors. """
        v2 = v1 - v0
        return sqrt(v2[0] * v2[0] + v2[1] * v2[1])
    
    def interpolate(self, u):
        x = self.fitter_x.interpolate(u)
        y = self.fitter_y.interpolate(u)
        return array([x, y])
        
def uniformly_spaced_data_demo(x_i, y_i):
    import pylab
        
    fitter = SplineFitter1DUniformSpacing(x_i, y_i)
    x = arange(0, max(x_i), 0.01)
    y = []
    for p in x:
        y.append(fitter.interpolate(p))
    
    p0 = pylab.plot(x_i, y_i, '*', label='control_points')
    p1 = pylab.plot(x, y, '-', label='spline')
    pylab.legend([p0, p1], ['control_points', 'spline'])
    pylab.show()
    
def arbitrarily_spaced_data_demo(x_j, y_j):
    fitter = SplineFitter1D(x_j, y_j)
    x = arange(0, max(x_j), 0.1)
    y = []
    for p in x:
        y.append(fitter.interpolate(p))
    
    p0 = pylab.plot(x_j, y_j, '*', label='control_points')
    p1 = pylab.plot(x, y, '-', label='spline')
    pylab.legend([p0, p1], ['control_points', 'spline'])
    pylab.show()
    
    
def parameterized_2d_spline_demo():
    u_i = array([0.0, 1.0, 1.0 + sqrt(2.0), 1.0 + sqrt(2.0) + 1.0, \
                1.0 + sqrt(2.0) + 2.0, 1.0 + sqrt(2.0) + 2.0 + sqrt(2.0), \
                1.0 + sqrt(2.0) + 2.0 + sqrt(2.0) + 1.0])    
    x_i = array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 4.0])
    y_i = array([1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0])
    fitter_x = SplineFitter1D(u_i, x_i)
    fitter_y = SplineFitter1D(u_i, y_i)
    x = []
    y = []
    u = arange(0, max(u_i), 0.1)
    for p in u:
        x.append(fitter_x.interpolate(p))
        y.append(fitter_y.interpolate(p))
    
    p0 = pylab.plot(x_i, y_i, '*', label='control_points')
    p1 = pylab.plot(x, y, '-', label='spline')
    pylab.legend([p0, p1], ['control_points', 'spline'])
    pylab.show()    
    
def parameterized_2d_spline_demo2():
    x_i = array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 4.0])
    y_i = array([1.0, 1.0, 2.0, 2.0, 2.0, 3.0, 3.0])
    p = zeros((len(x_i), 2))
    for i in range(len(x_i)):
        p[i,:] = array([x_i[i], y_i[i]])
    fitter = SplineFitter2D(p)
    
    # interpolate and plot
    xy = []
    u = arange(0, fitter.u_max, 0.1)
    for t in u:
        xy.append(fitter.interpolate(t))
    xy = array(xy)
    p0 = pylab.plot(x_i, y_i, '*', label='control_points')
    p1 = pylab.plot(xy[:, 0], xy[:, 1], '-', label='spline')
    pylab.legend([p0, p1], ['control_points', 'spline'])
    pylab.show()            
        
    
if __name__ == "__main__":
    import pylab
    
    y = rand(50)
    x = (arange(50) * 10.0) + rand(50)

    #uniformly_spaced_data_demo(x, y)
    #arbitrarily_spaced_data_demo(x, y)
    #parameterized_2d_spline_demo()
    parameterized_2d_spline_demo2()




























    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    