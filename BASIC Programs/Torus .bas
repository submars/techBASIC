System.showGraphics

DIM p as Plot
p = Graphics.newPlot
p.setGridColor(0.85, 0.85, 0.85)
p.setsurfacestyle(3)
p.setAxisStyle(5)

hSize% = 41
vSize% = 16
DIM x(hSize%, vSize%), y(hSize%, vSize%), z(hSize%, vSize%)
R = 3
a = 1
PI = 3.1415926535
FOR u% = 1 TO hSize%
  u = u%*2*PI/(hSize% - 1)
  FOR v% = 1 TO vSize%
    v = v%*2*PI/(vSize% - 1)
    z(u%, v%) = (R + a*cos(v))*cos(u)
    y(u%, v%) = (R + a*cos(v))*sin(u)
    x(u%, v%) = a*sin(v)
  NEXT
NEXT
DIM surface AS PlotSurface
surface = p.newSurface(x(), y(), z())

about$ = "Here's how to create arbitrary surfaces in three dimensions. You"
about$ = about$ & " can manipulate the surfaces with pinch and drag gestures."

about$ = about$ & CHR(10) & CHR(10) & "To plot your own surfaces, change the"
about$ = about$ & " lines in the program that create the X, Y and Z matrices."

about$ = about$ & CHR(10) & CHR(10) & "See the online Help and Reference"
about$ = about$ & " Manual for details about how to use surfaces. The"
about$ = about$ & " Reference Manual also has more examples of surfaces and"
about$ = about$ & " other kinds of plots."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " last line of the program."
i = Graphics.showAlert("About This Sample", about$)