! This program shows how to connect to Bluetooth LE devices. It
! connects to the key fob from the Texas Instruments Bluetooth
! Low Energy CC2540 Mini Development Kit. Support is included for
! the buttons, accelerometer, proximity alert and battery level.
!
! The key fob can be loaded with different software for different
! purposes. This program is compatible with the key fob software
! found in CC2540MiniDkDemoSlave.hex.
!
! See the blog at http://www.byteworks.us for a complete
! description of this program.

! Set up variables to hold the peripheral and the characteristics
! for the battery and buzzer.
DIM keyfob AS BLEPeripheral, batteryCharacteristic AS BLECharacteristic
DIM buzzerCharacteristic AS BLECharacteristic

! We will look for these four services.
DIM services(4) AS STRING
services(1) = "FFE0" : ! Push buttons
services(2) = "FFA0" : ! Accelerometer
services(3) = "180F" : ! Battery level
services(4) = "1802" : ! Proximity alert (buzzer)

! Start the BLE service and begin scanning for devices.
BLE.startBLE
DIM uuid(0) AS STRING
BLE.startScan(uuid)

! Set up the user interface. Several globals are defined here and
! used by multiple subroutines.
DIM lbutton AS ImageView, rbutton AS ImageView
points% = 100
deltaTime = 0.1
DIM xAccel(points%, 2), yAccel(points%, 2), zAccel(points%, 2)
DIM lastX, lastY, lastZ
DIM accelPlot AS Plot
DIM accelXPlot AS PlotPoint, accelYPlot AS PlotPoint, accelZPlot AS PlotPoint
DIM plotTime AS DOUBLE
DIM batteryLevel AS Label, bx, by, bh, bw
DIM batteryTime AS DOUBLE, batteryFound AS INTEGER, buzzerFound AS INTEGER
DIM soundBuzzer AS Button, quit AS Button
setUpGUI

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout


! Called when a peripheral is found. If it is a key fob, we
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
IF peripheral.bleName = "Keyfobdemo" OR peripheral.bleName = "TI BLE Keyfob" THEN
  keyfob = peripheral
  BLE.connect(keyfob)
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
  peripheral.discoverServices(uuid)
ELSE IF kind = 4 THEN
  ! Services were found. If it is one of the ones we are interested
  ! in, begin discovery of its characteristics.
  DIM availableServices(1) AS BLEService
  availableServices = peripheral.services
  FOR s = 1 to UBOUND(services, 1)
    FOR a = 1 TO UBOUND(availableServices, 1)
      IF services(s) = availableServices(a).uuid THEN
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
    IF service.uuid = "FFE0" AND characteristics(i).uuid = "FFE1" THEN
      ! Found the buttons. Ask for notifications when a button is
      ! pressed.
      peripheral.setNotify(characteristics(i), 1)
    ELSE IF service.uuid = "FFA0" THEN
      ! Found the accelerometer.
      SELECT CASE characteristics(i).uuid
        CASE "FFA1"
          ! Turn on the accelerometer.
          DIM value(1) as INTEGER
          value(1) = 1
          peripheral.writeCharacteristic(characteristics(i), value, 1)
          
        CASE "FFA3", "FFA4", "FFA5"
          ! Ask for notifications of changes in the acceleration
          ! along all three axis.
          peripheral.setNotify(characteristics(i), 1)
      END SELECT
    ELSE IF service.uuid = "180F" THEN
      ! Found the battery level. Remember it, which starts a
      ! timing loop in our nullEvent subroutine. This updates the
      ! battery level periodically.
      batteryCharacteristic = characteristics(i)
      batteryFound = 1
    ELSE IF service.uuid = "1802" THEN
      ! Found the buzzer. Remember it for use by the buzzer button.
      buzzerCharacteristic = characteristics(i)
      buzzerFound = 1
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
    CASE "FFE1"
      ! A button was pressed. Update the GUI to show a bright
      ! button for any that are held down.
      lbutton.setHidden(NOT (value(1) BITAND 1))
      rbutton.setHidden(NOT (value(1) BITAND 2))
      
    CASE "FFA3"
      ! Update the X accelerometer value.
      p% = value(1)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      lastX = p%/68.0 + 0.06
      
    CASE "FFA4"
      ! Update the Y accelerometer value.
      p% = value(1)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      lastY = p%/68.0 + 0.06
      
    CASE "FFA5"
      ! Update the X accelerometer value.
      p% = value(1)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      lastZ = p%/68.0 + 0.06
    
    CASE "2A19"
      ! Update the battery level.
      p% = value(1)
      IF p% BITAND $0080 THEN p% = p% BITOR $FF00
      setBatteryLevel(p%/100.0)
      
  END SELECT
END IF
END SUB


! Called when the program is not busy doing anything else, this
! subroutine updates the battery level and accelerometer plots.
!
! Parameters:
!    time - The time when the call was made.
!
SUB nullEvent (time AS DOUBLE)
! If it has been more than 10 seconds since the battery level was
! checked, check it again.
IF time - batteryTime > 10.0 AND batteryFound THEN
  batteryTime = time
  keyfob.readCharacteristic(batteryCharacteristic)
END IF

! If it has been more than deltaTime seconds since the
! accelerometer plot was updated, update it with the most recent
! values reported by the device.
IF plotTime = 0 THEN
  ! This is the first call. Initialize the plot.
  plotTime = time
ELSE IF time - plotTime > deltaTime THEN
  ! Update the plot with the most recent acceleration reported
  ! by the device.
  WHILE plotTime < time
    FOR i = 1 TO points% - 1
      xAccel(i, 2) = xAccel(i + 1, 2)
      yAccel(i, 2) = yAccel(i + 1, 2)
      zAccel(i, 2) = zAccel(i + 1, 2)
    NEXT
    xAccel(points%, 2) = lastX
    yAccel(points%, 2) = lastY
    zAccel(points%, 2) = lastZ
    plotTime = plotTime + deltaTime
  WEND
  accelXPlot.setPoints(xAccel)
  accelYPlot.setPoints(yAccel)
  accelZPlot.setPoints(zAccel)
  accelPlot.repaint
END IF
END SUB


! Look to see if this is an iPhone or iPad, and set the GUI up
! as appropriate.
!
SUB setUpGUI
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
! Draw the image of the key fob.
DIM keyfob AS ImageView
keyfob = Graphics.newImageView(100, 20)
keyfob.loadImage("keyfob250.png")

! Load images of the brightened buttons, but hide them until a
! button is pressed.
lbutton = Graphics.newImageView(149, 91)
lbutton.loadImage("lbutton240.png")
lbutton.setHidden(1)
rbutton = Graphics.newImageView(185, 91)
rbutton.loadImage("rbutton240.png")
rButton.setHidden(1)

! Set up the accelerometer plot.
DIM plotBackground AS Label
plotBackground = Graphics.newLabel(Graphics.width - 40, 300, 20, 300)
plotBackground.setBackgroundColor(0.886, 0.886, 0.886)

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
accelPlot.setRect(20, 300, Graphics.width - 60, 300)
accelPlot.setView(-totalTime, -1.28, 0, 1.28, 0)
accelPlot.setTitle("Acceleration in Gravities")
accelPlot.setTitleFont("Sans-Serif", 22, 0)
accelPlot.setXAxisLabel("Time in Seconds")
accelPlot.setYAxisLabel("Acceleration")
accelPlot.setAxisFont("Sans-Serif", 18, 0)

! Create the battery level indicator.
newBattery((Graphics.width - 200)/2, 620, 200, 50)

! Add a Quit button.
quit = Graphics.newButton(Graphics.width - 92, Graphics.height - 57)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.6, 0.6, 0.6)

! Add a button to sound the buzzer.
soundBuzzer = Graphics.newButton(410, 230, 140)
soundBuzzer.setTitle("Sound Alarm")
soundBuzzer.setBackgroundColor(1, 1, 1)
soundBuzzer.setGradientColor(0.6, 0.6, 0.6)

