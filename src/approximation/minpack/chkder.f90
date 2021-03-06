!** CHKDER
PURE SUBROUTINE CHKDER(M,N,X,Fvec,Fjac,Ldfjac,Xp,Fvecp,Mode,Err)
  !> Check the gradients of M nonlinear functions in N variables, evaluated
  !  at a point X, for consistency with the functions themselves.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  F3, G4C
  !***
  ! **Type:**      SINGLE PRECISION (CHKDER-S, DCKDER-D)
  !***
  ! **Keywords:**  GRADIENTS, JACOBIAN, MINPACK, NONLINEAR
  !***
  ! **Author:**  Hiebert, K. L. (SNLA)
  !***
  ! **Description:**
  !
  !   This subroutine is a companion routine to SNLS1,SNLS1E,SNSQ,and
  !   SNSQE which may be used to check the calculation of the Jacobian.
  !
  !     SUBROUTINE CHKDER
  !
  !     This subroutine checks the gradients of M nonlinear functions
  !     in N variables, evaluated at a point X, for consistency with
  !     the functions themselves. The user must call CKDER twice,
  !     first with MODE = 1 and then with MODE = 2.
  !
  !     MODE = 1. On input, X must contain the point of evaluation.
  !               On output, XP is set to a neighboring point.
  !
  !     MODE = 2. On input, FVEC must contain the functions and the
  !                         rows of FJAC must contain the gradients
  !                         of the respective functions each evaluated
  !                         at X, and FVECP must contain the functions
  !                         evaluated at XP.
  !               On output, ERR contains measures of correctness of
  !                          the respective gradients.
  !
  !     The subroutine does not perform reliably if cancellation or
  !     rounding errors cause a severe loss of significance in the
  !     evaluation of a function. Therefore, none of the components
  !     of X should be unusually small (in particular, zero) or any
  !     other value which may cause loss of significance.
  !
  !     The SUBROUTINE statement is
  !
  !       SUBROUTINE CHKDER(M,N,X,FVEC,FJAC,LDFJAC,XP,FVECP,MODE,ERR)
  !
  !     where
  !
  !       M is a positive integer input variable set to the number of functions.
  !
  !       N is a positive integer input variable set to the number of variables.
  !
  !       X is an input array of length N.
  !
  !       FVEC is an array of length M. On input when MODE = 2,
  !         FVEC must contain the functions evaluated at X.
  !
  !       FJAC is an M by N array. On input when MODE = 2,
  !         the rows of FJAC must contain the gradients of
  !         the respective functions evaluated at X.
  !
  !       LDFJAC is a positive integer input parameter not less than M
  !         which specifies the leading dimension of the array FJAC.
  !
  !       XP is an array of length N. On output when MODE = 1,
  !         XP is set to a neighboring point of X.
  !
  !       FVECP is an array of length M. On input when MODE = 2,
  !         FVECP must contain the functions evaluated at XP.
  !
  !       MODE is an integer input variable set to 1 on the first call
  !         and 2 on the second. Other values of MODE are equivalent to MODE = 1.
  !
  !       ERR is an array of length M. On output when MODE = 2,
  !         ERR contains measures of correctness of the respective
  !         gradients. If there is no severe loss of significance,
  !         then if ERR(I) is 1.0 the I-th gradient is correct,
  !         while if ERR(I) is 0.0 the I-th gradient is incorrect.
  !         For values of ERR between 0.0 and 1.0, the categorization
  !         is less certain. In general, a value of ERR(I) greater
  !         than 0.5 indicates that the I-th gradient is probably
  !         correct, while a value of ERR(I) less than 0.5 indicates
  !         that the I-th gradient is probably incorrect.
  !
  !***
  ! **References:**  M. J. D. Powell, A hybrid method for nonlinear equa-
  !                 tions. In Numerical Methods for Nonlinear Algebraic
  !                 Equations, P. Rabinowitz, Editor.  Gordon and Breach, 1988.
  !***
  ! **Routines called:**  R1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   800301  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTIONsection.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_sp
  !
  INTEGER, INTENT(IN) :: M, N, Ldfjac, Mode
  REAL(SP), INTENT(IN) :: X(N), Fvec(M), Fjac(Ldfjac,N), Fvecp(M)
  REAL(SP), INTENT(OUT) :: Xp(N), Err(M)
  !
  INTEGER :: i, j
  REAL(SP) :: eps, epsf, epslog, epsmch, temp
  !* FIRST EXECUTABLE STATEMENT  CHKDER
  epsmch = eps_sp
  !
  eps = SQRT(epsmch)
  !
  IF( Mode==2 ) THEN
    !
    !        MODE = 2.
    !
    epsf = 100._SP*epsmch
    epslog = LOG10(eps)
    DO i = 1, M
      Err(i) = 0._SP
    END DO
    DO j = 1, N
      temp = ABS(X(j))
      IF( temp==0._SP ) temp = 1._SP
      DO i = 1, M
        Err(i) = Err(i) + temp*Fjac(i,j)
      END DO
    END DO
    DO i = 1, M
      temp = 1._SP
      IF( Fvec(i)/=0._SP .AND. Fvecp(i)/=0._SP .AND. ABS(Fvecp(i)-Fvec(i))&
        >=epsf*ABS(Fvec(i)) ) temp = eps*ABS((Fvecp(i)-Fvec(i))/eps-Err(i))&
        /(ABS(Fvec(i))+ABS(Fvecp(i)))
      Err(i) = 1._SP
      IF( temp>epsmch .AND. temp<eps ) Err(i) = (LOG10(temp)-epslog)/epslog
      IF( temp>=eps ) Err(i) = 0._SP
    END DO
  ELSE
    !
    !        MODE = 1.
    !
    DO j = 1, N
      temp = eps*ABS(X(j))
      IF( temp==0._SP ) temp = eps
      Xp(j) = X(j) + temp
    END DO
  END IF
  !
  !
  !     LAST CARD OF SUBROUTINE CHKDER.
  !
END SUBROUTINE CHKDER