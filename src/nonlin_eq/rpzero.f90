!** RPZERO
PURE SUBROUTINE RPZERO(N,A,R,T,Iflg,S)
  !> Find the zeros of a polynomial with real coefficients.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  F1A1A
  !***
  ! **Type:**      SINGLE PRECISION (RPZERO-S, CPZERO-C)
  !***
  ! **Keywords:**  POLYNOMIAL ROOTS, POLYNOMIAL ZEROS, REAL ROOTS
  !***
  ! **Author:**  Kahaner, D. K., (NBS)
  !***
  ! **Description:**
  !
  !      Find the zeros of the real polynomial
  !         P(X)= A(1)*X**N + A(2)*X**(N-1) +...+ A(N+1)
  !
  !    Input...
  !       N = degree of P(X)
  !       A = real vector containing coefficients of P(X),
  !            A(I) = coefficient of X**(N+1-I)
  !       R = N word complex vector containing initial estimates for zeros
  !            if these are known.
  !       T = 6(N+1) word array used for temporary storage
  !       IFLG = flag to indicate if initial estimates of
  !              zeros are input.
  !            If IFLG = 0, no estimates are input.
  !            If IFLG /= 0, the vector R contains estimates of
  !               the zeros
  !       ** Warning ****** If estimates are input, they must
  !                         be separated; that is, distinct or
  !                         not repeated.
  !       S = an N word array
  !
  !    Output...
  !       R(I) = ith zero,
  !       S(I) = bound for R(I) .
  !       IFLG = error diagnostic
  !    Error Diagnostics...
  !       If IFLG = 0 on return, all is well.
  !       If IFLG = 1 on return, A(1)=0.0 or N=0 on input.
  !       If IFLG = 2 on return, the program failed to converge
  !                after 25*N iterations.  Best current estimates of the
  !                zeros are in R(I).  Error bounds are not calculated.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  CPZERO

  !* REVISION HISTORY  (YYMMDD)
  !   810223  DATE WRITTEN
  !   890206  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)

  INTEGER, INTENT(IN) :: N
  INTEGER, INTENT(INOUT) :: Iflg
  REAL(SP), INTENT(IN) :: A(N+1)
  REAL(SP), INTENT(OUT) :: S(N)
  COMPLEX(SP), INTENT(INOUT) :: T(6*N+6), R(N)
  INTEGER :: i, n1
  !* FIRST EXECUTABLE STATEMENT  RPZERO
  n1 = N + 1
  DO i = 1, n1
    T(i) = CMPLX(A(i),0._SP,SP)
  END DO
  CALL CPZERO(N,T,R,T(N+2),Iflg,S)

END SUBROUTINE RPZERO