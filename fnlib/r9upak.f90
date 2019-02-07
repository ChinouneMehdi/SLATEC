!*==R9UPAK.f90  processed by SPAG 6.72Dc at 10:56 on  6 Feb 2019
!DECK R9UPAK
SUBROUTINE R9UPAK(X,Y,N)
  IMPLICIT NONE
  !*--R9UPAK5
  !*** Start of declarations inserted by SPAG
  REAL absx, X, Y
  INTEGER N
  !*** End of declarations inserted by SPAG
  !***BEGIN PROLOGUE  R9UPAK
  !***PURPOSE  Unpack a floating point number X so that X = Y*2**N.
  !***LIBRARY   SLATEC (FNLIB)
  !***CATEGORY  A6B
  !***TYPE      SINGLE PRECISION (R9UPAK-S, D9UPAK-D)
  !***KEYWORDS  FNLIB, UNPACK
  !***AUTHOR  Fullerton, W., (LANL)
  !***DESCRIPTION
  !
  !   Unpack a floating point number X so that X = Y*2.0**N, where
  !   0.5 .LE. ABS(Y) .LT. 1.0.
  !
  !***REFERENCES  (NONE)
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   780701  DATE WRITTEN
  !   861211  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !***END PROLOGUE  R9UPAK
  !***FIRST EXECUTABLE STATEMENT  R9UPAK
  absx = ABS(X)
  N = 0
  IF ( X==0.0E0 ) THEN
    !
    Y = SIGN(absx,X)
  ELSE
    !
    DO WHILE ( absx<0.5E0 )
      N = N - 1
      absx = absx*2.0E0
    ENDDO
    !
    DO WHILE ( absx>=1.0E0 )
      N = N + 1
      absx = absx*0.5E0
    ENDDO
    Y = SIGN(absx,X)
  ENDIF
  !
END SUBROUTINE R9UPAK
