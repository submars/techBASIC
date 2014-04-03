! HiJack Moisture Meter

! Show the graphics screen
System.showGraphics(1)
System.setAllowedOrientations(1)
Graphics.setToolsHidden(1)

! Get the size of the graphics
! screen
width = Graphics.width
height = Graphics.height

! Paint the background light gray
bg = 0.9
Graphics.setColor(bg, bg, bg)
Graphics.fillRect(0, 0, width, height)

! Create a Quit button
DIM quit AS Button
quit = Graphics.newButton(width/2 - 36, height - 57)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.7, 0.7, 0.7)

! Put the name of the program at
! the top of the screen
DIM mmLabel AS Label
mmLabel = newLabel(0, 20, width, 40, 40, "Moisture Meter")
mmLabel.setBackgroundColor(bg, bg, bg)

! Create a large label to show
! the moisture level
DIM value AS Label
value = newLabel(0, 75, width, 40, 50, "0")

! Add 5 small labels to show the
! moisture scale along the top of
! the moisture bar
DIM nums(5) AS Label
plantLabelWidth = (width - 40)/4
FOR i = 0 TO 4
  x = i*plantLabelWidth
  nums(i + 1) = newLabel(x, 140, 40, 20, 16, STR(i))
NEXT

! Create the strings that will
! name the plants in each
! moisture group
DIM plants(4) AS TextView, plants$(4)
addPlant("Aloe", plants$(1))
addPlant("Geranium", plants$(1))
addPlant("Jade Plant", plants$(1))
addPlant("Orchid", plants$(1))
addPlant("Wandering Jew", plants$(1))
addPlant("African Violet", plants$(2))
addPlant("Cacti", plants$(2))
addPlant("Hibiscus", plants$(2))
addPlant("Wax Plant", plants$(2))
addPlant("Begonia", plants$(3))
addPlant("Flowering Maple", plants$(3))
addPlant("Peppers", plants$(3))
addPlant("Spider Plant", plants$(3))
addPlant("Azalea", plants$(4))
addPlant("Ferns", plants$(4))
addPlant("Melons", plants$(4))
addPlant("Peace Lily", plants$(4))
addPlant("Tomatoes", plants$(4))

! Add colored labels below the
! moisture bar showing the plants
! in each group
plantLabelHeight = 150
FOR i = 1 TO 4
  x = 20 + (i - 1)*plantLabelWidth
  color = 1 - i/5
  plants(i) = newTextView(x, 170, plantLabelWidth, plantLabelHeight, _
    11, color, plants$(i))
NEXT

! Create the moisture bar
DIM moisture AS Progress
moisture = Graphics.newProgress(20, 165, width - 40)

! Set HiJack to sample 10 times
! per second
HiJack.setRate(10)


! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout


! Create a label
!
! Parameters:
!   x - Horizontal location
!   y - Vertical location
!   width - Label width
!   height - Label height
!   fontSize - Point size for the
!      font
!   text$ - Label text
!
! Returns: The label

FUNCTION newLabel (x, y, width, height, fontSize, text$) AS Label
DIM nl AS Label
nl = Graphics.newLabel(x, y, width, height)
nl.setText(text$)
nl.setBackgroundColor(1, 1, 1, 0)
nl.setAlignment(2)
nl.setFont("Sans_Serif", fontSize, 0)
newLabel = nl
END FUNCTION


! Add a plant name to a string
! containing plant names
!
! Parameters:
!   newPlant$ - New plant name
!   plant$ - Current plant names

SUB addPlant (newPlant$, BYREF plant$)
IF LEN(plant$) <> 0 THEN
  plant$ = plant$ & CHR(10) & CHR(10)
END IF
plant$ = plant$ & newPlant$
END SUB


! Create a text view to show a
! list of plants
!
! Parameters:
!   x - Horizontal location
!   y - Vertical location
!   width - TextView width
!   height - TextView height
!   fontSize - Point size for the
!      font
!   color - White level for 
!      background; the color will
!      be blue, lightened by this
!      amount
!   text$ - TextView text
!
! Returns: The text view

FUNCTION newTextView (x, y, width, height, fontSize, color, text$) AS TextView
DIM ntv AS TextView
ntv = Graphics.newTextView(x, y, width, height)
ntv.setText(text$)
ntv.setEditable(0)
ntv.setBackgroundColor(color, color, 1, 1)
IF color < 0.5 THEN
  ntv.setColor(1, 1, 1)
END IF
ntv.setAlignment(2)
ntv.setFont("Sans_Serif", fontSize, 0)
newTextView = ntv
END FUNCTION


! Handle a tap on a button
!
! Parameters:
!   ctrl - The button tapped
!   time - When the button was
!      tapped

SUB touchUpInside(ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  STOP
END IF
END SUB


! Read and process HiJack values
!
! Parameters:
!    time - Event time

SUB nullEvent (time AS DOUBLE)
v = HiJack.receive
m = -5.385531 + 0.07708497*v(1)
IF m < 0 THEN m = 0
IF m > 4 THEN m = 4
moisture.setValue(m/4)
value.setText(STR(INT(m*10)/10))
END SUB


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "Implements a plant moisture meter using HiJack. Specialized hardware is required to use this program."

about$ = about$ & CHR(10) & CHR(10) & "See the O'Reilly book, Building iPhone and iPad Electronic Projects, for a complete description of this app and instructions showing how to build the moisture meter."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB
