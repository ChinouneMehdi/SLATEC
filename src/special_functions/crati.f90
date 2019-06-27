!** CRATI
PURE SUBROUTINE CRATI(Z,Fnu,N,Cy,Tol)
  !> Subsidiary to CBESH, CBESI and CBESK
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (CRATI-A, ZRATI-A)
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !     CRATI COMPUTES RATIOS OF I BESSEL FUNCTIONS BY BACKWARD
  !     RECURRENCE.  THE STARTING INDEX IS DETERMINED BY FORWARD
  !     RECURRENCE AS DESCRIBED IN J. RES. OF NAT. BUR. OF STANDARDS-B,
  !     MATHEMATICAL SCIENCES, VOL 77B, P111-114, SEPTEMBER, 1973,
  !     BESSEL FUNCTIONS I AND J OF COMPLEX ARGUMENT AND INTEGER ORDER,
  !     BY D. J. SOOKNE.
  !
  !***
  ! **See also:**  CBESH, CBESI, CBESK
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)

  INTEGER, INTENT(IN) :: N
  REAL(SP), INTENT(IN) :: Fnu, Tol
  COMPLEX(SP), INTENT(IN) :: Z
  COMPLEX(SP), INTENT(OUT) :: Cy(N)
  INTEGER :: i, id, idnu, inu, itime, k, kk, magz
  COMPLEX(SP) :: cdfnu, pt, p1, p2, rz, t1
  REAL(SP) :: ak, amagz, ap1, ap2, arg, az, dfnu, fdnu, flam, fnup, &
    rap1, rho, test, test1
  COMPLEX(SP), PARAMETER :: czero = (0._SP,0._SP), cone = (1._SP,0._SP)
  !* FIRST EXECUTABLE STATEMENT  CRATI
  az = ABS(Z)
  inu = INT( Fnu )
  idnu = inu + N - 1
  fdnu = idnu
  magz = INT( az )
  amagz = magz + 1
  fnup = MAX(amagz,fdnu)
  id = idnu - magz - 1
  itime = 1
  k = 1
  rz = (cone+cone)/Z
  t1 = CMPLX(fnup,0._SP,SP)*rz
  p2 = -t1
  p1 = cone
  t1 = t1 + rz
  IF( id>0 ) id = 0
  ap2 = ABS(p2)
  ap1 = ABS(p1)
  !-----------------------------------------------------------------------
  !     THE OVERFLOW TEST ON K(FNU+I-1,Z) BEFORE THE CALL TO CBKNX
  !     GUARANTEES THAT P2 IS ON SCALE. SCALE TEST1 AND ALL SUBSEQUENT
  !     P2 VALUES BY AP1 TO ENSURE THAT AN OVERFLOW DOES NOT OCCUR
  !     PREMATURELY.
  !-----------------------------------------------------------------------
  arg = (ap2+ap2)/(ap1*Tol)
  test1 = SQRT(arg)
  test = test1
  rap1 = 1._SP/ap1
  p1 = p1*CMPLX(rap1,0._SP,SP)
  p2 = p2*CMPLX(rap1,0._SP,SP)
  ap2 = ap2*rap1
  DO
    k = k + 1
    ap1 = ap2
    pt = p2
    p2 = p1 - t1*p2
    p1 = pt
    t1 = t1 + rz
    ap2 = ABS(p2)
    IF( ap1>test ) THEN
      IF( itime==2 ) THEN
        kk = k + 1 - id
        ak = kk
        dfnu = Fnu + (N-1)
        cdfnu = CMPLX(dfnu,0._SP,SP)
        t1 = CMPLX(ak,0._SP,SP)
        p1 = CMPLX(1._SP/ap2,0._SP,SP)
        p2 = czero
        DO i = 1, kk
          pt = p1
          p1 = rz*(cdfnu+t1)*p1 + p2
          p2 = pt
          t1 = t1 - cone
        END DO
        IF( REAL(p1)==0._SP .AND. AIMAG(p1)==0._SP ) p1 = CMPLX(Tol,Tol,SP)
        Cy(N) = p2/p1
        IF( N==1 ) RETURN
        k = N - 1
        ak = k
        t1 = CMPLX(ak,0._SP,SP)
        cdfnu = CMPLX(Fnu,0._SP,SP)*rz
        DO i = 2, N
          pt = cdfnu + t1*rz + Cy(k+1)
          IF( REAL(pt)==0._SP .AND. AIMAG(pt)==0._SP ) pt = CMPLX(Tol,Tol,SP)
          Cy(k) = cone/pt
          t1 = t1 - cone
          k = k - 1
        END DO
        EXIT
      ELSE
        ak = ABS(t1)*0.5_SP
        flam = ak + SQRT(ak*ak-1._SP)
        rho = MIN(ap2/ap1,flam)
        test = test1*SQRT(rho/(rho*rho-1._SP))
        itime = 2
      END IF
    END IF
  END DO

END SUBROUTINE CRATI