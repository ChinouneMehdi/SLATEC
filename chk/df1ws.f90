!*==DF1WS.f90  processed by SPAG 6.72Dc at 10:52 on  6 Feb 2019
!DECK DF1WS
      DOUBLE PRECISION FUNCTION DF1WS(X)
      IMPLICIT NONE
!*--DF1WS5
!***BEGIN PROLOGUE  DF1WS
!***PURPOSE  Subsidiary to
!***LIBRARY   SLATEC
!***AUTHOR  (UNKNOWN)
!***ROUTINES CALLED  (NONE)
!***REVISION HISTORY  (YYMMDD)
!   ??????  DATE WRITTEN
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!***END PROLOGUE  DF1WS
      DOUBLE PRECISION X
!***FIRST EXECUTABLE STATEMENT  DF1WS
      DF1WS = 0.00D+00
      IF ( X-0.33D+00/=0.00D+00 ) DF1WS = ABS(X-0.33D+00)**(-0.999D+00)
      END FUNCTION DF1WS
