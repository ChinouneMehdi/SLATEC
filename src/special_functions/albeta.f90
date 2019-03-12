!DECK ALBETA
FUNCTION ALBETA(A,B)
  IMPLICIT NONE
  REAL A, ALBETA, ALNGAM, ALNREL, B, corr, GAMMA, p, q, R9LGMC, &
    sq2pil
  !***BEGIN PROLOGUE  ALBETA
  !***PURPOSE  Compute the natural logarithm of the complete Beta
  !            function.
  !***LIBRARY   SLATEC (FNLIB)
  !***CATEGORY  C7B
  !***TYPE      SINGLE PRECISION (ALBETA-S, DLBETA-D, CLBETA-C)
  !***KEYWORDS  FNLIB, LOGARITHM OF THE COMPLETE BETA FUNCTION,
  !             SPECIAL FUNCTIONS
  !***AUTHOR  Fullerton, W., (LANL)
  !***DESCRIPTION
  !
  ! ALBETA computes the natural log of the complete beta function.
  !
  ! Input Parameters:
  !       A   real and positive
  !       B   real and positive
  !
  !***REFERENCES  (NONE)
  !***ROUTINES CALLED  ALNGAM, ALNREL, GAMMA, R9LGMC, XERMSG
  !***REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   900727  Added EXTERNAL statement.  (WRB)
  !***END PROLOGUE  ALBETA
  EXTERNAL GAMMA
  SAVE sq2pil
  DATA sq2pil/0.91893853320467274E0/
  !***FIRST EXECUTABLE STATEMENT  ALBETA
  p = MIN(A,B)
  q = MAX(A,B)
  !
  IF ( p<=0.0 ) CALL XERMSG('SLATEC','ALBETA',&
    'BOTH ARGUMENTS MUST BE GT ZERO',1,2)
  IF ( p>=10.0 ) THEN
    !
    ! P AND Q ARE BIG.
    !
    corr = R9LGMC(p) + R9LGMC(q) - R9LGMC(p+q)
    ALBETA = -0.5*LOG(q) + sq2pil + corr + (p-0.5)*LOG(p/(p+q))&
      + q*ALNREL(-p/(p+q))
    RETURN
  ELSEIF ( q<10.0 ) THEN
    !
    ! P AND Q ARE SMALL.
    !
    ALBETA = LOG(GAMMA(p)*(GAMMA(q)/GAMMA(p+q)))
    RETURN
  ENDIF
  !
  ! P IS SMALL, BUT Q IS BIG.
  !
  corr = R9LGMC(q) - R9LGMC(p+q)
  ALBETA = ALNGAM(p) + corr + p - p*LOG(p+q) + (q-0.5)*ALNREL(-p/(p+q))
  RETURN
END FUNCTION ALBETA