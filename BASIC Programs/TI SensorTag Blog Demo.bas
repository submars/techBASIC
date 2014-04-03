! This is the complete source for the demo program developed in the SensorTag blog.
System.showConsole
PRINT
PRINT "This simple text program connects to a Texas Instruments SensorTag, which is required for execution. Press the Stop button to stop the program."
PRINT
PRINT "See the Blogs section of the Byte Works web site for a tutorial introduction to the SesnorTag that describes this program."
PRINT

! Set up variables to hold the peripheral and the characteristics
! for the battery and buzzer.
DIM sensorTag AS BLEPeripheral

! We will look for these services.
DIM servicesHeader AS STRING, services(1) AS STRING
servicesHeader = "-0451-4000-B000-000000000000"
services(1) = "F000AA10" & servicesHeader : ! Accelerometer
accel% = 1

! Start the BLE service and begin scanning for devices.
debug = 1
BLE.startBLE
DIM uuid(0) AS STRING
BLE.startScan(uuid)

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
          
        CASE "F000AA13" & servicesHeader
          ! Set the sample rate to 100ms.
          DIM value(1) as INTEGER
          value(1) = 100
          IF debug THEN PRINT "Setting accelerometer sample rate to "; value(1)
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

      PRINT lastAccelX, lastAccelY, lastAccelZ
    
  END SELECT
ELSE IF kind = 3 AND err <> 0 THEN
  PRINT "Error writing "; characteristic.uuid; ": ("; err; ") "; message
END IF
END SUB
