! Create a quit button.
DIM quit AS Button
quit = Graphics.newButton(Graphics.width - 20 - 72, Graphics.height - 37 - 20)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.7, 0.7, 0.7)

! Create a text view with a label.
DIM myTextView AS TextView, textViewLabel AS Label
textViewLabel = Graphics.newLabel(20, 20, 100)
textViewLabel.setText("Text View:")
textViewLabel.setAlignment(3)

x = 30
width = (Graphics.width - x - 20)
y = 20 + 21 + 8
height = (Graphics.height - 40 - 21 - 37 - 16 - 20)/2
myTextView = Graphics.newTextView(x, y, width, height)

! Create a read-only text view to show the types text.
DIM textViewValue AS TextView
y = y + height + 8
textViewValue = Graphics.newTextView(x, y, width, height)
textViewValue.setEditable(0)

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
about$ = "This program shows how to use Text Views from techBASIC. Tap in the gray area to dismiss the keyboard."

about$ = about$ & CHR(10) & CHR(10) & "See the Blogs section of the Byte Works web site for a tutorial that develops this program."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("Busy Box 2 of 5", about$)
END SUB


SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  STOP
END IF
END SUB


SUB textChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = myTextView THEN
  textViewValue.setText(myTextView.getText)
END IF
END SUB
