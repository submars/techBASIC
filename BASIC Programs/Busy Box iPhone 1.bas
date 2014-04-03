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

x = 40
y = 20 + 21 + 8
width = (Graphics.width - x - 20)
myTextField = Graphics.newTextField(x, y, width)
myTextField.setBackgroundColor(1, 1, 1)

! Create a label to show the current value of the text field.
DIM textFieldValueLabel AS Label
y = y + 39
textFieldValueLabel = Graphics.newLabel(x, y, width)

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

i = Graphics.showAlert("Busy Box 1 of 5", about$)
END SUB


SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  STOP
END IF
END SUB


SUB textChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = myTextField THEN
  textFieldValueLabel.setText(myTextField.getText)
END IF
END SUB
