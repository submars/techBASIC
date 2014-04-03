! This app implements an electronic version of table tennis, also known as
! ping pong. It requires two BLE equipped iPhones and a BLE equipped iPad. See 
! Chapter 10 of "Building iPhone and iPad Electronics Projects" for details.

DIM quitButton AS Button
DIM leftScoreLabel AS Label, rightScoreLabel AS Label, gameTime AS Label
DIM leftScore, rightScore
DIM leftPaddle AS BLEPeripheral, rightPaddle AS BLEPeripheral
DIM leftPaddleLabel AS Label, rightPaddleLabel AS Label
DIM ballLabel AS Label

leftServiceUUID$ = "7240D580-B108-11E2-9E96-0800200C9A66"
leftCharacteristicUUID$ = "7241D580-B108-11E2-9E96-0800200C9A66"
rightServiceUUID$ = "7242D580-B108-11E2-9E96-0800200C9A66"
rightCharacteristicUUID$ = "7243D580-B108-11E2-9E96-0800200C9A66"

DIM status AS Label
leftStatus = 0
rightStatus = 0

top = 120
bottom = Graphics.height - 80

paddleHeight = 70
paddleWidth = 20

DIM ballX, ballY, ballVX, ballVY
ballX = -2*ballSize
serveLeft = INT(RND(1)*2)
ballSize = paddleWidth

DIM lastTime AS DOUBLE, gameTimer AS DOUBLE, startGame AS INTEGER

scanForPaddles
setUpGUI


! Called when a peripheral is found. If it is a Paddles paddle, we
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
    IF advertisements(i, 2) = "LeftPaddle" THEN
      BLE.connect(peripheral)
      leftPaddle = peripheral
      leftStatus = 1
      setStatus
    ELSE IF advertisements(i, 2) = "RightPaddle" THEN
      BLE.connect(peripheral)
      rightPaddle = peripheral
      rightStatus = 1
      setStatus
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

  CASE 2, 3
    IF leftPaddle <> NULL AND peripheral.uuid = leftPaddle.uuid THEN
      leftStatus = 0
      BLE.connect(leftPaddle)
    ELSE IF rightPaddle <> NULL AND peripheral.uuid = rightPaddle.UUID THEN
      rightStatus = 0
      BLE.connect(rightPaddle)
    END IF
    setStatus

  CASE 4
    DIM services(1) AS BLEService, included(1) AS BLEService
    services = peripheral.services
    FOR i = 1 TO UBOUND(services, 1)
      IF services(i).uuid = leftServiceUUID$ THEN
        peripheral.discoverCharacteristics(uuid, services(i))
      ELSE IF services(i).uuid = rightServiceUUID$ THEN
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
    IF characteristics(i).uuid = leftCharacteristicUUID$ THEN
      peripheral.setNotify(characteristics(i), 1)
      leftStatus = 2
      setStatus
    ELSE IF characteristics(i).uuid = rightCharacteristicUUID$ THEN
      peripheral.setNotify(characteristics(i), 1)
      rightStatus = 2
      setStatus
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
  DIM value(1) AS INTEGER
  value = characteristic.value
  IF characteristic.UUID = leftCharacteristicUUID$ THEN
    movePaddle(1, value(1))
  ELSE IF characteristic.UUID = rightCharacteristicUUID$ THEN
    movePaddle(0, value(1))
  END IF
ELSE IF kind = 3 AND err <> 0 THEN
  PRINT "Error writing "; characteristic.uuid; ": ("; err; ") "; message
END IF
END SUB


! Move a paddle.
!
! Parameters:
!    isLeft - True to move the left paddle, or false to move the right paddle.
!    angle - The angle at which the paddle controller is held.

SUB movePaddle (isLeft AS INTEGER, angle)
tilt = 40
angle = angle - 90
IF angle < -tilt THEN
  angle = -tilt
ELSE IF angle > tilt THEN
  angle = tilt
END IF
  space = bottom - top - paddleHeight
  y = top + space*(angle + tilt)/(2*tilt)
