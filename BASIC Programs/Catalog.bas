! ---------------------------------------------------
!
! Catalog
!
! This program lists all of the files in the iOS
! sandbox.
!
! ---------------------------------------------------
System.showConsole
numberOfFiles = 0
Catalog("")
PRINT
PRINT "There are "; numberOfFiles; " files in the sandbox."
System.showConsole
END

! ---------------------------------------------------
!
! Catalog - Recursively print all files in a
!           directory.
!
! Parameters:
!    directory - The directory to print. Pass an
!                empty string for the current 
!                directory.
!
! ---------------------------------------------------
SUB Catalog (directory AS STRING)
DIM fileName AS STRING
DIM count AS INTEGER
DIM directories(1) AS STRING, temp(1) AS STRING
!
! Create the directory to catalog, making sure any 
! name ends with /.
!
IF directory = "" THEN
  fileName = DIR("*")
ELSE
  IF RIGHT(directory, 1) <> "/" THEN
    directory = directory & "/"
  END IF
  fileName = DIR(directory & "*")
END IF
!
! Print all files in the directory, and remember all
! subdirectories.
!
WHILE fileName <> ""
  IF ISDIR(directory & fileName) THEN
    temp = directories
    DIM directories(count + 1) AS STRING
    FOR i = 1 to count
      directories(i) = temp(i)
    NEXT
    count = count + 1
    directories(count) = directory & fileName
  ELSE
    PRINT directory & fileName
    numberOfFiles = numberOfFiles + 1
  END IF
  fileName = DIR
WEND
!
! Print any subdirectories.
!
FOR i = 1 TO count
  Catalog(directories(i))
NEXT
END SUB