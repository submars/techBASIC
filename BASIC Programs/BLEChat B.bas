! BLE Chat sets up peer-to-peer communication between two BLE equipped
! iOS devices. Run BLE Chat A on one device, and BLE Chat B on the other.

! Set up global GUI controls.
DIM quitButton AS Button, console AS TextView, inputLine AS TextField
DIM sendStatus AS Label, receiveStatus AS Label

! Set up a variable to hold any text that has not yet been sent to the
! central device.
line$ = ""

! Create variables to hold the peripherals and characteristics.
DIM localTextCharacteristic AS BLEMutableCharacteristic
DIM localReadyCharacteristic AS BLEMutableCharacteristic
DIM remotePeripheral AS BLEPeripheral
DIM remoteReadyCharacteristic AS BLECharacteristic
DIM peripheralManager AS BLEPeripheralManager

! Set up the UUIDs and names.
isA = 0

IF isA THEN
  localName$ = "BLEChatA"
  localServiceUUID$ = "01A00C7B-153C-45F9-B083-FE135E4E5CA0"
  localTextCharacteristicUUID$ = "01A10C7B-153C-45F9-B083-FE135E4E5CA0"
  localReadyCharacteristicUUID$ = "01A20C7B-153C-45F9-B083-FE135E4E5CA0"
  remoteName$ = "BLEChatB"
  remoteServiceUUID$ = "01B00C7B-153C-45F9-B083-FE135E4E5CA0"
  remoteTextCharacteristicUUID$ = "01B10C7B-153C-45F9-B083-FE135E4E5CA0"
  remoteReadyCharacteristicUUID$ = "01B20C7B-153C-45F9-B083-FE135E4E5CA0"
ELSE
  localName$ = "BLEChatB"
  localServiceUUID$ = "01B00C7B-153C-45F9-B083-FE135E4E5CA0"
  localTextCharacteristicUUID$ = "01B10C7B-153C-45F9-B083-FE135E4E5CA0"
  localReadyCharacteristicUUID$ = "01B20C7B-153C-45F9-B083-FE135E4E5CA0"
  remoteName$ = "BLEChatA"
  remoteServiceUUID$ = "01A00C7B-153C-45F9-B083-FE135E4E5CA0"
  remoteTextCharacteristicUUID$ = "01A10C7B-153C-45F9-B083-FE135E4E5CA0"
  remoteReadyCharacteristicUUID$ = "01A20C7B-153C-45F9-B083-FE135E4E5CA0"
END IF

! Establish communication and set up the UI.
advertise
scanForChats
setUpGUI


! Set up the communication service and advertise.

SUB advertise
peripheralManager = BLE.newBLEPeripheralManager

DIM service AS BLEMutableService
service = peripheralManager.newService(localServiceUUID$, 1)

localTextCharacteristic = service.newCharacteristic(localTextCharacteristicUUID$, $0012, $0001)
localReadyCharacteristic = service.newCharacteristic(localReadyCharacteristicUUID$, $0006, $0003)

peripheralManager.addService(service)
peripheralManager.startAdvertising(localName$)
END SUB


! Called when a peripheral is found. If it is another chat client, we
! initiate a connection to it and stop scanning for peripherals.
!
! Parameters:
!    time - The time when the peripheral was discovered.
!    peripheral - The peripheral that was discovered.
!    services - List of services offered by the device.
!    advertisements - Advertisements (information provided by the
!        device without the need to read a service/characteristic)
!    rssi - Received Signal Strength Indicator

SUB BLEDiscoveredPeripheral (time AS DOUBLE, _
                             peripheral AS BLEPeripheral, _
                             services() AS STRING, _
                             advertisements(,) AS STRING, _
                             rssi)
FOR i = 1 TO UBOUND(advertisements, 1)
  IF advertisements(i, 1) = "kCBAdvDataLocalName" THEN
    IF advertisements(i, 2) = remoteName$ THEN
      BLE.connect(peripheral)
      remotePeripheral = peripheral
    END IF
  END IF
NEXT
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

