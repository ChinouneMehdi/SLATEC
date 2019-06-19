!** DEFEHL
SUBROUTINE DEFEHL(F,Neq,T,Y,H,Yp,F1,F2,F3,F4,F5,Ys)
  !> Subsidiary to DERKF
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (DEFEHL-S, DFEHL-D)
  !***
  ! **Author:**  Watts, H. A., (SNLA)
  !***
  ! **Description:**
  !
  !     Fehlberg Fourth-Fifth order Runge-Kutta Method
  !- *********************************************************************
  !
  !    DEFEHL integrates a system of NEQ first order
  !    ordinary differential equations of the form
  !               dU/DX = F(X,U)
  !    over one step when the vector Y(*) of initial values for U(*) and
  !    the vector YP(*) of initial derivatives, satisfying  YP = F(T,Y),
  !    are given at the starting point X=T.
  !
  !    DEFEHL advances the solution over the fixed step H and returns
  !    the fifth order (sixth order accurate locally) solution
  !    approximation at T+H in the array YS(*).
  !    F1,---,F5 are arrays of dimension NEQ which are needed
  !    for internal storage.
  !    The formulas have been grouped to control loss of significance.
  !    DEFEHL should be called with an H not smaller than 13 units of
  !    roundoff in T so that the various independent arguments can be
  !    distinguished.
  !
  !    This subroutine has been written with all variables and statement
  !    numbers entirely compatible with DERKFS. For greater efficiency,
  !    the call to DEFEHL can be replaced by the module beginning with
  !    line 222 and extending to the last line just before the return
  !    statement.
  !
  !- *********************************************************************
  !
  !***
  ! **See also:**  DERKF
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   800501  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   891009  Removed unreferenced statement label.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910722  Updated AUTHOR section.  (ALS)

  INTERFACE
    SUBROUTINE F(X,U,Uprime)
      IMPORT SP
      REAL(SP) :: X
      REAL(SP) :: U(:), Uprime(:)
    END SUBROUTINE F
  END INTERFACE
  INTEGER :: Neq
  REAL(SP) :: H, T
  REAL(SP) :: F1(Neq), F2(Neq), F3(Neq), F4(Neq), F5(Neq), Y(Neq), Yp(Neq), Ys(Neq)
  INTEGER :: k
  REAL(SP) :: ch
  !
  !* FIRST EXECUTABLE STATEMENT  DEFEHL
  ch = H/4.
  DO k = 1, Neq
    Ys(k) = Y(k) + ch*Yp(k)
  END DO
  CALL F(T+ch,Ys,F1)
  !
  ch = 3.*H/32.
  DO k = 1, Neq
    Ys(k) = Y(k) + ch*(Yp(k)+3.*F1(k))
  END DO
  CALL F(T+3.*H/8.,Ys,F2)
  !
  ch = H/2197.
  DO k = 1, Neq
    Ys(k) = Y(k) + ch*(1932.*Yp(k)+(7296.*F2(k)-7200.*F1(k)))
  END DO
  CALL F(T+12.*H/13.,Ys,F3)
  !
  ch = H/4104.
  DO k = 1, Neq
    Ys(k) = Y(k) + ch*((8341.*Yp(k)-845.*F3(k))+(29440.*F2(k)-32832.*F1(k)))
  END DO
  CALL F(T+H,Ys,F4)
  !
  ch = H/20520.
  DO k = 1, Neq
    Ys(k) = Y(k) + ch*((-6080.*Yp(k)+(9295.*F3(k)-5643.*F4(k)))&
      +(41040.*F1(k)-28352.*F2(k)))
  END DO
  CALL F(T+H/2.,Ys,F5)
  !
  !     COMPUTE APPROXIMATE SOLUTION AT T+H
  !
  ch = H/7618050.
  DO k = 1, Neq
    Ys(k) = Y(k) + ch*((902880.*Yp(k)+(3855735.*F3(k)-1371249.*F4(k)))&
      +(3953664.*F2(k)+277020.*F5(k)))
  END DO
  !
END SUBROUTINE DEFEHL
