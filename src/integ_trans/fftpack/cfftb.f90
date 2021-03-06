!** CFFTB
PURE SUBROUTINE CFFTB(N,C,Wsave)
  !> Compute the unnormalized inverse of CFFTF.
  !***
  ! **Library:**   SLATEC (FFTPACK)
  !***
  ! **Category:**  J1A2
  !***
  ! **Type:**      COMPLEX (RFFTB-S, CFFTB-C)
  !***
  ! **Keywords:**  FFTPACK, FOURIER TRANSFORM
  !***
  ! **Author:**  Swarztrauber, P. N., (NCAR)
  !***
  ! **Description:**
  !
  !  ********************************************************************
  !  *   NOTICE   NOTICE   NOTICE   NOTICE   NOTICE   NOTICE   NOTICE   *
  !  ********************************************************************
  !  *                                                                  *
  !  *   This routine uses non-standard Fortran 77 constructs and will  *
  !  *   be removed from the library at a future date.  You are         *
  !  *   requested to use CFFTB1.                                       *
  !  *                                                                  *
  !  ********************************************************************
  !
  !  Subroutine CFFTB computes the backward complex discrete Fourier
  !  transform (the Fourier synthesis).  Equivalently, CFFTB computes
  !  a complex periodic sequence from its Fourier coefficients.
  !  The transform is defined below at output parameter C.
  !
  !  A call of CFFTF followed by a call of CFFTB will multiply the
  !  sequence by N.
  !
  !  The array WSAVE which is used by subroutine CFFTB must be
  !  initialized by calling subroutine CFFTI(N,WSAVE).
  !
  !  Input Parameters
  !
  !  N       the length of the complex sequence C.  The method is
  !          more efficient when N is the product of small primes.
  !
  !  C       a complex array of length N which contains the sequence
  !
  !  WSAVE   a real work array which must be dimensioned at least 4*N+15
  !          in the program that calls CFFTB.  The WSAVE array must be
  !          initialized by calling subroutine CFFTI(N,WSAVE), and a
  !          different WSAVE array must be used for each different
  !          value of N.  This initialization does not have to be
  !          repeated so long as N remains unchanged.  Thus subsequent
  !          transforms can be obtained faster than the first.
  !          The same WSAVE array can be used by CFFTF and CFFTB.
  !
  !  Output Parameters
  !
  !  C       For J=1,...,N
  !
  !              C(J)=the sum from K=1,...,N of
  !
  !                 C(K)*EXP(I*(J-1)*(K-1)*2*PI/N)
  !
  !                         where I=SQRT(-1)
  !
  !  WSAVE   contains initialization calculations which must not be
  !          destroyed between calls of subroutine CFFTF or CFFTB
  !
  !***
  ! **References:**  P. N. Swarztrauber, Vectorizing the FFTs, in Parallel
  !                 Computations (G. Rodrigue, ed.), Academic Press,
  !                 1982, pp. 51-83.
  !***
  ! **Routines called:**  CFFTB1

  !* REVISION HISTORY  (YYMMDD)
  !   790601  DATE WRITTEN
  !   830401  Modified to use SLATEC library source file format.
  !   860115  Modified by Ron Boisvert to adhere to Fortran 77 by
  !           changing dummy array size declarations (1) to (*).
  !   861211  REVISION DATE from Version 3.2
  !   881128  Modified by Dick Valent to meet prologue standards.
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900131  Routine changed from user-callable to subsidiary
  !           because of non-standard Fortran 77 arguments in the
  !           call to CFFTB1.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: N
  REAL(SP), INTENT(INOUT) :: Wsave(4*N+15)
  COMPLEX(SP), INTENT(INOUT) :: C(N)
  REAL(SP) :: rc(2*N)
  INTEGER :: ifac(15), i
  !* FIRST EXECUTABLE STATEMENT  CFFTF
  IF( N==1 ) RETURN
  rc = [ ( [REAL(C(i)), AIMAG(C(i))], i=1,N ) ]
  ifac = INT( Wsave(4*N+1:4*N+15) )
  CALL CFFTB1(N,rc,Wsave,Wsave(2*N+1),ifac)
  C(1:N) = [ ( CMPLX(rc(i),rc(i+1),SP), i=1,2*N-1,2 ) ]
  Wsave(4*N+1:4*N+15) = ifac

END SUBROUTINE CFFTB