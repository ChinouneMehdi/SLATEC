!** MPADD2
SUBROUTINE MPADD2(X,Y,Z,Y1,Trunc)
  !> Subsidiary to DQDOTA and DQDOTI
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (MPADD2-A)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !  Called by MPADD, MPSUB etc.
  !  X, Y and Z are MP numbers, Y1 and TRUNC are integers.
  !  To force call by reference rather than value/result, Y1 is
  !  declared as an array, but only Y1(1) is ever used.
  !  Sets Z = X + Y1(1)*ABS(Y), where Y1(1) = +- Y(1).
  !  If TRUNC = 0, R*-rounding is used;  otherwise, truncation.
  !  R*-rounding is defined in the Kuki and Cody reference.
  !
  !  The arguments X(*), Y(*), and Z(*) are all INTEGER arrays of size
  !  30.  See the comments in the routine MPBLAS for the reason for this
  !  choice.
  !
  !***
  ! **See also:**  DQDOTA, DQDOTI, MPBLAS
  !***
  ! **References:**  H. Kuki and W. J. Cody, A statistical study of floating
  !                 point number systems, Communications of the ACM 16, 4
  !                 (April 1973), pp. 223-230.
  !               R. P. Brent, On the precision attainable with various
  !                 floating-point number systems, IEEE Transactions on
  !                 Computers C-22, 6 (June 1973), pp. 601-607.
  !               R. P. Brent, A Fortran multiple-precision arithmetic
  !                 package, ACM Transactions on Mathematical Software 4,
  !                 1 (March 1978), pp. 57-70.
  !               R. P. Brent, MP, a Fortran multiple-precision arithmetic
  !                 package, Algorithm 524, ACM Transactions on Mathema-
  !                 tical Software 4, 1 (March 1978), pp. 71-81.
  !***
  ! **Routines called:**  MPADD3, MPCHK, MPERR, MPNZR, MPSTR
  !***
  ! COMMON BLOCKS    MPCOM

  !* REVISION HISTORY  (YYMMDD)
  !   791001  DATE WRITTEN
  !   ??????  Modified for use with BLAS.  Blank COMMON changed to named
  !           COMMON.  R given dimension 12.
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  !   920528  Added a REFERENCES section revised.  (WRB)
  !   930124  Increased Array size in MPCON for SUN -r8.  (RWC)
  USE MPCOM, ONLY : t_com, mxr_com

  INTEGER, INTENT(IN) :: Trunc
  INTEGER, INTENT(IN) :: X(mxr_com), Y(mxr_com), Y1(mxr_com)
  INTEGER, INTENT(OUT) :: Z(mxr_com)
  INTEGER :: j, med, s, ed, rs, re
  !* FIRST EXECUTABLE STATEMENT  MPADD2
  IF( X(1)/=0 ) THEN
    IF( Y1(1)==0 ) GOTO 100
    ! COMPARE SIGNS
    s = X(1)*Y1(1)
    IF( ABS(s)<=1 ) THEN
      ! COMPARE EXPONENTS
      ed = X(2) - Y(2)
      med = ABS(ed)
      IF( ed<0 ) THEN
        ! HERE EXPONENT(Y) >= EXPONENT(X)
        IF( med<=t_com ) GOTO 200
      ELSEIF( ed==0 ) THEN
        ! EXPONENTS EQUAL SO COMPARE SIGNS, THEN FRACTIONS IF NEC.
        IF( s>0 ) GOTO 200
        DO j = 1, t_com
          IF( X(j+2)<Y(j+2) ) GOTO 200
          IF( X(j+2)/=Y(j+2) ) GOTO 400
        END DO
        ! RESULT IS ZERO
        Z(1) = 0
        RETURN
      ELSE
        ! ABS(X) > ABS(Y)
        IF( med<=t_com ) GOTO 400
        GOTO 100
      END IF
    ELSE
      ERROR STOP ' *** SIGN NOT 0, +1 OR -1 IN CALL TO MPADD2, POSSIBLE OVERWRITING PROBLEM ***'
      Z(1) = 0
      RETURN
    END IF
  END IF
  CALL MPSTR(Y,Z)
  Z(1) = Y1(1)
  RETURN
  100  CALL MPSTR(X,Z)
  RETURN
  200  rs = Y1(1)
  re = Y(2)
  CALL MPADD3(X,Y,s,med,re)
  ! NORMALIZE, ROUND OR TRUNCATE, AND RETURN
  300  CALL MPNZR(rs,re,Z,Trunc)
  RETURN
  400  rs = X(1)
  re = X(2)
  CALL MPADD3(Y,X,s,med,re)
  GOTO 300

END SUBROUTINE MPADD2