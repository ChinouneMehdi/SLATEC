!*==DF0F.f90  processed by SPAG 6.72Dc at 10:52 on  6 Feb 2019
!DECK DF0F
      DOUBLE PRECISION FUNCTION DF0F(X)
      IMPLICIT NONE
!*--DF0F5
!***BEGIN PROLOGUE  DF0F
!***PURPOSE  Subsidiary to
!***LIBRARY   SLATEC
!***AUTHOR  (UNKNOWN)
!***ROUTINES CALLED  (NONE)
!***REVISION HISTORY  (YYMMDD)
!   ??????  DATE WRITTEN
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!***END PROLOGUE  DF0F
      DOUBLE PRECISION X
!***FIRST EXECUTABLE STATEMENT  DF0F
      DF0F = 0.0D+00
      IF ( X/=0.0D+00 ) DF0F = SIN(0.5D+02*X)/(X*SQRT(X))
      END FUNCTION DF0F
