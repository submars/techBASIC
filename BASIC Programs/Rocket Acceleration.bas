! Scan the file and count the number of data points.
accelCount% = 0
startTime# = -1
name$ = "flight1i.rkt"
OPEN name$ FOR INPUT AS #1
WHILE NOT EOF(1)
  INPUT #1, tag$, time#, x, y, z
  IF tag$ = "acceleration" THEN
    IF startTime# = -1 THEN
      startTime# = time#
    END IF
    accelCount% = accelCount% + 1
  END IF
WEND
CLOSE #1
IF accelCount% > 16383 THEN accelCount% = 16383

! Read the acceleration data.
DIM accel(accelCount%, 2)
OPEN name$ FOR INPUT AS #1
index% = 1
WHILE NOT EOF(1)
  INPUT #1, tag$, time#, x, y, z
  IF tag$ = "acceleration" THEN
    IF index% <= accelCount% THEN
      accel(index%, 1) = time# - startTime#
      accel(index%, 2) = SQR(x*x + y*y + z*z)
      index% = index% + 1
    END IF
  END IF
WEND
CLOSE #1

! Create the plot.
DIM p AS Plot, d AS PlotPoint
p = Graphics.newPlot
d = p.newPlot(accel)
System.showGraphics
