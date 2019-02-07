!*==EG8CK.f90  processed by SPAG 6.72Dc at 10:52 on  6 Feb 2019
!DECK EG8CK
SUBROUTINE EG8CK(Lun,Kprint,Ipass)
  IMPLICIT NONE
  !*--EG8CK5
  !*** Start of declarations inserted by SPAG
  INTEGER Kprint
  !*** End of declarations inserted by SPAG
  !***BEGIN PROLOGUE  EG8CK
  !***PURPOSE  Quick check for EXINT and GAUS8.
  !***LIBRARY   SLATEC
  !***TYPE      SINGLE PRECISION (EG8CK-S, DEG8CK-D)
  !***KEYWORDS  QUICK CHECK
  !***AUTHOR  Amos, D. E., (SNLA)
  !***DESCRIPTION
  !
  !   EG8CK is a quick check routine for EXINT and GAUS8.  Exponential
  !   integrals from EXINT are checked against quadratures from GAUS8.
  !
  !***ROUTINES CALLED  EXINT, FEIN, GAUS8, R1MACH
  !***COMMON BLOCKS    FEINX
  !***REVISION HISTORY  (YYMMDD)
  !   800501  DATE WRITTEN
  !   890718  Added check when testing error conditions.  (WRB)
  !   890718  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   910708  Code revised to test error returns for all values of
  !           KPRINT.  (WRB)
  !   920206  Corrected argument list in CALL to EXINT.  (WRB)
  !***END PROLOGUE  EG8CK
  COMMON /FEINX / X, A, FKM
  INTEGER i, icase, ie, ierr, ii, ik, Ipass, ix, iy, k, ke, kk, &
    kode, kx, Lun, m, n, nm, nz
  REAL A, ans, atol, bb, en, er, ex, FKM, sig, sum, tol, t1, &
    t2, X, xx, y
  REAL R1MACH, FEIN
  DIMENSION en(4), y(4), xx(5)
  LOGICAL fatal
  EXTERNAL FEIN
  !***FIRST EXECUTABLE STATEMENT  EG8CK
  IF ( Kprint>=2 ) WRITE (Lun,99001)
  !
  99001 FORMAT ('1'/' QUICK CHECK FOR EXINT AND GAUS8'/)
  Ipass = 1
  tol = SQRT(MAX(R1MACH(4),1.0E-18))
  DO kode = 1, 2
    ik = kode - 1
    FKM = ik
    DO n = 1, 25, 8
      DO m = 1, 4
        nm = n + m - 1
        DO ix = 1, 25, 8
          X = ix - 0.20E0
          CALL EXINT(X,n,kode,m,tol,en,nz,ierr)
          kx = X + 0.5E0
          IF ( kx==0 ) kx = 1
          icase = 1
          A = n
          IF ( kx>n ) THEN
            icase = 2
            A = nm
            IF ( kx<nm ) THEN
              icase = 3
              A = kx
            ENDIF
          ENDIF
          sig = 3.0E0/X
          t2 = 1.0E0
          sum = 0.0E0
          DO
            t1 = t2
            t2 = t2 + sig
            atol = tol
            CALL GAUS8(FEIN,t1,t2,atol,ans,ierr)
            sum = sum + ans
            IF ( ABS(ans)<ABS(sum)*tol ) THEN
              ex = 1.0E0
              IF ( kode==1 ) ex = EXP(-X)
              bb = A
              IF ( icase==3 ) THEN
                iy = kx - n + 1
                y(iy) = sum
                ke = m - iy
                ie = iy - 1
                kk = iy
                ii = iy
              ELSEIF ( icase/=2 ) THEN
                y(1) = sum
                IF ( m==1 ) GOTO 5
                ke = m - 1
                kk = 1
              ELSE
                y(m) = sum
                IF ( m==1 ) GOTO 5
                ie = m - 1
                ii = m
                EXIT
              ENDIF
              !
              !             Forward recur
              !
              DO k = 1, ke
                y(kk+1) = (ex-X*y(kk))/bb
                bb = bb + 1.0E0
                kk = kk + 1
              ENDDO
              IF ( icase==3 ) EXIT
              GOTO 5
            ENDIF
          ENDDO
          bb = A - 1.0E0
          !
          !             Backward recur
          !
          DO i = 1, ie
            y(ii-1) = (ex-bb*y(ii))/X
            bb = bb - 1.0E0
            ii = ii - 1
          ENDDO
          5            DO i = 1, m
          er = ABS((y(i)-en(i))/y(i))
          IF ( er>tol ) THEN
            WRITE (Lun,99002)
            99002             FORMAT (//' ERROR IN EG8CK COMPARISON TEST'/)
            Ipass = 0
            GOTO 100
          ENDIF
        ENDDO
      ENDDO
    ENDDO
  ENDDO
ENDDO
!
!     Trigger 6 error conditions.
!
100  fatal = .FALSE.
!
IF ( Kprint>=3 ) WRITE (Lun,99003)
99003 FORMAT (/' TRIGGER 6 ERROR CONDITIONS')
xx(1) = 1.0E0
xx(2) = 1.0E0
xx(3) = 1.0E0
xx(4) = 1.0E0
xx(5) = 0.01E0
DO i = 1, 5
  xx(i) = -xx(i)
  k = xx(2)
  n = xx(3)
  m = xx(4)
  CALL EXINT(xx(i),n,k,m,xx(5),en,nz,ierr)
  IF ( ierr/=1 ) THEN
    Ipass = 0
    fatal = .TRUE.
    WRITE (Lun,99004) i
    99004     FORMAT (' Error occurred with DO index I =',I2)
  ENDIF
  xx(i) = -xx(i)
ENDDO
X = 0.0E0
tol = 1.0E-2
CALL EXINT(X,1,1,1,tol,en,nz,ierr)
IF ( ierr/=1 ) THEN
  Ipass = 0
  fatal = .TRUE.
  WRITE (Lun,99005)
  99005   FORMAT (' Error occurred with X = 0.0')
ENDIF
IF ( fatal ) THEN
  IF ( Kprint>=2 ) THEN
    WRITE (Lun,99006)
    99006     FORMAT (/' AT LEAST ONE INCORRECT ARGUMENT TEST FAILED')
  ENDIF
ELSEIF ( Kprint>=3 ) THEN
  WRITE (Lun,99007)
  99007   FORMAT (/' ALL INCORRECT ARGUMENT TESTS PASSED')
ENDIF
!
IF ( Ipass==1.AND.Kprint>=2 ) WRITE (Lun,99008)
99008 FORMAT (/' **********EXINT AND GAUS8 PASSED ALL TESTS**********')
IF ( Ipass==0.AND.Kprint>=1 ) WRITE (Lun,99009)
99009 FORMAT (/' **********EXINT OR GAUS8 FAILED SOME TESTS**********')
RETURN
END SUBROUTINE EG8CK
