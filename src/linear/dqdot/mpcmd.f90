!** MPCMD
PURE SUBROUTINE MPCMD(X,Dz)
  !> Subsidiary to DQDOTA and DQDOTI
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (MPCMD-A)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !  Converts multiple-precision X to double-precision DZ. Assumes
  !  X is in allowable range for double-precision numbers. There is
  !  some loss of accuracy if the exponent is large.
  !
  !  The argument X(*) is INTEGER array of size 30.  See the comments in
  !  the routine MPBLAS for the reason for this choice.
  !
  !***
  ! **See also:**  DQDOTA, DQDOTI, MPBLAS
  !***
  ! **Routines called:**  MPCHK, MPERR
  !***
  ! COMMON BLOCKS    MPCOM

  !* REVISION HISTORY  (YYMMDD)
  !   791001  DATE WRITTEN
  !   ??????  Modified for use with BLAS.  Blank COMMON changed to named
  !           COMMON.  R given dimension 12.
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  !   930124  Increased Array size in MPCON for SUN -r8.  (RWC)
  USE MPCOM, ONLY : b_com, t_com, mxr_com

  INTEGER, INTENT(IN) :: X(mxr_com)
  REAL(DP), INTENT(OUT) :: Dz
  INTEGER :: i, tm
  REAL(DP) :: db, dz2
  !* FIRST EXECUTABLE STATEMENT  MPCMD
  Dz = 0._DP
  IF( X(1)==0 ) RETURN
  db = REAL( b_com, DP )
  DO i = 1, t_com
    Dz = db*Dz + REAL( X(i+2), DP )
    tm = i
    ! CHECK IF FULL DOUBLE-PRECISION ACCURACY ATTAINED
    dz2 = Dz + 1._DP
    ! TEST BELOW NOT ALWAYS EQUIVALENT TO - IF(DZ2<=DZ) GO TO 20,
    ! FOR EXAMPLE ON CYBER 76.
    IF( (dz2-Dz)<=0._DP ) EXIT
  END DO
  ! NOW ALLOW FOR EXPONENT
  Dz = Dz*(db**(X(2)-tm))
  ! CHECK REASONABLENESS OF RESULT.
  IF( Dz>0._DP ) THEN
    ! LHS SHOULD BE <= 0.5 BUT ALLOW FOR SOME ERROR IN LOG
    IF( ABS(REAL(X(2), DP)-(LOG(Dz)/LOG(REAL(b_com, DP))+0.5D0))<=0.6_DP ) THEN
      IF( X(1)<0 ) Dz = -Dz
      RETURN
    END IF
  END IF
  ! FOLLOWING MESSAGE INDICATES THAT X IS TOO LARGE OR SMALL -
  ! TRY USING MPCMDE INSTEAD.
  ERROR STOP ' *** FLOATING-POINT OVER/UNDER-FLOW IN MPCMD ***'

END SUBROUTINE MPCMD