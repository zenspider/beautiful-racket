#lang br/demo/basic
1 REM http://www.vintage-basic.net/bcg/amazing.bas

10 PRINT TAB(28);"AMAZING PROGRAM"
20 PRINT TAB(15);"CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY"
30 PRINT:PRINT:PRINT:PRINT
100 INPUT "WHAT ARE YOUR WIDTH AND LENGTH";H,V
102 IF H<>1 AND V<>1 THEN 110
104 PRINT "MEANINGLESS DIMENSIONS.  TRY AGAIN.":GOTO 100