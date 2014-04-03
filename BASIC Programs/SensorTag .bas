! This program shows how to connect to Bluetooth LE devices. It
! connects to the Sensor Tag from the Texas Instruments Bluetooth
! Low Energy CC2541 Mini Development Kit.
!
! See the blog at http://www.byteworks.us for a complete
! description of this program.

! Set up variables to hold the peripheral and the characteristics
! for the battery and buzzer.
DIM sensorTag AS BLEPeripheral

! We will look for these services.
DIM servicesHeader AS STRING, services(6) AS STRING
servicesHeader = "-0451-4000-B000-000000000000"
services(1) = "F000AA00" & servicesHeader : ! Thermometer
services(2) = "F000AA10" & servicesHeader : ! Accelerometer
services(3) = "F000AA20" & servicesHeader : ! Humidity
services(4) = "F000AA30" & servicesHeader : ! Magnetometer
services(5) = "F000AA40" & servicesHeader : ! Pressure
services(6) = "F000AA50" & servicesHeader : ! Gyroscope
therm% = 1
accel% = 2
hum% = 3
mag% = 4
press% = 5
gyro% = 6

! Start the BLE service and begin scanning for devices.
debug = 0
BLE.startBLE
DIM uuid(0) AS STRING
BLE.startScan(uuid)

! Set up the user interface. Several globals are defined here and
! used by multiple subroutines.
DIM objectTemp(1) AS Control, humidity(1) AS Control, pressure(1) AS Control, bar(1) AS Control

DIM m_barCalib(8)

points% = 100
deltaTime = 0.1
DIM xAccel(points%, 2), yAccel(points%, 2), zAccel(points%, 2)
DIM lastAccelX, lastAccelY, lastAccelZ
DIM accelPlot AS Plot
DIM accelXPlot AS PlotPoint, accelYPlot AS PlotPoint, accelZPlot AS PlotPoint
DIM accelBackground AS Label

DIM xMag(points%, 2), yMag(points%, 2), zMag(points%, 2)
DIM lastMagX, lastMagY, lastMagZ
DIM magPlot AS Plot
DIM magXPlot AS PlotPoint, magYPlot AS PlotPoint, magZPlot AS PlotPoint
DIM magBackground AS Label

DIM xGyro(points%, 2), yGyro(points%, 2), zGyro(points%, 2)
DIM lastGyroX, lastGyroY, lastGyroZ
DIM gyroPlot AS Plot
DIM gyroXPlot AS PlotPoint, gyroYPlot AS PlotPoint, gyroZPlot AS PlotPoint
DIM gyroBackground AS Label

DIM plotTime AS DOUBLE

DIM quit AS Button, tabBar AS SegmentedControl
setUpGUI

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout


! Called when a peripheral is found. If it is a Sensor Tag, we
! initiate a connection to it and stop scanning for peripherals.
!
! Parameters:
!    time - The time when the peripheral was discovered.
!    peripheral - The peripheral that was discovered.
!    services - List of services offered by the device.
!    advertisements - Advertisements (information provided by the
!        device without the need to read a service/characteristic)
!    rssi - Received Signal Strength Indicator
!
SUB BLEDiscoveredPeripheral (time AS DOUBLE, peripheral AS BLEPeripheral, services() AS STRING, advertisements(,) AS STRING, rssi)
IF peripheral.bleName = "TI BLE Sensor Tag" THEN
  sensorTag = peripheral
  BLE.connect(sensorTag)
  BLE.stopScan
  IF debug THEN PRINT "Discovered SensorTag."
END IF
END SUB

! Called to report information about the connection status of the
! peripheral or to report that services have been discovered.
!
! Parameters:
!    time - The time when the information was received.
!    peripheral - The peripheral.
!    kind - The kind of call. One of
!        1 - Connection completed
!        2 - Connection failed
!        3 - Connection lost
!        4 - Services discovered
!    message - For errors, a human-readable error message.
!    err - If there was an error, the Apple error number. If there
!        was no error, this value is 0.
!
SUB BLEPeripheralInfo (time AS DOUBLE, peripheral AS BLEPeripheral, kind AS INTEGER, message AS STRING, err AS LONG)
IF kind = 1 THEN
  ! The connection was established. Look for available services.
  IF debug THEN PRINT "Connection made."
  peripheral.discoverServices(uuid)
ELSE IF kind = 2 OR kind = 3 THEN
  IF debug THEN PRINT "Connection lost: "; kind
  BLE.connect(sensorTag)
