!DECK DLBETA
REAL(8) FUNCTION DLBETA(A,B)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  DLBETA
  !***PURPOSE  Compute the natural logarithm of the complete Beta
  !            function.
  !***LIBRARY   SLATEC (FNLIB)
  !***CATEGORY  C7B
  !***TYPE      DOUBLE PRECISION (ALBETA-S, DLBETA-D, CLBETA-C)
  !***KEYWORDS  FNLIB, LOGARITHM OF THE COMPLETE BETA FUNCTION,
  !             SPECIAL FUNCTIONS
  !***AUTHOR  Fullerton, W., (LANL)
  !***DESCRIPTION
  !
  ! DLBETA(A,B) calculates the double precision natural logarithm of
  ! the complete beta function for double precision arguments
  ! A and B.
  !
  !***REFERENCES  (NONE)
  !***ROUTINES CALLED  D9LGMC, DGAMMA, DLNGAM, DLNREL, XERMSG
  !***REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900727  Added EXTERNAL statement.  (WRB)
  !***END PROLOGUE  DLBETA
  REAL(8) :: A, B, p, q, corr, sq2pil, D9LGMC, DGAMMA, &
    DLNGAM, DLNREL
  EXTERNAL DGAMMA
  SAVE sq2pil
  DATA sq2pil/0.91893853320467274178032973640562D0/
  !***FIRST EXECUTABLE STATEMENT  DLBETA
  p = MIN(A,B)
  q = MAX(A,B)
  !
  IF ( p<=0.D0 ) CALL XERMSG('SLATEC','DLBETA',&
    'BOTH ARGUMENTS MUST BE GT ZERO',1,2)
  !
  IF ( p>=10.D0 ) THEN
    !
    ! P AND Q ARE BIG.
    !
    corr = D9LGMC(p) + D9LGMC(q) - D9LGMC(p+q)
    DLBETA = -0.5D0*LOG(q) + sq2pil + corr + (p-0.5D0)*LOG(p/(p+q))&
      + q*DLNREL(-p/(p+q))
    GOTO 99999
  ELSEIF ( q<10.D0 ) THEN
    !
    ! P AND Q ARE SMALL.
    !
    DLBETA = LOG(DGAMMA(p)*(DGAMMA(q)/DGAMMA(p+q)))
    RETURN
  ENDIF
  !
  ! P IS SMALL, BUT Q IS BIG.
  !
  corr = D9LGMC(q) - D9LGMC(p+q)
  DLBETA = DLNGAM(p) + corr + p - p*LOG(p+q) + (q-0.5D0)*DLNREL(-p/(p+q))
  RETURN
  !
  99999 CONTINUE
  END FUNCTION DLBETA