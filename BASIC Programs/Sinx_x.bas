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

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "Here's a simple way to visualize functions in 3D. Swipe with one finger, or use two to rotate. Pinches enlarge or shrink the plot. Tap the button at the top right of the display to switch from changing the plot to changing the axis."

about$ = about$ & CHR(10) & CHR(10) & "The function that is plotted is right at the end of the program. Change it and you change the plot to whatever function you want to visualize."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! This is the function the program plots.
!
FUNCTION f(x, y)
d = SQR(x*x + y*y)
IF d = 0 THEN
  f = 10
ELSE
  f = 10*SIN(d)/d
END if
END FUNCTION