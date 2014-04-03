PRINT "Simple WiFly Terminal"
PRINT
PRINT "Requires a Roving Networks WiFly module to function."
PRINT
Comm.openTCPIP(1, "169.254.1.1", 2000)
DIM t AS DOUBLE
t = System.ticks

SUB nullEvent (time AS DOUBLE)
IF System.ticks - t > 0.25 THEN
  PRINT
  LINE INPUT "> "; a$
  PRINT #1, a$
  t = System.ticks
ELSE
  WHILE NOT EOF(1)
    GET #1,,b~
    PRINT CHR(b~);
  WEND
END IF
END SUB