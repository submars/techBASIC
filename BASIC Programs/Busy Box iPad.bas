! Create a quit button.
DIM quit AS Button
quit = Graphics.newButton(Graphics.width - 20 - 72, Graphics.height - 37 - 20)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.7, 0.7, 0.7)
	
! Create a text field with a label.
DIM myTextField AS TextField, textFieldLabel as Label
textFieldLabel = Graphics.newLabel(20, 20, 100)
textFieldLabel.setText("Text Field:")
textFieldLabel.setAlignment(3)

x = 128
width = (Graphics.width - x - 28)/2
myTextField = Graphics.newTextField(x, 20, width)
myTextField.setBackgroundColor(1, 1, 1)

! Create a label to show the current value of the text field.
DIM textFieldValueLabel AS Label
textFieldValueLabel = Graphics.newLabel(x + width + 8, 20, width)

! Create a text view with a label.
DIM myTextView AS TextView, textViewLabel AS Label
y = 71
textViewLabel = Graphics.newLabel(20, y, 100)
textViewLabel.setText("Text View:")
textViewLabel.setAlignment(3)

myTextView = Graphics.newTextView(x, y, width, 230)

! Create a read-only text view to show the typed text.
DIM textViewValue AS TextView
textViewValue = Graphics.newTextView(x + width + 8, y, width, 230)
textViewValue.setEditable(0)

! Create a Switch control and a label to show its value.
DIM mySwitch AS Switch
y = y + 250
mySwitch = Graphics.newSwitch(20, y)

DIM onOrOff AS Label
onOrOff = Graphics.newLabel(107, y)
onOrOff.setText("Off")

! Create a number picker.
DIM numberPicker AS Picker, wheels(3) AS INTEGER, rows(10) AS STRING
x = 169
numberPicker = Graphics.newPicker(x, y)

FOR i = 1 TO 3
  wheels(i) = i
NEXT
numberPicker.insertWheels(wheels)

FOR i = 1 TO 10
  rows(i) = STR(i - 1)
NEXT
FOR i = 1 TO 3
  numberPicker.insertRows(rows, 1, i)
NEXT

numberPicker.setShowsSelection(1)

! Create a label to show the results from the number picker.
DIM resultsLabel AS Label
resultsLabel = Graphics.newLabel(x, y + 224, 330)
resultsLabel.setAlignment(2)

! Hide the number picker.
numberPicker.setHidden(1)

! Create a date picker.
DIM myDatePicker AS DatePicker
myDatePicker = Graphics.newDatePicker(x, y)

! Create a segmented control to choose between various controls.
DIM controlPicker AS SegmentedControl
controlPicker = Graphics.newSegmentedControl(x, y + 253, 330)
controlPicker.insertSegment("Date Picker", 1, 0)
controlPicker.insertSegment("Picker", 2, 0)
controlPicker.insertSegment("Map", 3, 0)
controlPicker.setSelected(1)
controlPicker.setApportionByContent(1)

! Create a map view.
DIM map AS MapView
map = Graphics.newMapView(x, y, 330, 216)
map.setShowLocation(1)
map.setLocationTitle("Me", "Programming")
map.setHidden(1)

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

! Create a table.
DIM myTable AS Table, tableValue AS Label
x = 169 + 20 + 330
y = 321
width = Graphics.width - 20 - x
tableValue = Graphics.newLabel(x, y, width)
myTable = Graphics.newTable(x, y + 29, width)

myTable.insertRow("One", 1)
myTable.insertRow("Two", 2)
myTable.insertRow("Three", 3)
myTable.insertRow("Four", 4)
myTable.insertRow("Five", 5)
myTable.insertRow("Six", 6)
myTable.insertRow("Seven", 7)
myTable.insertRow("Eight", 8)
myTable.insertRow("Nine", 9)
myTable.insertRow("Ten", 10)

DIM sections(2) AS INTEGER
sections(1) = 2
sections(2) = 3
myTable.insertSections(sections)

myTable.insertRow("Uno", 1, 2)
myTable.insertRow("Dos", 2, 2)
myTable.insertRow("Tres", 3, 2)

myTable.insertRow("I", 1, 3)
myTable.insertRow("II", 2, 3)
myTable.insertRow("III", 3, 3)
myTable.insertRow("IV", 4, 3)

myTable.setSectionText("English", 1)
myTable.setSectionText("Spanish", 2)
myTable.setSectionText("Roman", 3)

myTable.setSelection(1)
myTable.setFont("Arial", 16, 1)

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

i = Graphics.showAlert("About This Sample", about$)
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


SUB textChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = myTextField THEN
  textFieldValueLabel.setText(myTextField.getText)
ELSE IF ctrl = myTextView THEN
  textViewValue.setText(myTextView.getText)
END IF
END SUB


SUB valueChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = mySwitch THEN
  IF mySwitch.isOn THEN
    onOrOff.setText("On")
  ELSE
    onOrOff.setText("Off")
  END IF
ELSE IF ctrl = numberPicker THEN
  r$ = STR(numberPicker.selection - 1)
  r$ = r$ & STR(numberPicker.selection(2) - 1)
  r$ = r$ & STR(numberPicker.selection(3) - 1)
  resultsLabel.setText(r$)
ELSE IF ctrl = controlPicker THEN
  SELECT CASE controlPicker.selected
    CASE 1:
      numberPicker.setHidden(1)
      myDatePicker.setHidden(0)
      map.setHidden(1)
    CASE 2:
      numberPicker.setHidden(0)
      myDatePicker.setHidden(1)
      map.setHidden(1)
    CASE 3:
      numberPicker.setHidden(1)
      myDatePicker.setHidden(1)
      map.setHidden(0)
  END SELECT
ELSE IF ctrl = myDatePicker THEN
  DIM datePickerDate AS Date
  datePickerDate = myDatePicker.date
  resultsLabel.setText(datePickerDate.longDate & " " & datePickerDate.longTime)
ELSE IF ctrl = mySlider THEN
  slideValue.setValue(mySlider.value)
ELSE IF ctrl = myStepper THEN
  stepValue.setText(STR(myStepper.value))
END IF
END SUB


SUB mapLocation (ctrl AS Control, time AS DOUBLE, latitude AS DOUBLE, longitude AS DOUBLE)
s$ = "Tap at: "
s$ = s$ & STR(CSNG(latitude))
s$ = s$ & ", " & STR(CSNG(longitude))
resultsLabel.setText(s$)
END SUB


SUB cellSelected (ctrl AS Control, time AS DOUBLE, row AS INTEGER, section AS INTEGER)
tableValue.setText(myTable.getText(row, section))
END SUB
