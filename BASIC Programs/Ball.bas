! Display the graphics view.
system.showGraphics

! Set up the plot. Turn off the axis, hide the border 
! and use false color.
DIM p AS Plot
p = graphics.newPlot
p.setBorderColor(1, 1, 1)
p.setSurfaceStyle(3)
p.setAxisStyle(2)

! Plot the function.
DIM func AS PlotFunction
func = p.newSpherical(FUNCTION f)

p.setTranslation3D(0, 0, -5)
p.setTranslation(0, 1.5)

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "This sample shows how to plot a function in spherical coordinates."

about$ = about$ & CHR(10) & CHR(10) & "You can use swipe and pinch gestures to manipulate the plot. Tap the tools button at the top right to switch between changing the function and chaning the axis. Tap to see the coordinates of a point."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! This is the function to plot.
!
FUNCTION f(theta, phi)
f = 5
END FUNCTION
