MODULE SAVEX
  IMPLICIT NONE
  REAL :: XSAve, TERm
END MODULE SAVEX
!** FMAT
SUBROUTINE FMAT(X,Y,Yp)
  USE SAVEX
  IMPLICIT NONE
  !>
  !***
  !  Subsidiary to
  !***
  ! **Library:**   SLATEC
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Routines called:**  (NONE)
  !***
  ! COMMON BLOCKS    SAVEX

  !* REVISION HISTORY  (YYMMDD)
  !   ??????  DATE WRITTEN
  !   891214  Prologue converted to Version 4.0 format.  (BAB)

  REAL tanx, X, Y(*), Yp(*)
  !* FIRST EXECUTABLE STATEMENT  FMAT
  Yp(1) = Y(2)
  IF ( X/=XSAve ) THEN
    XSAve = X
    tanx = TAN(X/57.2957795130823)
    TERm = 3.0/tanx + 2.0*tanx
  END IF
  Yp(2) = -TERm*Y(2) - 0.7*Y(1)
END SUBROUTINE FMAT