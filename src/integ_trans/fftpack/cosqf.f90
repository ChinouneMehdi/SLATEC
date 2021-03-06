!** COSQF
PURE SUBROUTINE COSQF(N,X,Wsave)
  !> Compute the forward cosine transform with odd wave numbers.
  !***
  ! **Library:**   SLATEC (FFTPACK)
  !***
  ! **Category:**  J1A3
  !***
  ! **Type:**      SINGLE PRECISION (COSQF-S)
  !***
  ! **Keywords:**  COSINE FOURIER TRANSFORM, FFTPACK
  !***
  ! **Author:**  Swarztrauber, P. N., (NCAR)
  !***
  ! **Description:**
  !
  !  Subroutine COSQF computes the fast Fourier transform of quarter
  !  wave data. That is, COSQF computes the coefficients in a cosine
  !  series representation with only odd wave numbers.  The transform
  !  is defined below at Output Parameter X
  !
  !  COSQF is the unnormalized inverse of COSQB since a call of COSQF
  !  followed by a call of COSQB will multiply the input sequence X by 4*N.
  !
  !  The array WSAVE which is used by subroutine COSQF must be
  !  initialized by calling subroutine COSQI(N,WSAVE).
  !
  !
  !  Input Parameters
  !
  !  N       the length of the array X to be transformed.  The method
  !          is most efficient when N is a product of small primes.
  !
  !  X       an array which contains the sequence to be transformed
  !
  !  WSAVE   a work array which must be dimensioned at least 3*N+15
  !          in the program that calls COSQF.  The WSAVE array must be
  !          initialized by calling subroutine COSQI(N,WSAVE), and a
  !          different WSAVE array must be used for each different
  !          value of N.  This initialization does not have to be
  !          repeated so long as N remains unchanged.  Thus subsequent
  !          transforms can be obtained faster than the first.
  !
  !  Output Parameters
  !
  !  X       For I=1,...,N
  !
  !               X(I) = X(1) plus the sum from K=2 to K=N of
  !
  !                  2*X(K)*COS((2*I-1)*(K-1)*PI/(2*N))
  !
  !               A call of COSQF followed by a call of
  !               COSQB will multiply the sequence X by 4*N.
  !               Therefore COSQB is the unnormalized inverse
  !               of COSQF.
  !
  !  WSAVE   contains initialization calculations which must not
  !          be destroyed between calls of COSQF or COSQB.
  !
  !***
  ! **References:**  P. N. Swarztrauber, Vectorizing the FFTs, in Parallel
  !                 Computations (G. Rodrigue, ed.), Academic Press,
  !                 1982, pp. 51-83.
  !***
  ! **Routines called:**  COSQF1

  !* REVISION HISTORY  (YYMMDD)
  !   790601  DATE WRITTEN
  !   830401  Modified to use SLATEC library source file format.
  !   860115  Modified by Ron Boisvert to adhere to Fortran 77 by
  !           (a) changing dummy array size declarations (1) to (*),
  !           (b) changing definition of variable SQRT2 by using
  !               FORTRAN intrinsic function SQRT instead of a DATA statement.
  !   861211  REVISION DATE from Version 3.2
  !   881128  Modified by Dick Valent to meet prologue standards.
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: N
  REAL(SP), INTENT(INOUT) :: Wsave(3*N+15), X(N)
  REAL(SP) :: sqrt2, tsqx
  !* FIRST EXECUTABLE STATEMENT  COSQF
  sqrt2 = SQRT(2._SP)
  IF( N<2 ) THEN
  ELSEIF( N==2 ) THEN
    tsqx = sqrt2*X(2)
    X(2) = X(1) - tsqx
    X(1) = X(1) + tsqx
  ELSE
    CALL COSQF1(N,X,Wsave,Wsave(N+1))
    RETURN
  END IF

  RETURN
END SUBROUTINE COSQF