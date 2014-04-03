! Display the stars within 10 parsecs of the sun.

! Create a table that maps star color indexes to RGB values.
colorMap = [[-0.4, $9b, $b2, $ff],
            [-0.2, $b2, $c5, $ff],
            [0.0, $d3, $dd, $ff],
            [0.2, $e9, $ec, $ff],
            [0.4, $fe, $f9, $ff],
            [0.6, $ff, $f3, $ea],
            [0.8, $ff, $eb, $d6],
            [1.0, $ff, $e5, $c6],
            [1.2, $ff, $df, $b8],
            [1.4, $ff, $d8, $a9],
            [1.6, $ff, $d0, $96],
            [1.8, $ff, $b7, $65],
            [2.0, $ff, $52, $00]]

! Open, read and process the star database. The first line in the file
! is the number of stars in the database, which lists the 298 brightest
! know stars within 10 parsecs of our sun. The lines that follow have
! comma separated valued containing the name of hte star, the x, y and 
! z coordinates in parsecs, with the sun at the origin, the star's 
! color index, and the brightness for the pixel, which has been mapped 
! to a range of 0.7 to 1. This is brighter than realistic, but makes it 
! easier to see the dim stars.
!
! For stars with no common name, the Gliese index of nearby stars is
! shown.
OPEN "Stars.txt" FOR INPUT AS #1
INPUT #1, count
DIM xyz(count, 3), names(count) AS STRING, colors(count, 3)
FOR i = 1 TO count

  ! Read one line from the star database.
  INPUT #1, names(i), xyz(i, 1), xyz(i, 2), xyz(i, 3), color, bright
  
  ! Create the color for the star's point.
  IF color < colorMap(1, 1) THEN
    colors(i, 1) = colorMap(1, 2)*bright/255
    colors(i, 2) = colorMap(1, 3)*bright/255
    colors(i, 3) = colorMap(1, 4)*bright/255
  ELSE
    FOR c% = UBOUND(colorMap, 1) TO 1 STEP -1
      IF color >= colorMap(c%, 1) THEN
        colors(i, 1) = colorMap(c%, 2)*bright/255
        colors(i, 2) = colorMap(c%, 3)*bright/255
        colors(i, 3) = colorMap(c%, 4)*bright/255
        GOTO out
      END IF
    NEXT
out:
  END IF
NEXT
CLOSE #1

! Set up the plot on a black background with no axis. Set the label
! color to white so callouts will be visible on the black background.
DIM p AS Plot, s AS PlotPoint
p = graphics.newPlot
p.setBackgroundColor(0, 0, 0)
p.setBorderColor(0, 0, 0)
p.setLabelColor(1, 1, 1)
p.setAxisStyle(2)

! Set up the plot with the star locations for the point cloud data.
s = p.newPlot(xyz)

! Show the stars as a small + sign to make them easier to see.
! Comment out this line for point-like stars.
s.setPointStyle(2)

! Don't connect the stars with lines.
s.setStyle(0)

! Set up tags with the star names. Tapping a star will show a callout
! with the star name.
s.setTags(names)

! Set the star colors.
s.setColors(colors)

! Change the view to center it on our sun, and magnify it a bit.
p.setView3D(0, 0, 0, 10, 10, 10)
p.setTranslation(0, -2)
p.setScale(0.6, 0.6)

! Show the star cloud.
system.showGraphics

! Show the about box. Comment out the next line to prevent the About alert
! from showing up when the program starts.
showAbout

! Shows the About alert when the program starts.
!
SUB showAbout
about$ = "You're about to see the stars within 10 parsecs of the sun."

about$ = about$ & CHR(10) & CHR(10) & "Swip or twist with two fingers to rotate the star field, or tap on a star to get it's name. Many just have catalog numbers, but some familiar stars are lurking in the field."

about$ = about$ & CHR(10) & CHR(10) & "To disable this alert, comment out the"
about$ = about$ & " line ""showAbout""."

i = Graphics.showAlert("About This Sample", about$)
END SUB