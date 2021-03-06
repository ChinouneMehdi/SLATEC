!** R9GMIC
REAL(SP) ELEMENTAL FUNCTION R9GMIC(A,X,Alx)
  !> Compute the complementary incomplete Gamma function for A
  !  near a negative integer and for small X.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C7E
  !***
  ! **Type:**      SINGLE PRECISION (R9GMIC-S, D9GMIC-D)
  !***
  ! **Keywords:**  COMPLEMENTARY INCOMPLETE GAMMA FUNCTION, FNLIB, SMALL X,
  !             SPECIAL FUNCTIONS
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! Compute the complementary incomplete gamma function for A near
  ! a negative integer and for small X.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900720  Routine changed from user-callable to subsidiary.  (WRB)
  USE service, ONLY : eps_2_sp, tiny_sp
  !
  REAL(SP), INTENT(IN) :: A, Alx, X
  !
  INTEGER :: k, m, ma, mm1
  REAL(SP) :: alng, fk, fkp1, fm, s, sgng, t, te
  REAL(SP), PARAMETER :: euler = .5772156649015329_SP
  REAL(SP), PARAMETER :: eps = 0.5_SP*eps_2_sp, bot = LOG(tiny_sp)
  !* FIRST EXECUTABLE STATEMENT  R9GMIC
  !
  IF( A>0._SP ) ERROR STOP 'R9GMIC : A MUST BE NEAR A NEGATIVE INTEGER'
  IF( X<=0._SP ) ERROR STOP 'R9GMIC : X MUST BE GT ZERO'
  !
  ma = INT( A - 0.5_SP )
  fm = -ma
  m = -ma
  !
  te = 1._SP
  t = 1._SP
  s = t
  DO k = 1, 200
    fkp1 = k + 1
    te = -X*te/(fm+fkp1)
    t = te/fkp1
    s = s + t
    IF( ABS(t)<eps*s ) GOTO 100
  END DO
  ERROR STOP 'R9GMIC : NO CONVERGENCE IN 200 TERMS OF CONTINUED FRACTION'
  !
  100  R9GMIC = -Alx - euler + X*s/(fm+1._SP)
  IF( m==0 ) RETURN
  !
  IF( m==1 ) THEN
    R9GMIC = -R9GMIC - 1._SP + 1._SP/X
    RETURN
  END IF
  !
  te = fm
  t = 1._SP
  s = t
  mm1 = m - 1
  DO k = 1, mm1
    fk = k
    te = -X*te/fk
    t = te/(fm-fk)
    s = s + t
    IF( ABS(t)<eps*ABS(s) ) EXIT
  END DO
  !
  DO k = 1, m
    R9GMIC = R9GMIC + 1._SP/k
  END DO
  !
  sgng = 1._SP
  IF( MOD(m,2)==1 ) sgng = -1._SP
  alng = LOG(R9GMIC) - LOG_GAMMA(fm+1._SP)
  !
  R9GMIC = 0._SP
  IF( alng>bot ) R9GMIC = sgng*EXP(alng)
  IF( s/=0._SP ) R9GMIC = R9GMIC + SIGN(EXP(-fm*Alx+LOG(ABS(s)/fm)),s)
  !
  !IF( R9GMIC==0._SP .AND. s==0._SP ) CALL XERMSG('R9GMIC','RESULT UNDERFLOWS',1,1)

END FUNCTION R9GMIC