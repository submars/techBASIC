! This program collects data from the TI Sensor Tag. It is designed
! for use in a model rocket, collecting acceleration, pressure, and
! rotation data. The data are written to a simple CSV text file for 
! later analysis. Status information and the current acceleration 
! are shown in real time.
!
! This program is designed to work with a special build of the firmware
! for the Sensor Tag that collects acceleration data in the range -8G 
! to 8G, rather than te normal -2G to 2G.
!
! See the blog at http://www.byteworks.us for a complete
! description of this program.

! Set up variables to hold the peripheral and the characteristics
! for the battery and buzzer.
DIM sensorTag AS BLEPeripheral

! We will look for these services.
DIM servicesHeader AS STRING, services(3) AS STRING
servicesHeader = "-0451-4000-B000-000000000000"
services(1) = "F000AA10" & servicesHeader : ! Accelerometer
services(2) = "F000AA40" & servicesHeader : ! Pressure
services(3) = "F000AA50" & servicesHeader : ! Gyroscope
accel% = 1
press% = 2
gyro% = 3
services% = 0

DIM m_barCalib(8)

! Set up the user interface. Several globals are defined here and
! used by multiple subroutines.
DIM quit AS Button, status AS Label, accelValue AS Label
setUpGUI

! Start the BLE service and begin scanning for devices.
debug = 0
BLE.startBLE
DIM uuid(0) AS STRING
BLE.startScan(uuid)

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
  status.setBackgroundColor(1, 1, 0): ! Connection made: Status Yellow.
  peripheral.discoverServices(uuid)
ELSE IF kind = 2 OR kind = 3 THEN
  IF debug THEN PRINT "Connection lost: "; kind
  status.setBackgroundColor(1, 0, 0): ! Connection lost: Status Red.
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
    IF service.uuid = services(accel%) THEN
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
          services% = services% BITOR (1 << (accel% - 1))
          IF services% = 7 THEN
            ! Connection complete: Status Green.
            status.setBackgroundColor(0, 1, 0)
          END IF
          
        CASE "F000AA13" & servicesHeader
          ! Set the sample rate to 100ms.
          DIM value(1) as INTEGER
          value(1) = 10
          IF debug THEN PRINT "Setting accelerometer sample rate to "; value(1)
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
          services% = services% BITOR (1 << (press% - 1))
          IF services% = 7 THEN
            ! Connection complete: Status Green.
            status.setBackgroundColor(0, 1, 0)
          END IF
          
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
          
          services% = services% BITOR (1 << (gyro% - 1))
          IF services% = 7 THEN
            ! Connection complete: Status Green.
            status.setBackgroundColor(0, 1, 0)
          END IF
          
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
    CASE "F000AA11" & servicesHeader
      ! Get the acceleration.
      c = 16
      p% = value(1)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      x = p%/c

      p% = value(2)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      y = p%/c
      
      p% = value(3)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      z = p%/c
      
      PRINT #1, "acceleration,"; time; ","; x; ","; y; ","; z
      g = sqr(x*x + y*y + z*z)
      accelValue.setText(STR(g))
    
    CASE "F000AA41" & servicesHeader
      ! Get the pressure.
      Tr = value(1) BITOR (value(2) << 8)
      S = m_barCalib(3) + Tr*(m_barCalib(4)/2^17 + Tr*m_barCalib(5)/2^34)
      O = m_barCalib(6)*2^14 + Tr*(m_barCalib(7)/8.0 + Tr*m_barCalib(8)/2^19)
      Pr = (value(3) BITOR (value(4) << 8)) BITAND $00FFFF
      Pa = (S*Pr + O)/2^14
      
      ! Convert from Pascal to Bar and use a display range of 0.6 to 1.2 Bar.
      Pa = Pa/100000.0
      PRINT #1, "pressure,"; time; ","; Pa
    
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
      x = ((value(2) << 8) BITOR value(1))/c
      y = ((value(4) << 8) BITOR value(3))/c
      z = ((value(6) << 8) BITOR value(5))/c
      PRINT #1, "rotation,"; time; ","; x; ","; y; ","; z
    
  END SELECT
END IF
END SUB


! Gets a unique filename for the output file. The filename begins
! with "output", followed by a number and then ".rkt".
!
! Returns: An unused filename.
!
FUNCTION getFileName AS STRING
index = 1
done = 0
WHILE NOT done
  name$ = "output" & STR(index) & ".rkt"
  IF EXISTS(name$) THEN
    index = index + 1
  ELSE
    done = 1
  END IF
WEND
getFileName = name$
END FUNCTION


! Set up the GUI and the output data file.
!
SUB setUpGUI
! Use vector graphics.
Graphics.setPixelGraphics(0)

! Switch to the graphics screen.
System.showGraphics(1)
IF System.device = 0 OR System.device = 256 THEN
  System.setAllowedOrientations(1)
END IF

! Get the size of the display.
height = Graphics.height
width = Graphics.width

! Label the app.
DIM title AS Label
title = Graphics.newLabel(10, 10, Graphics.width - 20, 25)
title.setText("Rocket Data")
title.setAlignment(2)
title.setFont("Arial", 28, 1)

! Add a status indicator. The status label is set to red initially,
! turns yellow when a connection is made to the SensorTag, and
! changes to green when all three sensors are started.
DIM statusLabel AS Label
y = 60
statusLabel = Graphics.newLabel(0, y, width/2)
statusLabel.setText("Status:")
statusLabel.setAlignment(3)
statusLabel.setFont("Arial", 20, 0)

status = Graphics.newLabel(width/2 + 10, y, 21)
status.setBackgroundColor(1, 0, 0)

! Add an overall acceleration indicator.
DIM accelLabel AS Label
y = y + 41
accelLabel = Graphics.newLabel(0, y, width/2)
accelLabel.setText("Acceleration:")
accelLabel.setAlignment(3)
accelLabel.setFont("Arial", 20, 0)

accelValue = Graphics.newLabel(width/2 + 10, y, width/2 - 10)
accelValue.setText("1")
accelValue.setFont("Arial", 20, 0)

! Open the output file.
name$ = getFileName
OPEN name$ FOR OUTPUT AS #1

! Indicate the output file name.
DIM nameLabel AS Label, nameValue AS Label
y = y + 41
nameLabel = Graphics.newLabel(0, y, width/2)
nameLabel.setText("Output file:")
nameLabel.setAlignment(3)
nameLabel.setFont("Arial", 20, 0)

nameValue = Graphics.newLabel(width/2 + 10, y, width/2 - 10)
nameValue.setText(name$)
nameValue.setFont("Arial", 20, 0)

! Add a Quit button.
quit = Graphics.newButton(width - 92, height - 47)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.6, 0.6, 0.6)
END SUB


! Shows the About alert when the program starts.

SUB showAbout
about$ = "This app collects flight data from a Texas Instruments SensorTag carried in a model rocket. A SensorTag is required to use this program."

about$ = about$ & CHR(10) & CHR(10) & "See the O'Reilly book, Building iPhone and iPad Electronic Projects, for a complete description of this app and instructions showing how to build your own rocket to collect read flight data."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


! Handle a tap on a button.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time stamp when the button was tapped.
!
SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quit THEN
  CLOSE #1
  STOP
END IF
END SUB
