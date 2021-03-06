!** DDATRP
PURE SUBROUTINE DDATRP(X,Xout,Yout,Ypout,Neq,Kold,Phi,Psi)
  !> Interpolation routine for DDASSL.
  !***
  ! **Library:**   SLATEC (DASSL)
  !***
  ! **Type:**      DOUBLE PRECISION (SDATRP-S, DDATRP-D)
  !***
  ! **Author:**  Petzold, Linda R., (LLNL)
  !***
  ! **Description:**
  !-----------------------------------------------------------------------
  !     THE METHODS IN SUBROUTINE DDASTP USE POLYNOMIALS
  !     TO APPROXIMATE THE SOLUTION. DDATRP APPROXIMATES THE
  !     SOLUTION AND ITS DERIVATIVE AT TIME XOUT BY EVALUATING
  !     ONE OF THESE POLYNOMIALS, AND ITS DERIVATIVE,THERE.
  !     INFORMATION DEFINING THIS POLYNOMIAL IS PASSED FROM
  !     DDASTP, SO DDATRP CANNOT BE USED ALONE.
  !
  !     THE PARAMETERS ARE:
  !     X     THE CURRENT TIME IN THE INTEGRATION.
  !     XOUT  THE TIME AT WHICH THE SOLUTION IS DESIRED
  !     YOUT  THE INTERPOLATED APPROXIMATION TO Y AT XOUT
  !           (THIS IS OUTPUT)
  !     YPOUT THE INTERPOLATED APPROXIMATION TO YPRIME AT XOUT
  !           (THIS IS OUTPUT)
  !     NEQ   NUMBER OF EQUATIONS
  !     KOLD  ORDER USED ON LAST SUCCESSFUL STEP
  !     PHI   ARRAY OF SCALED DIVIDED DIFFERENCES OF Y
  !     PSI   ARRAY OF PAST STEPSIZE HISTORY
  !-----------------------------------------------------------------------
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   830315  DATE WRITTEN
  !   901009  Finished conversion to SLATEC 4.0 format (F.N.Fritsch)
  !   901019  Merged changes made by C. Ulrich with SLATEC 4.0 format.
  !   901026  Added explicit declarations for all variables and minor
  !           cosmetic changes to prologue.  (FNF)
  !
  INTEGER, INTENT(IN) :: Neq, Kold
  REAL(DP), INTENT(IN) :: X, Xout
  REAL(DP), INTENT(IN) :: Phi(Neq,Kold+1), Psi(Kold+1)
  REAL(DP), INTENT(OUT) :: Yout(Neq), Ypout(Neq)
  !
  INTEGER :: i, j, koldp1
  REAL(DP) :: c, d, gama, temp1
  !
  !* FIRST EXECUTABLE STATEMENT  DDATRP
  koldp1 = Kold + 1
  temp1 = Xout - X
  DO i = 1, Neq
    Yout(i) = Phi(i,1)
    Ypout(i) = 0._DP
  END DO
  c = 1._DP
  d = 0._DP
  gama = temp1/Psi(1)
  DO j = 2, koldp1
    d = d*gama + c/Psi(j-1)
    c = c*gama
    gama = (temp1+Psi(j-1))/Psi(j)
    DO i = 1, Neq
      Yout(i) = Yout(i) + c*Phi(i,j)
      Ypout(i) = Ypout(i) + d*Phi(i,j)
    END DO
  END DO
  !
  !------END OF SUBROUTINE DDATRP------
END SUBROUTINE DDATRP