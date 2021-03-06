!** XADD
SUBROUTINE XADD(X,Ix,Y,Iy,Z,Iz,Ierror)
  !> To provide single-precision floating-point arithmetic
  !            with an extended exponent range.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  A3D
  !***
  ! **Type:**      SINGLE PRECISION (XADD-S, DXADD-D)
  !***
  ! **Keywords:**  EXTENDED-RANGE SINGLE-PRECISION ARITHMETIC
  !***
  ! **Author:**  Lozier, Daniel W., (National Bureau of Standards)
  !           Smith, John M., (NBS and George Mason University)
  !***
  ! **Description:**
  !     REAL X, Y, Z
  !     INTEGER IX, IY, IZ
  !
  !                  FORMS THE EXTENDED-RANGE SUM  (Z,IZ) =
  !                  (X,IX) + (Y,IY).  (Z,IZ) IS ADJUSTED
  !                  BEFORE RETURNING. THE INPUT OPERANDS
  !                  NEED NOT BE IN ADJUSTED FORM, BUT THEIR
  !                  PRINCIPAL PARTS MUST SATISFY
  !                  RADIX**(-2L)<=ABS(X)<=RADIX**(2L),
  !                  RADIX**(-2L)<=ABS(Y)<=RADIX**(2L).
  !
  !***
  ! **See also:**  XSET
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  XADJ
  !***
  ! COMMON BLOCKS    XBLK2

  !* REVISION HISTORY  (YYMMDD)
  !   820712  DATE WRITTEN
  !   881020  Revised to meet SLATEC CML recommendations.  (DWL and JMS)
  !   901019  Revisions to prologue.  (DWL and WRB)
  !   901106  Changed all specific intrinsics to generic.  (WRB)
  !           Corrected order of sections in prologue and added TYPE
  !           section.  (WRB)
  !   920127  Revised PURPOSE section of prologue.  (DWL)
  USE XBLK ,ONLY: radixx_com, radixl_com, rad2l_com, l_com
  INTEGER :: Ierror, Ix, Iy, Iz
  REAL(SP) :: X, Y, Z
  INTEGER :: i, i1, i2, is, j
  REAL(SP) :: s, t
  !
  !
  !   THE CONDITIONS IMPOSED ON L AND KMAX BY THIS SUBROUTINE
  ! ARE
  !     (1) 1 < L <= 0.5*LOGR(0.5*DZERO)
  !
  !     (2) NRADPL < L <= KMAX/6
  !
  !     (3) KMAX <= (2**NBITS - 4*L - 1)/2
  !
  ! THESE CONDITIONS MUST BE MET BY APPROPRIATE CODING
  ! IN SUBROUTINE XSET.
  !
  !* FIRST EXECUTABLE STATEMENT  XADD
  Ierror = 0
  IF( X==0._SP ) THEN
    Z = Y
    Iz = Iy
    CALL XADJ(Z,Iz,Ierror)
    RETURN
  ELSEIF( Y/=0._SP ) THEN
    IF( Ix<0 .OR. Iy<0 ) THEN
      IF( Ix>=0 .OR. Iy>=0 ) THEN
        IF( ABS(Ix)>6*l_com .OR. ABS(Iy)>6*l_com ) THEN
          IF( Ix>=0 ) THEN
            Z = X
            Iz = Ix
          ELSE
            Z = Y
            Iz = Iy
          END IF
          CALL XADJ(Z,Iz,Ierror)
          RETURN
        END IF
      END IF
    END IF
    i = Ix - Iy
    IF( i<0 ) THEN
      s = Y
      is = Iy
      t = X
    ELSEIF( i==0 ) THEN
      IF( ABS(X)>1._SP .AND. ABS(Y)>1._SP ) THEN
        s = X/radixl_com
        t = Y/radixl_com
        Z = s + t
        Iz = Ix + l_com
      ELSEIF( ABS(X)<1._SP .AND. ABS(Y)<1._SP ) THEN
        s = X*radixl_com
        t = Y*radixl_com
        Z = s + t
        Iz = Ix - l_com
      ELSE
        Z = X + Y
        Iz = Ix
      END IF
      CALL XADJ(Z,Iz,Ierror)
      RETURN
    ELSE
      s = X
      is = Ix
      t = Y
    END IF
    !
    !  AT THIS POINT, THE ONE OF (X,IX) OR (Y,IY) THAT HAS THE
    ! LARGER AUXILIARY INDEX IS STORED IN (S,IS). THE PRINCIPAL
    ! PART OF THE OTHER INPUT IS STORED IN T.
    !
    i1 = ABS(i)/l_com
    i2 = MOD(ABS(i),l_com)
    IF( ABS(t)>=radixl_com ) THEN
      j = i1 - 2
      IF( j<0 ) GOTO 200
      t = t*radixx_com**(-i2)/rad2l_com
      GOTO 300
    ELSE
      IF( ABS(t)>=1._SP ) GOTO 200
      IF( radixl_com*ABS(t)<1._SP ) THEN
        j = i1 + 1
        t = t*radixx_com**(l_com-i2)
        GOTO 300
      END IF
    END IF
  ELSE
    Z = X
    Iz = Ix
    CALL XADJ(Z,Iz,Ierror)
    RETURN
  END IF
  100  j = i1
  t = t*radixx_com**(-i2)
  GOTO 300
  200  j = i1 - 1
  IF( j<0 ) GOTO 100
  t = t*radixx_com**(-i2)/radixl_com
  !
  !  AT THIS POINT, SOME OR ALL OF THE DIFFERENCE IN THE
  ! AUXILIARY INDICES HAS BEEN USED TO EFFECT A LEFT SHIFT
  ! OF T.  THE SHIFTED VALUE OF T SATISFIES
  !
  !       RADIX**(-2*L) <= ABS(T) <= 1.0
  !
  ! AND, IF J=0, NO FURTHER SHIFTING REMAINS TO BE DONE.
  !
  300 CONTINUE
  IF( j/=0 ) THEN
    IF( ABS(s)<radixl_com .AND. j<=3 ) THEN
      IF( ABS(s)>=1._SP ) THEN
        SELECT CASE (j)
          CASE (1)
            s = s*radixl_com
            GOTO 400
          CASE (2,3)
            GOTO 350
          CASE DEFAULT
        END SELECT
      END IF
      IF( radixl_com*ABS(s)>=1._SP ) THEN
        SELECT CASE (j)
          CASE (1)
            s = s*radixl_com
          CASE (2)
            s = s*radixl_com
            s = s*radixl_com
          CASE (3)
            GOTO 350
          CASE DEFAULT
            GOTO 320
        END SELECT
        GOTO 400
      END IF
      320 CONTINUE
      SELECT CASE (j)
        CASE (1)
          s = s*radixl_com
          GOTO 400
        CASE (2)
        CASE (3)
          s = s*radixl_com
        CASE DEFAULT
          GOTO 350
      END SELECT
      s = s*radixl_com
      s = s*radixl_com
      GOTO 400
    END IF
    350  Z = s
    Iz = is
    CALL XADJ(Z,Iz,Ierror)
    RETURN
  END IF
  !
  !   AT THIS POINT, THE REMAINING DIFFERENCE IN THE
  ! AUXILIARY INDICES HAS BEEN USED TO EFFECT A RIGHT SHIFT
  ! OF S.  IF THE SHIFTED VALUE OF S WOULD HAVE EXCEEDED
  ! RADIX**L, THEN (S,IS) IS RETURNED AS THE VALUE OF THE
  ! SUM.
  !
  400 CONTINUE
  IF( ABS(s)>1._SP .AND. ABS(t)>1._SP ) THEN
    s = s/radixl_com
    t = t/radixl_com
    Z = s + t
    Iz = is - j*l_com + l_com
  ELSEIF( ABS(s)<1._SP .AND. ABS(t)<1._SP ) THEN
    s = s*radixl_com
    t = t*radixl_com
    Z = s + t
    Iz = is - j*l_com - l_com
  ELSE
    Z = s + t
    Iz = is - j*l_com
  END IF
  CALL XADJ(Z,Iz,Ierror)
  RETURN
END SUBROUTINE XADD