ELSE IF kind = 4 THEN
  ! Services were found. If it is one of the ones we are interested
  ! in, begin discovery of its characteristics.
  DIM availableServices(1) AS BLEService
  availableServices = peripheral.services
  FOR s = 1 to UBOUND(services, 1)
    FOR a = 1 TO UBOUND(availableServices, 1)
      IF services(s) = availableServices(a).uuid THEN
        IF debug THEN PRINT "Discovering characteristics for "; services(s)
        peripheral.discoverCharacteristics(uuid, availableServices(a))
      END IF
    NEXT
  NEXT
END IF
END SUB


! Called to report information about a characteristic or included
! services for a service. If it is one we are interested in, start
! handling it.
!
! Parameters:
!    time - The time when the information was received.
!    peripheral - The peripheral.
!    service - The service whose characteristic or included
!        service was found.
!    kind - The kind of call. One of
!        1 - Characteristics found
!        2 - Included services found
!    message - For errors, a human-readable error message.
!    err - If there was an error, the Apple error number. If there
!        was no error, this value is 0.
!
SUB BLEServiceInfo (time AS DOUBLE, peripheral AS BLEPeripheral, service AS BLEService, kind AS INTEGER, message AS STRING, err AS LONG)
IF kind = 1 THEN
  ! Get the characteristics.
  DIM characteristics(1) AS BLECharacteristic
  characteristics = service.characteristics
  FOR i = 1 TO UBOUND(characteristics, 1)
    IF service.uuid = services(therm%) THEN
      ! Found the thermometer.
      SELECT CASE characteristics(i).uuid
        CASE "F000AA01" & servicesHeader
          ! Tell the thermometer to begin sending data.
          IF debug THEN PRINT "Start thermometer."
          DIM value(2) as INTEGER
          value = [0, 1]
          peripheral.writeCharacteristic(characteristics(i), value, 0)
          peripheral.setNotify(characteristics(i), 1)
          
        CASE "F000AA02" & servicesHeader
          ! Turn the thermometer sensor on.
          IF debug THEN PRINT "Thermometer on."
          DIM value(1) as INTEGER
          value(1) = 1
          peripheral.writeCharacteristic(characteristics(i), value, 1)
      END SELECT
    ELSE IF service.uuid = services(accel%) THEN
      ! Found the accelerometer.
      SELECT CASE characteristics(i).uuid
        CASE "F000AA11" & servicesHeader
          ! Tell the accelerometer to begin sending data.
          IF debug THEN PRINT "Start accelerometer."
          DIM value(2) as INTEGER
          value = [0, 1]
          peripheral.writeCharacteristic(characteristics(i), value, 0)
          peripheral.setNotify(characteristics(i), 1)
          
        CASE "F000AA12" & servicesHeader
          ! Turn the accelerometer sensor on.
          IF debug THEN PRINT "Accelerometer on."
          DIM value(1) as INTEGER
          value(1) = 1
          peripheral.writeCharacteristic(characteristics(i), value, 1)
          
        CASE "F000AA13" & servicesHeader
          ! Set the sample rate to 100ms.
          DIM value(1) as INTEGER
          value(1) = 100
          IF debug THEN PRINT "Setting accelerometer sample rate to "; value(1)
          peripheral.writeCharacteristic(characteristics(i), value, 1)
      END SELECT
    ELSE IF service.uuid = services(hum%) THEN
      ! Found the humidity sensor.
      SELECT CASE characteristics(i).uuid
        CASE "F000AA21" & servicesHeader
          ! Tell the humidity sensor to begin sending data.
          IF debug THEN PRINT "Start humidity sensor."
          DIM value(2) as INTEGER
          value = [0, 1]
          peripheral.writeCharacteristic(characteristics(i), value, 0)
          peripheral.setNotify(characteristics(i), 1)
          
        CASE "F000AA22" & servicesHeader
          ! Turn the humidity sensor on.
          IF debug THEN PRINT "Humidity on."
          DIM value(1) as INTEGER
          value(1) = 1
          peripheral.writeCharacteristic(characteristics(i), value, 1)
      END SELECT
    ELSE IF service.uuid = services(mag%) THEN
      ! Found the magnetometer.
      SELECT CASE characteristics(i).uuid
        CASE "F000AA31" & servicesHeader
          ! Tell the magnetometer to begin sending data.
          IF debug THEN PRINT "Start magnetometer."
          DIM value(2) as INTEGER
          value = [0, 1]
          peripheral.writeCharacteristic(characteristics(i), value, 0)
          peripheral.setNotify(characteristics(i), 1)
          
        CASE "F000AA32" & servicesHeader
          ! Turn the magnetometer sensor on.
          IF debug THEN PRINT "Magnetometer on."
          DIM value(1) as INTEGER
          value(1) = 1
          peripheral.writeCharacteristic(characteristics(i), value, 1)
          
        CASE "F000AA33" & servicesHeader
          ! Set the sample rate to 100ms.
          DIM value(1) as INTEGER
          value(1) = 100
          IF debug THEN PRINT "Setting magnetometer sample rate to "; value(1)
          peripheral.writeCharacteristic(characteristics(i), value, 1)
      END SELECT
    ELSE IF service.uuid = services(press%) THEN
      ! Found the pressure sensor.
      SELECT CASE characteristics(i).uuid
        CASE "F000AA41" & servicesHeader
          ! Tell the pressure sensor to begin sending data.
          IF debug THEN PRINT "Start pressure sensor."
          DIM value(2) as INTEGER
          value = [0, 1]
          peripheral.writeCharacteristic(characteristics(i), value, 0)
          peripheral.setNotify(characteristics(i), 1)
          
        CASE "F000AA42" & servicesHeader
          ! Turn the pressure sensor on.
          IF debug THEN PRINT "Pressure on."
          DIM value(1) as INTEGER
          value(1) = 1
          peripheral.writeCharacteristic(characteristics(i), value, 1)
          value(1) = 2
          peripheral.writeCharacteristic(characteristics(i), value, 1)
          
        CASE "F000AA43" & servicesHeader
          ! Get the calibration data.
          peripheral.readCharacteristic(characteristics(i))
      END SELECT
    ELSE IF service.uuid = services(gyro%) THEN
      ! Found the gyroscope.
      SELECT CASE characteristics(i).uuid
        CASE "F000AA51" & servicesHeader
          ! Tell the gyroscope to begin sending data.
          IF debug THEN PRINT "Start gyroscope."
          DIM value(2) as INTEGER
          value = [0, 1]
          peripheral.writeCharacteristic(characteristics(i), value, 0)
          peripheral.setNotify(characteristics(i), 1)
          
        CASE "F000AA52" & servicesHeader
          ! Turn the gyroscope on.
          IF debug THEN PRINT "Gyroscope on."
          DIM value(1) as INTEGER
          value(1) = 7
          peripheral.writeCharacteristic(characteristics(i), value, 1)
      END SELECT
    END IF
  NEXT
END IF
END SUB


! Called to return information from a characteristic.
!
! Parameters:
!    time - The time when the information was received.
!    peripheral - The peripheral.
!    characteristic - The characteristic whose information
!        changed.
!    kind - The kind of call. One of
!        1 - Called after a discoverDescriptors call.
!        2 - Called after a readCharacteristics call.
!        3 - Called to report status after a writeCharacteristics
!            call.
!    message - For errors, a human-readable error message.
!    err - If there was an error, the Apple error number. If there
!        was no error, this value is 0.
!
SUB BLECharacteristicInfo (time AS DOUBLE, peripheral AS BLEPeripheral, characteristic AS BLECharacteristic, kind AS INTEGER, message AS STRING, err AS LONG)
IF kind = 2 THEN
  DIM value(1) AS INTEGER
  value = characteristic.value
  SELECT CASE characteristic.uuid
    CASE "F000AA01" & servicesHeader
      ! Update the thermometer.
      temp = value(3) BITOR (value(4) << 8)
      temp = temp/128.0
      
      target = value(1) BITOR (value(2) << 8)
      target = target*0.00000015625
      die2 = 273.15 + temp
      s0 = 6.4e-14
      a1 = 1.75e-3
      a2 = -1.678e-5
      b0 = -2.9e-5
      b1 = -5.7e-7
      b2 = 4.63e-9
      c2 = 13.4
      tref = 298.15
      dt2 = (die2 - tref)*(dies2 - tref)
      S = s0*(1 + a1*(die2 - tref) + a2*dt2)
      Vos = b0 + b1*(die2 - tref) + b2*dt2
      fObj = (target - Vos) + c2*((target - Vos)*(target - Vos))
      tObj = (die2^4 + fObj/S)^0.25
      tObj = tObj - 273.15
      if Math.isNaN(tObj) then
        tObj = 1
      end if
      setThermometerValue(objectTemp, tObj/100.0)
    
    CASE "F000AA11" & servicesHeader
      ! Update the accelerometer.
      c = 64.0
      p% = value(1)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      lastAccelX = p%/c

      p% = value(2)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      lastAccelY = p%/c
      
      p% = value(3)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      lastAccelZ = p%/c
    
    CASE "F000AA21" & servicesHeader
      ! Update the humidity indicator.
      v = value(3) BITOR (value(4) << 8)
      v = v BITAND $FFFC
      v = v*125.0/65536 - 6.0
      setThermometerValue(humidity, v/100.0)
    
    CASE "F000AA31" & servicesHeader
      ! Update the magnetometer.
      c = 65536.0/2000.0
      lastMagX = ((value(2) << 8) BITOR value(1))/c
      lastMagY = ((value(4) << 8) BITOR value(3))/c
      lastMagZ = ((value(6) << 8) BITOR value(5))/c
    
    CASE "F000AA41" & servicesHeader
      ! Update the pressure indicator.
      Tr = value(1) BITOR (value(2) << 8)
      S = m_barCalib(3) + Tr*(m_barCalib(4)/2^17 + Tr*m_barCalib(5)/2^34)
      O = m_barCalib(6)*2^14 + Tr*(m_barCalib(7)/8.0 + Tr*m_barCalib(8)/2^19)
      Pr = (value(3) BITOR (value(4) << 8)) BITAND $00FFFF
      Pa = (S*Pr + O)/2^14
      
      ! Convert from Pascal to Bar and use a display range of 0.6 to 1.2 Bar.
      Pa = Pa/100000.0
      setThermometerValue(bar, (Pa - 0.6)/0.6)
    
    CASE "F000AA43" & servicesHeader
      ! Get the pressure calibration data.
      FOR i = 1 TO 4
        j = 1 + (i - 1)*2
        m_barCalib(i) = (value(j) BITOR (value(j + 1) << 8)) BITAND $00FFFF
      NEXT
      FOR i = 5 TO 8
        j = 1 + (i - 1)*2
        m_barCalib(i) = value(j) BITOR (value(j + 1) << 8)
      NEXT
    
    CASE "F000AA51" & servicesHeader
      ! Update the gyroscope.
      c = 65536.0/500.0
      lastGyroX = ((value(2) << 8) BITOR value(1))/c
      lastGyroY = ((value(4) << 8) BITOR value(3))/c
      lastGyroZ = ((value(6) << 8) BITOR value(5))/c
    
    CASE ELSE
      PRINT "Read from "; characteristic.uuid
      
  END SELECT
ELSE IF kind = 3 AND err <> 0 THEN
  PRINT "Error writing "; characteristic.uuid; ": ("; err; ") "; message
END IF
END SUB


! Label a thermometer-like display.
!
! Parameters:
!    x, y - The location of the labels, generally a bit to the right of
!	the thermometer.
!    height - Height of the thermometer.
!    thermWidth - Width of the thermometer.
!    axisLabel$ - The vertical label that describes the thermometer.
!    minLabel$ - A label for the lowest value, e.g. 0 C.
!    maxLabel$ - A label for the highest value, e.g. 100 C.
!    divisions - The number of divisions to draw.
!
SUB labelThermometer (x, y, height, thermWidth, axisLabel$, minLabel$, maxLabel$, divisions)
height = height - thermWidth
FOR i = 0 TO divisions
  y0 = y + height - i*height/divisions
  Graphics.drawLine(x, y0, x + thermWidth/2, y0)
NEXT
Graphics.setFont("Arial", 12, 0)
x = x + thermWidth*0.75
Graphics.drawText(x, y + height, 0, minLabel$)
Graphics.drawText(x, y + Graphics.ascender, 0, maxLabel$)

Graphics.setFont("Arial", 16, 0)
width = Graphics.stringWidth(axisLabel$)
x = x + thermWidth*0.25 + Graphics.ascender
y = y + height - (height - width)/2
Graphics.drawText(x, y, Math.PI/2, axisLabel$)
END SUB


! Create and draw a new thermometer control.
!
! Parameters:
!    x, y - Location of the control.
!    width, height - Size of the control.
!    r1, g1, b1 - The color of the "mercury."
!    r2, g2, b2 - The color of the "glass."
!
! Returns: A float array with values describing the control. Pass this
!	array to setThermometerValue to update the thermometer.
!
FUNCTION newThermometer (x, y, width, height, r, g, b) (3) AS Control
DIM btn1 AS Button, btn2 AS Button, btn3 AS Button
btn1 = Graphics.newButton(x, y + height - width, width, width)
btn1.setBackgroundColor(r, g, b)
btn1.setStyle(3)
btn2 = Graphics.newButton(x + width/6, y, width*2.0/3.0, height - width + 2)
range = height - width + 1
value = 0
btn3 = Graphics.newButton(x + width/6, y + 1 + range*(1 - value), width*2.0/3.0, range*value)
btn3.setColor(r, g, b)
btn3.setBackgroundColor(r, g, b)
btn3.setStyle(2)

DIM therm(3) AS Control
therm(1) = btn1
therm(2) = btn2
therm(3) = btn3
newThermometer = therm
END FUNCTION


! Called when the program is not busy doing anything else, this
! subroutine updates the battery level and accelerometer plots.
!
! Parameters:
!    time - The time when the call was made.
!
SUB nullEvent (time AS DOUBLE)
! If it has been more than deltaTime seconds since the
! accelerometer plot was updated, update it with the most recent
! values reported by the device.
IF plotTime = 0 THEN
  ! This is the first call. Initialize the plot.
  plotTime = time
ELSE IF time - plotTime > deltaTime THEN
  ! Update the plot with the most recent sensor data reported
  ! by the device.
  WHILE plotTime < time
    FOR i = 1 TO points% - 1
      xAccel(i, 2) = xAccel(i + 1, 2)
      yAccel(i, 2) = yAccel(i + 1, 2)
      zAccel(i, 2) = zAccel(i + 1, 2)

      xMag(i, 2) = xMag(i + 1, 2)
      yMag(i, 2) = yMag(i + 1, 2)
      zMag(i, 2) = zMag(i + 1, 2)

      xGyro(i, 2) = xGyro(i + 1, 2)
      yGyro(i, 2) = yGyro(i + 1, 2)
      zGyro(i, 2) = zGyro(i + 1, 2)
    NEXT
    xAccel(points%, 2) = lastAccelX
    yAccel(points%, 2) = lastAccelY
    zAccel(points%, 2) = lastAccelZ

    xMag(points%, 2) = lastMagX
    yMag(points%, 2) = lastMagY
    zMag(points%, 2) = lastMagZ

    xGyro(points%, 2) = lastGyroX
    yGyro(points%, 2) = lastGyroY
    zGyro(points%, 2) = lastGyroZ
    
    plotTime = plotTime + deltaTime
  WEND
  
  accelXPlot.setPoints(xAccel)
  accelYPlot.setPoints(yAccel)
  accelZPlot.setPoints(zAccel)
  accelPlot.repaint
  
  magXPlot.setPoints(xMag)
  magYPlot.setPoints(yMag)
  magZPlot.setPoints(zMag)
  magPlot.repaint
  
  gyroXPlot.setPoints(xGyro)
  gyroYPlot.setPoints(yGyro)
  gyroZPlot.setPoints(zGyro)
  gyroPlot.repaint
END IF
END SUB


! Set the value of a thermometer.
!
! Parameters:
!    therm - The thermometer array created by newThermometer.
!    value - A value from 0 to 1.
!
SUB setThermometerValue(therm() AS Control, value)
IF Math.isNaN(value) THEN value = 0.0
IF value > 1.0 THEN value = 1.0
IF value < 0.0 THEN value = 0.0
range = therm(2).height - 1
x = therm(3).x
y = therm(2).y + 1 + (1 - value)*range
height = value*range
width = therm(3).width
therm(3).setFrame(x, y, width, height)
therm(3).setColor(1, 1, 1)
END SUB


! Look to see if this is an iPhone or iPad, and set the GUI up
! as appropriate.
!
SUB setUpGUI
! Use vector graphics.
Graphics.setPixelGraphics(0)

! Set up the GUI.
IF System.device = 0 OR System.device = 256 THEN
  setUpiPhoneGUI
ELSE
  setUpiPadGUI
END IF

! Switch to the graphics screen.
System.showGraphics
END SUB


! Set up the GUI for an iPad.
!
SUB setUpiPadGUI
! Label the app.
DIM title AS Label
title = Graphics.newLabel(20, 20, Graphics.width - 40, 50)
title.setText("TI Sensor Tag")
title.setAlignment(2)
title.setFont("Arial", 36, 1)

! Set up the magnetometer plot.
x = 20
height = 260
y = Graphics.height - 97 - height*2
width = (Graphics.width - 60)/2
magBackground = Graphics.newLabel(x + width - 20, y, 20, height)
magBackground.setBackgroundColor(0.886, 0.886, 0.886)

totalTime = points%*deltaTime
FOR i = 1 TO points%
  xMag(i, 1) = i/totalTime - totalTime
  yMag(i, 1) = i/totalTime - totalTime
  zMag(i, 1) = i/totalTime - totalTime
NEXT
magPlot = Graphics.newPlot
magXPlot = magPlot.newPlot(xMag)
magXPlot.setColor(1, 0, 0)
magXPlot.setPointColor(1, 0, 0)
magYPlot = magPlot.newPlot(yMag)
magYPlot.setColor(0, 1, 0)
magYPlot.setPointColor(0, 1, 0)
magZPlot = magPlot.newPlot(zMag)
magZPlot.setColor(0, 0, 1)
magZPlot.setPointColor(0, 0, 1)
magPlot.setRect(x, y, width - 20, height)
magPlot.setView(-totalTime, -200, 0, 200, 0)
magPlot.setTitle("Mag. Field in uT")
magPlot.setTitleFont("Sans-Serif", 22, 0)
magPlot.setXAxisLabel("Time in Seconds")
magPlot.setYAxisLabel("Mag. Field")
magPlot.setAxisFont("Sans-Serif", 18, 0)

! Set up the thermometers and thermometer-like indicators.
thermHeight = 260
thermWidth = 16

objectTemp = newThermometer(370, y, thermWidth, thermHeight, 1, 0, 0)
labelThermometer(390, y, thermHeight, thermWidth, "Temperature", "0 C", "100 C", 10)

humidity = newThermometer(485, y, thermWidth, thermHeight, 0.2, 0.2, 1)
labelThermometer(505, y, thermHeight, thermWidth, "Relative Humidity", "0%", "100%", 10)

bar = newThermometer(600, y, thermWidth, thermHeight, 0.769, 0.769, 0.836)
labelThermometer(620, y, thermHeight, thermWidth, "Barometric Pressure", "0.6 Bar", "1.2 Bar", 6)

! Set up the accelerometer plot.
x = 20
y = y + 20 + height
width = (Graphics.width - 60)/2
accelBackground = Graphics.newLabel(x + width - 20, y, 20, height)
accelBackground.setBackgroundColor(0.886, 0.886, 0.886)

totalTime = points%*deltaTime
FOR i = 1 TO points%
  xAccel(i, 1) = i/totalTime - totalTime
  yAccel(i, 1) = i/totalTime - totalTime
  zAccel(i, 1) = i/totalTime - totalTime
NEXT
accelPlot = Graphics.newPlot
accelXPlot = accelPlot.newPlot(xAccel)
accelXPlot.setColor(1, 0, 0)
accelXPlot.setPointColor(1, 0, 0)
accelYPlot = accelPlot.newPlot(yAccel)
accelYPlot.setColor(0, 1, 0)
accelYPlot.setPointColor(0, 1, 0)
accelZPlot = accelPlot.newPlot(zAccel)
accelZPlot.setColor(0, 0, 1)
accelZPlot.setPointColor(0, 0, 1)
accelPlot.setRect(x, y, width - 20, height)
accelPlot.setView(-totalTime, -2.2, 0, 2.2, 0)
accelPlot.setTitle("Acceleration in Gravities")
accelPlot.setTitleFont("Sans-Serif", 22, 0)
accelPlot.setXAxisLabel("Time in Seconds")
accelPlot.setYAxisLabel("Acceleration")
accelPlot.setAxisFont("Sans-Serif", 18, 0)

! Set up the gyroscope plot.
x = x + width + 20
gyroBackground = Graphics.newLabel(x + width - 20, y, 20, height)
gyroBackground.setBackgroundColor(0.886, 0.886, 0.886)

totalTime = points%*deltaTime
FOR i = 1 TO points%
  xGyro(i, 1) = i/totalTime - totalTime
  yGyro(i, 1) = i/totalTime - totalTime
  zGyro(i, 1) = i/totalTime - totalTime
NEXT
gyroPlot = Graphics.newPlot
gyroXPlot = gyroPlot.newPlot(xGyro)
gyroXPlot.setColor(1, 0, 0)
gyroXPlot.setPointColor(1, 0, 0)
gyroYPlot = gyroPlot.newPlot(yGyro)
gyroYPlot.setColor(0, 1, 0)
gyroYPlot.setPointColor(0, 1, 0)
gyroZPlot = gyroPlot.newPlot(zGyro)
gyroZPlot.setColor(0, 0, 1)
gyroZPlot.setPointColor(0, 0, 1)
gyroPlot.setRect(x, y, width - 20, height)
gyroPlot.setView(-totalTime, -250, 0, 250, 0)
gyroPlot.setTitle("Rotation in Deg./s")
gyroPlot.setTitleFont("Sans-Serif", 22, 0)
gyroPlot.setXAxisLabel("Time in Seconds")
gyroPlot.setYAxisLabel("Rotation")
gyroPlot.setAxisFont("Sans-Serif", 18, 0)

