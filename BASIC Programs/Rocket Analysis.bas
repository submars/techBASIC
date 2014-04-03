! Rocket Data Analysis
!
! This program analyzes data from rocket flights recorded with the Rocket Data
! program. That program records acceleration, rotation and barometric pressure
! during a rocket flight.
!
! Created at the Byte Works, Inc.
! Copyright 2012, All Rights Reserved
! support@byteworks.us
!
! Permission is grandet to use and modify this program for any noncommercial use so 
! long as the above copyright notice is not removed.

! Show the GUI.
System.showGraphics

! Create the list of files we can display and process.
count = 0
DIM files$(count), flightT0(count), flightT1(count), calibT0(count), calibT1(count)
flightIndex = 1
calibFile$ = "RocketDataCalibration.txt"

! Define globals.
DIM accelPlot AS Plot, accelPlotPoint AS PlotPoint, accelPoints(2, 2)
DIM velPlot AS Plot, velPlotPoint AS PlotPoint, velPoints(2, 2)
DIM distPlot AS Plot, distPlotPoint AS PlotPoint, distPoints(2, 2)
DIM gyroPlot AS Plot, gyroXPlotPoint AS PlotPoint, gyroXPoints(2, 2), gyroYPlotPoint AS PlotPoint, gyroYPoints(2, 2), gyroZPlotPoint AS PlotPoint, gyroZPoints(2, 2)
DIM isVisible(201 TO 205) AS INTEGER
DIM baroPlot AS Plot, baroPlotPoint AS PlotPoint, baroPoints(2, 2)

DIM flightT0TextField AS TextField, flightT1TextField AS TextField
DIM calibT0TextField AS TextField, calibT1TextField AS TextField
DIM iPhoneControls(11) AS Control

! Decide on a screen size.
IF Graphics.width = 768 THEN
  width = 768
  height = 960
ELSE
  width = Graphics.width
  height = Graphics.height
END IF

! Get the list of data files.
findDataFiles

! Read the calibration and flight time data.
readCalibration

! Set up the user interface.
setUpGUI
DIM act AS Activity
act = Graphics.newActivity(Graphics.width/2, Graphics.height/2)
act.setStyle(2)
act.setColor(0, 0, 1)

! Load the initial data.
readData(files$(1))

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
act.setHidden(1)


! Calculate the speed and altitude based on acceleration and the current
! flight and calibration times.

SUB calculateSpeedAltitude
! Calibrate the acceleration based on data at a known 1G.
count% = UBOUND(accelPoints, 1)
t0 = calibT0(flightIndex)
t1 = calibT1(flightIndex)
calibA = 0
points = 0
FOR i = 1 to count%
  IF t >= t0 AND t <= t1 THEN
    points = points + 1
    calibA = calibA + accelPoints(i, 2)
  END IF
NEXT
IF points > 0 THEN calibA = 1.0 - calibA/points

! Calculate velocity and altitude (assuming vertical flight).
DIM vel(count%, 2), dist(count%, 2)
vel(1, 1) = accel(1, 1)
vel(1, 2) = 0
dist(1, 1) = accel(1, 1)
dist(1, 2) = 0
t0 = flightT0(flightIndex)
t1 = flightT1(flightIndex)
IF t1 = 0 THEN t1 = accelPoints(UBOUND(accelPoints, 1), 1)
IF t1 <= t0 THEN t1 = t0 + 1
FOR i = 2 TO count%
  t = accelPoints(i, 1)
  a = (accelPoints(i, 2) - 1 + calibA)*9.8
  dt = t - accelPoints(i - 1, 1)
  vel(i, 1) = t
  dist(i, 1) = t
  IF t >= t0 AND t <= t1 THEN
    vel(i, 2) = vel(i - 1, 2) + a*dt
    dist(i, 2) = dist(i - 1, 2) + vel(i - 1, 2)*dt + a*dt*dt
  ELSE
    vel(i, 2) = 0
    dist(i, 2) = 0
  END IF
NEXT

! Save the points and redraw the plots.
velPoints = vel
velPlotPoint.setPoints(velPoints)

distPoints = dist
distPlotPoint.setPoints(distPoints)
END SUB

