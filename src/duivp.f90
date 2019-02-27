!DECK DUIVP
SUBROUTINE DUIVP(X,Y,Yp)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  DUIVP
  !***PURPOSE  Dummy routine for DBVSUP quick check.
  !***LIBRARY   SLATEC
  !***TYPE      DOUBLE PRECISION (UIVP-S, DUIVP-D)
  !***KEYWORDS  QUICK CHECK
  !***AUTHOR  Watts, H. A., (SNLA)
  !***DESCRIPTION
  !
  !   This routine is never called;  it is here to prevent loaders from
  !   complaining about undefined externals while testing DBVSUP.
  !
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   750601  DATE WRITTEN
  !   890618  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920401  Variables declaration and TYPE sections added.  (WRB)
  !***END PROLOGUE  DUIVP
  !     .. Scalar Arguments ..
  REAL(8) :: X
  !     .. Array Arguments ..
  REAL(8) :: Y(*), Yp(*)
  !***FIRST EXECUTABLE STATEMENT  DUIVP
  STOP
END SUBROUTINE DUIVP