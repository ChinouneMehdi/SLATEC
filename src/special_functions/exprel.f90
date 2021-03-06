!** EXPREL
REAL(SP) ELEMENTAL FUNCTION EXPREL(X)
  !> Calculate the relative error exponential (EXP(X)-1)/X.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C4B
  !***
  ! **Type:**      SINGLE PRECISION (EXPREL-S, DEXPRL-D, CEXPRL-C)
  !***
  ! **Keywords:**  ELEMENTARY FUNCTIONS, EXPONENTIAL, FIRST ORDER, FNLIB
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! Evaluate  EXPREL(X) = (EXP(X) - 1.0) / X.   For small ABS(X) the
  ! Taylor series is used.  If X is negative, the reflection formula
  !         EXPREL(X) = EXP(X) * EXPREL(ABS(X))
  ! may be used.  This reflection formula will be of use when the
  ! evaluation for small ABS(X) is done by Chebyshev series rather than
  ! Taylor series.  EXPREL and X are single precision.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  R1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   770801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  USE service, ONLY : eps_2_sp
  !
  REAL(SP), INTENT(IN) :: X
  !
  INTEGER :: i
  REAL(SP) :: absx
  REAL(SP), PARAMETER :: alneps = LOG(eps_2_sp), xn = 3.72_SP - 0.3_SP*alneps, &
    xln = LOG((xn+1._SP)/1.36_SP), xbnd = eps_2_sp
  INTEGER, PARAMETER :: nterms = INT( xn - (xn*xln+alneps)/(xln+1.36_SP) + 1.5_SP )
  !* FIRST EXECUTABLE STATEMENT  EXPREL
  !
  absx = ABS(X)
  IF( absx>0.5_SP ) THEN
    EXPREL = (EXP(X)-1._SP)/X
  ELSEIF( absx<xbnd ) THEN
    EXPREL = 1._SP
  ELSE
    EXPREL = 0._SP
    DO i = 1, nterms
      EXPREL = 1._SP + EXPREL*X/(nterms+2-i)
    END DO
  END IF

END FUNCTION EXPREL