! Scans for any files with a file extension of .rkt. Use the results to set the
! size of the global data arrays and to create the list of data files.

SUB findDataFiles
! Count the data files.
count = 0
name$ = DIR("*")
WHILE name$ <> ""
  IF RIGHT(name$, 4) = ".rkt" THEN
    count = count + 1
  END IF
  name$ = DIR
WEND

! Create an array of file names and an empty value array, used to set the size of
! the global data arrays.
DIM localFiles$(count), temp(count)
files$ = localFiles$
flightT0 = temp
flightT1 = temp
calibT0 = temp
calibT1 = temp

! Read the files.
count = 0
name$ = DIR("*")
WHILE name$ <> ""
  IF RIGHT(name$, 4) = ".rkt" THEN
    count = count + 1
    files$(count) = name$
  END IF
  name$ = DIR
WEND
END SUB


! Create a shaded button.
!
! Parameters:
!	x, y - The position of the button.
!	width, height - The size of the button.
!	title - The title of the button.
!	command - The command (e.g. tag) for the button.
!
! Returns:
!	The button.

FUNCTION newShadedButton (x, y, width, height, title AS STRING, command AS INTEGER) AS Button
DIM b AS Button
b = Graphics.newButton(x, y, width, height)
b.setTitle(title)
b.setFont("Sans-serif", 16, 1)
b.setColor(0, 0, 0.1)
b.setBackgroundColor(1, 1, 1)
b.setGradientColor(0.85, 0.85, 0.85)
b.setColor(0, 0, 0.1, 1, 4)
b.setBackgroundColor(0.85, 0.85, 0.9, 1, 4)
b.setGradientColor(1, 1, 1, 1, 4)
b.setTag(command)
newShadedButton = b
END FUNCTION


! Read the calibration and flight time values for all known files.

SUB readCalibration
IF EXISTS(calibFile$) THEN
  OPEN calibFile$ FOR INPUT AS #1
  WHILE NOT EOF(1)
    INPUT #1, file$, ft0, ft1, ct0, ct1
    FOR i = 1 TO UBOUND(files$, 1)
      IF files$(i) = file$ THEN
        flightT0(i) = ft0
        flightT1(i) = ft1
        calibT0(i) = ct0
        calibT1(i) = ct1
      END IF
    NEXT
  WEND
  CLOSE #1
END IF
END SUB


! Read the data from a data set, discarding any old data. Plots are redrawn
! with the new data.
!
! Parameters:
!    name$ - The name of the data file to read.

SUB readData (name$)
! Scan the file and count the number of data points.
accelCount% = 0
gyroCount% = 0
baroCount% = 0
startTime# = -1
OPEN name$ FOR INPUT AS #1
WHILE NOT EOF(1)
  INPUT #1, tag$, time#, x, y, z
  IF startTime# = -1 THEN
    startTime# = time#
  END IF
  IF tag$ = "acceleration" THEN
    accelCount% = accelCount% + 1
  ELSE IF tag$ = "pressure" THEN
    baroCount% = baroCount% + 1
  ELSE IF tag$ = "rotation" THEN
    gyroCount% = gyroCount% + 1
  END IF
WEND
CLOSE #1
IF accelCount% > 16383 THEN accelCount% = 16383
IF baroCount% > 16383 THEN baroCount% = 16383
IF gyroCount% > 16383 THEN gyroCount% = 16383

! Read the data.
DIM accel(accelCount%, 2), baro(baroCount%, 2)
DIM gyroX(gyroCount%, 2), gyroY(gyroCount%, 2), gyroZ(gyroCount%, 2)
OPEN name$ FOR INPUT AS #1
accelIndex% = 1
baroIndex% = 1
gyroIndex% = 1
WHILE NOT EOF(1)
  INPUT #1, tag$, time#, x, y, z
  IF tag$ = "acceleration" AND accelIndex% <= accelCount% THEN
    accel(accelIndex%, 1) = time# - startTime#
    accel(accelIndex%, 2) = SQR(x*x + y*y + z*z)
    accelIndex% = accelIndex% + 1
  ELSE IF tag$ = "pressure" AND baroIndex% <= baroCount% THEN
    baro(baroIndex%, 1) = time# - startTime#
    baro(baroIndex%, 2) = x
    baroIndex% = baroIndex% + 1
  ELSE IF tag$ = "rotation" AND gyroIndex% <= gyroCount% THEN
    gyroX(gyroIndex%, 1) = time# - startTime#
    gyroX(gyroIndex%, 2) = x
    gyroY(gyroIndex%, 1) = time# - startTime#
    gyroY(gyroIndex%, 2) = y
    gyroZ(gyroIndex%, 1) = time# - startTime#
    gyroZ(gyroIndex%, 2) = z
    gyroIndex% = gyroIndex% + 1
  END IF
WEND
CLOSE #1

! Redraw the plots.
accelPoints = accel
accelPlotPoint.setPoints(accelPoints)

baroPoints = baro
baroPlotPoint.setPoints(baroPoints)

gyroXPoints = gyroX
gyroXPlotPoint.setPoints(gyroXPoints)
gyroYPoints = gyroY
gyroYPlotPoint.setPoints(gyroYPoints)
gyroZPoints = gyroZ
gyroZPlotPoint.setPoints(gyroZPoints)

! Calculate the speed and altitude.
calculateSpeedAltitude

setPlotView
END SUB


! Set the views for the plots, This is done when the original data is read, and again
! each time the plot is resized.
!
! The views are set to show the domain of data selected as valid for the flight and
! the range for the points within this domain.

SUB setPlotView
! Find the start and end times.
t0 = flightT0(flightIndex)
t1 = flightT1(flightIndex)
IF t1 = 0 THEN t1 = accelPoints(UBOUND(accelPoints, 1), 1)
IF t1 <= t0 THEN t1 = t0 + 1

! Find the min and max ranges, as needed.
maxAccel = 0
maxVel = 0
minVel = 0
maxDist = 0
minDist = 0
FOR i = 1 TO UBOUND(accelPoints, 1)
  t = accelPoints(i, 1)
  IF t >= t0 AND t <= t1 THEN
    IF accelPoints(i, 2) > maxAccel THEN maxAccel = accelPoints(i, 2)
    IF velPoints(i, 2) > maxVel THEN maxVel = velPoints(i, 2)
    IF velPoints(i, 2) < minVel THEN minVel = velPoints(i, 2)
    IF distPoints(i, 2) > maxDist THEN maxDist = distPoints(i, 2)
    IF distPoints(i, 2) < minDist THEN minDist = distPoints(i, 2)
  END IF
NEXT

minBaro = 100
maxBaro = -100
FOR i = 1 TO UBOUND(baroPoints, 1)
  t = baroPoints(i, 1)
  IF t >= t0 AND t <= t1 THEN
    IF baroPoints(i, 2) > maxBaro THEN maxBaro = baroPoints(i, 2)
    IF baroPoints(i, 2) < minBaro THEN minBaro = baroPoints(i, 2)
  END IF
NEXT

maxGyro = -300
minGyro = 300
FOR i = 1 TO UBOUND(gyroXPoints, 1)
  t = gyroXPoints(i, 1)
  IF t >= t0 AND t <= t1 THEN
    IF gyroXPoints(i, 2) > maxGyro THEN maxGyro = gyroXPoints(i, 2)
    IF gyroXPoints(i, 2) < minGyro THEN minGyro = gyroXPoints(i, 2)
    IF gyroYPoints(i, 2) > maxGyro THEN maxGyro = gyroYPoints(i, 2)
    IF gyroYPoints(i, 2) < minGyro THEN minGyro = gyroYPoints(i, 2)
    IF gyroZPoints(i, 2) > maxGyro THEN maxGyro = gyroZPoints(i, 2)
    IF gyroZPoints(i, 2) < minGyro THEN minGyro = gyroZPoints(i, 2)
  END IF
NEXT

! Reset the views.
accelPlot.setView(t0, 0, t1, maxAccel, 0)
velPlot.setView(t0, minVel, t1, maxVel, 0)
distPlot.setView(t0, minDist, t1, maxDist, 0)

baroPlot.setView(t0, minBaro, t1, maxBaro, 0)

gyroPlot.setView(t0, minGyro, t1, maxGyro, 0)
END SUB


! Set up the user interface.

SUB setUpGUI
! Use vector graphics.
Graphics.setPixelGraphics(0)

! Set up the controls based on the device.
IF System.device = 0 OR System.device = 256 THEN
  setUpIPhoneGUI
ELSE
  setUpIPadGUI
END IF
END SUB


! Set up the user interface.

SUB setUpIPhoneGUI
! Find the size of the screen.
width = 320
IF Graphics.height = 320 THEN
  height = Graphics.width
ELSE
  height = Graphics.height
END IF

! Draw the title.
DIM title AS Label
title = Graphics.newLabel(0, 5, width, 20)
title.setText("Rocket Flight Analysis")
title.setFont("Sans-Serif", 20, 1)
title.setAlignment(2)

! Add a picker for selecting the data.
DIM flight AS Picker
y = 30
flight = Graphics.newPicker(0, y, 320, 180)
FOR i = 1 TO UBOUND(files$, 1)
  flight.insertRow(files$(i), i)
NEXT
flight.setTag(301)

! Add labels and text boxes for entering the flight time.
DIM flightLabel AS Label, flightT0Label AS Label, flightT1Label AS Label
x = 0
y = y + 180 + 20
flightLabel = Graphics.newLabel(x, y, 80)
flightLabel.setText("Flight time:")
flightLabel.setAlignment(3)
flightLabel.setFont("Sans-Serif", 14, 0)

flightT0Label = Graphics.newLabel(x + 110, y, 45)
flightT0Label.setText("Start:")
flightT0Label.setAlignment(3)

flightT0TextField = Graphics.newTextField(x + 160, y, 55, 21)
flightT0TextField.setBackgroundColor(0.95, 0.95, 0.95)
flightT0TextField.setTag(401)
flightT0TextField.setText(STR(flightT0(1)))

flightT1Label = Graphics.newLabel(x + 220, y, 40)
flightT1Label.setText("End:")
flightT1Label.setAlignment(3)

flightT1TextField = Graphics.newTextField(x + 265, y, 55, 21)
flightT1TextField.setBackgroundColor(0.95, 0.95, 0.95)
flightT1TextField.setTag(402)
flightT1TextField.setText(STR(flightT1(1)))

! Add labels and text boxes for entering the calibration range.
DIM calibLabel AS Label, calibT0Label AS Label, calibT1Label AS Label
y = y + 41
calibLabel = Graphics.newLabel(x, y + 2, 110)
calibLabel.setText("Callibration time:")
calibLabel.setAlignment(3)
calibLabel.setFont("Sans-Serif", 14, 0)

calibT0Label = Graphics.newLabel(x + 110, y, 45)
calibT0Label.setText("Start:")
calibT0Label.setAlignment(3)

calibT0TextField = Graphics.newTextField(x + 160, y, 55, 21)
calibT0TextField.setBackgroundColor(0.95, 0.95, 0.95)
calibT0TextField.setTag(501)
calibT0TextField.setText(STR(calibT0(1)))

calibT1Label = Graphics.newLabel(x + 220, y, 40)
calibT1Label.setText("End:")
calibT1Label.setAlignment(3)

calibT1TextField = Graphics.newTextField(x + 265, y, 55, 21)
calibT1TextField.setBackgroundColor(0.95, 0.95, 0.95)
calibT1TextField.setTag(502)
calibT1TextField.setText(STR(calibT1(1)))

! Save the controls that are hidden and shown with the files page.
iPhoneControls(1) = flight
iPhoneControls(2) = flightLabel
iPhoneControls(3) = flightT0Label
iPhoneControls(4) = flightT0TextField
iPhoneControls(5) = flightT1Label
iPhoneControls(6) = flightT1TextField
iPhoneControls(7) = calibLabel
iPhoneControls(8) = calibT0Label
iPhoneControls(9) = calibT0TextField
iPhoneControls(10) = calibT1Label
iPhoneControls(11) = calibT1TextField

! Create the plots.
accelPoints = [[0, 0], [1, 1]]
accelPlot = Graphics.newPlot
accelPlotPoint = accelPlot.newPlot(accelPoints)
accelPlot.setTitle("Acceleration in G")
accelPlot.setTitleFont("Sans-Serif", 18, 0)
accelPlot.setXAxisLabel("Time in Seconds")
accelPlot.setYAxisLabel("Acceleration")
accelPlot.setAxisFont("Sans-Serif", 14, 0)
accelPlotPoint.setColor(1, 0, 0)
accelPlotPoint.setPointColor(1, 0, 0)

velPlot = Graphics.newPlot
velPlotPoint = velPlot.newPlot(velPoints)
velPlot.setTitle("Velocity in m/s")
velPlot.setTitleFont("Sans-Serif", 18, 0)
velPlot.setXAxisLabel("Time in Seconds")
velPlot.setYAxisLabel("Velocity")
velPlot.setAxisFont("Sans-Serif", 14, 0)
velPlotPoint.setColor(0, 1, 0)
velPlotPoint.setPointColor(0, 1, 0)

distPlot = Graphics.newPlot
distPlotPoint = distPlot.newPlot(distPoints)
distPlot.setTitle("Altitude in Meters")
distPlot.setTitleFont("Sans-Serif", 18, 0)
distPlot.setXAxisLabel("Time in Seconds")
distPlot.setYAxisLabel("Altitude")
distPlot.setAxisFont("Sans-Serif", 14, 0)
distPlotPoint.setColor(0, 0, 1)
distPlotPoint.setPointColor(0, 0, 1)

baroPlot = Graphics.newPlot
baroPlotPoint = baroPlot.newPlot(accelPoints)
baroPlot.setTitle("Pressure in Bar")
baroPlot.setTitleFont("Sans-Serif", 18, 0)
baroPlot.setXAxisLabel("Time in Seconds")
baroPlot.setYAxisLabel("Pressure")
baroPlot.setAxisFont("Sans-Serif", 14, 0)

gyroPlot = Graphics.newPlot
gyroXPlotPoint = gyroPlot.newPlot(accelPoints)
gyroXPlotPoint.setColor(1, 0, 0)
gyroXPlotPoint.setPointColor(1, 0, 0)
gyroYPlotPoint = gyroPlot.newPlot(accelPoints)
gyroYPlotPoint.setColor(0, 1, 0)
gyroYPlotPoint.setPointColor(0, 1, 0)
gyroZPlotPoint = gyroPlot.newPlot(accelPoints)
gyroZPlotPoint.setColor(0, 0, 1)
gyroZPlotPoint.setPointColor(0, 0, 1)
gyroPlot.setTitle("Rotation in Deg/s")
gyroPlot.setTitleFont("Sans-Serif", 18, 0)
gyroPlot.setXAxisLabel("Time in Seconds")
gyroPlot.setYAxisLabel("Rotation")
gyroPlot.setAxisFont("Sans-Serif", 14, 0)

! Position the plots.
tilePlots

! Add a tool bar.
DIM tools AS SegmentedControl
tools = Graphics.newSegmentedControl(-4, height - 35, width + 8, 37)
tools.setStyle(3)
tools.insertSegment("Files", 1, 0)
tools.insertSegment("Accel", 2, 0)
tools.insertSegment("Speed", 3, 0)
tools.insertSegment("Dist", 4, 0)
tools.insertSegment("Gyro", 5, 0)
tools.insertSegment("Press", 6, 0)
tools.insertSegment("Quit", 7, 0)
tools.setTag(701)
END SUB


! Set up the user interface.

SUB setUpIPadGUI
! Draw the title.
DIM title AS Label
title = Graphics.newLabel(0, 10, width, 35)
title.setText("Rocket Flight Analysis")
title.setFont("Sans-Serif", 32, 1)
title.setAlignment(2)

! Add a picker for selecting the data.
DIM flight AS Picker
y = 65
IF Graphics.width >= 768 THEN
  x = 370
  w = 330
ELSE
  x = 310
  w = 270
END IF
flight = Graphics.newPicker(20, y, w)
FOR i = 1 TO UBOUND(files$, 1)
  flight.insertRow(files$(i), i)
