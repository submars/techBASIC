! Shows a running plot of HiJack 
! input for the last 10 seconds
! in 0.1 second intervals.
!
! Initialize the display with the
! value set to 0.
DIM value(100, 2)
FOR t = 1 TO 100
  value(t, 1) = (t - 100)/10.0
NEXT

! Initialize the plot and show
! it.
DIM p as Plot, ph as PlotPoint
p = Graphics.newPlot
p.setTitle("HiJack Raw Data")
p.setXAxisLabel("Time in Seconds")
p.setYAxisLabel("Value Read")
p.showGrid(1)
p.setGridColor(0.8, 0.8, 0.8)

ph = p.newPlot(value)
ph.setColor(1, 0, 0)
ph.setPointColor(1, 0, 0)

! Set the plot range and
! domain. This must be done
! after adding the first
! PlotPoint, since that also
! sets the range and domain.
p.setView(-10, 0, 0, 255, 0)

system.showGraphics


! Show the about box. Comment 
! out the next line to prevent
! the About alert from showing
! up when the program starts.
showAbout

! Loop continuously, collecting
! HiJack data and updating the
! plot.
DIM time AS double
time = System.ticks - 10.0
WHILE 1
  ! Wait for 0.1 seconds to
  ! elapse.
  WHILE System.ticks < time + 10.1
  WEND
  time = time + 0.1
  
  ! Get and plot one data point.
  h = HiJack.receive
  FOR i = 1 TO 99
    value(i, 2) = value(i + 1, 2)
  NEXT
  value(100, 2) = h(1)
  ph.setPoints(value)
  Graphics.repaint
WEND


! Shows the About alert when
! the program starts.
!
SUB showAbout
about$ = "Plots sensor readings from a HiJack A-D converter. A HiJack is required to use this program."

about$ = about$ & CHR(10) & CHR(10) & "Tap the Stop button to stop this program."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line that calls showAbout."

i = Graphics.showAlert("About This Sample", about$)
END SUB
