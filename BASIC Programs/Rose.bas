! Display the graphics view.
system.showGraphics

! Set up the plot and set the plot title.
DIM p AS Plot
p = graphics.newPlot
p.setTitle("sin(2*theta)*cos(2*theta)")

! Define the function. Set the line color to red
! and the line style to a dashed line.
DIM func AS PlotFunction
func = p.newPolar(FUNCTION f)
func.setColor(1, 0, 0)
func.setStyle(2)

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "This sample shows how to plot a function in polar coordinates."

about$ = about$ & CHR(10) & CHR(10) & "You can use swipe and pinch gestures to manipulate the plot. Tap to see the coordinates of a point."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! Plot this function.
!
FUNCTION f(theta)
f = SIN(2*theta)*COS(2*theta)
END FUNCTION
