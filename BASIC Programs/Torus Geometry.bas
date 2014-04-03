! Show the graphics screen.
System.showGraphics

! Set up the plot.
DIM p as Plot
p = Graphics.newPlot
p.setGridColor(0.85, 0.85, 0.85)
p.setSurfaceColor(0.5, 0.7, 1.0, 0.5)
p.setAxisStyle(3)

! Set up the initial torus.
hSize% = 41
vSize% = 16
DIM x(hSize%, vSize%), y(hSize%, vSize%), z(hSize%, vSize%)
R = 3
a = 1
PI = 3.1415926535
DIM surface AS PlotSurface
newTorus(R, a)
surface = p.newSurface(x(), y(), z())

! Set up the slider controls and quit button.
DIM rSlider AS Slider, rLabel AS Label, aSlider AS Slider, aLabel AS Label
width = 200
h = (Graphics.width - width)/2
v = Graphics.height - 50
rSlider = Graphics.newSlider(h, v, width)
rSlider.setMinValue(0)
rSlider.setMaxValue(4)
rSlider.setValue(3)

rLabel = Graphics.newLabel(h - 60, v, 50)
rLabel.setText("R:")
rLabel.setAlignment(3)
rLabel.setBackgroundColor(1, 1, 1, 0)

v = v - 30
aSlider = Graphics.newSlider(h, v, width)
aSlider.setMinValue(0)
aSlider.setMaxValue(4)
aSlider.setValue(1)

aLabel = Graphics.newLabel(h - 60, v, 50)
aLabel.setText("a:")
aLabel.setAlignment(3)
aLabel.setBackgroundColor(1, 1, 1, 0)

DIM quit AS Button
IF System.device = 1 OR System.device = 257 THEN
  quit = Graphics.newButton(Graphics.width - 82, Graphics.height - 70)
ELSE
  quit = Graphics.newButton(10, 10)
END IF
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.6, 0.6, 0.6)

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END

! Calculate and display a torus.
!
! Parameters:
!    R - The distance from the center of the torus to the center of the
!        ring.
!    a - The radius of the ring.
!
! Returns: A new torus surface is built in the program's x, y and z matrices.
!
SUB newTorus (R, a)
FOR u% = 1 TO hSize%
  u = u%*2*PI/(hSize% - 1)
  FOR v% = 1 TO vSize%
    v = v%*2*PI/(vSize% - 1)
    x(u%, v%) = (R + a*cos(v))*cos(u)
    y(u%, v%) = (R + a*cos(v))*sin(u)
    z(u%, v%) = a*sin(v)
  NEXT
NEXT
END SUB

! Handle a change in one of the slider values.
!
! Parameters:
!    ctrl - The slider that changed.
!    time - The time stamp when the slider changed.
!
SUB valueChanged (ctrl AS Control, when AS DOUBLE)
IF ctrl = rSlider THEN
  R = rSlider.value
ELSE IF ctrl = aSlider THEN
  a = aSlider.value
END IF
newTorus(R, a)
surface.setSurface(x(), y(), z())
p.repaint
END SUB

! Handle a tap on the Quit button.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time stamp when the button was tapped.
!
SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  STOP
END IF
END SUB

! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "You can visualize complex mathematical functions and relationships, even dynamically changing them, as seen in this torus."

about$ = about$ & CHR(10) & CHR(10) & "By changing the radius of the tube (a) and the distance from the center of the torus to the center of the tube (R), you can see how the torus gradually changes from a ring torus to a horn torus, a spindle torus, and finally degenerates to a sphere."

about$ = about$ & CHR(10) & CHR(10) & "See the online Help and Reference"
about$ = about$ & " Manual for details about how to use controls like the slider and plots like the surface of the torus. The"
about$ = about$ & " Reference Manual also has more examples of controls and surfaces."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB