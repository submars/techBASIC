! Create a quit button.
DIM quit AS Button
quit = Graphics.newButton(Graphics.width - 20 - 72, Graphics.height - 37 - 20)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.7, 0.7, 0.7)
	
! Create a Switch control and a label to show its value.
DIM mySwitch AS Switch
y = 20
mySwitch = Graphics.newSwitch(20, y)

DIM onOrOff AS Label
onOrOff = Graphics.newLabel(107, y)
onOrOff.setText("Off")

! Create a slider.
DIM mySlider AS Slider
y = y + 47
mySlider = Graphics.newSlider(20, y, 129)

! Create a progress bar to show the slider value.
DIM slideValue AS Progress
y = y + 33
slideValue = Graphics.newProgress(20, y, 129)

! Create an activity indicator with two buttons to start and stop it.
DIM activityIndicator AS Activity
DIM activityStart as Button, activityStop as Button

y = y + 29
activityIndicator = Graphics.newActivity(75, y)
activityIndicator.setColor(0, 0, 1)

y = y + 30
activityStart = Graphics.newButton(20, y, 60)
activityStart.setTitle("Start")
activityStart.setBackgroundColor(1, 1, 1)
activityStart.setGradientColor(0.7, 0.7, 0.7)

activityStop = Graphics.newButton(90, y, 60)
activityStop.setTitle("Stop")
activityStop.setBackgroundColor(1, 1, 1)
activityStop.setGradientColor(0.7, 0.7, 0.7)

! Create a stepper with a label to show its value.
DIM myStepper AS Stepper, stepValue AS Label

y = y + 57
myStepper = Graphics.newStepper(20, y)
myStepper.setStepValue(5)
myStepper.setMinValue(-50)
myStepper.setMaxValue(50)
myStepper.setValue(0)

stepValue = Graphics.newLabel(122, y, 27)
stepValue.setText("0")

! Create a button to bring up an alert, and a label to show
! which button was pressed on the alert.
DIM alertButton AS Button, alertLabel AS Label
y = y + 47
alertButton = Graphics.newButton(20, y, 100)
alertButton.setTitle("Alert")
alertButton.setBackgroundColor(1, 1, 1)
alertButton.setGradientColor(0.7, 0.7, 0.7)

alertLabel = Graphics.newLabel(20, y + 45, 135)

! Paint the background gray.
Graphics.setColor(0.95, 0.95, 0.95)
Graphics.fillRect(0, 0, Graphics.width, Graphics.height)

! Show the graphics screen.
System.showGraphics

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "This program shows how to use many of the controls available from techBASIC."

about$ = about$ & CHR(10) & CHR(10) & "See the Blogs section of the Byte Works web site for a tutorial that develops this program."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("Busy Box 4 of 5", about$)
END SUB


SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  STOP
ELSE IF ctrl = activityStart THEN
  activityIndicator.startAnimation
ELSE IF ctrl = activityStop THEN
  activityIndicator.stopAnimation
ELSE IF ctrl = alertButton THEN
  i = Graphics.showAlert("Title", "Message", "1", "2", "3", "4")
  alertLabel.setText("Button " & str(i) & " pressed.")
END IF
END SUB


SUB valueChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = mySwitch THEN
  IF mySwitch.isOn THEN
    onOrOff.setText("On")
  ELSE
    onOrOff.setText("Off")
  END IF
ELSE IF ctrl = mySlider THEN
  slideValue.setValue(mySlider.value)
ELSE IF ctrl = myStepper THEN
  stepValue.setText(STR(myStepper.value))
END IF
END SUB