NEXT
flight.setTag(301)

! Add the buttons to select graphs.
DIM plots AS Label
DIM accelButton AS Button, velocityButton AS Button, positionButton AS Button
DIM gyroButton AS Button, pressureButton AS Button

plots = Graphics.newLabel(x, y, 100)
plots.setText("Visible Plots:")
plots.setFont("Sans-Serif", 16, 0)

y = y + 31
bWidth = 120
accelButton = newShadedButton(x, y, bWidth, 37, "Acceleration", 201)
accelButton.setSelected(1)
isVisible(201) = 1
velocityButton = newShadedButton(x + bWidth + 10, y, bWidth, 37, "Speed", 202)
positionButton = newShadedButton(x + (bWidth + 10)*2, y, bWidth, 37, "Distance", 203)
gyroButton = newShadedButton(x, y + 47, bWidth, 37, "Gyro", 204)
pressureButton = newShadedButton(x + bWidth + 10, y + 47, bWidth, 37, "Pressure", 205)

! Add labels and text boxes for entering the flight time.
DIM flightLabel AS Label, flightT0Label AS Label, flightT1Label AS Label
y = y + 2*47 + 20
flightLabel = Graphics.newLabel(x, y, 130)
flightLabel.setText("Flight time:")
flightLabel.setAlignment(3)

flightT0Label = Graphics.newLabel(x + 140, y, 50)
flightT0Label.setText("Start:")
flightT0Label.setAlignment(3)

flightT0TextField = Graphics.newTextField(x + 200, y, 60, 21)
flightT0TextField.setBackgroundColor(0.95, 0.95, 0.95)
flightT0TextField.setTag(401)
flightT0TextField.setText(STR(flightT0(1)))

flightT1Label = Graphics.newLabel(x + 270, y, 40)
flightT1Label.setText("End:")
flightT1Label.setAlignment(3)

flightT1TextField = Graphics.newTextField(x + 320, y, 60, 21)
flightT1TextField.setBackgroundColor(0.95, 0.95, 0.95)
flightT1TextField.setTag(402)
flightT1TextField.setText(STR(flightT1(1)))

! Add labels and text boxes for entering the calibration range.
DIM calibLabel AS Label, calibT0Label AS Label, calibT1Label AS Label
y = y + 41
calibLabel = Graphics.newLabel(x, y, 130)
calibLabel.setText("Callibration time:")
calibLabel.setAlignment(3)

calibT0Label = Graphics.newLabel(x + 140, y, 50)
calibT0Label.setText("Start:")
calibT0Label.setAlignment(3)

calibT0TextField = Graphics.newTextField(x + 200, y, 60, 21)
calibT0TextField.setBackgroundColor(0.95, 0.95, 0.95)
calibT0TextField.setTag(501)
calibT0TextField.setText(STR(calibT0(1)))

calibT1Label = Graphics.newLabel(x + 270, y, 40)
calibT1Label.setText("End:")
calibT1Label.setAlignment(3)

calibT1TextField = Graphics.newTextField(x + 320, y, 60, 21)
calibT1TextField.setBackgroundColor(0.95, 0.95, 0.95)
calibT1TextField.setTag(502)
calibT1TextField.setText(STR(calibT1(1)))

! Create the plots.
accelPoints = [[0, 0], [1, 1]]
accelPlot = Graphics.newPlot
accelPlotPoint = accelPlot.newPlot(accelPoints)
accelPlot.setTitle("Acceleration in G")
accelPlot.setTitleFont("Sans-Serif", 18, 0)
accelPlot.setXAxisLabel("Time in Seconds")
accelPlot.setYAxisLabel("Acceleration")
accelPlot.setAxisFont("Sans-Serif", 14, 0)
accelPlotPoint.setColor(1, 0, 0)
accelPlotPoint.setPointColor(1, 0, 0)

velPlot = Graphics.newPlot
velPlotPoint = velPlot.newPlot(velPoints)
velPlot.setTitle("Velocity in m/s")
velPlot.setTitleFont("Sans-Serif", 18, 0)
velPlot.setXAxisLabel("Time in Seconds")
velPlot.setYAxisLabel("Velocity")
velPlot.setAxisFont("Sans-Serif", 14, 0)
velPlotPoint.setColor(0, 1, 0)
velPlotPoint.setPointColor(0, 1, 0)

