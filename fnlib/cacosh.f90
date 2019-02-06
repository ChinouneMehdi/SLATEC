!*==CACOSH.f90  processed by SPAG 6.72Dc at 10:56 on  6 Feb 2019
!DECK CACOSH
      COMPLEX FUNCTION CACOSH(Z)
      IMPLICIT NONE
!*--CACOSH5
!***BEGIN PROLOGUE  CACOSH
!***PURPOSE  Compute the arc hyperbolic cosine.
!***LIBRARY   SLATEC (FNLIB)
!***CATEGORY  C4C
!***TYPE      COMPLEX (ACOSH-S, DACOSH-D, CACOSH-C)
!***KEYWORDS  ACOSH, ARC HYPERBOLIC COSINE, ELEMENTARY FUNCTIONS, FNLIB,
!             INVERSE HYPERBOLIC COSINE
!***AUTHOR  Fullerton, W., (LANL)
!***DESCRIPTION
!
! CACOSH(Z) calculates the complex arc hyperbolic cosine of Z.
!
!***REFERENCES  (NONE)
!***ROUTINES CALLED  CACOS
!***REVISION HISTORY  (YYMMDD)
!   770401  DATE WRITTEN
!   861211  REVISION DATE from Version 3.2
!   891214  Prologue converted to Version 4.0 format.  (BAB)
!***END PROLOGUE  CACOSH
      COMPLEX Z , ci , CACOS
      SAVE ci
      DATA ci/(0.,1.)/
!***FIRST EXECUTABLE STATEMENT  CACOSH
      CACOSH = ci*CACOS(Z)
!
      END FUNCTION CACOSH
