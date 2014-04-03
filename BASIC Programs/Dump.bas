! ---------------------------------------------------
!
! Dump a file
!
! This program prints the contents of any file in
! both hexadecimal and ASCII form.
!
! ---------------------------------------------------
!
! Set up the variables
!
DIM fileName AS STRING
DIM count AS LONG
DIM bytes(16) AS BYTE
DIM lineCount AS INTEGER
!
! Get the name of the file to dump
!
System.showConsole
PRINT "Dump 1.1: Hex and ASCII dump of any data file."
PRINT
INPUT "File to dump: "; fileName
!
! Open and dump the file
!
IF EXISTS(fileName) AND NOT ISDIR(fileName) THEN
  OPEN fileName FOR INPUT AS #1
  lineCount = 1
  WHILE NOT EOF(1)
    GET #1,, bytes(lineCount)
    lineCount = lineCount + 1
    IF lineCount = 17 THEN
      PrintLine(count, BYTES(), 16)
      count = count + 16
      lineCount = 1
    END IF
  WEND
  IF lineCount <> 1 THEN
    PrintLine(count, bytes(), lineCount - 1)
  END IF
  CLOSE #1
ELSE
  PRINT fileName; " does not exist."
  PRINT
  PRINT "Use Catalog to get a list of files."
  PRINT
END IF
END

! ---------------------------------------------------
!
! PrintLine - Print one line from the file
!
! Parameters:
!    count - number of bytes before this line
!    bytes - line of bytes
!    lineCount - number of bytes in this line
!
! ---------------------------------------------------
SUB PrintLine(count AS LONG , bytes() AS BYTE , lineCount AS INTEGER )
!
! Print the file displacement
!
PrintByte(count/256)
PrintByte(count)
PRINT ":";
!
! Print the hexadecimal bytes
!
FOR group = 0 TO 3
  PRINT " ";
  FOR offset = 0 TO 3
    IF group*4 + offset < lineCount THEN
      PrintByte(bytes(group*4 + offset + 1))
    ELSE
      PRINT "  ";
    END IF
  NEXT
NEXT
!
! Print the line as ASCII text
!
PRINT "  '";
FOR offset = 1 TO 16
  IF offset <= lineCount THEN
    IF (bytes(offset) >= 32) AND (bytes(offset) < 127) THEN
      PRINT CHR(bytes(offset));
    ELSE
      PRINT " ";
    END IF
  ELSE
    PRINT " ";
  END IF
NEXT
PRINT "'"
END SUB

! ---------------------------------------------------
!
! PrintByte - Print one byte
!
! Parameters:
!    b - byte to print
!
! ---------------------------------------------------
SUB PrintByte(b AS INTEGER )
DIM b1 AS INTEGER
!
b = b - 256*CINT(b/256)
b1 = b/16
b = b - b1*16
IF b1 > 9 THEN
  PRINT CHR(ASC("A") + b1 - 10);
ELSE
  PRINT CHR(ASC("0") + b1);
END IF
IF b > 9 THEN
  PRINT CHR(ASC("A") + b - 10);
ELSE
  PRINT CHR(ASC("0") + b);
END IF
END SUB