! Add a Quit button.
quit = Graphics.newButton(Graphics.width - 92, Graphics.height - 57)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.6, 0.6, 0.6)
END SUB


SUB setUpiPhoneGUI
! Get the size of the graphics screen.
gWidth = Graphics.width
gHeight = Graphics.height

! Label the app.
DIM title AS Label
title = Graphics.newLabel(0, 5, gWidth, 30)
title.setText("TI Sensor Tag")
title.setAlignment(2)
title.setFont("Arial", 24, 1)

! Set up the magnetometer plot.
x = 0
height = gHeight - 100
y = 40
width = gWidth
magBackground = Graphics.newLabel(x + width - 20, y, 20, height)
magBackground.setBackgroundColor(0.886, 0.886, 0.886)

totalTime = points%*deltaTime
FOR i = 1 TO points%
  xMag(i, 1) = i/totalTime - totalTime
  yMag(i, 1) = i/totalTime - totalTime
  zMag(i, 1) = i/totalTime - totalTime
NEXT
magPlot = Graphics.newPlot
magXPlot = magPlot.newPlot(xMag)
magXPlot.setColor(1, 0, 0)
magXPlot.setPointColor(1, 0, 0)
magYPlot = magPlot.newPlot(yMag)
magYPlot.setColor(0, 1, 0)
magYPlot.setPointColor(0, 1, 0)
magZPlot = magPlot.newPlot(zMag)
magZPlot.setColor(0, 0, 1)
magZPlot.setPointColor(0, 0, 1)
magPlot.setRect(x, y, width - 20, height)
magPlot.setView(-totalTime, -200, 0, 200, 0)
magPlot.setTitle("Mag. Field in uT")
magPlot.setTitleFont("Sans-Serif", 22, 0)
magPlot.setXAxisLabel("Time in Seconds")
magPlot.setYAxisLabel("Mag. Field")
magPlot.setAxisFont("Sans-Serif", 18, 0)

! Set up the thermometers and thermometer-like indicators.
thermHeight = gHeight - 155
thermWidth = 16
yt = y + 20

objectTemp = newThermometer(20, yt, thermWidth, thermHeight, 1, 0, 0)
labelThermometer(40, yt, thermHeight, thermWidth, "Temperature", "0 C", "100 C", 10)

humidity = newThermometer(125, yt, thermWidth, thermHeight, 0.2, 0.2, 1)
labelThermometer(145, yt, thermHeight, thermWidth, "Relative Humidity", "0%", "100%", 10)

bar = newThermometer(230, yt, thermWidth, thermHeight, 0.769, 0.769, 0.836)
labelThermometer(250, yt, thermHeight, thermWidth, "Barometric Pressure", "0.6 Bar", "1.2 Bar", 6)

! Set up the accelerometer plot.
accelBackground = Graphics.newLabel(x + width - 20, y, 20, height)
accelBackground.setBackgroundColor(0.886, 0.886, 0.886)

totalTime = points%*deltaTime
FOR i = 1 TO points%
  xAccel(i, 1) = i/totalTime - totalTime
  yAccel(i, 1) = i/totalTime - totalTime
  zAccel(i, 1) = i/totalTime - totalTime
NEXT
accelPlot = Graphics.newPlot
accelXPlot = accelPlot.newPlot(xAccel)
accelXPlot.setColor(1, 0, 0)
accelXPlot.setPointColor(1, 0, 0)
accelYPlot = accelPlot.newPlot(yAccel)
accelYPlot.setColor(0, 1, 0)
accelYPlot.setPointColor(0, 1, 0)
accelZPlot = accelPlot.newPlot(zAccel)
accelZPlot.setColor(0, 0, 1)
accelZPlot.setPointColor(0, 0, 1)
accelPlot.setRect(x, y, width - 20, height)
accelPlot.setView(-totalTime, -2.2, 0, 2.2, 0)
accelPlot.setTitle("Acceleration in Gravities")
accelPlot.setTitleFont("Sans-Serif", 22, 0)
accelPlot.setXAxisLabel("Time in Seconds")
accelPlot.setYAxisLabel("Acceleration")
accelPlot.setAxisFont("Sans-Serif", 18, 0)

! Set up the gyroscope plot.
gyroBackground = Graphics.newLabel(x + width - 20, y, 20, height)
gyroBackground.setBackgroundColor(0.886, 0.886, 0.886)

totalTime = points%*deltaTime
FOR i = 1 TO points%
  xGyro(i, 1) = i/totalTime - totalTime
  yGyro(i, 1) = i/totalTime - totalTime
  zGyro(i, 1) = i/totalTime - totalTime
