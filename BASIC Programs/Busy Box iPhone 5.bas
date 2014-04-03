! Create a quit button.
DIM quit AS Button
quit = Graphics.newButton(Graphics.width - 20 - 72, Graphics.height - 37 - 20)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.7, 0.7, 0.7)

! Create a table.
DIM myTable AS Table, tableValue AS Label
x = 20
y = 20
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

i = Graphics.showAlert("Busy Box 5 of 5", about$)
END SUB


SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  STOP
END IF
END SUB


SUB cellSelected (ctrl AS Control, time AS DOUBLE, row AS INTEGER, section AS INTEGER)
tableValue.setText(myTable.getText(row, section))
END SUB
