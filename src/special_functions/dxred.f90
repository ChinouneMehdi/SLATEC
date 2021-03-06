!** DXRED
SUBROUTINE DXRED(X,Ix,Ierror)
  !> To provide double-precision floating-point arithmetic
  !            with an extended exponent range.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  A3D
  !***
  ! **Type:**      DOUBLE PRECISION (XRED-S, DXRED-D)
  !***
  ! **Keywords:**  EXTENDED-RANGE DOUBLE-PRECISION ARITHMETIC
  !***
  ! **Author:**  Lozier, Daniel W., (National Bureau of Standards)
  !           Smith, John M., (NBS and George Mason University)
  !***
  ! **Description:**
  !     DOUBLE PRECISION X
  !     INTEGER IX
  !
  !                  IF
  !                  RADIX**(-2L) <= (ABS(X),IX) <= RADIX**(2L)
  !                  THEN DXRED TRANSFORMS (X,IX) SO THAT IX=0.
  !                  IF(X,IX) IS OUTSIDE THE ABOVE RANGE,
  !                  THEN DXRED TAKES NO ACTION.
  !                  THIS SUBROUTINE IS USEFUL IF THE
  !                  RESULTS OF EXTENDED-RANGE CALCULATIONS
  !                  ARE TO BE USED IN SUBSEQUENT ORDINARY
  !                  DOUBLE-PRECISION CALCULATIONS.
  !
  !***
  ! **See also:**  DXSET
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  (NONE)
  !***
  ! COMMON BLOCKS    DXBLK2

  !* REVISION HISTORY  (YYMMDD)
  !   820712  DATE WRITTEN
  !   881020  Revised to meet SLATEC CML recommendations.  (DWL and JMS)
  !   901019  Revisions to prologue.  (DWL and WRB)
  !   901106  Changed all specific intrinsics to generic.  (WRB)
  !           Corrected order of sections in prologue and added TYPE
  !           section.  (WRB)
  !   920127  Revised PURPOSE section of prologue.  (DWL)
  USE DXBLK ,ONLY: radixx_com, rad2l_com, l2_com
  INTEGER :: Ierror, Ix
  REAL(DP) :: X
  INTEGER :: i, ixa, ixa1, ixa2
  REAL(DP) :: xa
  !
  !* FIRST EXECUTABLE STATEMENT  DXRED
  Ierror = 0
  IF( X==0._DP ) THEN
    Ix = 0
  ELSE
    xa = ABS(X)
    IF( Ix/=0 ) THEN
      ixa = ABS(Ix)
      ixa1 = ixa/l2_com
      ixa2 = MOD(ixa,l2_com)
      IF( Ix>0 ) THEN
        !
        DO WHILE( xa>=1._DP )
          xa = xa/rad2l_com
          ixa1 = ixa1 + 1
        END DO
        xa = xa*radixx_com**ixa2
        IF( ixa1/=0 ) THEN
          DO i = 1, ixa1
            IF( xa>1._DP ) RETURN
            xa = xa*rad2l_com
          END DO
        END IF
      ELSE
        DO WHILE( xa<=1._DP )
          xa = xa*rad2l_com
          ixa1 = ixa1 + 1
        END DO
        xa = xa/radixx_com**ixa2
        IF( ixa1/=0 ) THEN
          DO i = 1, ixa1
            IF( xa<1._DP ) RETURN
            xa = xa/rad2l_com
          END DO
        END IF
      END IF
    END IF
    IF( xa<=rad2l_com ) THEN
      IF( xa>1._DP ) THEN
        X = SIGN(xa,X)
        Ix = 0
      ELSEIF( rad2l_com*xa>=1._DP ) THEN
        X = SIGN(xa,X)
        Ix = 0
      END IF
    END IF
  END IF
  RETURN
END SUBROUTINE DXRED