! Add some text to describe the program.
DIM title1 AS Label, title2 AS Label
title1 = Graphics.newLabel(280, 40, 400, 30)
title1.setText("Bluetooth LE Demo")
title1.setAlignment(2)
title1.setFont("Serif", 36, 1)
title2 = Graphics.newLabel(280, 90, 400, 30)
title2.setText("TI Key Fob")
title2.setAlignment(2)
title2.setFont("Serif", 30, 1)
END SUB

SUB setUpiPhoneGUI
! Get the size of the display.
height = Graphics.height
width = Graphics.width

! Draw the image of the key fob.
DIM keyfob AS ImageView
keyfob = Graphics.newImageView(20, 10)
keyfob.loadImage("keyfob120.png")

! Load images of the brightened buttons, but hide them until a
! button is pressed.
lbutton = Graphics.newImageView(42, 44)
lbutton.loadImage("lbutton120.png")
lbutton.setHidden(1)
rbutton = Graphics.newImageView(60, 44)
rbutton.loadImage("rbutton120.png")
rButton.setHidden(1)

! Set up the accelerometer plot.
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
accelPlot.setRect(10, 135, width - 30, 170)
accelPlot.setView(-totalTime, -1.28, 0, 1.28, 0)
accelPlot.setBorderColor(1, 1, 1)
accelPlot.setTitle("Acceleration in Gravities")
accelPlot.setXAxisLabel("Time in Seconds")
accelPlot.setYAxisLabel("Acceleration")

! Create the battery level indicator.
newBattery(20, 314, 160, 35)

! Add a Quit button.
quit = Graphics.newButton(width - 92, height - 47)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.6, 0.6, 0.6)

! Add a button to sound the buzzer.
soundBuzzer = Graphics.newButton(150, 90, 140)
soundBuzzer.setTitle("Sound Alarm")
soundBuzzer.setBackgroundColor(1, 1, 1)
soundBuzzer.setGradientColor(0.6, 0.6, 0.6)

! Add some text to describe the program.
DIM title1 AS Label, title2 AS Label
title1 = Graphics.newLabel(130, 25, 180, 20)
title1.setText("Bluetooth LE Demo")
title1.setAlignment(2)
title1.setFont("Serif", 20, 1)
title2 = Graphics.newLabel(150, 55, 140, 20)
title2.setText("TI Key Fob")
title2.setAlignment(2)
title2.setFont("Serif", 18, 1)
END SUB


! Create a battery level indicator using several stacked, colored
! labels.
!
! Parameters:
!    x, y - Location for the indicator.
!    width, height - Size of the indicator.
!
SUB newBattery (x, y, width, height)
DIM outline AS Label, pole AS Label, inside AS Label
outline = Graphics.newLabel(x, y, width*0.97, height)
outline.setBackgroundColor(0, 0, 0)
pole = Graphics.newLabel(x + width*0.97, y + height*0.25, width*0.03, height/2)
pole.setBackgroundColor(0, 0, 0)
bx = x + 2
by = y + 2
bw = width*0.97 - 4
bh = height - 4
inside = Graphics.newLabel(bx, by, bw, bh)
batteryLevel = Graphics.newLabel(bx, by, bw*0.01, bh)
batteryLevel.setBackgroundColor(0, 1, 0)
END SUB


! Change the battery level by changing the size of the green label
! in the battery level indicator set up by newBattery.
!
! Parameters:
!    level - The new battery level, from 0.0 to 1.0.
!
SUB setBatteryLevel (level)
batteryLevel.setFrame(bx, by, bw*level, bh)
END SUB


! Handle a tap on a button.
!
! Parameters:
!    ctrl - The button that was tapped.
!    time - The time stamp when the button was tapped.
!
SUB touchUpInside (ctrl AS Button, time AS DOUBLE)
IF ctrl = soundBuzzer THEN
  IF buzzerFound THEN
    DIM value(1) AS INTEGER
    value = [2]
    keyfob.writeCharacteristic(buzzerCharacteristic, value)
  END IF
ELSE IF ctrl = quit THEN
  STOP
END IF
END SUB


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "KeyFob manipulates the Texas Instruments BLE KeyFob. A KeyFob is required to use this program."

about$ = about$ & CHR(10) & CHR(10) & "See the Blogs section of the Byte Works web site for a tutorial introduciton to Bluetooth LE programming based on this program."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB
