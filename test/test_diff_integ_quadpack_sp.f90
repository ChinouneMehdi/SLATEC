MODULE TEST39_MOD
  USE service, ONLY : SP, DP
  IMPLICIT NONE

CONTAINS
  !** CQAG
  SUBROUTINE CQAG(Lun,Kprint,Ipass)
    !> Quick check for QAG.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQAG-S, CDQAG-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, F1G, F2G, F3G, QAG, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    USE service, ONLY : eps_sp
    USE diff_integ, ONLY : QAG

    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: ierv(2), Lun
    REAL(SP) :: a, abserr, b, epmach, epsabs, epsrel, error, result, work(400)
    INTEGER :: ier, ip, Ipass, iwork(100), key, Kprint, last, lenw, limit, neval
    REAL(SP), PARAMETER :: exact1 = 0.1154700538379252E+01_SP
    !* FIRST EXECUTABLE STATEMENT  CQAG
    IF( Kprint>=2 ) WRITE (Lun,'(''1QAG QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    limit = 100
    lenw = limit*4
    epsabs = 0._SP
    epmach = eps_sp
    key = 6
    epsrel = MAX(SQRT(epmach),0.1E-7_SP)
    a = 0._SP
    b = 1._SP
    CALL QAG(F1G,a,b,epsabs,epsrel,key,result,abserr,neval,ier,limit,lenw,&
      last,iwork,work)
    ierv(1) = ier
    ip = 0
    error = ABS(exact1-result)
    IF( ier==0 .AND. error<=abserr .AND. abserr<=epsrel*ABS(exact1) ) ip = 1
    IF( ip==0 ) Ipass = 0
    CALL CPRIN(Lun,0,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    limit = 1
!    lenw = limit*4
!    b = pi*2._SP
!    CALL QAG(F2G,a,b,epsabs,epsrel,key,result,abserr,neval,ier,limit,lenw,&
!      last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,1,Kprint,ip,exact2,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 2 OR 1
    !
!    uflow = tiny_sp
!    limit = 100
!    lenw = limit*4
!    CALL QAG(F2G,a,b,uflow,0._SP,key,result,abserr,neval,ier,limit,lenw,&
!      last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 1
!    ip = 0
!    IF( ier==2 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,2,Kprint,ip,exact2,result,abserr,neval,ierv,2)
    !
    ! TEST ON IER = 3 OR 1
    !
!    b = 1._SP
!    CALL QAG(F3G,a,b,epsabs,epsrel,1,result,abserr,neval,ier,limit,lenw,last,&
!      iwork,work)
!    ierv(1) = ier
!    ierv(2) = 1
!    ip = 0
!    IF( ier==3 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,3,Kprint,ip,exact3,result,abserr,neval,ierv,2)
    !
    ! TEST ON IER = 6
    !
!    lenw = 1
!    CALL QAG(F1G,a,b,epsabs,epsrel,key,result,abserr,neval,ier,limit,lenw,&
!      last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 .AND. result==0._SP .AND. abserr==0._SP .AND. neval==0 .AND. &
!      last==0 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,6,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQAG FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQAG PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQAG
  !** CQAGI
  SUBROUTINE CQAGI(Lun,Kprint,Ipass)
    !> Quick check for QAGI.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQAGI-S, CDQAGI-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, QAGI, R1MACH, T0, T1, T2, T3, T4, T5

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891009  Removed unreferenced variables.  (WRB)
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    USE service, ONLY : eps_sp
    USE diff_integ, ONLY : QAGI

    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: ierv(4), inf
    REAL(SP) :: abserr, bound, epmach, epsabs, epsrel, error, result, work(800)
    INTEGER :: ier, ip, Ipass, iwork(200), Kprint, last, lenw, limit, Lun, neval
    REAL(SP), PARAMETER :: exact0 = 2._SP
    !* FIRST EXECUTABLE STATEMENT  CQAGI
    IF( Kprint>=2 ) WRITE (Lun,'(''1QAGI QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    limit = 200
    lenw = limit*4
    epsabs = 0._SP
    epmach = eps_sp
    epsrel = MAX(SQRT(epmach),0.1E-7_SP)
    bound = 0._SP
    inf = 1
    CALL QAGI(T0,bound,inf,epsabs,epsrel,result,abserr,neval,ier,limit,lenw,&
      last,iwork,work)
    error = ABS(result-exact0)
    ierv(1) = ier
    ip = 0
    IF( ier==0 .AND. error<=abserr .AND. abserr<=epsrel*ABS(exact0) ) ip = 1
    IF( ip==0 ) Ipass = 0
    CALL CPRIN(Lun,0,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    CALL QAGI(T1,bound,inf,epsabs,epsrel,result,abserr,neval,ier,1,4,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,1,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 2 OR 4 OR 1
    !
!    uflow = tiny_sp
!    CALL QAGI(T2,bound,inf,uflow,0._SP,result,abserr,neval,ier,limit,lenw,&
!      last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ip = 0
!    IF( ier==2 .OR. ier==4 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,2,Kprint,ip,exact2,result,abserr,neval,ierv,3)
    !
    ! TEST ON IER = 3 OR 4 OR 1
    !
!    CALL QAGI(T3,bound,inf,uflow,0._SP,result,abserr,neval,ier,limit,lenw,&
!      last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ip = 0
!    IF( ier==3 .OR. ier==4 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,3,Kprint,ip,exact3,result,abserr,neval,ierv,3)
    !
    ! TEST ON IER = 4 OR 3 OR 1
    !
!    CALL QAGI(T4,bound,inf,epsabs,epsrel,result,abserr,neval,ier,limit,lenw,&
!      last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 3
!    ierv(3) = 1
!    ierv(4) = 2
!    ip = 0
!    IF( ier==4 .OR. ier==3 .OR. ier==1 .OR. ier==2 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,4,Kprint,ip,exact4,result,abserr,neval,ierv,4)
    !
    ! TEST ON IER = 5
    !
!    oflow = huge_sp
!    CALL QAGI(T5,bound,inf,epsabs,epsrel,result,abserr,neval,ier,limit,lenw,&
!      last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==5 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,5,Kprint,ip,oflow,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 6
    !
!    CALL QAGI(T1,bound,inf,epsabs,0._SP,result,abserr,neval,ier,limit,lenw,&
!      last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 .AND. result==0._SP .AND. abserr==0._SP .AND. neval==0 .AND. &
!      last==0 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,6,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQAGI FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQAGI PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQAGI
  !** CQAGP
  SUBROUTINE CQAGP(Lun,Kprint,Ipass)
    !> Quick check for QAGP.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQAGP-S, CDQAGP-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, F1P, F2P, F3P, F4P, QAGP, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    USE service, ONLY : eps_sp
    USE diff_integ, ONLY : QAGP

    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: ierv(4)
    REAL(SP) :: a, abserr, b, epmach, epsabs, epsrel, error, &
      points(5), result, work(405)
    INTEGER :: ier, ip, Ipass, iwork(205), Kprint, last, leniw, lenw, limit, &
      Lun, neval, npts2
    REAL(SP), PARAMETER :: exact1 = 0.4285277667368085E+01_SP
    REAL(SP), PARAMETER :: p1 = 0.1428571428571428_SP
    REAL(SP), PARAMETER :: p2 = 0.6666666666666667_SP
    !* FIRST EXECUTABLE STATEMENT  CQAGP
    IF( Kprint>=2 ) WRITE (Lun,'(''1QAGP QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    npts2 = 4
    limit = 100
    leniw = limit*2 + npts2
    lenw = limit*4 + npts2
    epsabs = 0._SP
    epmach = eps_sp
    epsrel = MAX(SQRT(epmach),0.1E-7_SP)
    a = 0._SP
    b = 1._SP
    points(1) = p1
    points(2) = p2
    CALL QAGP(F1P,a,b,npts2,points,epsabs,epsrel,result,abserr,neval,ier,&
      leniw,lenw,last,iwork,work)
    error = ABS(result-exact1)
    ierv(1) = ier
    ip = 0
    IF( ier==0 .AND. error<=epsrel*ABS(exact1) ) ip = 1
    IF( ip==0 ) Ipass = 0
    CALL CPRIN(Lun,0,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    leniw = 10
!    lenw = leniw*2 - npts2
!    CALL QAGP(F1P,a,b,npts2,points,epsabs,epsrel,result,abserr,neval,ier,&
!      leniw,lenw,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,1,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 2, 4, 1 OR 3
    !
!    npts2 = 3
!    points(1) = 0.1_SP
!    leniw = limit*2 + npts2
!    lenw = limit*4 + npts2
!    uflow = tiny_sp
!    a = 0.1_SP
!    CALL QAGP(F2P,a,b,npts2,points,uflow,0._SP,result,abserr,neval,ier,&
!      leniw,lenw,last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ierv(4) = 3
!    ip = 0
!    IF( ier==2 .OR. ier==4 .OR. ier==1 .OR. ier==3 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,2,Kprint,ip,exact2,result,abserr,neval,ierv,4)
    !
    ! TEST ON IER = 3 OR 4 OR 1 OR 2
    !
!    npts2 = 2
!    leniw = limit*2 + npts2
!    lenw = limit*4 + npts2
!    a = 0._SP
!    b = 5._SP
!    CALL QAGP(F3P,a,b,npts2,points,uflow,0._SP,result,abserr,neval,ier,&
!      leniw,lenw,last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ierv(4) = 2
!    ip = 0
!    IF( ier==3 .OR. ier==4 .OR. ier==1 .OR. ier==2 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,3,Kprint,ip,exact3,result,abserr,neval,ierv,4)
    !
    ! TEST ON IER = 5
    !
!    b = 1._SP
!    CALL QAGP(F4P,a,b,npts2,points,epsabs,epsrel,result,abserr,neval,ier,&
!      leniw,lenw,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==5 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    oflow = huge_sp
!    CALL CPRIN(Lun,5,Kprint,ip,oflow,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 6
    !
!    npts2 = 5
!    leniw = limit*2 + npts2
!    lenw = limit*4 + npts2
!    points(1) = p1
!    points(2) = p2
!    points(3) = 0.3E+01
!    CALL QAGP(F1P,a,b,npts2,points,epsabs,epsrel,result,abserr,neval,ier,&
!      leniw,lenw,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 .AND. result==0._SP .AND. abserr==0._SP .AND. neval==0 .AND. &
!      last==0 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,6,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQAGP FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQAGP PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQAGP
  !** CQAGS
  SUBROUTINE CQAGS(Lun,Kprint,Ipass)
    !> Quick check for QAGS.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQAGS-S, CDQAGS-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, F0S, F1S, F2S, F3S, F4S, F5S, QAGS, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    !   911114  Modified test on IER=4 to allow IER=5.  (WRB)
    USE service, ONLY : eps_sp
    USE diff_integ, ONLY : QAGS

    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: ierv(5), Lun
    REAL(SP) :: a, abserr, b, epmach, epsabs, epsrel, error, result, work(800)
    INTEGER :: ier, ip, Ipass, iwork(200), Kprint, last, lenw, limit, neval
    REAL(SP), PARAMETER :: exact0 = 2._SP
    !* FIRST EXECUTABLE STATEMENT  CQAGS
    IF( Kprint>=2 ) WRITE (Lun,'(''1QAGS QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    limit = 200
    lenw = limit*4
    epsabs = 0._SP
    epmach = eps_sp
    epsrel = MAX(SQRT(epmach),0.1E-7_SP)
    a = 0._SP
    b = 1._SP
    CALL QAGS(F0S,a,b,epsabs,epsrel,result,abserr,neval,ier,limit,lenw,last,&
      iwork,work)
    error = ABS(result-exact0)
    ierv(1) = ier
    ip = 0
    IF( ier==0 .AND. error<=abserr .AND. abserr<=epsrel*ABS(exact0) ) ip = 1
    IF( ip==0 ) Ipass = 0
    CALL CPRIN(Lun,0,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    CALL QAGS(F1S,a,b,epsabs,epsrel,result,abserr,neval,ier,1,4,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,1,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 2 OR 4 OR 1
    !
!    uflow = tiny_sp
!    a = 0.1_SP
!    CALL QAGS(F2S,a,b,uflow,0._SP,result,abserr,neval,ier,limit,lenw,last,&
!      iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ip = 0
!    IF( ier==2 .OR. ier==4 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,2,Kprint,ip,exact2,result,abserr,neval,ierv,3)
    !
    ! TEST ON IER = 3 OR 4 OR 1 OR 2
    !
!    a = 0._SP
!    b = 5._SP
!    CALL QAGS(F3S,a,b,uflow,0._SP,result,abserr,neval,ier,limit,lenw,last,&
!      iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ierv(4) = 2
!    ip = 0
!    IF( ier==3 .OR. ier==4 .OR. ier==1 .OR. ier==2 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,3,Kprint,ip,exact3,result,abserr,neval,ierv,4)
    !
    ! TEST ON IER = 4, OR 5 OR 3 OR 1 OR 0
    !
!    b = 1._SP
!    epsrel = 1.E-4_SP
!    CALL QAGS(F4S,a,b,epsabs,epsrel,result,abserr,neval,ier,limit,lenw,last,&
!      iwork,work)
!    !      IER=4
!    ierv(1) = ier
!    ierv(2) = 5
!    ierv(3) = 3
!    ierv(4) = 1
!    ierv(5) = 0
!    ip = 0
!    IF( ier==5 .OR. ier==4 .OR. ier==3 .OR. ier==1 .OR. ier==0 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,4,Kprint,ip,exact4,result,abserr,neval,ierv,5)
    !
    ! TEST ON IER = 5
    !
!    oflow = huge_sp
!    CALL QAGS(F5S,a,b,epsabs,epsrel,result,abserr,neval,ier,limit,lenw,last,&
!      iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==5 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,5,Kprint,ip,oflow,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 6
    !
!    CALL QAGS(F1S,a,b,epsabs,0._SP,result,abserr,neval,ier,limit,lenw,last,&
!      iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 .AND. result==0._SP .AND. abserr==0._SP .AND. neval==0 .AND. &
!      last==0 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,6,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQAGS FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQAGS PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQAGS
  !** CQAWC
  SUBROUTINE CQAWC(Lun,Kprint,Ipass)
    !> Quick check for QAWC.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQAWC-S, CDQAWC-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, F0C, F1C, QAWC, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    USE service, ONLY : eps_sp
    USE diff_integ, ONLY : QAWC
    !
    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: ierv(2), Lun
    REAL(SP) :: a, abserr, b, epmach, epsabs, epsrel, error, c, result, work(800)
    INTEGER :: ier, ip, Ipass, iwork(200), Kprint, last, lenw, limit, neval
    REAL(SP), PARAMETER :: exact0 = -0.6284617285065624E+03_SP
    !* FIRST EXECUTABLE STATEMENT  CQAWC
    IF( Kprint>=2 ) WRITE (Lun,'(''1QAWC QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    c = 0.5_SP
    a = -1._SP
    b = 1._SP
    limit = 200
    lenw = limit*4
    epsabs = 0._SP
    epmach = eps_sp
    epsrel = MAX(SQRT(epmach),0.1E-7_SP)
    CALL QAWC(F0C,a,b,c,epsabs,epsrel,result,abserr,neval,ier,limit,lenw,last,&
      iwork,work)
    ierv(1) = ier
    ip = 0
    error = ABS(exact0-result)
    IF( ier==0 .AND. error<=abserr .AND. abserr<=epsrel*ABS(exact0) ) ip = 1
    IF( ip==0 ) Ipass = 0
    CALL CPRIN(Lun,0,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    CALL QAWC(F0C,a,b,c,epsabs,epsrel,result,abserr,neval,ier,1,4,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,1,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 2 OR 1
    !
!    uflow = tiny_sp
!    CALL QAWC(F0C,a,b,c,uflow,0._SP,result,abserr,neval,ier,limit,lenw,last,&
!      iwork,work)
!    ierv(1) = ier
!    ierv(2) = 1
!    ip = 0
!    IF( ier==2 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,2,Kprint,ip,exact0,result,abserr,neval,ierv,2)
    !
    ! TEST ON IER = 3 OR 1
    !
!    CALL QAWC(F1C,0._SP,b,c,uflow,0._SP,result,abserr,neval,ier,limit,&
!      lenw,last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 1
!    ip = 0
!    IF( ier==3 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,3,Kprint,ip,exact1,result,abserr,neval,ierv,2)
    !
    ! TEST ON IER = 6
    !
!    epsabs = 0._SP
!    epsrel = 0._SP
!    CALL QAWC(F0C,a,b,c,epsabs,epsrel,result,abserr,neval,ier,limit,lenw,last,&
!      iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,6,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQAWC FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQAWC PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQAWC
  !** CQAWF
  SUBROUTINE CQAWF(Lun,Kprint,Ipass)
    !> Quick check for QAWF.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQAWF-S, CDQAWF-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, F0F, F1F, QAWF, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    USE service, ONLY : eps_sp
    USE diff_integ, ONLY : QAWF
    !
    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: ierv(3), integr, iwork(450), leniw, Lun, maxp1
    REAL(SP) :: a, abserr, epsabs, epmach, error, omega, result, work(1425)
    INTEGER :: ier, ip, Ipass, Kprint, lenw, limit, limlst, lst, neval
    REAL(SP), PARAMETER :: exact0 = 0.1422552162575912E+01_SP
    !* FIRST EXECUTABLE STATEMENT  CQAWF
    IF( Kprint>=2 ) WRITE (Lun,'(''1QAWF QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    maxp1 = 21
    limlst = 50
    limit = 200
    leniw = limit*2 + limlst
    lenw = leniw*2 + maxp1*25
    epmach = eps_sp
    epsabs = MAX(SQRT(epmach),0.1E-02_SP)
    a = 0._SP
    omega = 0.8E+01
    integr = 2
    CALL QAWF(F0F,a,omega,integr,epsabs,result,abserr,neval,ier,limlst,lst,&
      leniw,maxp1,lenw,iwork,work)
    ierv(1) = ier
    ip = 0
    error = ABS(exact0-result)
    IF( ier==0 .AND. error<=abserr .AND. abserr<=epsabs ) ip = 1
    IF( ip==0 ) Ipass = 0
    CALL CPRIN(Lun,0,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    limlst = 3
!    leniw = 403
!    lenw = leniw*2 + maxp1*25
!    CALL QAWF(F0F,a,omega,integr,epsabs,result,abserr,neval,ier,limlst,lst,&
!      leniw,maxp1,lenw,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,1,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 3 OR 4 OR 1
    !
!    limlst = 50
!    leniw = limit*2 + limlst
!    lenw = leniw*2 + maxp1*25
!    uflow = tiny_sp
!    CALL QAWF(F1F,a,0._SP,1,uflow,result,abserr,neval,ier,limlst,lst,leniw,&
!      maxp1,lenw,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ip = 0
!    IF( ier==3 .OR. ier==4 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,3,Kprint,ip,pi,result,abserr,neval,ierv,3)
    !
    ! TEST ON IER = 6
    !
!    limlst = 50
!    leniw = 20
!    CALL QAWF(F0F,a,omega,integr,epsabs,result,abserr,neval,ier,limlst,lst,&
!      leniw,maxp1,lenw,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,6,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 7
    !
!    limlst = 50
!    leniw = 52
!    lenw = leniw*2 + maxp1*25
!    CALL QAWF(F0F,a,omega,integr,epsabs,result,abserr,neval,ier,limlst,lst,&
!      leniw,maxp1,lenw,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==7 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,7,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQAWF FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQAWF PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQAWF
  !** CQAWO
  SUBROUTINE CQAWO(Lun,Kprint,Ipass)
    !> Quick check for QAWO.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQAWO-S, CDQAWO-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, F0O, F1O, F2O, QAWO, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    USE service, ONLY : eps_sp
    USE diff_integ, ONLY : QAWO
    !
    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: leniw
    REAL(SP) :: a, abserr, b, epmach, epsabs, epsrel, error, omega, result, work(1325)
    INTEGER :: ier, ierv(4), integr, ip, Ipass, iwork(400), Kprint, last, lenw, &
      Lun, maxp1, neval
    REAL(SP), PARAMETER :: exact0 = 0.1042872789432789E+05_SP
    REAL(SP), PARAMETER :: pi = 0.31415926535897932E+01_SP
    !* FIRST EXECUTABLE STATEMENT  CQAWO
    IF( Kprint>=2 ) WRITE (Lun,'(''1QAWO QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    maxp1 = 21
    leniw = 400
    lenw = leniw*2 + maxp1*25
    epsabs = 0._SP
    epmach = eps_sp
    epsrel = MAX(SQRT(epmach),0.1E-7_SP)
    a = 0._SP
    b = pi
    omega = 1._SP
    integr = 2
    CALL QAWO(F0O,a,b,omega,integr,epsabs,epsrel,result,abserr,neval,ier,&
      leniw,maxp1,lenw,last,iwork,work)
    ierv(1) = ier
    ip = 0
    error = ABS(exact0-result)
    IF( ier==0 .AND. error<=abserr .AND. abserr<=epsrel*ABS(exact0) ) ip = 1
    IF( ip==0 ) Ipass = 0
    CALL CPRIN(Lun,0,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    leniw = 2
!    lenw = leniw*2 + maxp1*25
!    CALL QAWO(F0O,a,b,omega,integr,epsabs,epsrel,result,abserr,neval,ier,&
!      leniw,maxp1,lenw,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,1,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 2 OR 4 OR 1
    !
!    uflow = tiny_sp
!    leniw = 400
!    lenw = leniw*2 + maxp1*25
!    CALL QAWO(F0O,a,b,omega,integr,uflow,0._SP,result,abserr,neval,ier,&
!      leniw,maxp1,lenw,last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ip = 0
!    IF( ier==2 .OR. ier==4 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,2,Kprint,ip,exact0,result,abserr,neval,ierv,3)
    !
    ! TEST ON IER = 3 OR 4 OR 1
    !
!    b = 5._SP
!    omega = 0._SP
!    integr = 1
!    CALL QAWO(F1O,a,b,omega,integr,uflow,0._SP,result,abserr,neval,ier,&
!      leniw,maxp1,lenw,last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 4
!    ierv(3) = 1
!    ip = 0
!    IF( ier==3 .OR. ier==4 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,3,Kprint,ip,pi,result,abserr,neval,ierv,3)
    !
    ! TEST ON IER = 5
    !
!    b = 1._SP
!    oflow = huge_sp
!    CALL QAWO(F2O,a,b,omega,integr,epsabs,epsrel,result,abserr,neval,ier,&
!      leniw,maxp1,lenw,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==5 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,5,Kprint,ip,oflow,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 6
    !
!    integr = 3
!    CALL QAWO(F0O,a,b,omega,integr,epsabs,epsrel,result,abserr,neval,ier,&
!      leniw,maxp1,lenw,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 .AND. result==0._SP .AND. abserr==0._SP .AND. neval==0 .AND. &
!      last==0 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,6,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQAWO FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQAWO PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQAWO
  !** CQAWS
  SUBROUTINE CQAWS(Lun,Kprint,Ipass)
    !> Quick check for QAWS.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQAWS-S, CDQAWS-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, F0WS, F1WS, QAWS, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    USE service, ONLY : eps_sp
    USE diff_integ, ONLY : QAWS

    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: ierv(2), Lun
    REAL(SP) :: a, abserr, b, epmach, epsabs, epsrel, error, &
      alfa, beta, result, work(800)
    INTEGER :: ier, ip, Ipass, iwork(200), Kprint, last, lenw, limit, neval, integr
    REAL(SP), PARAMETER :: exact0 = 0.5350190569223644_SP
    !* FIRST EXECUTABLE STATEMENT  CQAWS
    IF( Kprint>=2 ) WRITE (Lun,'(''1QAWS QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    alfa = -0.5_SP
    beta = -0.5_SP
    integr = 1
    a = 0._SP
    b = 1._SP
    limit = 200
    lenw = limit*4
    epsabs = 0._SP
    epmach = eps_sp
    epsrel = MAX(SQRT(epmach),0.1E-7_SP)
    CALL QAWS(F0WS,a,b,alfa,beta,integr,epsabs,epsrel,result,abserr,neval,ier,&
      limit,lenw,last,iwork,work)
    ierv(1) = ier
    ip = 0
    error = ABS(exact0-result)
    IF( ier==0 .AND. error<=epsrel*ABS(exact0) ) ip = 1
    IF( ip==0 ) Ipass = 0
    CALL CPRIN(Lun,0,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    CALL QAWS(F0WS,a,b,alfa,beta,integr,epsabs,epsrel,result,abserr,neval,ier,&
!      2,8,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,1,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 2 OR 1
    !
!    uflow = tiny_sp
!    CALL QAWS(F0WS,a,b,alfa,beta,integr,uflow,0._SP,result,abserr,neval,ier,&
!      limit,lenw,last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 1
!    ip = 0
!    IF( ier==2 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,2,Kprint,ip,exact0,result,abserr,neval,ierv,2)
    !
    ! TEST ON IER = 3 OR 1
    !
!    CALL QAWS(F1WS,a,b,alfa,beta,integr,epsabs,epsrel,result,abserr,neval,ier,&
!      limit,lenw,last,iwork,work)
!    ierv(1) = ier
!    ierv(2) = 1
!    ip = 0
!    IF( ier==3 .OR. ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,3,Kprint,ip,exact1,result,abserr,neval,ierv,2)
    !
    ! TEST ON IER = 6
    !
!    integr = 0
!    CALL QAWS(F1WS,a,b,alfa,beta,integr,epsabs,epsrel,result,abserr,neval,ier,&
!      limit,lenw,last,iwork,work)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    CALL CPRIN(Lun,6,Kprint,ip,exact0,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQAWS FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQAWS PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQAWS
  !** CQNG
  SUBROUTINE CQNG(Lun,Kprint,Ipass)
    !> Quick check for QNG.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CQNG-S, CDQNG-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CPRIN, F1N, F2N, QNG, R1MACH

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901205  Added PASS/FAIL message and changed the name of the first argument.  (RWC)
    !   910501  Added PURPOSE and TYPE records.  (WRB)
    USE service, ONLY : eps_sp, tiny_sp
    USE diff_integ, ONLY : QNG

    ! FOR FURTHER DOCUMENTATION SEE ROUTINE CQPDOC
    INTEGER :: Lun
    REAL(SP) :: a, abserr, b, epmach, epsabs, epsrel, error, result, uflow
    INTEGER :: ier, ierv(1), ip, Ipass, Kprint, neval
    REAL(SP), PARAMETER :: exact1 = 0.7281029132255818_SP
    !* FIRST EXECUTABLE STATEMENT  CQNG
    IF( Kprint>=2 ) WRITE (Lun,'(''1QNG QUICK CHECK''/)')
    !
    ! TEST ON IER = 0
    !
    Ipass = 1
    epsabs = 0._SP
    epmach = eps_sp
    uflow = tiny_sp
    epsrel = MAX(SQRT(epmach),0.1E-07_SP)
    a = 0._SP
    b = 1._SP
    CALL QNG(F1N,a,b,epsabs,epsrel,result,abserr,neval,ier)
    ierv(1) = ier
    ip = 0
    error = ABS(exact1-result)
    IF( ier==0 .AND. error<=abserr .AND. abserr<=epsrel*ABS(exact1) ) ip = 1
    IF( ip==0 ) Ipass = 0
    IF( Kprint/=0 ) CALL CPRIN(Lun,0,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 1
    !
!    CALL QNG(F2N,a,b,uflow,0._SP,result,abserr,neval,ier)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==1 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    IF( Kprint/=0 ) CALL CPRIN(Lun,1,Kprint,ip,exact2,result,abserr,neval,ierv,1)
    !
    ! TEST ON IER = 6
    !
!    epsabs = 0._SP
!    epsrel = 0._SP
!    CALL QNG(F1N,a,b,epsabs,0._SP,result,abserr,neval,ier)
!    ierv(1) = ier
!    ip = 0
!    IF( ier==6 .AND. result==0._SP .AND. abserr==0._SP .AND. neval==0 ) ip = 1
!    IF( ip==0 ) Ipass = 0
!    IF( Kprint/=0 ) CALL CPRIN(Lun,6,Kprint,ip,exact1,result,abserr,neval,ierv,1)
    !
    IF( Kprint>=1 ) THEN
      IF( Ipass==0 ) THEN
        WRITE (Lun,'(/'' SOME TEST(S) IN CQNG FAILED''/)')
      ELSEIF( Kprint>=2 ) THEN
        WRITE (Lun,'(/'' ALL TEST(S) IN CQNG PASSED''/)')
      END IF
    END IF
  END SUBROUTINE CQNG
  !** F0C
  REAL(SP) PURE FUNCTION F0C(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F0C
    F0C = 1._SP/(X*X+1.E-4_SP)
  END FUNCTION F0C
  !** F0F
  REAL(SP) PURE FUNCTION F0F(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F0F
    F0F = 0._SP
    IF( X/=0._SP ) F0F = SIN(0.5E+02_SP*X)/(X*SQRT(X))
  END FUNCTION F0F
  !** F0O
  REAL(SP) PURE FUNCTION F0O(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F0O
    F0O = (2._SP*SIN(X))**14
  END FUNCTION F0O
  !** F0S
  REAL(SP) PURE FUNCTION F0S(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F0S
    F0S = 0._SP
    IF( X/=0.0 ) F0S = 1._SP/SQRT(X)
  END FUNCTION F0S
  !** F0WS
  REAL(SP) PURE FUNCTION F0WS(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F0WS
    F0WS = SIN(10._SP*X)
  END FUNCTION F0WS
  !** F1C
  REAL(SP) PURE FUNCTION F1C(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F1C
    F1C = 0._SP
    IF( X/=0.33_SP ) F1C = (X-0.5_SP)*ABS(X-0.33_SP)**(-0.9_SP)
  END FUNCTION F1C
  !** F1F
  REAL(SP) PURE FUNCTION F1F(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP) :: x1, y
    !* FIRST EXECUTABLE STATEMENT  F1F
    x1 = X + 1._SP
    F1F = 5._SP/x1/x1
    y = 5._SP/x1
    IF( y>3.1415926535897932 ) F1F = 0._SP
  END FUNCTION F1F
  !** F1G
  REAL(SP) PURE FUNCTION F1G(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP), PARAMETER :: pi = 3.1415926535897932_SP
    !* FIRST EXECUTABLE STATEMENT  F1G
    F1G = 2._SP/(2._SP+SIN(10._SP*pi*X))
  END FUNCTION F1G
  !** F1N
  REAL(SP) PURE FUNCTION F1N(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F1N
    F1N = 1._SP/(X**4+X**2+1._SP)
  END FUNCTION F1N
  !** F1O
  REAL(SP) PURE FUNCTION F1O(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F1O
    F1O = 1._SP
    IF( X>3.1415926535897932 ) F1O = 0._SP
  END FUNCTION F1O
  !** F1P
  REAL(SP) PURE FUNCTION F1P(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP) :: alfa1, alfa2, d1, d2
    !  P1 = 1/7, P2 = 2/3
    REAL(SP), PARAMETER :: p1 = 0.1428571428571428_SP
    REAL(SP), PARAMETER :: p2 = 0.6666666666666667_SP
    !* FIRST EXECUTABLE STATEMENT  F1P
    alfa1 = -0.25_SP
    alfa2 = -0.5_SP
    d1 = ABS(X-p1)
    d2 = ABS(X-p2)
    F1P = 0._SP
    IF( d1/=0._SP .AND. d2/=0._SP ) F1P = d1**alfa1 + d2**alfa2
  END FUNCTION F1P
  !** F1S
  REAL(SP) PURE FUNCTION F1S(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F1S
    F1S = 2._SP/(2._SP+SIN(0.314159E+02_SP*X))
  END FUNCTION F1S
  !** F1WS
  REAL(SP) PURE FUNCTION F1WS(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F1WS
    F1WS = ABS(X-0.33_SP)**(-0.999_SP)
  END FUNCTION F1WS
  !** F2G
  REAL(SP) PURE FUNCTION F2G(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F2G
    F2G = X*SIN(0.3E+02_SP*X)*COS(0.5E+02_SP*X)
  END FUNCTION F2G
  !** F2N
  REAL(SP) PURE FUNCTION F2N(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F2N
    F2N = X**(-0.9_SP)
  END FUNCTION F2N
  !** F2O
  REAL(SP) PURE FUNCTION F2O(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F2O
    F2O = 0._SP
    IF( X/=0._SP ) F2O = 1._SP/(X*X*SQRT(X))
  END FUNCTION F2O
  !** F2P
  REAL(SP) PURE FUNCTION F2P(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F2P
    F2P = SIN(0.314159E+03_SP*X)/(0.314159E+01_SP*X)
  END FUNCTION F2P
  !** F2S
  REAL(SP) PURE FUNCTION F2S(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F2S
    F2S = 100._SP
    IF( X/=0._SP ) F2S = SIN(0.314159E+03_SP*X)/(0.314159E+01_SP*X)
  END FUNCTION F2S
  !** F3G
  REAL(SP) PURE FUNCTION F3G(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F3G
    F3G = ABS(X-0.33_SP)**(-0.9_SP)
  END FUNCTION F3G
  !** F3P
  REAL(SP) PURE FUNCTION F3P(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F3P
    F3P = 1._SP
    IF( X>3.1415926535897932 ) F3P = 0._SP
  END FUNCTION F3P
  !** F3S
  REAL(SP) PURE FUNCTION F3S(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F3S
    F3S = 1._SP
    IF( X>3.1415926535897932 ) F3S = 0._SP
  END FUNCTION F3S
  !** F4P
  REAL(SP) PURE FUNCTION F4P(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F4P
    F4P = 0._SP
    IF( X>0.0 ) F4P = 1._SP/(X*SQRT(X))
  END FUNCTION F4P
  !** F4S
  REAL(SP) PURE FUNCTION F4S(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F4S
    IF( X==.33_SP ) THEN
      F4S = 0._SP
      RETURN
    END IF
    F4S = ABS(X-0.33_SP)**(-0.999_SP)
    RETURN
    RETURN
  END FUNCTION F4S
  !** F5S
  REAL(SP) PURE FUNCTION F5S(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  F5S
    F5S = 0._SP
    IF( X/=0.0 ) F5S = 1._SP/(X*SQRT(X))
  END FUNCTION F5S
  !** T0
  REAL(SP) PURE FUNCTION T0(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  F0S

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP) :: a, b, x1, y
    !* FIRST EXECUTABLE STATEMENT  T0
    a = 0._SP
    b = 1._SP
    x1 = X + 1._SP
    y = (b-a)/x1 + a
    T0 = (b-a)*F0S(y)/x1/x1
  END FUNCTION T0
  !** T1
  REAL(SP) PURE FUNCTION T1(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  F1S

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP) :: a, b, x1, y
    !* FIRST EXECUTABLE STATEMENT  T1
    a = 0._SP
    b = 1._SP
    x1 = X + 1._SP
    y = (b-a)/x1 + a
    T1 = (b-a)*F1S(y)/x1/x1
  END FUNCTION T1
  !** T2
  REAL(SP) PURE FUNCTION T2(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  F2S

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP) :: a, b, x1, y
    !* FIRST EXECUTABLE STATEMENT  T2
    a = 0.1_SP
    b = 1._SP
    x1 = X + 1._SP
    y = (b-a)/x1 + a
    T2 = (b-a)*F2S(y)/x1/x1
  END FUNCTION T2
  !** T3
  REAL(SP) PURE FUNCTION T3(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  F3S

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP) :: a, b, x1, y
    !* FIRST EXECUTABLE STATEMENT  T3
    a = 0._SP
    b = 5._SP
    x1 = X + 1._SP
    y = (b-a)/x1 + a
    T3 = (b-a)*F3S(y)/x1/x1
  END FUNCTION T3
  !** T4
  REAL(SP) PURE FUNCTION T4(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  F4S

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP) :: a, b, x1, y
    !* FIRST EXECUTABLE STATEMENT  T4
    a = 0._SP
    b = 1._SP
    x1 = X + 1._SP
    y = (b-a)/x1 + a
    T4 = (b-a)*F4S(y)/x1/x1
  END FUNCTION T4
  !** T5
  REAL(SP) PURE FUNCTION T5(X)
    !> Subsidiary to
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  F5S

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)

    REAL(SP), INTENT(IN) :: X
    REAL(SP) :: a, b, x1, y
    !* FIRST EXECUTABLE STATEMENT  T5
    a = 0._SP
    b = 1._SP
    x1 = X + 1._SP
    y = (b-a)/x1 + a
    T5 = (b-a)*F5S(y)/x1/x1
  END FUNCTION T5
  !** CPRIN
  SUBROUTINE CPRIN(Lun,Num1,Kprint,Ip,Exact,Result,Abserr,Neval,Ierv,Lierv)
    !> Subsidiary to CQAG, CQAG, CQAGI, CQAGP, CQAGS, CQAWC,
    !            CQAWF, CQAWO, CQAWS, and CQNG.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Author:**  Piessens, Robert
    !             Applied Mathematics and Programming Division
    !             K. U. Leuven
    !           de Doncker, Elise
    !             Applied Mathematics and Programming Division
    !             K. U. Leuven
    !***
    ! **Description:**
    !
    !   This program is called by the (single precision) Quadpack quick
    !   check routines for printing out their messages.
    !
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   810401  DATE WRITTEN
    !   890831  Modified array declarations.  (WRB)
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   910627  Code completely rewritten.  (WRB)

    !     .. Scalar Arguments ..
    REAL(SP) :: Abserr, Exact, Result
    INTEGER :: Ip, Kprint, Lierv, Lun, Neval, Num1
    !     .. Array Arguments ..
    INTEGER :: Ierv(Lierv)
    !     .. Local Scalars ..
    REAL(SP) :: error
    INTEGER :: ier, k
    !     .. Intrinsic Functions ..
    INTRINSIC ABS
    !* FIRST EXECUTABLE STATEMENT  CPRIN
    ier = Ierv(1)
    error = ABS(Exact-Result)
    !
    IF( Kprint>=2 ) THEN
      IF( Ip/=1 ) THEN
        !
        !         Write failure messages.
        !
        WRITE (UNIT=Lun,FMT=99002) Num1
        IF( Num1==0 ) WRITE (UNIT=Lun,FMT=99003)
        IF( Num1>0 ) WRITE (UNIT=Lun,FMT=99004) Num1
        IF( Lierv>1 ) WRITE (UNIT=Lun,FMT=99005) (Ierv(k),k=2,Lierv)
        IF( Num1==6 ) WRITE (UNIT=Lun,FMT=99006)
        WRITE (UNIT=Lun,FMT=99007)
        WRITE (UNIT=Lun,FMT=99008)
        IF( Num1/=5 ) THEN
          WRITE (UNIT=Lun,FMT=99009) Exact, Result, error, Abserr, ier, Neval
        ELSE
          WRITE (Lun,FMT=99010) Result, Abserr, ier, Neval
        END IF
      ELSEIF( Kprint>=3 ) THEN
        !
        !           Write PASS message.
        !
        WRITE (UNIT=Lun,FMT=99001) Num1
      END IF
    END IF
    !
    RETURN
    !
    99001 FORMAT (' TEST ON IER = ',I2,' PASSED')
    99002 FORMAT (' TEST ON IER = ',I1,' FAILED.')
    99003 FORMAT (' WE MUST HAVE IER = 0, ERROR<=ABSERR AND ABSERR.LE',&
      '.MAX(EPSABS,EPSREL*ABS(EXACT))')
    99004 FORMAT (' WE MUST HAVE IER = ',I1)
    99005 FORMAT (' OR IER =     ',8(I1,2X))
    99006 FORMAT (' RESULT, ABSERR, NEVAL AND EVENTUALLY LAST SHOULD BE',' ZERO')
    99007 FORMAT (' WE HAVE   ')
    99008 FORMAT (7X,'EXACT',11X,'RESULT',6X,'ERROR',4X,'ABSERR',4X,'IER     NEVAL',&
      /,' ',42X,'(EST.ERR.)(FLAG)(NO F-EVAL)')
    99009 FORMAT (' ',2(E15.7,1X),2(E9.2,1X),I4,4X,I6)
    99010 FORMAT (5X,'INFINITY',4X,E15.7,11X,E9.2,I5,4X,I6)
  END SUBROUTINE CPRIN
END MODULE TEST39_MOD
!** TEST39
PROGRAM TEST39
  USE TEST39_MOD, ONLY : CQAG, CQAGI, CQAGP, CQAGS, CQAWC, CQAWF, CQAWO, CQAWS, CQNG
  USE ISO_FORTRAN_ENV, ONLY : INPUT_UNIT, OUTPUT_UNIT
  USE common_mod, ONLY : GET_ARGUMENT
  IMPLICIT NONE
  !> Driver for testing SLATEC subprograms
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  H2
  !***
  ! **Type:**      SINGLE PRECISION (TEST39-S, TEST40-D)
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
  !        QAG      QAGI     QAGP     QAGS     QAWC
  !        QAWF     QAWO     QAWS     QNG
  !
  !***
  ! **References:**  Kirby W. Fong, Thomas H. Jefferson, Tokihiko Suyehiro
  !                 and Lee Walton, Guide to the SLATEC Common Mathema-
  !                 tical Library, April 10, 1990.
  !***
  ! **Routines called:**  CQAG, CQAGI, CQAGP, CQAGS, CQAWC, CQAWF, CQAWO,
  !                    CQAWS, CQNG, I1MACH, XERMAX, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   890618  DATE WRITTEN
  !   890618  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900524  Cosmetic changes to code.  (WRB)
  INTEGER :: ipass, kprint, lin, lun, nfail
  !* FIRST EXECUTABLE STATEMENT  TEST39
  lun = OUTPUT_UNIT
  lin = INPUT_UNIT
  nfail = 0
  !
  !     Read KPRINT parameter
  !
  CALL GET_ARGUMENT(kprint)
  !
  !     Test single precision QUADPACK routines
  !
  !     Test QAG.
  !
  CALL CQAG(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test QAGS.
  !
  CALL CQAGS(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test QAGP.
  !
  CALL CQAGP(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test QAGI.
  !
  CALL CQAGI(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test QAWO.
  !
  CALL CQAWO(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test QAWF.
  !
  CALL CQAWF(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test QAWS.
  !
  CALL CQAWS(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test QAWC.
  !
  CALL CQAWC(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test QNG.
  !
  CALL CQNG(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Write PASS or FAIL message
  !
  IF( nfail==0 ) THEN
    WRITE (lun,99001)
    99001 FORMAT (/' --------------TEST39 PASSED ALL TESTS----------------')
  ELSE
    WRITE (lun,99002) nfail
    99002 FORMAT (/' ************* WARNING -- ',I5,&
      ' TEST(S) FAILED IN PROGRAM TEST39 *************')
  END IF
  STOP
END PROGRAM TEST39
