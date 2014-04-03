! This app uses the accelerometer to control a car hacked to use the
! RedBear BLE Shield and an Arduino.

redBearUUID$ = "713D0000-503E-4C75-BA94-3148F18D941E"
txUUID$ = "713D0003-503E-4C75-BA94-3148F18D941E"

DIM BLEShield AS BLEPeripheral
DIM txCharacteristic AS BLECharacteristic
DIM status AS Label
DIM lastTime AS DOUBLE
haveConnection = 0
turn = 0
speed = 0
orientation = 0
oldPout = 0

! Set up the speed and turn state engines.
state = 1
maxState = 6
DIM speedForState(-4 TO 4, maxState), turnForState(-4 TO 4, maxState)
speedForState = [[ 4,  4,  4,  4,  4,  4],
                 [ 4,  4,  0,  4,  4,  0],
                 [ 4,  0,  4,  0,  4,  0],
                 [ 4,  0,  0,  4,  0,  0],
                 [ 0,  0,  0,  0,  0,  0],
                 [ 8,  0,  0,  8,  0,  0],
                 [ 8,  0,  8,  0,  8,  0],
                 [ 8,  8,  0,  8,  8,  0],
                 [ 8,  8,  8,  8,  8,  8]]
 turnForState = [[32, 32, 32, 32, 32, 32],
                 [32, 32,  0, 32, 32,  0],
                 [32,  0, 32,  0, 32,  0],
                 [32,  0,  0, 32,  0,  0],
                 [ 0,  0,  0,  0,  0,  0],
                 [16,  0,  0, 16,  0,  0],
                 [16,  0, 16,  0, 16,  0],
                 [16, 16,  0, 16, 16,  0],
                 [16, 16, 16, 16, 16, 16]]

! Draw the GUI.
setUp

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout


! Called when a peripheral is found. If it is a RedBear BLE shield, we
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
BLE.connect(peripheral)
BLE.stopScan
BLEShield = peripheral
haveConnection = 1
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
DIM uuid(1) AS STRING
IF kind = 1 THEN
  ! The connection was established. Discover the service.
  uuid(1) = redBearUUID$
  peripheral.discoverServices(uuid)
  status.setBackgroundColor(1, 1, 0): ! Connection made: Status Yellow.
ELSE IF kind = 2 OR kind = 3 THEN
  ! Lost the connection--Change the status and begin looking again.
  status.setBackgroundColor(1, 0, 0): ! Connection lost: Status Red.
  haveConnection = 0
  BLE.connect(peripheral)
ELSE IF kind = 4 THEN
  ! Once the RedBear service is found, start discovery on the characteristics.
  DIM availableServices(1) AS BLEService
  availableServices = peripheral.services
  FOR a = 1 TO UBOUND(availableServices, 1)
    IF availableServices(a).UUID = redBearUUID$ THEN
      uuid(1) = txUUID$
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

SUB BLEServiceInfo (time AS DOUBLE, _
                    peripheral AS BLEPeripheral, _
                    service AS BLEService, _
                    kind AS INTEGER, _
                    message AS STRING, _
                    err AS LONG)
IF kind = 1 THEN
  ! Get the characteristics.
  DIM characteristics(1) AS BLECharacteristic
  characteristics = service.characteristics
  FOR i = 1 TO UBOUND(characteristics, 1)
    IF characteristics(i).uuid = txUUID$ THEN
      ! Remember the transmit service.
      txCharacteristic = characteristics(i)

      ! Connection complete: Status Green.
      status.setBackgroundColor(0, 1, 0)
      haveConnection = 1
      
      ! Set the four pins we use so the Firmata software treats them 
      ! as output pins.
      DIM value(3) AS INTEGER
      value = [$F4, $02, $01]
      FOR pin = 2 TO 5
        BLEShield.writeCharacteristic(txCharacteristic, value)
        value(2) = value(2)*2
      NEXT
    END IF
  NEXT
END IF
END SUB