IF isLeft THEN
  leftPaddleLabel.setFrame(0, y, paddleWidth, paddleHeight)
ELSE
  rightPaddleLabel.setFrame(Graphics.width - paddleWidth, y, _
    paddleWidth, paddleHeight)
END IF
END SUB


! Move the ball.
!
! Moves the ball based on the current ball velocity, then checks for bounces,
! paddle hits, and paddle misses, handling them as appropriate.

SUB moveBall
ballY = ballY + ballVY
IF ballY < top THEN
  ballY = top + (top - ballY)
  ballVY = -ballVY
ELSE IF ballY > bottom - ballSize THEN
  temp = bottom - ballSize
  ballY = temp - (ballY - temp)
  ballVY = -ballVY
END IF

ballX = ballX + ballVX
IF ballX < paddleWidth THEN
  ballX = paddleWidth + (paddleWidth - ballX)
  ballVX = -ballVX
  y = leftPaddleLabel.y
  IF ballY < y - ballSize OR ballY > y + paddleHeight THEN
    ballLabel.setHidden(1)
    rightScore = rightScore + 1
    rightScoreLabel.setText(STR(rightScore))
    IF rightScore = 15 THEN
      startGame = 1
    ELSE
      System.wait(1)
      serveLeft = 1
      serve
    END IF
  ELSE
    dy = 15*((ballY - (y - ballSize))/(ballSize + paddleHeight) - 0.5)
    ballVY = ballVY + dy
  END IF
ELSE IF ballX > Graphics.width - paddleWidth - ballSize THEN
  temp = Graphics.width - paddleWidth - ballSize
  ballX = temp - (ballX - temp)
  ballVX = -ballVX
  y = rightPaddleLabel.y
  IF ballY < y - ballSize OR ballY > y + paddleHeight THEN
    ballLabel.setHidden(1)
    leftScore = leftScore + 1
    leftScoreLabel.setText(STR(leftScore))
    IF leftScore = 15 THEN
      startGame = 1
    ELSE
      System.wait(1)
      serveLeft = 0
      serve
    END IF
  ELSE
    dy = 15*((ballY - (y - ballSize))/(ballSize + paddleHeight) - 0.5)
    ballVY = ballVY + dy
  END IF
END IF

ballLabel.setFrame(ballX, ballY, ballSize, ballSize)
END SUB


! Called when the program is not doing anything else, this subroutine
! moves the ball every 0.1 seconds. It also handles the start of game
! timer if a game has not yet started.
!
! Parameters:
!    time - The time when the call was made.

SUB nullEvent (time AS DOUBLE)
IF time - lastTime > 0.1 AND leftStatus = 2 AND rightStatus = 2 THEN
  moveBall
  lastTime = time
END IF

IF startGame AND leftStatus = 2 AND rightStatus = 2 THEN
  startGame = 0
  gameTimer = time + 5
  ballLabel.setHidden(1)
  ballX = Graphics.width/2
  ballVX = 0
END IF

IF gameTimer > 0 THEN
  IF gameTimer < time THEN
    gameTimer = 0
    gameTime.setText("")
    leftScoreLabel.setText("0")
    leftScore = 0
    rightScoreLabel.setText("0")
    rightScore = 0
    serve
  ELSE
    t = 1 + INT(gameTimer - time)
    gameTime.setText("Game starts in: " & STR(t))
  END IF
END IF
END SUB


! Serve the ball.
!
! Call this subroutine when it is time to serve the ball.

SUB serve
ballX = Graphics.width/2
ballY = top + (bottom - top - ballSize)*RND(1)
ballVX = 15 + 10*RND(1)
IF serveLeft THEN ballVX = -ballVX
ballVY = 15*(RND(1) - 0.5)
ballLabel.setFrame(ballX, ballY, ballSize, ballSize)
ballLabel.setHidden(0)
END SUB


! Call when the status changes.
!
! Updates the status indicator and, if both paddles are now connected, starts
! a game.

SUB setStatus
print "leftStatus = "; leftStatus; ", rightStatus = "; rightStatus
IF leftStatus = 0 OR rightStatus = 0 THEN
  status.setBackgroundColor(1, 0, 0)
