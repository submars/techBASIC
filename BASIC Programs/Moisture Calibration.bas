! Perform linear regression on a CSV file. Each
! line of the file should contain an X and Y 
! value separated by a comma.
!
! Determine the number of values. Also find the
! min and max values for X, used later.
name$ = "moisture.csv"
OPEN name$ FOR INPUT AS #1
n = 0
minX = 1e50
maxX = -minX
WHILE NOT EOF(1)
  INPUT #1, x0, y0
  IF x0 < minX THEN minX = x0
  IF x0 > maxX THEN maxX = x0
  n = n + 1
WEND
CLOSE #1

! Dimension arrays for the values. The x
! and y arrays are used for regression,
! while the v array is used for the plot.
DIM v(n, 2), x(n), y(n)

! Read the values.
OPEN name$ FOR INPUT AS #1
FOR i = 1 TO n
   INPUT #1, x(i), y(i)
   v(i, 1) = x(i)
   v(i, 2) = y(i)
NEXT
CLOSE #1

! Do the regression.
coef = Math.polyfit(x, y)

! Create an array showing the fit.
DIM fit(0 TO 10, 2)
FOR i = 0 TO 10
  fit(i, 1) = minX + i*(maxX - minX)/10
  fit(i, 2) = coef(1) + coef(2)*fit(i, 1)
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
e$ = "f(x) = " & STR(coef(1)) & " + " & STR(coef(2)) & "x"
equation.setText(e$)

! Show the graphics screen.
System.showGraphics