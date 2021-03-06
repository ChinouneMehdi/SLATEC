!** DFDJC1
PURE SUBROUTINE DFDJC1(FCN,N,X,Fvec,Fjac,Ldfjac,Iflag,Ml,Mu,Epsfcn,Wa1,Wa2)
  !> Subsidiary to DNSQ and DNSQE
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (FDJAC1-S, DFDJC1-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     This subroutine computes a forward-difference approximation
  !     to the N by N Jacobian matrix associated with a specified
  !     problem of N functions in N variables. If the Jacobian has
  !     a banded form, then function evaluations are saved by only
  !     approximating the nonzero terms.
  !
  !     The subroutine statement is
  !
  !       SUBROUTINE DFDJC1(FCN,N,X,FVEC,FJAC,LDFJAC,IFLAG,ML,MU,EPSFCN,
  !                         WA1,WA2)
  !
  !     where
  !
  !       FCN is the name of the user-supplied subroutine which
  !         calculates the functions. FCN must be declared
  !         in an EXTERNAL statement in the user calling
  !         program, and should be written as follows.
  !
  !         SUBROUTINE FCN(N,X,FVEC,IFLAG)
  !         INTEGER N,IFLAG
  !         DOUBLE PRECISION X(N),FVEC(N)
  !         ----------
  !         Calculate the functions at X and
  !         return this vector in FVEC.
  !         ----------
  !         RETURN
  !
  !         The value of IFLAG should not be changed by FCN unless
  !         the user wants to terminate execution of DFDJC1.
  !         In this case set IFLAG to a negative integer.
  !
  !       N is a positive integer input variable set to the number
  !         of functions and variables.
  !
  !       X is an input array of length N.
  !
  !       FVEC is an input array of length N which must contain the
  !         functions evaluated at X.
  !
  !       FJAC is an output N by N array which contains the
  !         approximation to the Jacobian matrix evaluated at X.
  !
  !       LDFJAC is a positive integer input variable not less than N
  !         which specifies the leading dimension of the array FJAC.
  !
  !       IFLAG is an integer variable which can be used to terminate
  !         the execution of DFDJC1. See description of FCN.
  !
  !       ML is a nonnegative integer input variable which specifies
  !         the number of subdiagonals within the band of the
  !         Jacobian matrix. If the Jacobian is not banded, set
  !         ML to at least N - 1.
  !
  !       EPSFCN is an input variable used in determining a suitable
  !         step length for the forward-difference approximation. This
  !         approximation assumes that the relative errors in the
  !         functions are of the order of EPSFCN. If EPSFCN is less
  !         than the machine precision, it is assumed that the relative
  !         errors in the functions are of the order of the machine
  !         precision.
  !
  !       MU is a nonnegative integer input variable which specifies
  !         the number of superdiagonals within the band of the
  !         Jacobian matrix. If the Jacobian is not banded, set
  !         MU to at least N - 1.
  !
  !       WA1 and WA2 are work arrays of length N. If ML + MU + 1 is at
  !         least N, then the Jacobian is considered dense, and WA2 is
  !         not referenced.
  !
  !***
  ! **See also:**  DNSQ, DNSQE
  !***
  ! **Routines called:**  D1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   800301  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTIONsection.  (WRB)
  !   900328  Added TYPE section.  (WRB)
  USE service, ONLY : eps_dp
  !
  INTERFACE
    PURE SUBROUTINE FCN(N,X,Fvec,iflag)
      IMPORT DP
      INTEGER, INTENT(IN) :: N, Iflag
      REAL(DP), INTENT(IN) :: X(N)
      REAL(DP), INTENT(OUT) :: Fvec(N)
    END SUBROUTINE FCN
  END INTERFACE
  INTEGER, INTENT(IN) :: Iflag, Ldfjac, Ml, Mu, N
  REAL(DP), INTENT(IN) :: Epsfcn
  REAL(DP), INTENT(IN) :: Fvec(N), X(N)
  REAL(DP), INTENT(OUT) :: Fjac(Ldfjac,N), Wa1(N), Wa2(N)
  !
  INTEGER :: i, j, k, msum
  REAL(DP) :: eps, epsmch, h, temp, x_temp(N)
  !
  !     EPSMCH IS THE MACHINE PRECISION.
  !
  !* FIRST EXECUTABLE STATEMENT  DFDJC1
  epsmch = eps_dp
  !
  eps = SQRT(MAX(Epsfcn,epsmch))
  msum = Ml + Mu + 1
  x_temp = X
  IF( msum<N ) THEN
    !
    !        COMPUTATION OF BANDED APPROXIMATE JACOBIAN.
    !
    DO k = 1, msum
      DO j = k, N, msum
        Wa2(j) = X(j)
        h = eps*ABS(Wa2(j))
        IF( h==0._DP ) h = eps
        x_temp(j) = Wa2(j) + h
      END DO
      CALL FCN(N,x_temp,Wa1,Iflag)
      IF( Iflag<0 ) EXIT
      DO j = k, N, msum
        x_temp(j) = Wa2(j)
        h = eps*ABS(Wa2(j))
        IF( h==0._DP ) h = eps
        DO i = 1, N
          Fjac(i,j) = 0._DP
          IF( i>=j-Mu .AND. i<=j+Ml ) Fjac(i,j) = (Wa1(i)-Fvec(i))/h
        END DO
      END DO
    END DO
  ELSE
    !
    !        COMPUTATION OF DENSE APPROXIMATE JACOBIAN.
    !
    DO j = 1, N
      temp = X(j)
      h = eps*ABS(temp)
      IF( h==0._DP ) h = eps
      x_temp(j) = temp + h
      CALL FCN(N,x_temp,Wa1,Iflag)
      IF( Iflag<0 ) EXIT
      x_temp(j) = temp
      DO i = 1, N
        Fjac(i,j) = (Wa1(i)-Fvec(i))/h
      END DO
    END DO
  END IF
  !
  !     LAST CARD OF SUBROUTINE DFDJC1.
  !
END SUBROUTINE DFDJC1