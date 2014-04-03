! Shows a running plot of rotation for the last 10 seconds 
! in 0.1 second intervals. Supports recording the values
! and emailing the results.

! Create the plots and arrays to hold the plot points.
DIM p as Plot, px as PlotPoint, py as PlotPoint, pz as PlotPoint
DIM rx(100, 2), ry(100, 2), rz(100, 2)

! Create the controls.
DIM quit AS Button, record AS Button, send AS Button

! Create and initialize the global tracking variables.
fileName$ = "tempdata.txt"
recording = 0

! Get and set an initial time for the gyroscope.
DIM t0 AS DOUBLE
IF Sensors.gyroAvailable THEN
  WHILE t0 = 0
    r = Sensors.gyro
    t0 = r(4)
  WEND
END IF

! Create the user interface.
setUpGUI


! Creates a new button with a gradient fill.
!
! Parameters:
!    x - Horizontal location.
!    y - Vertical location.
!    title - Name of the button.
!
! Returns: The new button.

FUNCTION newButton (x, y, title AS STRING) AS Button
DIM b AS Button
b = Graphics.newButton(x, y)
b.setTitle(title)
b.setBackgroundColor(1, 1, 1)
b.setGradientColor(0.6, 0.6, 0.6)
newButton = b
END FUNCTION


! Called when nothing else is happening, this
! subroutine checks to see if 0.1 seconds have
! elapsed since the last sensor reading. If so, a
! new one is recorded and displayed.
!
! Parameters:
!    time - The time when the event occurred.

SUB nullEvent (time AS DOUBLE)
r = Sensors.gyro

IF recording AND (t0 <> r(4)) THEN
  PRINT #1, r(1); ","; r(2); ","; r(3); ","; r(4)
END IF

IF r(4) > t0 + 0.1 THEN
  WHILE r(4) > t0 + 0.1
    t0 = t0 + 0.1
    FOR i = 1 TO 99
      rx(i, 2) = rx(i + 1, 2)
      ry(i, 2) = ry(i + 1, 2)
      rz(i, 2) = rz(i + 1, 2)
    NEXT
    rx(100, 2) = r(1)
    ry(100, 2) = r(2)
    rz(100, 2) = r(3)
  WEND
  px.setPoints(rx)
  py.setPoints(ry)
  pz.setPoints(rz)
END IF
END SUB


! Send the last recorded data file to an email.

SUB sendData
DIM e AS eMail
e = System.newEMail
IF e.canSendMail THEN
  e.setSubject("Gyroscope data")
  e.setMessage("Gyroscope data")
  e.addAttachment(fileName$, "text/plain")
  e.send
ELSE
  button = Graphics.showAlert("Can't Send", _
     "Email cannot be sent from this device.")
END IF
END SUB


! Set up the user interface.

SUB setUpGUI
! Tell the gyroscope to update once every 0.05 seconds.
Sensors.setGyroRate(0.05)

! Initialize the plot arrays.
FOR t = 1 TO 100
  rx(t, 1) = t/10.0 - 10
  ry(t, 1) = t/10.0 - 10
  rz(t, 1) = t/10.0 - 10
NEXT

! Initialize the plot and show it.
p = Graphics.newPlot
p.setTitle("Rotation in Radians per Second")
p.setXAxisLabel("Time in Seconds")
p.setYAxisLabel("Rotation: X: Green, Y: Red, Z: Blue")
p.showGrid(1)
p.setGridColor(0.8, 0.8, 0.8)
p.setAllowedGestures($0042)

px = p.newPlot(rx)
px.setColor(0, 1, 0)
px.setPointColor(0, 1, 0)

py = p.newPlot(ry)
py.setColor(1, 0, 0)
py.setPointColor(1, 0, 0)

pz = p.newPlot(rz)
pz.setColor(0, 0, 1)
pz.setPointColor(0, 0, 1)

! Set the plot range and domain. This must be done
! after adding the first PlotPoint, since that also
! sets the range and domain.
p.setView(-10, -10, 0, 10, 0)

! Show the graphics screen. Pass 1 as the parameter
! for full-screen mode.
system.showGraphics(1)

! Lock the screen in the current orientation.
orientation = 1 << (System.orientation - 1)
System.setAllowedOrientations(orientation)

! Set the plot size.
p.setRect(0, 0, Graphics.width, Graphics.height - 47)

! Draw the background.
Graphics.setPixelGraphics(0)
Graphics.setColor(0.886, 0.886, 0.886)
Graphics.fillRect(0, 0, Graphics.width, Graphics.height)

! Set up the user interface.
h = Graphics.height - 47
quit = newButton(Graphics.width - 82, h, "Quit")
record = newButton(Graphics.width - 174, h, "Record")
send = newButton(Graphics.width - 266, h, "Send")

! If there is nothing to send, disable the Send button.
IF NOT EXISTS(fileName$) THEN
  send.setEnabled(0)
END IF

! Make sure a gyroscope is available. If not, say
! so and stop the program.
IF NOT Sensors.gyroAvailable THEN
  msg$ = "This device does not have a gyroscope. "
  msg$ = msg$ & "The program will exit."
  button = Graphics.showAlert("No Gyro", msg$)
  STOP
END IF
END SUB


! Called when the program should start recording
! data, this subroutine changes the name of the
! recording button to Stop, opens the output file,
! and sets a flag indicating data should be
! recorded.

SUB startRecording
record.setTitle("Stop")
recording = 1
OPEN fileName$ FOR OUTPUT AS #1
END SUB


! Called to stop recording data, this subroutine
! changes the name of the recording button to 
! Recording, clears the recording flag and closes
! the output file.
!
! It is safe to call this subroutine even if
! nothing is being recorded.

SUB stopRecording
IF recording THEN
  record.setTitle("Record")
  CLOSE #1
  recording = 0
  send.setEnabled(1)
END IF
END SUB


! Handle a tap on one of the buttons.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time when the event occurred.

SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  stopRecording
  STOP
ELSE IF ctrl = record THEN
  IF recording THEN
    stopRecording
  ELSE
    startRecording
  END IF
ELSE IF ctrl = send THEN
  stopRecording
  sendData
END IF
END SUB