ELSE IF leftStatus = 1 OR rightStatus = 1 THEN
  status.setBackgroundColor(1, 1, 0)
ELSE
  status.setBackgroundColor(0, 1, 0)
  BLE.stopScan
  startGame = 1
END IF
END SUB


! Set up the user interface.

SUB setUpGUI
DIM title AS Label
title = Graphics.newLabel(20, 20, Graphics.width - 40, 45)
title.setFont("Sans-serif", 40, 0)
title.setText("Paddles")
title.setAlignment(2)
title.setBackgroundColor(0, 0, 0, 0)

! Add a status indicator. The status label is set to red initially,
! turns yellow when a connection is made to both paddles, and
! changes to green when both paddles are started.
DIM statusLabel AS Label
x = Graphics.width/2 - 90
y = 80
width = Graphics.width
statusLabel = Graphics.newLabel(x, y, 100)
statusLabel.setText("Status:")
statusLabel.setBackgroundColor(0, 0, 0, 0)
statusLabel.setAlignment(3)
statusLabel.setFont("Arial", 20, 0)

status = Graphics.newLabel(x + 110, y, 21)
setStatus

! Add the game score indicators, initializing them to 0.
leftScoreLabel = Graphics.newLabel(Graphics.width/8, 10, Graphics.width/4, 105)
leftScoreLabel.setFont("Sans-serif", 100, 0)
leftScoreLabel.setText("0")
leftScoreLabel.setAlignment(2)
leftScoreLabel.setBackgroundColor(0, 0, 0, 0)

rightScoreLabel = Graphics.newLabel(Graphics.width*5/8, 10, _
  Graphics.width/4, 105)
rightScoreLabel.setFont("Sans-serif", 100, 0)
rightScoreLabel.setText("0")
rightScoreLabel.setAlignment(2)
rightScoreLabel.setBackgroundColor(0, 0, 0, 0)

! Add the game time counter.
width = 200
gameTime = Graphics.newLabel((Graphics.width - width)/2, Graphics.height - 50, _
  width, 30)
gameTime.setFont("Sans-serif", 24, 0)
gameTime.setBackgroundColor(0, 0, 0, 0)

! Fill the non-playing field with gray.
Graphics.setColor(0.9, 0.9, 0.9)
Graphics.fillRect(0, 0, Graphics.width, top)
Graphics.fillRect(0, bottom, Graphics.width, Graphics.height - bottom)

! Draw the net at center court.
Graphics.setColor(0.8, 0.8, 0.8)
Graphics.fillRect((Graphics.width - paddleWidth)/2, top, _
  paddleWidth, bottom - top)

! Add the paddles.
leftPaddleLabel = Graphics.newLabel(0, (Graphics.height - paddleHeight)/2, _
  paddleWidth, paddleHeight)
leftPaddleLabel.setBackgroundColor(0, 0, 0)

rightPaddleLabel = Graphics.newLabel(Graphics.width - paddleWidth, _
  (Graphics.height - paddleHeight)/2, paddleWidth, paddleHeight)
rightPaddleLabel.setBackgroundColor(0, 0, 0)

! Add the ball
ballX = Graphics.width/2
ballVX = 0
ballLabel = Graphics.newLabel(ballX, 0, ballSize, ballSize)
ballLabel.setHidden(1)
ballLabel.setBackgroundColor(0, 0, 0)

! Add the Quit button.
quitButton = Graphics.newButton(Graphics.width - 92, Graphics.height - 57)
quitButton.setTitle("Quit")
quitButton.setBackgroundColor(1, 1, 1)
quitButton.setGradientColor(0.7, 0.7, 0.7)

System.showGraphics
END SUB


! Begins scanning for paddles.

SUB scanForPaddles
BLE.startBLE
DIM uuid(0) AS STRING
BLE.startScan(uuid)
END SUB


! Handle a tap on a button.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time stamp when the button was tapped.

SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = quitButton THEN
  STOP
END IF
END SUB