SUB BLEPeripheralInfo (time AS DOUBLE, _
                       peripheral AS BLEPeripheral, _
                       kind AS INTEGER, _
                       message AS STRING, _
                       err AS LONG)
DIM uuid(0) AS STRING
SELECT CASE kind
  CASE 1
    peripheral.discoverServices(uuid)
    BLE.stopScan
    sendStatus.setBackgroundColor(1, 1, 0): ! Connection made: Status Yellow.

  CASE 2, 3
	BLE.startScan(uuid)
    sendStatus.setBackgroundColor(1, 0, 0): ! Connection lost: Status Red.

  CASE 4
    DIM services(1) AS BLEService, included(1) AS BLEService
    services = peripheral.services
    FOR i = 1 TO UBOUND(services, 1)
      IF services(i).uuid = remoteServiceUUID$ THEN
        peripheral.discoverCharacteristics(uuid, services(i))
      END IF
    NEXT
END SELECT
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

SUB BLEServiceInfo (time AS DOUBLE, _
                    peripheral AS BLEPeripheral, _
                    service AS BLEService, _
                    kind AS INTEGER, _
                    message AS STRING, _
                    err AS LONG)
IF kind = 1 THEN
  DIM characteristics(1) AS BLECharacteristic
  characteristics = service.characteristics
  FOR i = 1 TO UBOUND(characteristics, 1)
    IF characteristics(i).uuid = remoteTextCharacteristicUUID$ THEN
      peripheral.setNotify(characteristics(i), 1)
      sendStatus.setBackgroundColor(0, 1, 0): ! Connection complete: Status Green.
    ELSE IF characteristics(i).uuid = remoteReadyCharacteristicUUID$ THEN
      remoteReadyCharacteristic = characteristics(i)
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

SUB BLECharacteristicInfo (time AS DOUBLE, _
                           peripheral AS BLEPeripheral, _
                           characteristic AS BLECharacteristic, _
                           kind AS INTEGER, _
                           message AS STRING, _
                           err AS LONG)
IF kind = 2 THEN
  ! Get the data and display it in the console view.
  DIM value(1) AS INTEGER
  value = characteristic.value
  text$ = console.getText
  FOR i% = 1 TO UBOUND(value, 1)
    text$ = text$ & CHR(value(i%))
  NEXT
  console.setText(text$)
  
  ! Tell the slave device we are ready for more.
  value = [1]
  remotePeripheral.writeCharacteristic(remoteReadyCharacteristic, value, 0)
ELSE IF kind = 3 AND err <> 0 THEN
  PRINT "Error writing "; characteristic.uuid; ": ("; err; ") "; message
END IF
END SUB


! Called to return information from a characteristic of 
! a peripheral manager.
!
! Parameters:
!    time - The time when the information was received.
!    peripheral - The peripheral.
!    characteristic - The characteristic whose information
!        changed.
!    kind - The kind of call. One of
!        1 - Called after a central subscribes to a characteristic.
!		 2 - Called after a central unsubscribes from a characteristic.
!

SUB BLEMutableCharacteristicInfo (time AS DOUBLE, _
                                  peripheral AS BLEPeripheralManager, _
                                  characteristic AS BLECharacteristic, _
                                  kind AS INTEGER)
IF kind = 1 THEN
  receiveStatus.setBackgroundColor(0, 1, 0): ! Subscription active: Status Green.
ELSE
  receiveStatus.setBackgroundColor(1, 0, 0): ! Subscription inactive: Status Red.
END IF
END SUB


! Set up the user interface.

 SUB setUpGUI
Graphics.setColor(0.9, 0.9, 0.9)
Graphics.fillRect(0, 0, Graphics.width, Graphics.height)

DIM title AS Label
title = Graphics.newLabel(20, 20, Graphics.width - 40, 40)
title.setFont("Sans-serif", 48, 0)
title.setText("BLE Chat")
title.setAlignment(2)
title.setBackgroundColor(0, 0, 0, 0)

