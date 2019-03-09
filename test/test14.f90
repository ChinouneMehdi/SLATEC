MODULE TEST14_MOD
  IMPLICIT NONE

CONTAINS
  !DECK QCDRC
  SUBROUTINE QCDRC(Lun,Kprint,Ipass)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  QCDRC
    !***PURPOSE  Quick check for DRC.
    !***LIBRARY   SLATEC
    !***KEYWORDS  QUICK CHECK
    !***AUTHOR  Pexton, R. L., (LLNL)
    !***DESCRIPTION
    !
    !            QUICK TEST FOR CARLSON INTEGRAL DRC
    !
    !***ROUTINES CALLED  D1MACH, DRC, NUMXER, XERCLR, XGETF, XSETF
    !***REVISION HISTORY  (YYMMDD)
    !   790801  DATE WRITTEN
    !   890618  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   910708  Minor modifications in use of KPRINT.  (WRB)
    !***END PROLOGUE  QCDRC
    INTEGER Kprint, Ipass, contrl, kontrl, Lun, ier
    INTEGER ipass1, ipass2, ipass3, ipass4, NUMXER
    REAL(8) :: pi, trc, DRC, dif, D1MACH
    EXTERNAL D1MACH, DRC, NUMXER, XERCLR, XGETF, XSETF
    !***FIRST EXECUTABLE STATEMENT  QCDRC
    CALL XERCLR
    CALL XGETF(contrl)
    IF ( Kprint>=3 ) THEN
      kontrl = +1
    ELSE
      kontrl = 0
    ENDIF
    CALL XSETF(kontrl)
    !
    !  FORCE ERROR 1
    !
    IF ( Kprint>=3 ) WRITE (Lun,99001)
    99001 FORMAT (' DRC - FORCE ERROR 1 TO OCCUR')
    trc = DRC(-1.0D0,-1.0D0,ier)
    ier = NUMXER(ier)
    IF ( ier==1 ) THEN
      ipass1 = 1
    ELSE
      ipass1 = 0
    ENDIF
    CALL XERCLR
    !
    !  FORCE ERROR 2
    !
    IF ( Kprint>=3 ) WRITE (Lun,99002)
    99002 FORMAT (' DRC - FORCE ERROR 2 TO OCCUR')
    trc = DRC(D1MACH(1),D1MACH(1),ier)
    ier = NUMXER(ier)
    IF ( ier==2 ) THEN
      ipass2 = 1
    ELSE
      ipass2 = 0
    ENDIF
    CALL XERCLR
    !
    !  FORCE ERROR 3
    !
    IF ( Kprint>=3 ) WRITE (Lun,99003)
    99003 FORMAT (' DRC - FORCE ERROR 3 TO OCCUR')
    trc = DRC(D1MACH(2),D1MACH(2),ier)
    ier = NUMXER(ier)
    IF ( ier==3 ) THEN
      ipass3 = 1
    ELSE
      ipass3 = 0
    ENDIF
    CALL XERCLR
    !
    !  ARGUMENTS IN RANGE
    !
    pi = 3.141592653589793238462643383279D0
    trc = DRC(0.0D0,0.25D0,ier)
    CALL XERCLR
    dif = trc - pi
    IF ( (ABS(dif/pi)<1000.0D0*D1MACH(4)).AND.(ier==0) ) THEN
      ipass4 = 1
    ELSE
      ipass4 = 0
    ENDIF
    Ipass = MIN(ipass1,ipass2,ipass3,ipass4)
    IF ( Kprint<=0 ) THEN
    ELSEIF ( Kprint==1 ) THEN
      IF ( Ipass/=1 ) WRITE (Lun,99006)
    ELSEIF ( Ipass==1 ) THEN
      WRITE (Lun,99004)
      99004 FORMAT (' DRC - PASSED')
    ELSE
      WRITE (Lun,99006)
      IF ( ipass4==0 ) WRITE (Lun,99005) pi, trc, dif
      99005 FORMAT (' CORRECT ANSWER =',1PD20.14/'COMPUTED ANSWER =',&
        D20.14/'     DIFFERENCE =',D20.14)
    ENDIF
    CALL XSETF(contrl)
    99006 FORMAT (' DRC - FAILED')
  END SUBROUTINE QCDRC
  !DECK QCDRD
  SUBROUTINE QCDRD(Lun,Kprint,Ipass)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  QCDRD
    !***PURPOSE  Quick check for DRD.
    !***LIBRARY   SLATEC
    !***KEYWORDS  QUICK CHECK
    !***AUTHOR  Pexton, R. L., (LLNL)
    !***DESCRIPTION
    !
    !            QUICK TEST FOR CARLSON INTEGRAL DRD
    !
    !***ROUTINES CALLED  D1MACH, DRD, NUMXER, XERCLR, XGETF, XSETF
    !***REVISION HISTORY  (YYMMDD)
    !   790801  DATE WRITTEN
    !   890618  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   910708  Minor modifications in use of KPRINT.  (WRB)
    !   930214  Added more digits to BLEM.  (WRB)
    !***END PROLOGUE  QCDRD
    INTEGER Kprint, Ipass, contrl, kontrl, Lun, ier
    INTEGER ipass1, ipass2, ipass3, ipass4, NUMXER
    REAL(8) :: blem, trd, DRD, dif, D1MACH
    EXTERNAL D1MACH, DRD, NUMXER, XERCLR, XGETF, XSETF
    !***FIRST EXECUTABLE STATEMENT  QCDRD
    CALL XERCLR
    CALL XGETF(contrl)
    IF ( Kprint>=3 ) THEN
      kontrl = +1
    ELSE
      kontrl = 0
    ENDIF
    CALL XSETF(kontrl)
    !
    !  FORCE ERROR 1
    !
    IF ( Kprint>=3 ) WRITE (Lun,99001)
    99001 FORMAT (' DRD - FORCE ERROR 1 TO OCCUR')
    trd = DRD(-1.0D0,-1.0D0,-1.0D0,ier)
    ier = NUMXER(ier)
    IF ( ier==1 ) THEN
      ipass1 = 1
    ELSE
      ipass1 = 0
    ENDIF
    CALL XERCLR
    !
    !  FORCE ERROR 2
    !
    IF ( Kprint>=3 ) WRITE (Lun,99002)
    99002 FORMAT (' DRD - FORCE ERROR 2 TO OCCUR')
    trd = DRD(1.0D0,1.0D0,-1.0D0,ier)
    ier = NUMXER(ier)
    IF ( ier==2 ) THEN
      ipass2 = 1
    ELSE
      ipass2 = 0
    ENDIF
    CALL XERCLR
    !
    !  FORCE ERROR 3
    !
    IF ( Kprint>=3 ) WRITE (Lun,99003)
    99003 FORMAT (' DRD - FORCE ERROR 3 TO OCCUR')
    trd = DRD(D1MACH(2),D1MACH(2),D1MACH(2),ier)
    ier = NUMXER(ier)
    IF ( ier==3 ) THEN
      ipass3 = 1
    ELSE
      ipass3 = 0
    ENDIF
    CALL XERCLR
    !
    !  ARGUMENTS IN RANGE
    !  BLEM=3 * LEMNISCATE CONSTANT B
    !
    blem = 1.797210352103388311159883738420485817341D0
    trd = DRD(0.0D0,2.0D0,1.0D0,ier)
    CALL XERCLR
    dif = trd - blem
    IF ( (ABS(dif/blem)<1000.0D0*D1MACH(4)).AND.(ier==0) ) THEN
      ipass4 = 1
    ELSE
      Ipass = 0
    ENDIF
    Ipass = MIN(ipass1,ipass2,ipass3,ipass4)
    IF ( Kprint<=0 ) THEN
    ELSEIF ( Kprint==1 ) THEN
      IF ( Ipass/=1 ) WRITE (Lun,99006)
    ELSEIF ( Ipass==1 ) THEN
      WRITE (Lun,99004)
      99004 FORMAT (' DRD - PASSED')
    ELSE
      WRITE (Lun,99006)
      IF ( ipass4==0 ) WRITE (Lun,99005) blem, trd, dif
      99005 FORMAT (' CORRECT ANSWER =',1PD20.14/'COMPUTED ANSWER =',&
        D20.14/'     DIFFERENCE =',D20.14)
    ENDIF
    CALL XSETF(contrl)
    99006 FORMAT (' DRD - FAILED')
  END SUBROUTINE QCDRD
  !DECK QCDRF
  SUBROUTINE QCDRF(Lun,Kprint,Ipass)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  QCDRF
    !***PURPOSE  Quick check for DRF.
    !***LIBRARY   SLATEC
    !***KEYWORDS  QUICK CHECK
    !***AUTHOR  Pexton, R. L., (LLNL)
    !***DESCRIPTION
    !
    !            QUICK TEST FOR CARLSON INTEGRAL DRF
    !
    !***ROUTINES CALLED  D1MACH, DRF, NUMXER, XERCLR, XGETF, XSETF
    !***REVISION HISTORY  (YYMMDD)
    !   790801  DATE WRITTEN
    !   890618  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   910708  Minor modifications in use of KPRINT.  (WRB)
    !   930214  Added more digits to ALEM.  (WRB)
    !***END PROLOGUE  QCDRF
    INTEGER Kprint, Ipass, contrl, kontrl, Lun, ier
    INTEGER ipass1, ipass2, ipass3, ipass4, NUMXER
    REAL(8) :: alem, trf, DRF, dif, D1MACH
    EXTERNAL D1MACH, DRF, NUMXER, XERCLR, XGETF, XSETF
    !***FIRST EXECUTABLE STATEMENT  QCDRF
    CALL XERCLR
    CALL XGETF(contrl)
    IF ( Kprint>=3 ) THEN
      kontrl = +1
    ELSE
      kontrl = 0
    ENDIF
    CALL XSETF(kontrl)
    !
    !  FORCE ERROR 1
    !
    IF ( Kprint>=3 ) WRITE (Lun,99001)
    99001 FORMAT (' DRF - FORCE ERROR 1 TO OCCUR')
    trf = DRF(-1.0D0,-1.0D0,-1.0D0,ier)
    ier = NUMXER(ier)
    IF ( ier==1 ) THEN
      ipass1 = 1
    ELSE
      ipass1 = 0
    ENDIF
    CALL XERCLR
    !
    !  FORCE ERROR 2
    !
    IF ( Kprint>=3 ) WRITE (Lun,99002)
    99002 FORMAT (' DRF - FORCE ERROR 2 TO OCCUR')
    trf = DRF(D1MACH(1),D1MACH(1),D1MACH(1),ier)
    ier = NUMXER(ier)
    IF ( ier==2 ) THEN
      ipass2 = 1
    ELSE
      ipass2 = 0
    ENDIF
    CALL XERCLR
    !
    !  FORCE ERROR 3
    !
    IF ( Kprint>=3 ) WRITE (Lun,99003)
    99003 FORMAT (' DRF - FORCE ERROR 3 TO OCCUR')
    trf = DRF(D1MACH(2),D1MACH(2),D1MACH(2),ier)
    ier = NUMXER(ier)
    IF ( ier==3 ) THEN
      ipass3 = 1
    ELSE
      ipass3 = 0
    ENDIF
    CALL XERCLR
    !
    !  ARGUMENTS IN RANGE
    !  ALEM=LEMNISCATE CONSTANT A
    !
    alem = 1.3110287771460599052324197949455597068D0
    trf = DRF(0.0D0,1.0D0,2.0D0,ier)
    CALL XERCLR
    dif = trf - alem
    IF ( (ABS(dif/alem)<1000.0D0*D1MACH(4)).AND.(ier==0) ) THEN
      ipass4 = 1
    ELSE
      ipass4 = 0
    ENDIF
    Ipass = MIN(ipass1,ipass2,ipass3,ipass4)
    IF ( Kprint==0 ) THEN
    ELSEIF ( Kprint==1 ) THEN
      IF ( Ipass/=1 ) WRITE (Lun,99006)
    ELSEIF ( Ipass==1 ) THEN
      WRITE (Lun,99004)
      99004 FORMAT (' DRF - PASSED')
    ELSE
      WRITE (Lun,99006)
      IF ( ipass4==0 ) WRITE (Lun,99005) alem, trf, dif
      99005 FORMAT (' CORRECT ANSWER =',1PD20.14/'COMPUTED ANSWER =',&
        D20.14/'     DIFFERENCE =',D20.14)
    ENDIF
    CALL XSETF(contrl)
    99006 FORMAT (' DRF - FAILED')
  END SUBROUTINE QCDRF
  !DECK QCDRJ
  SUBROUTINE QCDRJ(Lun,Kprint,Ipass)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  QCDRJ
    !***PURPOSE  Quick check for DRJ.
    !***LIBRARY   SLATEC
    !***KEYWORDS  QUICK CHECK
    !***AUTHOR  Pexton, R. L., (LLNL)
    !***DESCRIPTION
    !
    !            QUICK TEST FOR CARLSON INTEGRAL DRJ
    !
    !***ROUTINES CALLED  D1MACH, DRJ, NUMXER, XERCLR, XGETF, XSETF
    !***REVISION HISTORY  (YYMMDD)
    !   790801  DATE WRITTEN
    !   890618  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   910708  Minor modifications in use of KPRINT.  (WRB)
    !   930214  Added more digits to CONSJ.  (WRB)
    !***END PROLOGUE  QCDRJ
    INTEGER Kprint, Ipass, contrl, kontrl, Lun, ier
    INTEGER ipass1, ipass2, ipass3, ipass4, NUMXER
    REAL(8) :: consj, trj, DRJ, dif, D1MACH
    EXTERNAL D1MACH, DRJ, NUMXER, XERCLR, XGETF, XSETF
    !***FIRST EXECUTABLE STATEMENT  QCDRJ
    CALL XERCLR
    CALL XGETF(contrl)
    IF ( Kprint>=3 ) THEN
      kontrl = +1
    ELSE
      kontrl = 0
    ENDIF
    CALL XSETF(kontrl)
    !
    !  FORCE ERROR 1
    !
    IF ( Kprint>=3 ) WRITE (Lun,99001)
    99001 FORMAT (' DRJ - FORCE ERROR 1 TO OCCUR')
    trj = DRJ(-1.0D0,-1.0D0,-1.0D0,-1.0D0,ier)
    ier = NUMXER(ier)
    IF ( ier==1 ) THEN
      ipass1 = 1
    ELSE
      ipass1 = 0
    ENDIF
    CALL XERCLR
    !
    !  FORCE ERROR 2
    !
    IF ( Kprint>=3 ) WRITE (Lun,99002)
    99002 FORMAT (' DRJ - FORCE ERROR 2 TO OCCUR')
    trj = DRJ(D1MACH(1),D1MACH(1),D1MACH(1),D1MACH(1),ier)
    ier = NUMXER(ier)
    IF ( ier==2 ) THEN
      ipass2 = 1
    ELSE
      ipass2 = 0
    ENDIF
    CALL XERCLR
    !
    !  FORCE ERROR 3
    !
    IF ( Kprint>=3 ) WRITE (Lun,99003)
    99003 FORMAT (' DRJ - FORCE ERROR 3 TO OCCUR')
    trj = DRJ(D1MACH(2),D1MACH(2),D1MACH(2),D1MACH(2),ier)
    ier = NUMXER(ier)
    IF ( ier==3 ) THEN
      ipass3 = 1
    ELSE
      ipass3 = 0
    ENDIF
    CALL XERCLR
    !
    !  ARGUMENTS IN RANGE
    !
    consj = 0.14297579667156753833233879421985774801D0
    trj = DRJ(2.0D0,3.0D0,4.0D0,5.0D0,ier)
    CALL XERCLR
    dif = trj - consj
    IF ( (ABS(dif/consj)<1000.0D0*D1MACH(4)).AND.(ier==0) ) THEN
      ipass4 = 1
    ELSE
      ipass4 = 0
    ENDIF
    Ipass = MIN(ipass1,ipass2,ipass3,ipass4)
    IF ( Kprint<=0 ) THEN
    ELSEIF ( Kprint==1 ) THEN
      IF ( Ipass/=1 ) WRITE (Lun,99006)
    ELSEIF ( Ipass==1 ) THEN
      WRITE (Lun,99004)
      99004 FORMAT (' DRJ - PASSED')
    ELSE
      WRITE (Lun,99006)
      IF ( ipass4==0 ) WRITE (Lun,99005) consj, trj, dif
      99005 FORMAT (' CORRECT ANSWER =',1PD20.14/'COMPUTED ANSWER =',&
        D20.14/'     DIFFERENCE =',D20.14)
    ENDIF
    CALL XSETF(contrl)
    99006 FORMAT (' DRJ - FAILED')
  END SUBROUTINE QCDRJ
