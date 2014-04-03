! Set up the plot.
DIM p AS Plot, pv AS PlotVector
p = Graphics.newPlot
p.setAllowedGestures(0)

System.showGraphics

! Define some constants.
PI = 3.1415926435
mu0 = PI*4e-7

! Set up the location and initial current for the two wires.
wire1X = 1.5
wire1Y = 5
wire2X = 8.5
wire2Y = 5
wire1Current = 1
wire2Current = -1

! Set up the initial vector field.
h% = 20
v% = 20
DIM m(h%*v%, 4)
calculateField
pv = p.newVectorPlot(m)

! Set up the slider controls and quit button.
DIM leftSlider AS Slider, leftLabel AS Label
DIM rightSlider AS Slider, rightLabel AS Label
DIM backgroundLabel AS Label

width = 200
IF System.device = 0 OR System.device = 256 THEN
  h = Graphics.width - 160
ELSE
  h = (Graphics.width - width)/2
END IF
v = Graphics.height - 80
backGroundLabel = Graphics.newLabel(h - 160, v - 5, 360, 60)
backGroundLabel.setBackgroundColor(1, 1, 1, 0.7)

leftSlider = Graphics.newSlider(h, v, 150)
leftSlider.setMinValue(-2)
leftSlider.setMaxValue(2)
leftSlider.setValue(1)

leftLabel = Graphics.newLabel(h - 160, v, 150)
leftLabel.setText("Left Wire Current:")
leftLabel.setAlignment(3)
leftLabel.setBackgroundColor(1, 1, 1, 0)

v = v + 30
rightSlider = Graphics.newSlider(h, v, 150)
rightSlider.setMinValue(-2)
rightSlider.setMaxValue(2)
rightSlider.setValue(1)

rightLabel = Graphics.newLabel(h - 160, v, 150)
rightLabel.setText("Right Wire Current:")
rightLabel.setAlignment(3)
rightLabel.setBackgroundColor(1, 1, 1, 0)

DIM quit AS Button
IF System.device = 0 OR System.device = 256 THEN
  quit = Graphics.newButton(10, 10)
ELSE
  quit = Graphics.newButton(Graphics.width - 82, Graphics.height - 70)
END IF
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.6, 0.6, 0.6)

! Don't use an axis.
p.setAxisStyle(2)

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END

! Calculate the combined field from two wires.
!
SUB calculateField
print wire1Current, wire2Current
index = 0
FOR x% = 1 TO h%
  FOR y% = 1 TO v%
    ! Find the index into the array and x, y values.
    index = index + 1
    x = x%*10.0/h%
    y = y%*10.0/v%

    ! Set the position for the vector.
    m(index, 1) = x
    m(index, 2) = y
       
    ! Find the contribution from wire1.
    r = SQR((y - wire1Y)*(y - wire1Y) + (x - wire1X)*(x - wire1X))
    B = mu0*wire1Current/(2*PI*r)
    iHat = B*(y - wire1Y)
    jHat = -B*(x - wire1X)
    
    ! Add the contribution from wire2.
    r = SQR((y - wire2Y)*(y - wire2Y) + (x - wire2X)*(x - wire2X))
    B = mu0*wire2Current/(2*PI*r)
    iHat = iHat + B*(y - wire2Y)
    jHat = jHat - B*(x - wire2X)
    
    ! Set the direction and length of the field at x, y.
    scale = 0.8e6
    m(index, 3) = x + scale*iHat
    m(index, 4) = y + scale*jHat
  NEXT y%
NEXT x%
END SUB

! Handle a change in one of the slider values.
!
! Parameters:
!    ctrl - The slider that changed.
!    time - The time stamp when the slider changed.
!
SUB valueChanged (ctrl AS Control, when AS DOUBLE)
IF ctrl = leftSlider THEN
  wire1Current = leftSlider.value
ELSE IF ctrl = rightSlider THEN
  wire2Current = rightSlider.value
END IF
calculateField
pv.setPoints(m)
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
about$ = "Interaction of fields can be difficult to visualize. Here's a classic example. Imagine two wires running through the display. They create a magnetic field, but what does it look like, especially as the currents in the wires are changed?"

about$ = about$ & CHR(10) & CHR(10) & "Find out with this program. The "
about$ = about$ & "sliders vary the current in the wires from -2 to 2"
about$ = about$ & " amps, and the magnetic field caused by the interaction"
about$ = about$ & " is shown. It's easy to change the program to show"
about$ = about$ & " different numbers of wires, or even different kinds"
about$ = about$ & " of fields."

about$ = about$ & CHR(10) & CHR(10) & "See the online Help and Reference"
about$ = about$ & " Manual for details about how to use controls like the"
about$ = about$ & " slider and plots like vector fields. The Reference Manual"
about$ = about$ & " also has more examples of controls and surfaces."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB