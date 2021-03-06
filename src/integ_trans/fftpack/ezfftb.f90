!** EZFFTB
PURE SUBROUTINE EZFFTB(N,R,Azero,A,B,Wsave)
  !> A simplified REAL(SP), periodic, backward fast Fourier transform.
  !***
  ! **Library:**   SLATEC (FFTPACK)
  !***
  ! **Category:**  J1A1
  !***
  ! **Type:**      SINGLE PRECISION (EZFFTB-S)
  !***
  ! **Keywords:**  FFTPACK, FOURIER TRANSFORM
  !***
  ! **Author:**  Swarztrauber, P. N., (NCAR)
  !***
  ! **Description:**
  !
  !  Subroutine EZFFTB computes a real periodic sequence from its
  !  Fourier coefficients (Fourier synthesis).  The transform is
  !  defined below at Output Parameter R.  EZFFTB is a simplified
  !  but slower version of RFFTB.
  !
  !  Input Parameters
  !
  !  N       the length of the output array R.  The method is most
  !          efficient when N is the product of small primes.
  !
  !  AZERO   the constant Fourier coefficient
  !
  !  A,B     arrays which contain the remaining Fourier coefficients.
  !          These arrays are not destroyed.
  !
  !          The length of these arrays depends on whether N is even or
  !          odd.
  !
  !          If N is even, N/2    locations are required.
  !          If N is odd, (N-1)/2 locations are required
  !
  !  WSAVE   a work array which must be dimensioned at least 3*N+15
  !          in the program that calls EZFFTB.  The WSAVE array must be
  !          initialized by calling subroutine EZFFTI(N,WSAVE), and a
  !          different WSAVE array must be used for each different
  !          value of N.  This initialization does not have to be
  !          repeated so long as N remains unchanged.  Thus subsequent
  !          transforms can be obtained faster than the first.
  !          The same WSAVE array can be used by EZFFTF and EZFFTB.
  !
  !  Output Parameters
  !
  !  R       if N is even, define KMAX=N/2
  !          if N is odd,  define KMAX=(N-1)/2
  !
  !          Then for I=1,...,N
  !
  !               R(I)=AZERO plus the sum from K=1 to K=KMAX of
  !
  !               A(K)*COS(K*(I-1)*2*PI/N)+B(K)*SIN(K*(I-1)*2*PI/N)
  !
  !  ********************* Complex Notation **************************
  !
  !          For J=1,...,N
  !
  !          R(J) equals the sum from K=-KMAX to K=KMAX of
  !
  !               C(K)*EXP(I*K*(J-1)*2*PI/N)
  !
  !          where
  !
  !               C(K) = .5*CMPLX(A(K),-B(K))   for K=1,...,KMAX
  !
  !               C(-K) = CONJG(C(K))
  !
  !               C(0) = AZERO
  !
  !                    and I=SQRT(-1)
  !
  !  *************** Amplitude - Phase Notation ***********************
  !
  !          For I=1,...,N
  !
  !          R(I) equals AZERO plus the sum from K=1 to K=KMAX of
  !
  !               ALPHA(K)*COS(K*(I-1)*2*PI/N+BETA(K))
  !
  !          where
  !
  !               ALPHA(K) = SQRT(A(K)*A(K)+B(K)*B(K))
  !
  !               COS(BETA(K))=A(K)/ALPHA(K)
  !
  !               SIN(BETA(K))=-B(K)/ALPHA(K)
  !
  !***
  ! **References:**  P. N. Swarztrauber, Vectorizing the FFTs, in Parallel
  !                 Computations (G. Rodrigue, ed.), Academic Press,
  !                 1982, pp. 51-83.
  !***
  ! **Routines called:**  RFFTB

  !* REVISION HISTORY  (YYMMDD)
  !   790601  DATE WRITTEN
  !   830401  Modified to use SLATEC library source file format.
  !   860115  Modified by Ron Boisvert to adhere to Fortran 77 by
  !           changing dummy array size declarations (1) to (*)
  !   861211  REVISION DATE from Version 3.2
  !   881128  Modified by Dick Valent to meet prologue standards.
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: N
  REAL(SP), INTENT(IN) :: A(N/2), Azero, B(N/2)
  REAL(SP), INTENT(INOUT) :: Wsave(3*N+15)
  REAL(SP), INTENT(OUT) :: R(N)
  INTEGER :: i, ns2
  !* FIRST EXECUTABLE STATEMENT  EZFFTB
  IF( N<2 ) THEN
    R(1) = Azero
    RETURN
  ELSEIF( N==2 ) THEN
    R(1) = Azero + A(1)
    R(2) = Azero - A(1)
    RETURN
  ELSE
    ns2 = (N-1)/2
    DO i = 1, ns2
      R(2*i) = 0.5_SP*A(i)
      R(2*i+1) = -0.5_SP*B(i)
    END DO
    R(1) = Azero
    IF( MOD(N,2)==0 ) R(N) = A(ns2+1)
    CALL RFFTB(N,R,Wsave(N+1))
  END IF

END SUBROUTINE EZFFTB