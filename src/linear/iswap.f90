!** ISWAP
PURE SUBROUTINE ISWAP(N,Ix,Incx,Iy,Incy)
  !> Interchange two vectors.
  !***
  ! **Library:**   SLATEC (BLAS)
  !***
  ! **Category:**  D1A5
  !***
  ! **Type:**      INTEGER (SSWAP-S, DSWAP-D, CSWAP-C, ISWAP-I)
  !***
  ! **Keywords:**  BLAS, INTERCHANGE, LINEAR ALGEBRA, VECTOR
  !***
  ! **Author:**  Vandevender, W. H., (SNLA)
  !***
  ! **Description:**
  !
  !                Extended B L A S  Subprogram
  !    Description of Parameters
  !
  !     --Input--
  !        N  number of elements in input vector(s)
  !       IX  integer vector with N elements
  !     INCX  storage spacing between elements of IX
  !       IY  integer vector with N elements
  !     INCY  storage spacing between elements of IY
  !
  !     --Output--
  !       IX  input vector IY (unchanged if N <= 0)
  !       IY  input vector IX (unchanged if N <= 0)
  !
  !     Interchange integer IX and integer IY.
  !     For I = 0 to N-1, interchange  IX(LX+I*INCX) and IY(LY+I*INCY),
  !     where LX = 1 if INCX >= 0, else LX = 1+(1-N)*INCX, and LY is
  !     defined in a similar way using INCY.
  !
  !***
  ! **References:**  C. L. Lawson, R. J. Hanson, D. R. Kincaid and F. T.
  !                 Krogh, Basic linear algebra subprograms for Fortran
  !                 usage, Algorithm No. 539, Transactions on Mathematical
  !                 Software 5, 3 (September 1979), pp. 308-323.
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   850601  DATE WRITTEN
  !   861211  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920310  Corrected definition of LX in DESCRIPTION.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: Incx, Incy, N
  INTEGER, INTENT(INOUT) :: Ix(N), Iy(N)
  INTEGER :: i, iix, iiy, m, mp1, ns, itemp1, itemp2, itemp3
  !* FIRST EXECUTABLE STATEMENT  ISWAP
  IF( N<=0 ) RETURN
  IF( Incx==Incy ) THEN
    IF( Incx<1 ) THEN
    ELSEIF( Incx==1 ) THEN
      !
      !     Code for both increments equal to 1.
      !
      !     Clean-up loop so remaining vector length is a multiple of 3.
      !
      m = MOD(N,3)
      IF( m/=0 ) THEN
        DO i = 1, m
          itemp1 = Ix(i)
          Ix(i) = Iy(i)
          Iy(i) = itemp1
        END DO
        IF( N<3 ) RETURN
      END IF
      GOTO 100
    ELSE
      !
      !     Code for equal, positive, non-unit increments.
      !
      ns = N*Incx
      DO i = 1, ns, Incx
        itemp1 = Ix(i)
        Ix(i) = Iy(i)
        Iy(i) = itemp1
      END DO
      RETURN
    END IF
  END IF
  !
  !     Code for unequal or nonpositive increments.
  !
  iix = 1
  iiy = 1
  IF( Incx<0 ) iix = (1-N)*Incx + 1
  IF( Incy<0 ) iiy = (1-N)*Incy + 1
  DO i = 1, N
    itemp1 = Ix(iix)
    Ix(iix) = Iy(iiy)
    Iy(iiy) = itemp1
    iix = iix + Incx
    iiy = iiy + Incy
  END DO
  RETURN
  100  mp1 = m + 1
  DO i = mp1, N, 3
    itemp1 = Ix(i)
    itemp2 = Ix(i+1)
    itemp3 = Ix(i+2)
    Ix(i) = Iy(i)
    Ix(i+1) = Iy(i+1)
    Ix(i+2) = Iy(i+2)
    Iy(i) = itemp1
    Iy(i+1) = itemp2
    Iy(i+2) = itemp3
  END DO

  RETURN
END SUBROUTINE ISWAP