END MODULE TEST14_MOD
!DECK TEST14
PROGRAM TEST14
  USE TEST14_MOD
  IMPLICIT NONE
  INTEGER I1MACH
  !***BEGIN PROLOGUE  TEST14
  !***PURPOSE  Driver for testing SLATEC subprograms
  !***LIBRARY   SLATEC
  !***CATEGORY  C14
  !***TYPE      DOUBLE PRECISION (TEST13-S, TEST14-D)
  !***KEYWORDS  QUICK CHECK DRIVER
  !***AUTHOR  SLATEC Common Mathematical Library Committee
  !***DESCRIPTION
  !
  ! *Usage:
  !     One input data record is required
  !         READ (LIN, '(I1)') KPRINT
  !
  ! *Arguments:
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
  ! *Description:
  !     Driver for testing SLATEC subprograms
  !        DRC      DRD      DRF      DRJ
  !
  !***REFERENCES  Kirby W. Fong, Thomas H. Jefferson, Tokihiko Suyehiro
  !                 and Lee Walton, Guide to the SLATEC Common Mathema-
  !                 tical Library, April 10, 1990.
  !***ROUTINES CALLED  I1MACH, QCDRC, QCDRD, QCDRF, QCDRJ, XERMAX, XSETF,
  !                    XSETUN
  !***REVISION HISTORY  (YYMMDD)
  !   890618  DATE WRITTEN
  !   890618  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900524  Cosmetic changes to code.  (WRB)
  !***END PROLOGUE  TEST14
  INTEGER ipass, kprint, lin, lun, nfail
  !***FIRST EXECUTABLE STATEMENT  TEST14
  lun = I1MACH(2)
  lin = I1MACH(1)
  nfail = 0
  !
  !     Read KPRINT parameter
  !
  CALL GET_ARGUMENT(kprint)
  CALL XERMAX(1000)
  CALL XSETUN(lun)
  IF ( kprint<=1 ) THEN
    CALL XSETF(0)
  ELSE
    CALL XSETF(1)
  ENDIF
  !
  !     Test double precision Carlson elliptic routines
  !
  CALL QCDRC(lun,kprint,ipass)
  IF ( ipass==0 ) nfail = nfail + 1
  CALL QCDRD(lun,kprint,ipass)
  IF ( ipass==0 ) nfail = nfail + 1
  CALL QCDRF(lun,kprint,ipass)
  IF ( ipass==0 ) nfail = nfail + 1
  CALL QCDRJ(lun,kprint,ipass)
  IF ( ipass==0 ) nfail = nfail + 1
  !
  !     Write PASS or FAIL message
  !
  IF ( nfail==0 ) THEN
    WRITE (lun,99001)
    99001 FORMAT (/' --------------TEST14 PASSED ALL TESTS----------------')
  ELSE
    WRITE (lun,99002) nfail
    99002 FORMAT (/' ************* WARNING -- ',I5,&
      ' TEST(S) FAILED IN PROGRAM TEST14  *************')
  ENDIF
  STOP
END PROGRAM TEST14