!** FMAT
SUBROUTINE FMAT(X,Y,Yp)
  !> Subsidiary to
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
  USE SAVEX, ONLY : xsave_com, term_com
  REAL(SP) :: X, Y(:), Yp(:)
  REAL(SP) :: tanx
  !* FIRST EXECUTABLE STATEMENT  FMAT
  Yp(1) = Y(2)
  IF( X/=xsave_com ) THEN
    xsave_com = X
    tanx = TAN(X/57.2957795130823)
    term_com = 3.0/tanx + 2.0*tanx
  END IF
  Yp(2) = -term_com*Y(2) - 0.7*Y(1)
END SUBROUTINE FMAT
