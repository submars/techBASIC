! Terminal program for the Blue Radios BR-XB-LE4.0-S2. See the blog
! at http://www.byteworks.us/Byte_Works/Blog/Blog.html for details.

! Define the various UUIDs
blueRadiosUUID$ = "DA2B84F1-6279-48DE-BDC0-AFBEA0226079"
infoUUID$ = "99564A02-DC01-4D3C-B04E-3BB1EF0571B2"
modeUUID$ = "A87988B9-694C-479C-900E-95DFA6C00A24"
rxUUID$ = "BF03260C-7205-4C25-AF43-93B1C299D159"
txUUID$ = "18CDA784-4BD3-4370-85BB-BFED91EC86AF"

! Set to 1 for verbose debug output.
debug% = 0

! This is the device we've connected to, if any.
DIM blueRadiosPeripheral AS BLEPeripheral

! Used to create a pause before accepting commands.
DIM commandsAllowed AS INTEGER, commandTime AS DOUBLE, delay AS DOUBLE
delay = 0.5

! Print the version.
PRINT "Blue Radios AT Terminal 1.0"
PRINT
PRINT "This is a terminal program for the Blue Radios BR-XB-LE4.0-S2. This"
PRINT "device is required for operation. Press the STOP button to end the"
PRINT "program."
PRINT
System.showConsole

! Start BLE processing and scan for a Blue Radios device.
BLE.startBLE
DIM uuid(1) AS STRING
uuid(1) = blueRadiosUUID$
BLE.startScan(uuid)


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
  DIM ch AS BLECharacteristic
  DIM value(1) AS INTEGER
  value = characteristic.value
  SELECT CASE characteristic.uuid
    CASE infoUUID$
      ! The device returned the initial information.
      DIM value(0) AS INTEGER
      value = characteristic.value
      IF debug% THEN
        PRINT "Info: "; valueToHex(value)
      END IF
      IF (value(1) BITAND $02) = $02 THEN
        ! Start watching for data from the device.
        ch = findCharacteristic(txUUID$)
        peripheral.setNotify(ch, 1)
        
        ! Set the mode to remote command mode.
        value = [2]
        ch = findCharacteristic(modeUUID$)
        peripheral.writeCharacteristic(ch, value, 1)
      ELSE
        PRINT "This device does not support terminal mode."
        STOP
      END IF
    
    CASE txUUID$
      ! The device sent back information via TX.
      data% = characteristic.value
      data$ = ""
      FOR i = 1 TO UBOUND(data%, 1)     
        IF data%(i) <> 13 THEN
          data$ = data$ & CHR(data%(i))
        END IF
      NEXT
      PRINT data$
      
    CASE modeUUID$
      ! The device sent back the mode.
      data% = characteristic.value
      IF debug% THEN
        PRINT "Mode: "; data%(1)
      END IF
    
    CASE ELSE
      PRINT "Unexpected value from "; characteristic.uuid; ": "; valueToHex(characteristic.value)
      
  END SELECT
ELSE IF kind = 3 THEN
  ! Write response recieved.
  IF debug% THEN
    r$ = "Response from characteristic " & characteristic.uuid
    r$ = r$ & " with error code " & STR(err)
    PRINT r$
  END IF

  ! All write responses indicate we can accept a new command. Set the
  ! flag, but be sure and wait a short time for other response pieces to
  ! arrive.
  IF characteristic.uuid = modeUUID$ THEN
    ! The mode has been set.
    IF debug% THEN
      peripheral.readCharacteristic(characteristic)
    END IF
  END IF
  commandsAllowed = 1
  commandTime = time + delay
END IF
END SUB


! Called when a peripheral is found. If it is a BlueRadios device, we
! initiate a connection to it and stop scanning for peripherals.
!
! Parameters:
!    time - The time when the peripheral was discovered.
!    peripheral - The peripheral that was discovered.
!    services - List of services offered by the device.
!    advertisements - Advertisements (information provided by the
!        device without the need to read a service/characteristic)
!    rssi - Received Signal Strength Indicator

