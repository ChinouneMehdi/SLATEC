!** DXC210
SUBROUTINE DXC210(K,Z,J,Ierror)
  !> To provide double-precision floating-point arithmetic
  !            with an extended exponent range.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  A3D
  !***
  ! **Type:**      DOUBLE PRECISION (XC210-S, DXC210-D)
  !***
  ! **Keywords:**  EXTENDED-RANGE DOUBLE-PRECISION ARITHMETIC
  !***
  ! **Author:**  Lozier, Daniel W., (National Bureau of Standards)
  !           Smith, John M., (NBS and George Mason University)
  !***
  ! **Description:**
  !     INTEGER K, J
  !     DOUBLE PRECISION Z
  !
  !                  GIVEN K THIS SUBROUTINE COMPUTES J AND Z
  !                  SUCH THAT  RADIX**K = Z*10**J, WHERE Z IS IN
  !                  THE RANGE 1/10 <= Z < 1.
  !                  THE VALUE OF Z WILL BE ACCURATE TO FULL
  !                  DOUBLE-PRECISION PROVIDED THE NUMBER
  !                  OF DECIMAL PLACES IN THE LARGEST
  !                  INTEGER PLUS THE NUMBER OF DECIMAL
  !                  PLACES CARRIED IN DOUBLE-PRECISION DOES NOT
  !                  EXCEED 60. DXC210 IS CALLED BY SUBROUTINE
  !                  DXCON WHEN NECESSARY. THE USER SHOULD
  !                  NEVER NEED TO CALL DXC210 DIRECTLY.
  !
  !***
  ! **See also:**  DXSET
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  XERMSG
  !***
  ! COMMON BLOCKS    DXBLK3

  !* REVISION HISTORY  (YYMMDD)
  !   820712  DATE WRITTEN
  !   890126  Revised to meet SLATEC CML recommendations.  (DWL and JMS)
  !   901019  Revisions to prologue.  (DWL and WRB)
  !   901106  Changed all specific intrinsics to generic.  (WRB)
  !           Corrected order of sections in prologue and added TYPE
  !           section.  (WRB)
  !           CALLs to XERROR changed to CALLs to XERMSG.  (WRB)
  !   920127  Revised PURPOSE section of prologue.  (DWL)
  USE DXBLK ,ONLY: nlg102_com, mlg102_com, lg102_com

  INTEGER :: Ierror, K, J
  REAL(DP) :: Z
  INTEGER :: i, ic, id, ii, it, ja, ka, ka1, ka2, m, nm1, np1
  !
  !   THE CONDITIONS IMPOSED ON NLG102, MLG102, AND LG102 BY
  ! THIS SUBROUTINE ARE
  !
  !     (1) NLG102 >= 2
  !
  !     (2) MLG102 >= 1
  !
  !     (3) 2*MLG102*(MLG102 - 1) <= 2**NBITS - 1
  !
  ! THESE CONDITIONS MUST BE MET BY APPROPRIATE CODING
  ! IN SUBROUTINE DXSET.
  !
  !* FIRST EXECUTABLE STATEMENT  DXC210
  Ierror = 0
  IF( K==0 ) THEN
    J = 0
    Z = 1._DP
    RETURN
  ELSE
    m = mlg102_com
    ka = ABS(K)
    ka1 = ka/m
    ka2 = MOD(ka,m)
    IF( ka1<m ) THEN
      nm1 = nlg102_com - 1
      np1 = nlg102_com + 1
      it = ka2*lg102_com(np1)
      ic = it/m
      id = MOD(it,m)
      Z = id
      IF( ka1>0 ) THEN
        DO ii = 1, nm1
          i = np1 - ii
          it = ka2*lg102_com(i) + ka1*lg102_com(i+1) + ic
          ic = it/m
          id = MOD(it,m)
          Z = Z/m + id
        END DO
        ja = ka*lg102_com(1) + ka1*lg102_com(2) + ic
      ELSE
        DO ii = 1, nm1
          i = np1 - ii
          it = ka2*lg102_com(i) + ic
          ic = it/m
          id = MOD(it,m)
          Z = Z/m + id
        END DO
        ja = ka*lg102_com(1) + ic
      END IF
      Z = Z/m
      IF( K>0 ) THEN
        J = ja + 1
        Z = 10._DP**(Z-1._DP)
      ELSE
        J = -ja
        Z = 10._DP**(-Z)
      END IF
      RETURN
    END IF
  END IF
  !   THIS ERROR OCCURS IF K EXCEEDS  MLG102**2 - 1  IN MAGNITUDE.
  !
  ERROR STOP 'DXC210 : K too large'
  Ierror = 208
  RETURN
END SUBROUTINE DXC210
