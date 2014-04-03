! Perform linear regression on a CSV file. Each
! line of the file should contain an X and Y 
! value separated by a comma.
!
! Determine the number of values.
name$ = "moisture.csv"
OPEN name$ FOR INPUT AS #1
n = 0
WHILE NOT EOF(1)
  INPUT #1, x, y
  n = n + 1
WEND
CLOSE #1

! Dimension an array for the values.
DIM v(n, 2)

! Read the values.
OPEN name$ FOR INPUT AS #1
FOR i = 1 TO n
   INPUT #1, v(i, 1), v(i, 2)
NEXT
CLOSE #1

! Find the sums of X, X^2, Y and XY. Also
! find the min and max X values for later
! use when drawing the fitted line.
sx = 0
sx2 = 0
sy = 0
sxy = 0
minX = 1E30
maxX = -1E30
FOR i = 1 TO n
  sx = sx + v(i, 1)
  sx2 = sx2 + v(i, 1)*v(i, 1)
  sy = sy + v(i, 2)
  sxy = sxy + v(i, 1)*v(i, 2)
  IF v(i, 1) < minX THEN minX = v(i, 1)
  IF v(i, 1) > maxX THEN maxX = v(i, 1)
NEXT

! Form the regression matrices.
A = [[sy,  sx],
     [sxy, sx2]]
B = [[n,  sy],
     [sx, sxy]]
C = [[n,  sx],
     [sx, sx2]]

! Calculate the slope and intercept.
c0 = DET(A)/DET(C)
c1 = DET(B)/DET(C)

! Create an array showing the fit.
DIM fit(0 TO 10, 2)
FOR i = 0 TO 10
  fit(i, 1) = minX + i*(maxX - minX)/10
  fit(i, 2) = c0 + c1*fit(i, 1)
NEXT

! Create the plot. Add the individual points
! and the fitted line.
DIM myPlot AS Plot, scatterPlot AS PlotPoint, fitPlot AS PlotPoint
myPlot = Graphics.newPlot
scatterPlot = myPlot.newPlot(v)
scatterPlot.setStyle(0)
scatterPlot.setPointStyle(2)
fitPlot = myPlot.newPlot(fit)
myPlot.setRect(0, 0, Graphics.width, Graphics.height - 41)

! Add a label showing the equation of the fit.
DIM equation AS Label
equation = Graphics.newLabel(0, Graphics.height - 31, Graphics.width)
equation.setAlignment(2)
e$ = "f(x) = " & STR(c0) & " + " & STR(c1) & "x"
equation.setText(e$)

! Show the graphics screen.
System.showGraphics