SUB BLEDiscoveredPeripheral (time AS DOUBLE, peripheral AS BLEPeripheral, services() AS STRING, advertisements(,) AS STRING, rssi)
blueRadiosPeripheral = peripheral
IF debug% THEN
  PRINT "Attempting to connect to "; blueRadiosPeripheral.bleName
END IF
BLE.connect(blueRadiosPeripheral)
BLE.stopScan
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

SUB BLEPeripheralInfo (time AS DOUBLE, peripheral AS BLEPeripheral, kind AS INTEGER, message AS STRING, err AS LONG)
DIM uuid(0) AS STRING

IF kind = 1 THEN
  ! The connection was established. Look for available services.
  peripheral.discoverServices(uuid)
ELSE IF kind = 2 OR kind = 3 THEN
  PRINT "The connection was lost."
ELSE IF kind = 4 THEN
  ! Services were found. If it is the main service, begin discovery
  ! of its characteristics.
  DIM availableServices(1) AS BLEService
  availableServices = peripheral.services
  FOR a = 1 TO UBOUND(availableServices, 1)
    IF debug% THEN
      PRINT "Found service "; availableServices(a).UUID
    END IF
    IF availableServices(a).UUID = blueRadiosUUID$ THEN
      peripheral.discoverCharacteristics(uuid, availableServices(a))
    END IF
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

SUB BLEServiceInfo (time AS DOUBLE, peripheral AS BLEPeripheral, service AS BLEService, kind AS INTEGER, message AS STRING, err AS LONG)
IF kind = 1 THEN
  ! Get the characteristics.
  DIM characteristics(1) AS BLECharacteristic
  characteristics = service.characteristics
  FOR i = 1 TO UBOUND(characteristics, 1)
    IF debug% THEN
      PRINT "Found characteristic "; i; ": "; characteristics(i).uuid
    END IF
    IF characteristics(i).uuid = infoUUID$ THEN
      peripheral.readCharacteristic(characteristics(i))
    END IF
  NEXT
END IF
END SUB


! Find a characteristic for the main blueRadiosUUID service by
! characteristic UUID. This cannot be done until after characteristics
! have been discovered.
!
! Parameters:
!	uuid - The UUID of the characteristic to find.
!
! Returns: The characteristic.

FUNCTION findCharacteristic (uuid AS STRING) AS BLECharacteristic
! Find the main BlueRadios service.
DIM availableServices(1) AS BLEService
availableServices = blueRadiosPeripheral.services
FOR a = 1 TO UBOUND(availableServices, 1)
  IF availableServices(a).UUID = blueRadiosUUID$ THEN
   
    ! Find the characteristic.
    DIM availableCharacteristics(1) AS BLECharacteristic
    availableCharacteristics = availableServices(a).characteristics
    FOR c = 1 TO UBOUND(availableCharacteristics, 1)
      IF availableCharacteristics(c).uuid = uuid THEN
        findCharacteristic = availableCharacteristics(c)
        GOTO 99
      END IF
    NEXT
  END IF
NEXT

PRINT "An expected characteristic was not found."
STOP

99:
END FUNCTION


! Called when nothing else is happening.
!
! Check to see if commands can be accepted. If so, get a user command.

SUB nullEvent (time AS DOUBLE)
IF commandsAllowed AND (time > commandTime) THEN
  ! Let the user type a command, sending it to RX.
  LINE INPUT "> "; line$
  DIM line%(LEN(line$) + 1)
  FOR i = 1 TO LEN(line$)
    line%(i) = ASC(MID(line$, i, 1))
  NEXT
  line%(UBOUND(line%, 1)) = 13
  
  DIM ch AS BLECharacteristic
  ch = findCharacteristic(rxUUID$)
  blueRadiosPeripheral.writeCharacteristic(ch, line%, 1)
  
  ! Don't allow additional commmands until this one is complete.
  commandsAllowed = 0
END IF  
END SUB


! Convert an array of byte values to a hexadecimal string.
!
! Parameters:
!	value - The array of bytes.
!
! Returns: A string of hexadecimal digits representing the value.

FUNCTION valueToHex (value() AS INTEGER) AS STRING
s$ = ""
FOR i = 1 TO UBOUND(value, 1)
  s$ = s$ & RIGHT(HEX(value(i)), 2)
NEXT
valueToHex = s$
END FUNCTION