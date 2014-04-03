! Create a quit button.
DIM quit AS Button
quit = Graphics.newButton(Graphics.width - 20 - 72, Graphics.height - 37 - 20)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.7, 0.7, 0.7)
	
! Create a number picker.
DIM numberPicker AS Picker, wheels(3) AS INTEGER, rows(10) AS STRING
x = 0
y = 0
width = Graphics.width
height = 216 : ! There are only 3 valid heights for a picker: 162, 180 or 216
numberPicker = Graphics.newPicker(x, y, width, height)

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
resultsLabel = Graphics.newLabel(20, y + height + 8, width - 40)
resultsLabel.setAlignment(2)

! Hide the number picker.
numberPicker.setHidden(1)

! Create a date picker.
DIM myDatePicker AS DatePicker
myDatePicker = Graphics.newDatePicker(x, y, width, height)

! Create a segmented control to choose between various controls.
DIM controlPicker AS SegmentedControl
controlPicker = Graphics.newSegmentedControl(20, y + height + 8 + 21 + 8, width - 40, 30)
controlPicker.insertSegment("Date Picker", 1, 0)
controlPicker.insertSegment("Picker", 2, 0)
controlPicker.insertSegment("Map", 3, 0)
controlPicker.setSelected(1)
controlPicker.setApportionByContent(1)

! Create a map view.
DIM map AS MapView
map = Graphics.newMapView(x, y, width, height)
map.setShowLocation(1)
map.setLocationTitle("Me", "Programming")
map.setHidden(1)

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

i = Graphics.showAlert("Busy Box 3 of 5", about$)
END SUB


SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  STOP
END IF
END SUB


SUB valueChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = numberPicker THEN
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
END IF
END SUB


SUB mapLocation (ctrl AS Control, time AS DOUBLE, latitude AS DOUBLE, longitude AS DOUBLE)
s$ = "Tap at: "
s$ = s$ & STR(CSNG(latitude))
s$ = s$ & ", " & STR(CSNG(longitude))
resultsLabel.setText(s$)
END SUB
