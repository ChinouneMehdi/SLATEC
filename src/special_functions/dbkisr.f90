!** DBKISR
SUBROUTINE DBKISR(X,N,Summ,Ierr)
  !> Subsidiary to DBSKIN
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (BKISR-S, DBKISR-D)
  !***
  ! **Author:**  Amos, D. E., (SNLA)
  !***
  ! **Description:**
  !
  !     DBKISR computes repeated integrals of the K0 Bessel function
  !     by the series for N=0,1, and 2.
  !
  !***
  ! **See also:**  DBSKIN
  !***
  ! **Routines called:**  D1MACH, DPSIXN

  !* REVISION HISTORY  (YYMMDD)
  !   820601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890911  Removed unnecessary intrinsics.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910722  Updated AUTHOR section.  (ALS)
  USE service, ONLY : D1MACH
  INTEGER :: i, Ierr, k, kk, kkn, k1, N, np
  REAL(DP) :: ak, atol, bk, fk, fn, hx, hxs, pol, pr, Summ, tkp, tol, trm, X, xln
  !
  REAL(DP), PARAMETER :: c(2) = [ 1.57079632679489662D+00, 1.0D0 ]
  !* FIRST EXECUTABLE STATEMENT  DBKISR
  Ierr = 0
  tol = MAX(D1MACH(4),1.0D-18)
  IF( X>=tol ) THEN
    pr = 1.0D0
    pol = 0.0D0
    IF( N/=0 ) THEN
      DO i = 1, N
        pol = -pol*X + c(i)
        pr = pr*X/i
      END DO
    END IF
    hx = X*0.5D0
    hxs = hx*hx
    xln = LOG(hx)
    np = N + 1
    tkp = 3.0D0
    fk = 2.0D0
    fn = N
    bk = 4.0D0
    ak = 2.0D0/((fn+1.0D0)*(fn+2.0D0))
    Summ = ak*(DPSIXN(N+3)-DPSIXN(3)+DPSIXN(2)-xln)
    atol = Summ*tol*0.75D0
    DO k = 2, 20
      ak = ak*(hxs/bk)*((tkp+1.0D0)/(tkp+fn+1.0D0))*(tkp/(tkp+fn))
      k1 = k + 1
      kk = k1 + k
      kkn = kk + N
      trm = (DPSIXN(k1)+DPSIXN(kkn)-DPSIXN(kk)-xln)*ak
      Summ = Summ + trm
      IF( ABS(trm)<=atol ) GOTO 100
      tkp = tkp + 2.0D0
      bk = bk + tkp
      fk = fk + 1.0D0
    END DO
    Ierr = 2
    RETURN
    !-----------------------------------------------------------------------
    !     SMALL X CASE, X<WORD TOLERANCE
    !-----------------------------------------------------------------------
  ELSEIF( N>0 ) THEN
    Summ = c(N)
    RETURN
  ELSE
    hx = X*0.5D0
    Summ = DPSIXN(1) - LOG(hx)
    RETURN
  END IF
  100  Summ = (Summ*hxs+DPSIXN(np)-xln)*pr
  IF( N==1 ) Summ = -Summ
  Summ = pol + Summ
  RETURN
END SUBROUTINE DBKISR
