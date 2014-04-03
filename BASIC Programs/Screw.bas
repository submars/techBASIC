! Display the graphics view.
system.showGraphics

! Set up the plot, labeling the axis, setting the axis
! style to show the color legend on a standard axis,
! and changing the mesh size to better display the entire
! range of the function.
DIM p AS Plot
p = graphics.newPlot
p.setSurfaceStyle(3)
p.setAxisStyle(4)
p.setBorderColor(1, 1, 1)
p.setMeshSize(5, 40)
p.setXAxisLabel("X Axis")
p.setYAxisLabel("Y Axis")
p.setZAxisLabel("Z Axis")

! Plot the function for a radius of 0 to 4 and theta
! from 0 to 5*pi.
DIM func AS PlotFunction
func = p.newCylindrical(FUNCTION f)
func.setDomain(0, 4, 0, 5*3.14159)

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "This sample shows how to plot a function in cylindrical coordinates."

about$ = about$ & CHR(10) & CHR(10) & "You can use swipe and pinch gestures to manipulate the plot. Tap the tools button at the top right to switch between changing the function and chaning the axis. Tap to see the coordinates of a point."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! This is the function to plot.
!
FUNCTION f(r, theta)
f = 2*theta/3.14159
END FUNCTION