! Display the graphics view.
system.showGraphics

! Set up the plot, label it, and display the function
! with false color.
DIM p AS Plot
p = graphics.newPlot
p.setTitle("f(x, y) = 10*sin(r)/r; r = sqrt(x*x + y*y)")
p.setGridColor(0.85, 0.85, 0.85)
p.setsurfacestyle(3)
p.setAxisStyle(5)

! Add the function.
DIM func AS PlotFunction
func = p.newFunction(FUNCTION f)

! Adjust the function so the portion under the X-Y
! plane is visible, and push it slightly off the Z
! axis so the beginning of the descending curve
! can be seen.
p.setTranslation3D(-4, -3, -2)
p.setScale3D(1, 1, .8)
END

FUNCTION f(x, y)
d = SQR(x*x + y*y)
IF d = 0 THEN
  f = 10
ELSE
  f = 10*SIN(d)/d
END if
END FUNCTION