NEXT
gyroPlot = Graphics.newPlot
gyroXPlot = gyroPlot.newPlot(xGyro)
gyroXPlot.setColor(1, 0, 0)
gyroXPlot.setPointColor(1, 0, 0)
gyroYPlot = gyroPlot.newPlot(yGyro)
gyroYPlot.setColor(0, 1, 0)
gyroYPlot.setPointColor(0, 1, 0)
gyroZPlot = gyroPlot.newPlot(zGyro)
gyroZPlot.setColor(0, 0, 1)
gyroZPlot.setPointColor(0, 0, 1)
gyroPlot.setRect(x, y, width - 20, height)
gyroPlot.setView(-totalTime, -250, 0, 250, 0)
gyroPlot.setTitle("Rotation in Deg./s")
gyroPlot.setTitleFont("Sans-Serif", 22, 0)
gyroPlot.setXAxisLabel("Time in Seconds")
gyroPlot.setYAxisLabel("Rotation")
gyroPlot.setAxisFont("Sans-Serif", 18, 0)

! Add a segmented control to choose the active view; select A first.
tabBar = Graphics.newSegmentedControl(-3, gHeight - 60, gWidth + 6, 62)
tabBar.setStyle(3)
tabBar.insertSegment("Accel", 1, 0)
tabBar.insertSegment("Mag", 2, 0)
tabBar.insertSegment("Gyro", 3, 0)
tabBar.insertSegment("Temp", 4, 0)
tabBar.insertSegment("Quit", 5, 0)
tabBar.setSelected(1)
valueChanged(tabBar, 0)
END SUB


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "SensorTag shows the current sensor readinsgs from a Texas Instruments SensorTag. A SensorTag is required to use this program."

about$ = about$ & CHR(10) & CHR(10) & "See the O'Reilly book, Building iPhone and iPad Electronic Projects, for a complete description of this app."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! Handle a value changed event.
!
! Parameters:
!    ctrl - The control whose value changed.
!    time - The time stamp when the change occurred.
!
SUB valueChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = tabBar THEN
  x = 0
  height = Graphics.height - 100
  y = 40
  width = Graphics.width
  SELECT CASE tabBar.selected
    CASE 1
      accelPlot.setRect(x, y, width - 20, height)
      accelBackground.setFrame(x + width - 20, y, 20, height)
      magPlot.setRect(x + 2*width, y, width - 20, height)
      magBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      gyroPlot.setRect(x + 2*width, y, width - 20, height)
      gyroBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      FOR i = 1 TO UBOUND(objectTemp, 1)
        objectTemp(i).setHidden(1)
        humidity(i).setHidden(1)
        bar(i).setHidden(1)
      NEXT
      
    CASE 2
      accelPlot.setRect(x + 2*width, y, width - 20, height)
      accelBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      magPlot.setRect(x, y, width - 20, height)
      magBackground.setFrame(x + width - 20, y, 20, height)
      gyroPlot.setRect(x + 2*width, y, width - 20, height)
      gyroBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      FOR i = 1 TO UBOUND(objectTemp, 1)
        objectTemp(i).setHidden(1)
        humidity(i).setHidden(1)
        bar(i).setHidden(1)
      NEXT
      
    CASE 3
      accelPlot.setRect(x + 2*width, y, width - 20, height)
      accelBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      magPlot.setRect(x + 2*width, y, width - 20, height)
      magBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      gyroPlot.setRect(x, y, width - 20, height)
      gyroBackground.setFrame(x + width - 20, y, 20, height)
      FOR i = 1 TO UBOUND(objectTemp, 1)
        objectTemp(i).setHidden(1)
        humidity(i).setHidden(1)
        bar(i).setHidden(1)
      NEXT
      
    CASE 4
      accelPlot.setRect(x + 2*width, y, width - 20, height)
      accelBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      magPlot.setRect(x + 2*width, y, width - 20, height)
      magBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      gyroPlot.setRect(x + 2*width, y, width - 20, height)
      gyroBackground.setFrame(x + width - 20 + 2*width, y, 20, height)
      FOR i = 1 TO UBOUND(objectTemp, 1)
        objectTemp(i).setHidden(0)
        humidity(i).setHidden(0)
        bar(i).setHidden(0)
      NEXT
    
    CASE 5
      STOP
      
  END SELECT
END IF
END SUB


! Handle a tap on a button.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time stamp when the button was tapped.
!
SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  STOP
END IF
END SUB
