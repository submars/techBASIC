! Display the graphics view.
system.showGraphics

! Create the plot.
DIM p as Plot
p = graphics.newPlot

! Set the plot to a black background, dark blue border,
! light gray grid and light blue labels.
p.setBackgroundColor(0, 0, 0)
p.setBorderColor(0, 0, 0.4)
p.setGridColor(0.25, 0.25, 0.25)
p.setLabelColor(0.75, 0.75, 1)
IF System.device = 0 OR System.device = 256 THEN
  p.setAxisStyle(2)
END IF

! Set up the title and axis labels.
p.setTitle("Beat Frequency")
p.setTitleFont("Serif", 22, 1)
p.setYAxisLabel("Amplitude")
p.setXAxisLabel("Frequency")
p.setAxisFont("Sans-serif", 18, 2)
p.setLabelFont("Sans-serif", 14, 0)

! Use a grid instead of tick marks.
p.showGrid(1)

! Define two sine waves with different frequencies.
frequency1 = 1.0
frequency2 = 0.9

DIM func AS PlotFunction
func = p.newFunction(FUNCTION f1)
func.setColor(1, 0, 0)

DIM func2 as PlotFunction
func2 = p.newFunction(FUNCTION f2)
func2.setColor(1, 1, 0)

! Set the view. Do this after adding functions, since adding the
! first one changes the view.
p.setView(0, -2, 10, 2, 0)

! Make room for the controls and add them.
DIM slider1 AS Slider, slider2 AS Slider, label1 AS Label, label2 AS Label

width = Graphics.width
height = Graphics.height
IF System.device = 0 OR System.device = 256 THEN
  p.setRect(0, 0, width, height - 60)
  label1 = Graphics.newLabel(0, height - 55, 120)
  label1.setFont("Sans-Serif", 14, 0)
  slider1 = Graphics.newSlider(120, height - 55, 110)
  label2 = Graphics.newLabel(0, height - 25, 120)
  label2.setFont("Sans-Serif", 14, 0)
  slider2 = Graphics.newSlider(120, height - 25, 110)
ELSE
  p.setRect(0, 0, width, height - 60)
  label1 = Graphics.newLabel(10, height - 40, 130)
  slider1 = Graphics.newSlider(140, height - 40, 150)
  label2 = Graphics.newLabel(300, height - 40, 150)
  slider2 = Graphics.newSlider(450, height - 40, 150)
END IF

label1.setText("Red Frequency:")
label1.setAlignment(3)
label1.setBackgroundColor(1, 1, 1, 0)

slider1.setMinValue(0.1)
slider1.setMaxValue(20)
slider1.setValue(frequency1)

label2.setText("Yellow Frequency:")
label2.setAlignment(3)
label2.setBackgroundColor(1, 1, 1, 0)

slider2.setMinValue(0.1)
slider2.setMaxValue(20)
slider2.setValue(frequency2)

Graphics.setPixelGraphics(0)
Graphics.setColor(0.85, 0.85, 0.85)
Graphics.fillRect(0, 0, width, height)

! Create the Quit button.
DIM quit AS Button
quit = Graphics.newButton(Graphics.width - 82, Graphics.height - 48)
quit.setTitle("Quit")
quit.setBackgroundColor(1, 1, 1)
quit.setGradientColor(0.6, 0.6, 0.6)

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END

FUNCTION f1(x)
f1 = SIN(frequency1*x)
END FUNCTION

FUNCTION f2(x)
f2 = SIN(frequency2*x)
END FUNCTION

! Handle a change in one of the slider values.
!
! Parameters:
!    ctrl - The slider that changed.
!    time - The time stamp when the slider changed.
!
SUB valueChanged (ctrl AS Control, when AS DOUBLE)
IF ctrl = slider1 THEN
  frequency1 = slider1.value
ELSE IF ctrl = slider2 THEN
  frequency2 = slider2.value
END IF
p.repaint
END SUB

! Handle a tap on the Quit button.
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

! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "A beat frequency occurs when two frequencies that are close to each other, but not quite the same, combine constructively and destructively, creating a third frequency that is different from either. This happens a lot with sound."

about$ = about$ & CHR(10) & CHR(10) & "This program shows the beat frequency visually. As you adjust the frequencies, look for dense bands where the two sine waves differ, and lighter bands where they are nearly the same. These alternating light and dark bands are the beat frequency, which is much lower than either of the input frequencies."

about$ = about$ & CHR(10) & CHR(10) & "See the online Help and Reference"
about$ = about$ & " Manual for details about how to use controls like the slider and plots like these 2D functions. The Reference Manual also has more examples of controls and plots."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB