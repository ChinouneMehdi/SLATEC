!** CFFTI1
PURE SUBROUTINE CFFTI1(N,Wa,Ifac)
  !> Initialize a real and an integer work array for CFFTF1 and CFFTB1.
  !***
  ! **Library:**   SLATEC (FFTPACK)
  !***
  ! **Category:**  J1A2
  !***
  ! **Type:**      COMPLEX (RFFTI1-S, CFFTI1-C)
  !***
  ! **Keywords:**  FFTPACK, FOURIER TRANSFORM
  !***
  ! **Author:**  Swarztrauber, P. N., (NCAR)
  !***
  ! **Description:**
  !
  !  Subroutine CFFTI1 initializes the work arrays WA and IFAC which are
  !  used in both CFFTF1 and CFFTB1.  The prime factorization of N and a
  !  tabulation of the trigonometric functions are computed and stored in
  !  IFAC and WA, respectively.
  !
  !  Input Parameter
  !
  !  N       the length of the sequence to be transformed
  !
  !  Output Parameters
  !
  !  WA      a real work array which must be dimensioned at least 2*N.
  !
  !  IFAC    an integer work array which must be dimensioned at least 15.
  !
  !          The same work arrays can be used for both CFFTF1 and CFFTB1
  !          as long as N remains unchanged.  Different WA and IFAC arrays
  !          are required for different values of N.  The contents of
  !          WA and IFAC must not be changed between calls of CFFTF1 or
  !          CFFTB1.
  !
  !***
  ! **References:**  P. N. Swarztrauber, Vectorizing the FFTs, in Parallel
  !                 Computations (G. Rodrigue, ed.), Academic Press,
  !                 1982, pp. 51-83.
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   790601  DATE WRITTEN
  !   830401  Modified to use SLATEC library source file format.
  !   860115  Modified by Ron Boisvert to adhere to Fortran 77 by
  !           (a) changing dummy array size declarations (1) to (*),
  !           (b) changing references to intrinsic function FLOAT to REAL(SP), and
  !           (c) changing definition of variable TPI by using
  !               FORTRAN intrinsic function ATAN instead of a DATA statement.
  !   881128  Modified by Dick Valent to meet prologue standards.
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900131  Routine changed from subsidiary to user-callable.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: N
  INTEGER, INTENT(OUT) :: Ifac(15)
  REAL(SP), INTENT(OUT) :: Wa(2*N)
  REAL(SP) :: arg, argh, argld, fi, tpi
  INTEGER :: i, i1, ib, ido, idot, ii, ip, ipm, j, k1, l1, l2, ld, nf, nl, nq, nr, ntry
  INTEGER, PARAMETER :: ntryh(4) = [ 3, 4, 2, 5 ]
  !* FIRST EXECUTABLE STATEMENT  CFFTI1
  nl = N
  nf = 0
  j = 0
  100  j = j + 1
  IF( j<=4 ) THEN
    ntry = ntryh(j)
  ELSE
    ntry = ntry + 2
  END IF
  DO
    nq = nl/ntry
    nr = nl - ntry*nq
    IF( nr/=0 ) GOTO 100
    nf = nf + 1
    Ifac(nf+2) = ntry
    nl = nq
    IF( ntry==2 ) THEN
      IF( nf/=1 ) THEN
        DO i = 2, nf
          ib = nf - i + 2
          Ifac(ib+2) = Ifac(ib+1)
        END DO
        Ifac(3) = 2
      END IF
    END IF
    IF( nl==1 ) THEN
      Ifac(1) = N
      Ifac(2) = nf
      tpi = 8._SP*ATAN(1._SP)
      argh = tpi/N
      i = 2
      l1 = 1
      DO k1 = 1, nf
        ip = Ifac(k1+2)
        ld = 0
        l2 = l1*ip
        ido = N/l2
        idot = ido + ido + 2
        ipm = ip - 1
        DO j = 1, ipm
          i1 = i
          Wa(i-1) = 1._SP
          Wa(i) = 0._SP
          ld = ld + l1
          fi = 0._SP
          argld = ld*argh
          DO ii = 4, idot, 2
            i = i + 2
            fi = fi + 1._SP
            arg = fi*argld
            Wa(i-1) = COS(arg)
            Wa(i) = SIN(arg)
          END DO
          IF( ip>5 ) THEN
            Wa(i1-1) = Wa(i-1)
            Wa(i1) = Wa(i)
          END IF
        END DO
        l1 = l2
      END DO
      EXIT
    END IF
  END DO

END SUBROUTINE CFFTI1