! Draw an indicator arrow.
!
! Parameters:
!    direction - The direction of the arrow, which is also used to determine
!	its position. Directions are one of:
!		1 - Up
!		2 - Left
!		3 - Right
!		4 - Down
!    value - The value of the arrow, from 0 to 1. This indicates the
!	relative force applied in the direction, where 0 means none and
!	1 means the motor is full power in the given direction.

SUB drawArrow (direction, value)
! Find the size of an arrow.
width = Graphics.width
height = Graphics.height
IF width < height THEN
  arrowSize = width/4
ELSE
  arrowSize = height/4
END IF
top = height/4
border = arrowSize/4

! Find the polygon outlining the arrow.
DIM poly(7, 2)
IF direction = 1 OR direction = 4 THEN
  IF direction = 1 THEN
    y0 = top
    y1 = top + arrowSize/2
    y2 = top + arrowSize
  ELSE
    y0 = height - border
    y1 = y0 - arrowSize/2
    y2 = y0 - arrowSize
  END IF
  x0 = (width - arrowSize)/2
  x1 = x0 + arrowSize/4
  x2 = x0 + arrowSize/2
  x3 = x0 + 3*arrowSize/4
  x4 = x0 + arrowSize
  poly(1, 1) = x2 : poly(1, 2) = y0
  poly(2, 1) = x0 : poly(2, 2) = y1
  poly(3, 1) = x1 : poly(3, 2) = y1
  poly(4, 1) = x1 : poly(4, 2) = y2
  poly(5, 1) = x3 : poly(5, 2) = y2
  poly(6, 1) = x3 : poly(6, 2) = y1
  poly(7, 1) = x4 : poly(7, 2) = y1
ELSE
  IF direction = 2 THEN
    x0 = border
    x1 = x0 + arrowSize/2
    x2 = x0 + arrowSize
  ELSE
    x0 = width - border
    x1 = x0 - arrowSize/2
    x2 = x0 - arrowSize
  END IF
  y0 = top + (height - top -  border - arrowSize)/2
  y1 = y0 + arrowSize/4
  y2 = y0 + arrowSize/2
  y3 = y0 + 3*arrowSize/4
  y4 = y0 + arrowSize
  poly(1, 1) = x0 : poly(1, 2) = y2
  poly(2, 1) = x1 : poly(2, 2) = y4
  poly(3, 1) = x1 : poly(3, 2) = y3
  poly(4, 1) = x2 : poly(4, 2) = y3
  poly(5, 1) = x2 : poly(5, 2) = y1
  poly(6, 1) = x1 : poly(6, 2) = y1
  poly(7, 1) = x1 : poly(7, 2) = y0
END IF

! Fill the arrow.
Graphics.setColor(1 - value, 1 - value, 1)
Graphics.fillPoly(poly)

! Outline the arrow in black.
Graphics.setColor(0, 0, 0)
Graphics.drawPoly(poly)
END SUB


! Check the accelerometer and send appropriate commands to the car.
!
! Parameters:
!    time - The time when the call was made.

