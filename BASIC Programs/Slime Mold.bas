! Slime mold is an actual organism where individuals follow simple rules,
! but colonies display advanced, seemingly intellegent behavior. This
! simulation explores a model of a slime mold colony that self organizes
! into clumps.
!
! Set up the variables that control the simulation.
PI = 3.1415926535
turnAngle = PI/3
width% = 50 : ! Height of ground
height% = 50 : ! Width of ground
count% = 200 : ! Number of slime mold cells
DIM ground(width%, height%)
DIM groundColor(width%, height%)
DIM slimeX(count%), slimeY(count%), slimeDirection(count%)

System.showGraphics

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout

! Run the simulation.
initialize
updateCells
WHILE 1
  move
  evaporate
  diffuse
  updateCells
WEND

! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "This is the classic slime mold program, showing a simple self-organizing system. Individual slime mold cells wander randomly, but when they find the scent of another cell, they tend to follow it. Eventually they clump together."

about$ = about$ & CHR(10) & CHR(10) & "Tap the Stop button to stop the simulation."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! Allow pheromone to diffuse into adjacent cells.
!
SUB diffuse
FOR x% = 1 TO width%
  xm% = x% - 1
  IF xm% = 0 THEN xm% = width%
  xp% = x% + 1
  IF xp% > width% THEN xp% = 1
  FOR y% = 1 TO height%
    ym% = y% - 1
    IF ym% = 0 THEN ym% = height%
    yp% = y% + 1
    IF yp% > height% THEN yp% = 1
    
    ground(x%, y%) = ground(x%, y%) + (ground(xm%, ym%) + ground(xm%, y%) + ground(xm%, yp%) + ground(x%, ym%) + ground(x%, yp%) + ground(xp%, ym%) + ground(xp%, y%) + ground(xp%, yp%))/140
NEXT y%, x%
END SUB

! Allow the pheromone to evaporate.
!
SUB evaporate
FOR x% = 1 TO width%
  FOR y% = 1 TO height%
    ground(x%, y%) = ground(x%, y%)*0.9
NEXT y%, x%
END SUB

! Initialize the simulation by setting the slime mold cells to
! random locations and directions, and setting up the labels used
! to display pheromone levels and the location of slime mold cells.
!
SUB initialize
! Initialize the slime mold locations and directions.
FOR i = 1 to count%
  slimeX(i) = RND(1)*width%
  slimeY(i) = RND(1)*height%
  slimeDirection(i) = RND(1)*2*PI
NEXT
END SUB

! Move a slime cell forward by the given amount.
!
! Parameters:
!    i - The index of the slime cell to move.
!    distance - The distance to move.
!
SUB forward (i, distance)
slimeX(i) = slimeX(i) + distance*COS(slimeDirection(i))
IF slimeX(i) < 0 THEN slimeX(i) = width% + slimeX(i)
IF slimeX(i) >= width% THEN slimeX(i) = slimeX(i) - width%

slimeY(i) = slimeY(i) + distance*SIN(slimeDirection(i))
IF slimeY(i) < 0 THEN slimeY(i) = height% + slimeY(i)
IF slimeY(i) > height% THEN slimeY(i) = slimeY(i) - height%
END SUB

! Move the slime cells.
!
SUB move
FOR i = 1 TO count%
  ! Move forward one unit.
  forward(i, 1)
  
  ! Drop some pheromone.
  ground(slimeX(i) + 1, slimeY(i) + 1) = ground(slimeX(i) + 1, slimeY(i) + 1) + 1
  
  ! See if there is pheromone above the threshold nearby. If so,
  ! head in that direction.
  bestTurn = 0
  forward(i, 1)
  bestPheromone = ground(slimeX(i) + 1, slimeY(i) + 1)
  forward(i, -1)
  
  slimeDirection(i) = slimeDirection(i) + turnAngle
  forward(i, 1)
  pheromone = ground(slimeX(i) + 1, slimeY(i) + 1)
  forward(i, -1)
  IF pheromone > threshold AND pheromone > bestPheromone THEN
    bestPheromone = pheromone
    bestTurn = turnAngle
  END IF
  
  slimeDirection(i) = slimeDirection(i) - 2*turnAngle
  forward(i, 1)
  pheromone = ground(slimeX(i) + 1, slimeY(i) + 1)
  forward(i, -1)
  slimeDirection(i) = slimeDirection(i) + turnAngle
  IF pheromone > threshold AND pheromone > bestPheromone THEN
    bestPheromone = pheromone
    bestTurn = -turnAngle
  END IF
  
  slimeDirection(i) = slimeDirection(i) + bestTurn
NEXT
END SUB

! Paint one slime mold cell.
!
! Parameters:
!    x%, y% - The position of hte cell to paint.
!    r, g, b - The color of the cell.
!
SUB paintCell (x%, y%, r, g, b)
w = Graphics.width/width%
x = (x% - 1)*w
h = Graphics.height/height%
y = (y% - 1)*h
Graphics.setColor(r, g, b)
Graphics.fillRect(x, y, w, h)
END SUB

! Set the colors of the ground based on pheromone levels and slime
! mold cell positions.
!
SUB updateCells
groundColor2 = ground
FOR i = 1 TO count%
  groundColor2(slimeX(i) + 1, slimeY(i) + 1) = -1
NEXT

Graphics.setUpdate(0)
FOR x% = 1 to width%
  FOR y% = 1 TO height%
    color = groundColor2(x%, y%)
    IF color <> groundColor(x%, y%) THEN
      groundColor(x%, y%) = color
      IF color = -1 THEN
        paintCell(x%, y%, 1, 0, 0)
      ELSE
        paintCell(x%, y%, 0, color/4, 0)
      END IF
    END IF
  NEXT
NEXT
Graphics.setUpdate(1)
END SUB