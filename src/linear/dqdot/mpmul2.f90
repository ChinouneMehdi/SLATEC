!** MPMUL2
SUBROUTINE MPMUL2(X,Iy,Z,Trunc)
  !> Subsidiary to DQDOTA and DQDOTI
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (MPMUL2-A)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !  Multiplies 'mp' X by single-precision integer IY giving 'mp' Z.
  !  Multiplication by 1 may be used to normalize a number even if some
  !  digits are greater than B-1. Result is rounded if TRUNC=0,
  !  otherwise truncated.
  !
  !  The arguments X(*) and Z(*), and the variable R in COMMON are all
  !  INTEGER arrays of size 30.  See the comments in the routine MPBLAS
  !  for the reason for this choice.
  !
  !***
  ! **See also:**  DQDOTA, DQDOTI, MPBLAS
  !***
  ! **Routines called:**  MPCHK, MPERR, MPNZR, MPOVFL, MPSTR
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
  USE MPCOM, ONLY : b_com, lun_com, m_com, t_com, r_com, mxr_com

  INTEGER, INTENT(IN) :: Iy, Trunc
  INTEGER, INTENT(IN) :: X(mxr_com)
  INTEGER, INTENT(INOUT) :: Z(mxr_com)
  INTEGER :: i, ij, is, ix, j, j1, j2, re, rs, c, c1, c2, ri, t1, t3, t4
  !* FIRST EXECUTABLE STATEMENT  MPMUL2
  rs = X(1)
  IF( rs/=0 ) THEN
    j = Iy
    IF( j<0 ) THEN
      j = -j
      rs = -rs
      ! CHECK FOR MULTIPLICATION BY B
      IF( j/=b_com ) GOTO 200
      IF( X(2)<m_com ) THEN
        CALL MPSTR(X,Z)
        Z(1) = rs
        Z(2) = X(2) + 1
        RETURN
      ELSE
        WRITE (lun_com,99001)
        99001 FORMAT (' *** OVERFLOW OCCURRED IN MPMUL2 ***')
        CALL MPOVFL(Z)
        RETURN
      END IF
    ELSEIF( j/=0 ) THEN
      GOTO 200
    END IF
  END IF
  ! RESULT ZERO
  100  Z(1) = 0
  RETURN
  ! SET EXPONENT TO EXPONENT(X) + 4
  200  re = X(2) + 4
  ! FORM PRODUCT IN ACCUMULATOR
  c = 0
  t1 = t_com + 1
  t3 = t_com + 3
  t4 = t_com + 4
  ! IF J*B NOT REPRESENTABLE AS AN INTEGER WE HAVE TO SIMULATE
  ! DOUBLE-PRECISION MULTIPLICATION.
  IF( j>=MAX(8*b_com,32767/b_com) ) THEN
    ! HERE J IS TOO LARGE FOR SINGLE-PRECISION MULTIPLICATION
    j1 = j/b_com
    j2 = j - j1*b_com
    ! FORM PRODUCT
    DO ij = 1, t4
      c1 = c/b_com
      c2 = c - b_com*c1
      i = t1 - ij
      ix = 0
      IF( i>0 ) ix = X(i+2)
      ri = j2*ix + c2
      is = ri/b_com
      c = j1*ix + c1 + is
      r_com(i+4) = ri - b_com*is
    END DO
    IF( c<0 ) GOTO 400
    IF( c==0 ) GOTO 300
  ELSE
    DO ij = 1, t_com
      i = t1 - ij
      ri = j*X(i+2) + c
      c = ri/b_com
      r_com(i+4) = ri - b_com*c
    END DO
    ! CHECK FOR INTEGER OVERFLOW
    IF( ri<0 ) GOTO 400
    ! HAVE TO TREAT FIRST FOUR WORDS OF R SEPARATELY
    DO ij = 1, 4
      i = 5 - ij
      ri = c
      c = ri/b_com
      r_com(i) = ri - b_com*c
    END DO
    IF( c==0 ) GOTO 300
  END IF
  DO
    ! HAVE TO SHIFT RIGHT HERE AS CARRY OFF END
    DO ij = 1, t3
      i = t4 - ij
      r_com(i+1) = r_com(i)
    END DO
    ri = c
    c = ri/b_com
    r_com(1) = ri - b_com*c
    re = re + 1
    IF( c<0 ) GOTO 400
    IF( c==0 ) EXIT
  END DO
  ! NORMALIZE AND ROUND OR TRUNCATE RESULT
  300  CALL MPNZR(rs,re,Z,Trunc)
  RETURN
  ! CAN ONLY GET HERE IF INTEGER OVERFLOW OCCURRED
  400 ERROR STOP ' *** INTEGER OVERFLOW IN MPMUL2, b_com TOO LARGE ***'
  GOTO 100

END SUBROUTINE MPMUL2