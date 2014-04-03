! This app implements the right 
! paddle controller for the 
! Paddles game. The Paddles game
! requires two BLE equipped 
! iPhones and a BLE equipped 
! iPad. See Chapter 10 of 
! "Building iPhone and iPad 
! Electronics Projects" for 
! details.

DIM quitButton AS Button
DIM characteristic AS BLEMutableCharacteristic
DIM peripheralManager AS BLEPeripheralManager
DIM lastTime AS Double
orientation = 0

name$ = "RightPaddle"
serviceUUID$ = "7242D580-B108-11E2-9E96-0800200C9A66"
characteristicUUID$ = "7243D580-B108-11E2-9E96-0800200C9A66"

advertise
setUpGUI


! Advertise our presence so the 
! Paddles game can find this 
! paddle.

SUB advertise
peripheralManager = BLE.newBLEPeripheralManager

DIM service AS BLEMutableService
service = peripheralManager.newService(serviceUUID$, 1)

characteristic = service.newCharacteristic(characteristicUUID$, $0012, $0001)

peripheralManager.addService(service)
peripheralManager.startAdvertising(name$)
END SUB


! Called when the program is not 
! busy, this event handler checks 
! to make sure 0.25 seconds have 
! elapsed. If so, a new paddle 
! position is reported to the 
! Paddles game.

SUB nullEvent (time AS DOUBLE)
IF time - lastTime > 0.25 THEN
  ! Get the angle of the device.
  a = Sensors.accel
  SELECT CASE orientation
    CASE 1 : ! Home button down
      angle = DEG(ANGLE(a(2), a(3)) + PI/2)
    
    CASE 2 : ! Home button left
      angle = DEG(ANGLE(a(2), a(3)) + PI/2)
    
    CASE 3 : ! Home button right
      angle = -DEG(ANGLE(a(2), a(3)) + PI/2)

    CASE 4: ! Home button up
      angle = -DEG(ANGLE(a(2), a(3)) + PI/2)
  END SELECT
  
  ! Send the new angle to the game.
  DIM value(1) AS INTEGER
  IF angle < -90 THEN
    angle = -90
  ELSE IF angle > 90 THEN
    angle = 90
  END IF
  value(1) = 90 - angle
  result% = peripheralManager.updateValue(characteristic, value)
    
  ! Remember the time so we don't do this constantly.
  lastTime = time
END IF
END SUB


! Set up the user interface.

SUB setUpGUI
! Switch to the graphics screen.
System.showGraphics(1)
System.setAllowedOrientations(1 << (System.orientation - 1))
orientation = System.orientation

DIM title AS Label
title = Graphics.newLabel(20, 20, Graphics.width - 40, 45)
title.setFont("Sans-serif", 40, 0)
title.setText("Right Paddle")
title.setAlignment(2)
title.setBackgroundColor(0, 0, 0, 0)

quitButton = Graphics.newButton(Graphics.width - 92, Graphics.height - 57)
quitButton.setTitle("Quit")
quitButton.setBackgroundColor(1, 1, 1)
quitButton.setGradientColor(0.7, 0.7, 0.7)
END SUB


! Handle a tap on one of the buttons.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time when the event occurred.

SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quitButton THEN
  STOP
END IF
END SUB