distPlot = Graphics.newPlot
distPlotPoint = distPlot.newPlot(distPoints)
distPlot.setTitle("Altitude in Meters")
distPlot.setTitleFont("Sans-Serif", 18, 0)
distPlot.setXAxisLabel("Time in Seconds")
distPlot.setYAxisLabel("Altitude")
distPlot.setAxisFont("Sans-Serif", 14, 0)
distPlotPoint.setColor(0, 0, 1)
distPlotPoint.setPointColor(0, 0, 1)

baroPlot = Graphics.newPlot
baroPlotPoint = baroPlot.newPlot(accelPoints)
baroPlot.setTitle("Pressure in Bar")
baroPlot.setTitleFont("Sans-Serif", 18, 0)
baroPlot.setXAxisLabel("Time in Seconds")
baroPlot.setYAxisLabel("Pressure")
baroPlot.setAxisFont("Sans-Serif", 14, 0)

gyroPlot = Graphics.newPlot
gyroXPlotPoint = gyroPlot.newPlot(accelPoints)
gyroXPlotPoint.setColor(1, 0, 0)
gyroXPlotPoint.setPointColor(1, 0, 0)
gyroYPlotPoint = gyroPlot.newPlot(accelPoints)
gyroYPlotPoint.setColor(0, 1, 0)
gyroYPlotPoint.setPointColor(0, 1, 0)
gyroZPlotPoint = gyroPlot.newPlot(accelPoints)
gyroZPlotPoint.setColor(0, 0, 1)
gyroZPlotPoint.setPointColor(0, 0, 1)
gyroPlot.setTitle("Rotation in Deg/s")
gyroPlot.setTitleFont("Sans-Serif", 18, 0)
gyroPlot.setXAxisLabel("Time in Seconds")
gyroPlot.setYAxisLabel("Rotation")
gyroPlot.setAxisFont("Sans-Serif", 14, 0)

! Position the plots.
y = 216 + 85
h = height - y - 57
Graphics.setColor(0.886, 0.886, 0.886)
Graphics.fillRect(0, y, width, h)
tilePlots

! Add a Quit button.
DIM quit AS Button
quit = newShadedButton(width - 92, height - 47, 72, 37, "Quit", 101)
END SUB


! Shows the About alert when the program starts.

SUB showAbout
about$ = "Shows the analysis from rocket flights tracked with a Texas Instruments SensorTag."

about$ = about$ & CHR(10) & CHR(10) & "See the O'Reilly book, Building iPhone and iPad Electronic Projects, for a complete description of this app and instructions showing how to build your own rocket to collect read flight data."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! The text in a text field has changed.
!
! Parameters:
!    ctrl - The control whose text changed.
!    time - The time when the text changed.

SUB textChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl.tag = 401 THEN
  flightT0(flightIndex) = VAL(ctrl.getText)
ELSE IF ctrl.tag = 402 THEN
  flightT1(flightIndex) = VAL(ctrl.getText)
ELSE IF ctrl.tag = 501 THEN
  calibT0(flightIndex) = VAL(ctrl.getText)
ELSE
  calibT1(flightIndex) = VAL(ctrl.getText)
END IF
END SUB


! Show, hide and tile plots as appropriate for the current set of buttons.

SUB tilePlots
! Get the overall size and location of the plot area.
x = 0
IF System.device = 0 OR System.device = 256 THEN
  y = 30
  h = height - y - 35
  w = width
ELSE
  y = 216 + 85
  h = height - y - 57
  w = width - 20
END IF

! Count the number of plots to show.
count = 0
FOR i = 201 TO 205
  IF isVisible(i) THEN count = count + 1
NEXT

! Decide on the size and spacing for the plots.
IF System.device = 0 OR System.device = 256 THEN
  ph = h
  pw = w
ELSE
  SELECT CASE count
    CASE 0 TO 1
      ph = h
      pw = w
     
    CASE 2
      ph = h/2
      pw = w

    CASE 3
      ph = h/3
      pw = w
    
    CASE 4
      ph = h/2
      pw = w/2
    
    CASE 5
      ph = h/3
      pw = w/2
  END SELECT
END IF

! Position the plots. Invisible plots have their position set offscreen.
px = x
py = y
IF isVisible(201) THEN
  accelPlot.setRect(px, py, pw, ph)
  py = py + ph
ELSE
  accelPlot.setRect(px + width*2, py, pw, ph)
END IF
IF isVisible(202) THEN
  velPlot.setRect(px, py, pw, ph)
  py = py + ph
  IF py >= y + h THEN
    py = y
    px = px + pw
  END IF
ELSE
  velPlot.setRect(px + width*2, py, pw, ph)
END IF
IF isVisible(203) THEN
  distPlot.setRect(px, py, pw, ph)
  py = py + ph
  IF py >= y + h THEN
    py = y
    px = px + pw
  END IF
ELSE
  distPlot.setRect(px + width*2, py, pw, ph)
END IF
IF isVisible(204) THEN
  gyroPlot.setRect(px, py, pw, ph)
  py = py + ph
  IF py >= y + h THEN
    py = y
    px = px + pw
  END IF
ELSE
  gyroPlot.setRect(px + width*2, py, pw, ph)
END IF
IF isVisible(205) THEN
  baroPlot.setRect(px, py, pw, ph)
ELSE
  baroPlot.setRect(px + width*2, py, pw, ph)
END IF
setPlotView
END SUB


! Handle a tap on a button.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time when the button was tapped.

SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
SELECT CASE ctrl.tag
  CASE 101
    writeCalibration
    STOP
  
  CASE 201 TO 205
    ctrl.setSelected(NOT ctrl.isSelected)
    isVisible(ctrl.tag) = ctrl.isSelected
    tilePlots
END SELECT
END SUB


! Handle the change in the value of a control.
!
! Parameters:
!    ctrl - The control whose value changed.
!    time - The time when the value changed.

SUB valueChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl.tag = 301 THEN
  flightIndex = ctrl.selection
  readData(files$(flightIndex))
  flightT0TextField.setText(STR(flightT0(flightIndex)))
  flightT1TextField.setText(STR(flightT1(flightIndex)))
  calibT0TextField.setText(STR(calibT0(flightIndex)))
  calibT1TextField.setText(STR(calibT1(flightIndex)))
ELSE IF ctrl.tag = 701 THEN
  SELECT CASE ctrl.selected
    CASE 1
      FOR i = 1 TO UBOUND(iPhoneControls, 1)
        iPhoneControls(i).setHidden(0)
      NEXT
      FOR i = 201 TO 205
        isVisible(i) = 0
      NEXT
      tilePlots
      
    CASE 2 TO 6
      FOR i = 1 TO UBOUND(iPhoneControls, 1)
        iPhoneControls(i).setHidden(1)
      NEXT
      FOR i = 201 TO 205
        isVisible(i) = ctrl.selected + 199 = i
      NEXT
      tilePlots

    CASE 7
      writeCalibration
      STOP
  END SELECT
ELSE
  ! One of the text fields changed. Recalculate the speed and altitude, and
  ! redraw the plots.
  IF ctrl.tag = 401 THEN
    flightT0(flightIndex) = VAL(ctrl.getText)
  ELSE IF ctrl.tag = 402 THEN
    flightT1(flightIndex) = VAL(ctrl.getText)
  ELSE IF ctrl.tag = 501 THEN
    calibT0(flightIndex) = VAL(ctrl.getText)
  ELSE
    calibT1(flightIndex) = VAL(ctrl.getText)
  END IF
  calculateSpeedAltitude
  tilePlots
END IF
END SUB


! Write the calibration and flight time values for all known files.

SUB writeCalibration
OPEN calibFile$ FOR OUTPUT AS #1
FOR i = 1 TO UBOUND(files$, 1)
  PRINT #1, files$(i); ","; flightT0(i); ","; flightT1(i); ","; calibT0(i); ","; calibT1(i)
NEXT
CLOSE #1
END SUB
