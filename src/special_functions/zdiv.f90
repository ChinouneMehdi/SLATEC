!DECK ZDIV
SUBROUTINE ZDIV(Ar,Ai,Br,Bi,Cr,Ci)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  ZDIV
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to ZBESH, ZBESI, ZBESJ, ZBESK, ZBESY, ZAIRY and
  !            ZBIRY
  !***LIBRARY   SLATEC
  !***TYPE      ALL (ZDIV-A)
  !***AUTHOR  Amos, D. E., (SNL)
  !***DESCRIPTION
  !
  !     DOUBLE PRECISION COMPLEX DIVIDE C=A/B.
  !
  !***SEE ALSO  ZAIRY, ZBESH, ZBESI, ZBESJ, ZBESK, ZBESY, ZBIRY
  !***ROUTINES CALLED  ZABS
  !***REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)
  !***END PROLOGUE  ZDIV
  REAL(8) :: Ar, Ai, Br, Bi, Cr, Ci, bm, ca, cb, cc, cd
  REAL(8) :: ZABS
  EXTERNAL ZABS
  !***FIRST EXECUTABLE STATEMENT  ZDIV
  bm = 1.0D0/ZABS(Br,Bi)
  cc = Br*bm
  cd = Bi*bm
  ca = (Ar*cc+Ai*cd)*bm
  cb = (Ai*cc-Ar*cd)*bm
  Cr = ca
  Ci = cb
END SUBROUTINE ZDIV