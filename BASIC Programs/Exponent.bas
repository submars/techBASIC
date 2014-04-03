! Display the graphics view.
system.showGraphics

! Create data for a mesh. Set the X axis to 30
! evenly distributed points, and Y to 25, then
! loop over the grid to set the Z values.
DIM x(31), y(26), z(31, 26)
FOR i = 1 TO 31
  x(i) = -2 + (i - 1)*4/30
NEXT
FOR j = 1 to 26
  y(j) = -2 + (j - 1)*4/25
NEXT
FOR i = 1 TO 31
  FOR j = 1 TO 26
    z(i, j) = f(x(i), y(j))
  NEXT
NEXT

! Set up the plot, label it, and display the mesh
! with false color.
DIM p AS Plot
p = graphics.newPlot
p.setGridColor(0.8, 0.8, 0.8)
p.setTitle("f(x, y) = x*y*exp(-x*x - y*y)")
p.setMeshStyle(3)
p.setAxisStyle(5)

! Add the mesh.
DIM m AS PlotMesh
m = p.newMesh(x, y, z)

! Adjust the function so the portion under the X-Y
! plane is visible, and push it off axis.
p.setView3D(-2, -2, -1.5, 2, 2, 1.5)
p.setScale3D(1, 1, 7.5)

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout
END


! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "Here's a simple way to visualize meshes in 3D. Swipe with one finger, or use two to rotate. Pinches enlarge or shrink the plot. Tap the button at the top right of the display to switch from changing the plot to changing the axis."

about$ = about$ & CHR(10) & CHR(10) & "This sample plots a fixed mesh of values, such as points from the sensor grid. See Sinx_x for a way to plot a function."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB


FUNCTION f(x, y)
f = x*y*exp(-x*x - y*y)
END FUNCTION
