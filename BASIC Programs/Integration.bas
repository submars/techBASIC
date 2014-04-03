! Numerically integrates a function. The function that is integrated
! is at the end of the program. The limits of integration can be
! changed by changing x0 and x1 right after these comments.
!
! For a complete discussion of this sample, see the blog titled
! "Numeric Integration with techBASIC" on the Byte Works web site at
! www.byteworks.us.
!
! Set up the limits of integration and find the integral.
x0 = 0
x1 = 2
ans = Math.trap(FUNCTION f, x0, x1)

! Create a plot to show the function and result.
DIM p AS Plot
p = Graphics.newPlot

! Draw the area under the curve.
DIM intfx AS PlotFunction
intfx = p.newFunction(FUNCTION f)
intfx.setDomain(x0, x1)
intfx.setFillColor(0, 1, 0)
intfx.setColor(0, 1, 0)

! Draw the function that was integrated.
DIM fx AS PlotFunction
fx = p.newFunction(FUNCTION f)

! Start by showing the area integrated in the middle 60% of the
! plot, with some buffer around the edges to see the part of the
! function that was not integrated.
y0 = f(x0)
y1 = y0
FOR x = x0 TO x1 STEP (x1 - x0)/100
  y = f(x)
  IF y < y0 THEN y0 = y
  IF y > y1 THEN y1 = y
NEXT
minY = y0
IF y1 < minY THEN minY = y1
minY = minY - ABS(y1 - y0)/3
maxY = minY + ABS(y1 - y0)*5/3

minX = x0
IF x1 < minX THEN minX = x1
minX = minX - ABS(x1 - x0)/3
maxX = minX + ABS(x1 - x0)*5/3

p.setView(minX, minY, maxX, maxY, 0)

! Use the plot title to show the limits of integration and the result.
p.setTitle("Integral of f(x) from " & STR(x0) & " to " & STR(x1) & " = " & STR(ans))
IF LCASE(LEFT(System.osVersion, 4)) = "ipad" THEN
  p.setTitleFont("Sans-Serif", 25, 0)
ELSE
  p.setTitleFont("Sans-Serif", 15, 0)
END IF

! Display the plot.
System.showGraphics

! This is the function to integrate.
FUNCTION f (x AS DOUBLE) AS DOUBLE
f = x*x*x*x*LOG(x + SQR(x*x + 1))
END FUNCTION