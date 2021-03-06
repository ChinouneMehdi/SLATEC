MODULE TEST07_MOD
  USE service, ONLY : SP, DP
  IMPLICIT NONE

CONTAINS
  !** QCKIN
  SUBROUTINE QCKIN(Lun,Kprint,Ipass)
    !> Quick check for BSKIN.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  Amos, D. E., (SNLA)
    !***
    ! **Description:**
    !
    !     ABSTRACT
    !     QCKIN IS A QUICK CHECK ROUTINE WHICH EXERCISES THE MAJOR
    !     LOOPS IN SUBROUTINE BSKIN (X,N,KODE,M,Y,NZ,IERR) FOR BICKLEY
    !     FUNCTIONS KI(J,X).  MORE PRECISELY, QCKIN DOES CONSISTENCY CHECKS
    !     ON THE OUTPUT FROM BSKIN BY COMPARING SINGLE EVALUATIONS (M=1)
    !     AGAINST SELECTED MEMBERS OF SEQUENCES WHICH ARE GENERATED BY
    !     RECURSION.  IF THE RELATIVE ERROR IS LESS THAN 1000 TIMES UNIT
    !     ROUND OFF, THEN THE TEST IS PASSED - IF NOT, THEN X, THE VALUES
    !     TO BE COMPARED, THE RELATIVE ERROR AND PARAMETERS KODE, N, M AND K
    !     ARE WRITTEN ON LOGICAL UNIT 6 WHERE K IS THE MEMBER OF THE
    !     SEQUENCE OF LENGTH M WHICH FAILED THE TEST.  THAT IS, THE INDEX
    !     OF THE FUNCTION WHICH FAILED THE TEST IS J=N+K-1.  UNDERFLOW
    !     TESTS ARE MADE AND ERROR CONDITIONS ARE TRIGGERED.
    !
    !     FUNCTIONS I1MACH AND R1MACH MUST BE INITIALIZED ACCORDING TO THE
    !     PROLOGUE IN EACH FUNCTION FOR THE MACHINE ENVIRONMENT BEFORE
    !     QCKIN OR BSKIN CAN BE EXECUTED.  FIFTEEN MACHINE ENVIRONMENTS
    !     CAN BE DEFINED IN I1MACH AND R1MACH.
    !
    !***
    ! **Routines called:**  BSKIN, I1MACH, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   820601  DATE WRITTEN
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   890911  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    USE service, ONLY : min_exp_sp, eps_sp, log10_radix_sp
    USE special_functions, ONLY : BSKIN
    !
    INTEGER :: Ipass, Kprint
    INTEGER :: i, ierr, iflg, ix, i1m12, j, k, kode, Lun, m, mdel, mm, n, ndel, nn, nz
    REAL(SP) :: aix, er, tol, v(1), x, xinc, y(10)
    !* FIRST EXECUTABLE STATEMENT  QCKIN
    tol = 1000._SP*MAX(eps_sp,1.E-18_SP)
    iflg = 0
    IF( Kprint>=3 ) WRITE (Lun,99001)
    99001 FORMAT ('1 QUICK CHECK DIAGNOSTICS FOR BSKIN'//)
    DO kode = 1, 2
      n = 0
      DO nn = 1, 7
        m = 1
        DO mm = 1, 4
          x = 0._SP
          DO ix = 1, 6
            IF( n/=0 .OR. ix/=1 ) THEN
              CALL BSKIN(x,n,kode,m,y,nz,ierr)
              DO k = 1, m, 2
                j = n + k - 1
                CALL BSKIN(x,j,kode,1,v,nz,ierr)
                er = ABS((v(1)-y(k))/v(1))
                IF( er>tol ) THEN
                  IF( iflg==0 ) THEN
                    IF( Kprint>=2 ) WRITE (Lun,99002)
                    99002 FORMAT (8X,'X',13X,'V(1)',11X,'Y(K)',9X,'REL ER','R',5X,&
                      'KODE',3X,'N',4X,'M',4X,'K')
                  END IF
                  iflg = iflg + 1
                  IF( Kprint>=2 ) WRITE (Lun,99003) x, v(1), y(k), er, &
                    kode, n, m, k
                  99003 FORMAT (4E15.6,4I5)
                  IF( iflg>200 ) GOTO 300
                END IF
              END DO
            END IF
            aix = 2*ix - 3
            xinc = MAX(1._SP,aix)
            x = x + xinc
          END DO
          mdel = MAX(1,mm-1)
          m = m + mdel
        END DO
        ndel = MAX(1,2*n-2)
        n = n + ndel
      END DO
    END DO
    !-----------------------------------------------------------------------
    !     TEST UNDERFLOW
    !-----------------------------------------------------------------------
    kode = 1
    m = 10
    n = 10
    i1m12 = min_exp_sp
    x = -2.302_SP*log10_radix_sp*i1m12
    CALL BSKIN(x,n,kode,m,y,nz,ierr)
    IF( nz==m ) THEN
      DO i = 1, m
        IF( y(i)/=0._SP ) GOTO 100
      END DO
    ELSE
      IF( Kprint>=2 ) WRITE (Lun,99004)
      99004 FORMAT (//' NZ IN UNDERFLOW TEST IS NOT 1'//)
      iflg = iflg + 1
    END IF
    GOTO 200
    100 CONTINUE
    IFlg = iflg + 1
    IF( Kprint>=2 ) WRITE (Lun,99005)
    99005 FORMAT (//' SOME Y VALUE IN UNDERFLOW TEST IS NOT ZERO'//)
    200 CONTINUE
    IF( iflg==0 .AND. Kprint>=3 ) THEN
      WRITE (Lun,99006)
      99006 FORMAT (//' QUICK CHECKS OK'//)
    END IF
    Ipass = 0
    IF( iflg==0 ) Ipass = 1
    RETURN
    300 CONTINUE
    IF( Kprint>=2 ) WRITE (Lun,99007)
    99007 FORMAT (//' PROCESSING OF MAIN LOOPS TERMINATED BECAUSE THE NUM',&
      'BER OF DIAGNOSTIC PRINTS EXCEEDS 200'//)
    Ipass = 0
    IF( iflg==0 ) Ipass = 1
  END SUBROUTINE QCKIN
  !** QCPSI
  SUBROUTINE QCPSI(Lun,Kprint,Ipass)
    !> Quick check for PSIFN.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  Amos, D. E., (SNLA)
    !***
    ! **Description:**
    !
    !     ABSTRACT
    !     QCPSI IS A QUICK CHECK ROUTINE WHICH EXERCISES THE MAJOR
    !     LOOPS IN SUBROUTINE PSIFN(X,N,KODE,M,ANS,NZ,IERR) FOR DERIVATIVES
    !     OF THE PSI FUNCTION.  FOR N=0, THE PSI FUNCTIONS ARE CALCULATED
    !     EXPLICITLY AND CHECKED AGAINST EVALUATIONS FROM PSIFN. FOR
    !     N>0, CONSISTENCY CHECKS ARE MADE BY COMPARING A SEQUENCE
    !     AGAINST SINGLE EVALUATIONS OF PSIFN, ONE AT A TIME.
    !     IF THE RELATIVE ERROR IS LESS THAN 1000 TIMES UNIT ROUNDOFF,
    !     THEN THE TEST IS PASSED--IF NOT,
    !     THEN X, THE VALUES TO BE COMPARED, THE RELATIVE ERROR AND
    !     PARAMETERS KODE AND N ARE WRITTEN ON LOGICAL UNIT 6 WHERE N IS
    !     THE ORDER OF THE DERIVATIVE AND KODE IS A SELECTION PARAMETER
    !     DEFINED IN THE PROLOGUE TO PSIFN.
    !
    !     FUNCTIONS I1MACH AND R1MACH MUST BE INITIALIZED ACCORDING TO THE
    !     PROLOGUE IN EACH FUNCTION FOR THE MACHINE ENVIRONMENT BEFORE
    !     QCPSI OR PSIFN CAN BE EXECUTED.
    !
    !***
    ! **Routines called:**  PSIFN, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   820601  DATE WRITTEN
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   890911  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    USE service, ONLY : eps_sp
    USE special_functions, ONLY : PSIFN
    !
    INTEGER :: Ipass, Kprint
    INTEGER :: i, ierr, iflg, ix, kode, Lun, m, n, nm, nn, nz
    REAL(SP) :: er, psi1(3), psi2(20), r1m4, s, tol, x
    REAL(SP), PARAMETER :: euler = 0.5772156649015328606_SP
    !* FIRST EXECUTABLE STATEMENT  QCPSI
    r1m4 = eps_sp
    tol = 1000._SP*MAX(r1m4,1.E-18_SP)
    IF( Kprint>=3 ) WRITE (Lun,99001)
    99001 FORMAT ('1 QUICK CHECK DIAGNOSTICS FOR PSIFN'//)
    !-----------------------------------------------------------------------
    !     CHECK PSI(I) AND PSI(I-0.5), I=1,2,...
    !-----------------------------------------------------------------------
    iflg = 0
    n = 0
    DO kode = 1, 2
      DO m = 1, 2
        s = -euler + (m-1)*(-2._SP*LOG(2._SP))
        x = 1._SP - (m-1)*0.5_SP
        DO i = 1, 20
          CALL PSIFN(x,n,kode,1,psi2,nz,ierr)
          psi1(1) = -s + (kode-1)*LOG(x)
          er = ABS((psi1(1)-psi2(1))/psi1(1))
          IF( er>tol ) THEN
            IF( iflg==0 ) THEN
              IF( Kprint>=2 ) WRITE (Lun,99004)
            END IF
            iflg = iflg + 1
            IF( Kprint>=2 ) WRITE (Lun,99005) x, psi1(1), psi2(i), er, kode, n
            IF( iflg>200 ) GOTO 100
          END IF
          s = s + 1._SP/x
          x = x + 1._SP
        END DO
      END DO
    END DO
    !-----------------------------------------------------------------------
    !     CHECK SMALL X<UNIT ROUNDOFF
    !-----------------------------------------------------------------------
    kode = 1
    x = tol/10000._SP
    n = 1
    CALL PSIFN(x,n,kode,1,psi2,nz,ierr)
    psi1(1) = x**(-n-1)
    er = ABS((psi1(1)-psi2(1))/psi1(1))
    IF( er>tol ) THEN
      IF( iflg==0 ) THEN
        IF( Kprint>=2 ) WRITE (Lun,99004)
      END IF
      iflg = iflg + 1
      IF( Kprint>=2 ) WRITE (Lun,99005) x, psi1(1), psi2(1), er, kode, n
    END IF
    !-----------------------------------------------------------------------
    !     CONSISTENCY TESTS FOR N>=0
    !-----------------------------------------------------------------------
    DO kode = 1, 2
      DO m = 1, 5
        DO n = 1, 16, 5
          nn = n - 1
          x = 0.1_SP
          DO ix = 1, 25, 2
            x = x + 1._SP
            CALL PSIFN(x,nn,kode,m,psi2,nz,ierr)
            DO i = 1, m
              nm = nn + i - 1
              CALL PSIFN(x,nm,kode,1,psi1,nz,ierr)
              er = ABS((psi2(i)-psi1(1))/psi1(1))
              IF( er>=tol ) THEN
                IF( iflg==0 ) THEN
                  IF( Kprint>=2 ) WRITE (Lun,99004)
                END IF
                iflg = iflg + 1
                IF( Kprint>=2 ) WRITE (Lun,99005) x, psi1(1), psi2(i), er, kode, nm
              END IF
            END DO
          END DO
        END DO
      END DO
    END DO
    IF( iflg==0 .AND. Kprint>=3 ) THEN
      WRITE (Lun,99002)
      99002 FORMAT (//' QUICK CHECKS OK'//)
    END IF
    Ipass = 0
    IF( iflg==0 ) Ipass = 1
    RETURN
    100 CONTINUE
    IF( Kprint>=2 ) WRITE (Lun,99003)
    99003 FORMAT (//' PROCESSING OF MAIN LOOPS TERMINATED BECAUSE THE NUM',&
      'BER OF DIAGNOSTIC PRINTS EXCEEDS 200'//)
    Ipass = 0
    IF( iflg==0 ) Ipass = 1
    99004 FORMAT (8X,'X',13X,'PSI1',11X,'PSI2',9X,'REL ERR',5X,'KODE',3X,'N')
    99005 FORMAT (4E15.6,2I5)
  END SUBROUTINE QCPSI
END MODULE TEST07_MOD
!** TEST07
PROGRAM TEST07
  USE TEST07_MOD, ONLY : QCKIN, QCPSI
  USE ISO_FORTRAN_ENV, ONLY : INPUT_UNIT, OUTPUT_UNIT
  USE common_mod, ONLY : GET_ARGUMENT
  IMPLICIT NONE
  !> Driver for testing SLATEC subprograms
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C
  !***
  ! **Type:**      SINGLE PRECISION (TEST07-S, TEST08-D)
  !***
  ! **Keywords:**  QUICK CHECK DRIVER
  !***
  ! **Author:**  SLATEC Common Mathematical Library Committee
  !***
  ! **Description:**
  !
  !- Usage:
  !     One input data record is required
  !         READ (LIN, '(I1)') KPRINT
  !
  !- Arguments:
  !     KPRINT = 0  Quick checks - No printing.
  !                 Driver       - Short pass or fail message printed.
  !              1  Quick checks - No message printed for passed tests,
  !                                short message printed for failed tests.
  !                 Driver       - Short pass or fail message printed.
  !              2  Quick checks - Print short message for passed tests,
  !                                fuller information for failed tests.
  !                 Driver       - Pass or fail message printed.
  !              3  Quick checks - Print complete quick check results.
  !                 Driver       - Pass or fail message printed.
  !
  !- Description:
  !     Driver for testing SLATEC subprograms
  !        BSKIN    PSIFN
  !
  !***
  ! **References:**  Kirby W. Fong, Thomas H. Jefferson, Tokihiko Suyehiro
  !                 and Lee Walton, Guide to the SLATEC Common Mathema-
  !                 tical Library, April 10, 1990.
  !***
  ! **Routines called:**  I1MACH, QCKIN, QCPSI, XERMAX, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   890618  DATE WRITTEN
  !   890618  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900524  Cosmetic changes to code.  (WRB)
  INTEGER :: ipass, kprint, lin, lun, nfail
  !* FIRST EXECUTABLE STATEMENT  TEST07
  lun = OUTPUT_UNIT
  lin = INPUT_UNIT
  nfail = 0
  !
  !     Read KPRINT parameter
  !
  CALL GET_ARGUMENT(kprint)
  !
  !     Test single precision special function routines
  !
  CALL QCKIN(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  CALL QCPSI(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Write PASS or FAIL message
  !
  IF( nfail==0 ) THEN
    WRITE (lun,99001)
    99001 FORMAT (/' --------------TEST07 PASSED ALL TESTS----------------')
  ELSE
    WRITE (lun,99002) nfail
    99002 FORMAT (/' ************* WARNING -- ',I5,&
      ' TEST(S) FAILED IN PROGRAM TEST07  *************')
  END IF
  STOP
END PROGRAM TEST07