DIM sendStatusLabel AS Label
x = Graphics.width/2 - 100
y = 90
sendStatusLabel = Graphics.newLabel(x, y, 150)
sendStatusLabel.setText("Send Status:")
sendStatusLabel.setAlignment(3)
sendStatusLabel.setFont("Arial", 20, 0)
sendStatusLabel.setBackgroundColor(0, 0, 0, 0)

sendStatus = Graphics.newLabel(x + 160, y, 21)
sendStatus.setBackgroundColor(1, 0, 0)

DIM receiveStatusLabel AS Label
y = y + 41
receiveStatusLabel = Graphics.newLabel(x, y, 150)
receiveStatusLabel.setText("Receive Status:")
receiveStatusLabel.setAlignment(3)
receiveStatusLabel.setFont("Arial", 20, 0)
receiveStatusLabel.setBackgroundColor(0, 0, 0, 0)

receiveStatus = Graphics.newLabel(x + 160, y, 21)
receiveStatus.setBackgroundColor(1, 0, 0)

y = y + 41
inputLine = Graphics.newTextField(20, y, Graphics.width - 40)
inputLine.setBackgroundColor(1, 1, 1)
inputLine.setFont("Sans_serif", 20, 0)

y = y + 41
console = Graphics.newTextView(20, y, Graphics.width - 40, Graphics.height - 292)
console.setEditable(0)
console.setFont("Sans_serif", 20, 0)

quitButton = Graphics.newButton(Graphics.width - 92, Graphics.height - 57)
quitButton.setTitle("Quit")
quitButton.setBackgroundColor(1, 1, 1)
quitButton.setGradientColor(0.7, 0.7, 0.7)

System.showGraphics
END SUB


! An attempt was made to send data to the central device, but the I/O channel
! was busy. It is now open. This method resends the data.
!
! Parameters:
!    time - The time stamp when the button was tapped.

SUB readyToUpdateSubscribers (time AS DOUBLE)
sendText
END SUB


! Start scanning for another device to talk to.

SUB scanForChats
BLE.startBLE
DIM uuid(0) AS STRING
BLE.startScan(uuid)
END SUB


! This utility routine takes the line stored in the global variable line$
! and sends up to 20 characters from the line to the central device. It
! checks to be sure the data was sent, then removes the characters from
! the line.

SUB sendText
! Make sure the central device is ready for more data. If not wait, but
! time out after 0.5 seconds.
time# = System.ticks
DIM value2(1) AS INTEGER
DO
  value2 = localReadyCharacteristic.value
  done = (UBOUND(value2, 1) = 1) AND (value2(1) = 1)
LOOP WHILE (NOT done) AND (System.ticks - time# < 0.5)

! Place up to 20 bytes into a value array.
IF LEN(line$) > 20 THEN
  length% = 20
ELSE
  length% = LEN(line$)
END IF
DIM value(length%) AS INTEGER
FOR i% = 1 TO length%
  value(i%) = ASC(MID(line$, i%, 1))
NEXT

! Set our handshaking value to 0. The central will set it to 1 after
! receiving the data.
value2 = [0]
localReadyCharacteristic.setValue(value2)

! Send the data to the central device.
result% = peripheralManager.updateValue(localTextCharacteristic, value)

! If the send was successful, remove the bytes from the line.
IF result% THEN
  console.setText(console.getText & LEFT(line$, 20))
  IF LEN(line$) > 20 THEN
    line$ = RIGHT(line$, LEN(line$) - 20)
    sendText
  ELSE
    line$ = ""
  END IF
END IF
END SUB


! Handle a tap on a button.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time stamp when the button was tapped.

SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quitButton THEN
  System.showSource
  STOP
END IF
END SUB


! Handle a press of the enter key by sending the text to the connected device.
!
! Parameters:
!    ctrl - The text field that changed.
!    time - The time stamp when the enter key was pressed.

SUB valueChanged (ctrl AS Control, time AS DOUBLE)
IF ctrl = inputLine THEN
  line$ = inputLine.getText & CHR(10)
  inputLine.setText("")
  sendText
END IF
END SUB