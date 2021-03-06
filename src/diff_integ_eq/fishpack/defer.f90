!** DEFER
PURE SUBROUTINE DEFER(COFX,COFY,Idmn,Usol,Grhs)
  !> Subsidiary to SEPELI
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (DEFER-S)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     This subroutine first approximates the truncation error given by
  !     TRUN1(X,Y)=DLX**2*TX+DLY**2*TY where
  !     TX=AFUN(X)*UXXXX/12.0+BFUN(X)*UXXX/6.0 on the interior and
  !     at the boundaries if periodic (here UXXX,UXXXX are the third
  !     and fourth partial derivatives of U with respect to X).
  !     TX is of the form AFUN(X)/3.0*(UXXXX/4.0+UXXX/DLX)
  !     at X=A or X=B if the boundary condition there is mixed.
  !     TX=0.0 along specified boundaries.  TY has symmetric form
  !     in Y with X,AFUN(X),BFUN(X) replaced by Y,DFUN(Y),EFUN(Y).
  !     The second order solution in USOL is used to approximate
  !     (via second order finite differencing) the truncation error
  !     and the result is added to the right hand side in GRHS
  !     and then transferred to USOL to be used as a new right
  !     hand side when calling BLKTRI for a fourth order solution.
  !
  !***
  ! **See also:**  SEPELI
  !***
  ! **Routines called:**  DX, DY
  !***
  ! COMMON BLOCKS    SPLPCM

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  USE SPLPCM, ONLY : l_com, ait_com, cit_com, dlx_com, dly_com, is_com, js_com, &
    k_com, kswx_com, kswy_com, ms_com, ns_com
  !
  INTERFACE
    PURE SUBROUTINE COFX(X,A,B,C)
      IMPORT SP
      REAL(SP), INTENT(IN) :: X
      REAL(SP), INTENT(OUT) :: A, B, C
    END SUBROUTINE COFX
    PURE SUBROUTINE COFY(Y,D,E,F)
      IMPORT SP
      REAL(SP), INTENT(IN) :: Y
      REAL(SP), INTENT(OUT) :: D, E, F
    END SUBROUTINE COFY
  END INTERFACE
  INTEGER, INTENT(IN) :: Idmn
  REAL(SP), INTENT(INOUT) :: Grhs(Idmn,ns_com), Usol(Idmn,ns_com)
  !
  INTEGER :: i, j
  REAL(SP) :: ai, bi, ci, dj, ej, fj, tx, ty, uxxx, uxxxx, uyyy, uyyyy, xi, yj
  !* FIRST EXECUTABLE STATEMENT  DEFER
  DO j = js_com, ns_com
    yj = cit_com + (j-1)*dly_com
    CALL COFY(yj,dj,ej,fj)
    DO i = is_com, ms_com
      xi = ait_com + (i-1)*dlx_com
      CALL COFX(xi,ai,bi,ci)
      !
      !     COMPUTE PARTIAL DERIVATIVE APPROXIMATIONS AT (XI,YJ)
      !
      CALL DX(Usol,Idmn,i,j,uxxx,uxxxx)
      CALL DY(Usol,Idmn,i,j,uyyy,uyyyy)
      tx = ai*uxxxx/12._SP + bi*uxxx/6._SP
      ty = dj*uyyyy/12._SP + ej*uyyy/6._SP
      !
      !     RESET FORM OF TRUNCATION IF AT BOUNDARY WHICH IS NON-PERIODIC
      !
      IF( .NOT. (kswx_com==1 .OR. (i>1 .AND. i<k_com)) )&
        tx = ai/3._SP*(uxxxx/4._SP+uxxx/dlx_com)
      IF( .NOT. (kswy_com==1 .OR. (j>1 .AND. j<l_com)) )&
        ty = dj/3._SP*(uyyyy/4._SP+uyyy/dly_com)
      Grhs(i,j) = Grhs(i,j) + dlx_com**2*tx + dly_com**2*ty
    END DO
  END DO
  !
  !     RESET THE RIGHT HAND SIDE IN USOL
  !
  DO i = is_com, ms_com
    DO j = js_com, ns_com
      Usol(i,j) = Grhs(i,j)
    END DO
  END DO
  !
END SUBROUTINE DEFER