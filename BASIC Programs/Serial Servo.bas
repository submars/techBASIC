! This app uses an RN-XV WiFly and a Pololu Micro Serial Controller
! to control the position and update speed of a servo. The servo
! controller can control up to 8 servos, and the app can easily
! be extended to do the same.

! Declare the controls.
DIM positionSlider AS Slider, speedSlider AS Slider, quitButton AS Button

! Define the device and servo numbers.
DIM deviceID AS BYTE, servoNumber AS BYTE
deviceID = 1
servoNumber = 0

! Open a channel to the servo controller.
Comm.openTCPIP(1, "169.254.1.1", 2000)

! Set up the user interface.
setUpGUI

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout


! Set up the user interface.

SUB setUpGUI
DIM positionLabel AS Label, speedLabel AS Label, nameLabel AS Label
nameLabel = Graphics.newLabel(10, 10, 300, 30)
nameLabel.setText("WiFi Servos")
nameLabel.setAlignment(2)
nameLabel.setFont("Arial", 20, 0)

y = 80
positionLabel = Graphics.newLabel(10, y, 80)
positionLabel.setText("Position:")
positionLabel.setAlignment(3)

positionSlider = Graphics.newSlider(100, y, 210)

y = y + 53

speedLabel = Graphics.newLabel(10, y, 80)
speedLabel.setText("Speed:")
speedLabel.setAlignment(3)

speedSlider = Graphics.newSlider(100, y, 210)
speedSlider.setValue(1)

quitButton = Graphics.newButton(Graphics.width - 82, Graphics.height - 47)
quitButton.setTitle("Quit")
quitButton.setBackgroundColor(1, 1, 1)
quitButton.setGradientColor(0.6, 0.6, 0.6)

System.showGraphics
END SUB


! Shows the About alert when the program starts.

SUB showAbout
about$ = "This app controls a servo over a WiFi connection using an RN-XV WiFly and a Pololu Micro Serial Servo Controller. Specialized hardware is required to use this program."

about$ = about$ & CHR(10) & CHR(10) & "See the O'Reilly book, Building iPhone and iPad Electronic Projects, for a complete description of this app and instructions showing how to build the circuit it controls."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! Handle a tap on a button.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time stamp when the button was tapped.

SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quitButton THEN
  STOP
END IF
END SUB


! Handle a value changed event.
!
! Parameters:
!    ctrl - The control whose value changed.
!    time - The time stamp when the change occurred.

SUB valueChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = positionSlider THEN
  ! The position slider changed. Move the servo.
  b~ = 128
  PUT #1,,b~
  PUT #1,,deviceID
  b~ = 4
  PUT #1,,b~
  PUT #1,,servoNumber
  position% = ctrl.value*5000 + 500
  b~ = position% >> 7
  PUT #1,,b~
  b~ = position% BITAND $007F
  PUT #1,,b~
ELSE IF ctrl = speedSlider THEN
  ! The speed slider changed. Change the movement
  ! speed for the servo.
  b~ = 128
  PUT #1,,b~
  PUT #1,,deviceID
  b~ = 1
  PUT #1,,b~
  PUT #1,,servoNumber
  b~ = ctrl.value*127
  IF b~ = 0 THEN b~ = 1
  PUT #1,,b~
END IF
END SUB