SUB nullEvent (time AS DOUBLE)
IF time > lastTime + 0.1 AND haveConnection AND txCharacteristic <> NULL THEN
  ! Get the angle of the device for speed and turning.
  a = Sensors.accel
  SELECT CASE orientation
    CASE 1 : ! Home button down
      turnAngle = DEG(ANGLE(a(1), a(3)) + PI/2)
      speedAngle = DEG(ANGLE(a(2), a(3)) + PI/2)
    
    CASE 2 : ! Home button left
      speedAngle = -DEG(ANGLE(a(1), a(3)) + PI/2)
      turnAngle = DEG(ANGLE(a(2), a(3)) + PI/2)
    
    CASE 3 : ! Home button right
      speedAngle = DEG(ANGLE(a(1), a(3)) + PI/2)
      turnAngle = -DEG(ANGLE(a(2), a(3)) + PI/2)

    CASE 4: ! Home button up
      turnAngle = -DEG(ANGLE(a(1), a(3)) + PI/2)
      speedAngle = -DEG(ANGLE(a(2), a(3)) + PI/2)
  END SELECT
  
  ! Decide on the proper speed.
  newSpeed = INT(speedAngle/8)
  IF newSpeed < 0 THEN newSpeed = newSpeed + 1
  IF newSpeed < -4 THEN newSpeed = -4
  IF newSpeed > 4 THEN newSpeed = 4
  IF newSpeed <> speed THEN
    IF newSpeed = 0 THEN
      IF speed > 0 THEN drawArrow(1, 0)
      IF speed < 0 THEN drawArrow(4, 0)
    ELSE IF newSpeed < 0 THEN
      IF speed > 0 THEN drawArrow(1, 0)
      drawArrow(4, -newSpeed/4)
    ELSE
      drawArrow(1, newSpeed/4)
      IF speed < 0 THEN drawArrow(4, 0)
    END IF
    speed = newSpeed
  END IF
  
  ! Decide on the proper direction.
  newTurn = INT(turnAngle/8)
  IF newTurn < 0 THEN newTurn = newTurn + 1
  IF newTurn < -4 THEN newTurn = -4
  IF newTurn > 4 THEN newTurn = 4
  IF newTurn <> turn THEN
    IF newTurn = 0 THEN
      IF turn < 0 THEN drawArrow(2, 0)
      IF turn > 0 THEN drawArrow(3, 0)
    ELSE IF newTurn < 0 THEN
      drawArrow(2, -newTurn/4)
      IF turn > 0 THEN drawArrow(3, 0)
    ELSE
      IF turn < 0 THEN drawArrow(2, 0)
      drawArrow(3, newTurn/4)
    END IF
    turn = newTurn
  END IF
  
  ! Advance the state.
  state = state + 1
  IF state > maxState THEN state = 1
  
  ! Decide whether each motor should be forward, off or reversed.
  pout = speedForState(speed, state)
  pout = pout BITOR turnForState(turn, state)
  IF oldPout <> pout THEN
    oldPout = pout
  
    ! Send the command to the BLE Shield.
    DIM value(3) AS INTEGER
    value = [$90, pout, $00]
    BLEShield.writeCharacteristic(txCharacteristic, value, 0)
  END IF
    
  ! Remember the time so we don't do this constantly.
  lastTime = time
END IF
END SUB


! Do program setup by drawing the GUI and beginning the scan for the
! RedBear BLE Shield

SUB setUp
! Switch to the graphics screen.
System.showGraphics(1)
System.setAllowedOrientations(1 << (System.orientation - 1))
orientation = System.orientation

! Get the size of the display.
height = Graphics.height
width = Graphics.width

! Label the app.
DIM title AS Label
title = Graphics.newLabel(10, 10, Graphics.width - 20, 25)
title.setText("BLE Truck")
title.setAlignment(2)
title.setFont("Arial", 28, 1)

! Add a status indicator. The status label is set to red initially,
! turns yellow when a connection is made, and changes to green
! when the transmit service is available.
DIM statusLabel AS Label
y = 60
statusLabel = Graphics.newLabel(0, y, width/2)
statusLabel.setText("Status:")
statusLabel.setAlignment(3)
statusLabel.setFont("Arial", 20, 0)

status = Graphics.newLabel(width/2 + 10, y, 21)
status.setBackgroundColor(1, 0, 0)

! Add four direction arrows that will update to give visual feedback
! as the device is tilted.
drawArrow(1, 0)
drawArrow(2, 0)
drawArrow(3, 0)
drawArrow(4, 0)

! Start the accelerometer, sampling 10 times a second.
Sensors.setAccelRate(0.1)

! Find the BLE Shield.
BLE.startBLE
DIM uuid(1) AS STRING
uuid(1) = redBearUUID$
BLE.startScan(uuid)
END SUB


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "This program controls a radio control car hacked to use an Arduino, with communications provided by a Red Bear BLE Shield. The proper hardware is required to use this program."

about$ = about$ & CHR(10) & CHR(10) & "See Chapter 8 of ""Building iPhone & iPad Electronics Projects,"" from O'Reilly Media, for a complete description of the hardware and how this program controls it."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB

