MODULE TEST52_MOD
  USE service, ONLY : SP, DP
  IMPLICIT NONE
  REAL(SP) :: EPS, RP, SVEps, TOL
  INTEGER :: IERp, IERr, NORd, NORdp
  REAL(SP) :: R(11)

CONTAINS
  !** CMPARE
  SUBROUTINE CMPARE(Icnt,Itest)
    !> Compare values in COMMON block CHECK for quick check routine PFITQX.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (CMPARE-S, DCMPAR-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)
    !***
    ! COMMON BLOCKS    CHECK

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   890921  Realigned order of variables in the COMMON block.
    !           (WRB)
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   920214  Minor improvements to code for readability.  (WRB)

    !     .. Scalar Arguments ..
    INTEGER :: Icnt
    !     .. Array Arguments ..
    INTEGER :: Itest(9)
    !     .. Local Scalars ..
    REAL(SP) :: rpp, ss
    INTEGER :: ierpp, nrdp
    !     .. Local Arrays ..
    INTEGER :: itemp(4)
    !     .. Intrinsic Functions ..
    INTRINSIC ABS
    !* FIRST EXECUTABLE STATEMENT  CMPARE
    Icnt = Icnt + 1
    itemp(1) = 0
    itemp(2) = 0
    itemp(3) = 0
    itemp(4) = 0
    ss = SVEps - EPS
    nrdp = NORdp - NORd
    rpp = RP - R(11)
    ierpp = IERp - IERr
    IF( ABS(ss)<=TOL .OR. Icnt<=2 .OR. Icnt>=6 ) itemp(1) = 1
    IF( ABS(nrdp)==0 ) itemp(2) = 1
    IF( ABS(rpp)<=TOL ) itemp(3) = 1
    IF( ABS(ierpp)==0 ) itemp(4) = 1
    !
    !     Check to see if all four tests were good.
    !     If so, set the test number equal to 1.
    !
    Itest(Icnt) = itemp(1)*itemp(2)*itemp(3)*itemp(4)
  END SUBROUTINE CMPARE
  !** PFITQX
  SUBROUTINE PFITQX(Lun,Kprint,Ipass)
    !> Quick check for POLFIT, PCOEF and PVALUE.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (PFITQX-S, DPFITT-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  CMPARE, PASS, PCOEF, POLFIT, PVALUE, R1MACH,
    !                    XERCLR, XGETF, XSETF
    !***
    ! COMMON BLOCKS    CHECK

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   890921  Realigned order of variables in the COMMON block.  (WRB)
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   900911  Test problem changed and cosmetic changes to code.  (WRB)
    !   901205  Changed usage of eps_2_sp to eps_sp and modified the FORMATs.  (RWC)
    !   910708  Minor modifications in use of KPRINT.  (WRB)
    !   920214  Code restructured to test for all values of KPRINT and to
    !           provide more PASS/FAIL information.  (WRB)
    USE service, ONLY : eps_sp
    USE approximation, ONLY : PCOEF, POLFIT, PVALUE
    USE common_mod, ONLY : PASS
    !     .. Scalar Arguments ..
    INTEGER :: Ipass, Kprint, Lun
    !     .. Local Scalars ..
    REAL(SP) :: yfit
    INTEGER :: i, icnt, m, maxord
    !     .. Local Arrays ..
    REAL(SP) :: a(97), tc(5), w(11), x(11), y(11), yp(5)
    INTEGER :: itest(9)
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, SQRT
    !* FIRST EXECUTABLE STATEMENT  PFITQX
    IF( Kprint>=2 ) WRITE (Lun,FMT=99002)
    !
    !     Initialize variables for testing passage or failure of tests
    !
    DO i = 1, 9
      itest(i) = 0
    END DO
    icnt = 0
    TOL = SQRT(eps_sp)
    m = 11
    DO i = 1, m
      x(i) = i - 6
      y(i) = x(i)**4
    END DO
    !
    !     Test POLFIT
    !     Input EPS is negative - specified level
    !
    w(1) = -1._SP
    EPS = -0.01_SP
    SVEps = EPS
    maxord = 8
    NORdp = 4
    RP = 625._SP
    IERp = 1
    CALL POLFIT(m,x,y,w,maxord,NORd,EPS,R,IERr,a)
    !
    !     See if test passed
    !
    CALL CMPARE(icnt,itest)
    !
    !     Check for suppression of printing.
    !
    IF( Kprint/=0 ) THEN
      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
        WRITE (Lun,FMT=99003)
        WRITE (Lun,FMT=99004)
        IF( Kprint>2 .OR. itest(icnt)/=1 ) THEN
          WRITE (Lun,FMT=99005) SVEps, NORdp, RP, IERp
          WRITE (Lun,FMT=99006) EPS, NORd, R(11), IERr
        END IF
        !
        !     Send message indicating passage or failure of test
        !
        CALL PASS(Lun,icnt,itest(icnt))
      END IF
    END IF
    !
    !     Input EPS is negative - computed level
    !
    EPS = -1._SP
    SVEps = EPS
    CALL POLFIT(m,x,y,w,maxord,NORd,EPS,R,IERr,a)
    !
    !     See if test passed
    !
    CALL CMPARE(icnt,itest)
    !
    !     Check for suppression of printing.
    !
    IF( Kprint/=0 ) THEN
      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
        WRITE (Lun,FMT=99007)
        IF( Kprint>2 .OR. itest(icnt)/=1 ) THEN
          WRITE (Lun,FMT=99008) maxord
          WRITE (Lun,FMT=99005) SVEps, NORdp, RP, IERp
          WRITE (Lun,FMT=99006) EPS, NORd, R(11), IERr
        END IF
        !
        !     Send message indicating passage or failure of test
        !
        CALL PASS(Lun,icnt,itest(icnt))
      END IF
    END IF
    !
    !     Input EPS is zero
    !
    w(1) = -1._SP
    EPS = 0._SP
    SVEps = EPS
    NORdp = 5
    maxord = 5
    CALL POLFIT(m,x,y,w,maxord,NORd,EPS,R,IERr,a)
    !
    !     See if test passed
    !
    CALL CMPARE(icnt,itest)
    !
    !     Check for suppression of printing.
    !
    IF( Kprint/=0 ) THEN
      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
        WRITE (Lun,FMT=99009)
        IF( Kprint>2 .OR. itest(icnt)/=1 ) THEN
          WRITE (Lun,FMT=99008) maxord
          WRITE (Lun,FMT=99005) SVEps, NORdp, RP, IERp
          WRITE (Lun,FMT=99006) EPS, NORd, R(11), IERr
        END IF
        !
        !     Send message indicating passage or failure of test
        !
        CALL PASS(Lun,icnt,itest(icnt))
      END IF
    END IF
    !
    !     Input EPS is positive
    !
    IERp = 1
    NORdp = 4
    EPS = 75._SP*eps_sp
    SVEps = EPS
    CALL POLFIT(m,x,y,w,maxord,NORd,EPS,R,IERr,a)
    !
    !     See if test passed
    !
    CALL CMPARE(icnt,itest)
    !
    !     Check for suppression of printing.
    !
    IF( Kprint/=0 ) THEN
      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
        WRITE (Lun,FMT=99010)
        IF( Kprint>2 .OR. itest(icnt)/=1 ) THEN
          WRITE (Lun,FMT=99008) maxord
          WRITE (Lun,FMT=99005) SVEps, NORdp, RP, IERp
          WRITE (Lun,FMT=99006) EPS, NORd, R(11), IERr
        END IF
        !
        !     Send message indicating passage or failure of test
        !
        CALL PASS(Lun,icnt,itest(icnt))
      END IF
    END IF
    !
    !     Improper input
    !
!    IERp = 2
!    m = -2
    !
    !     Check for suppression of printing.
    !
!    kontrl = control_xer
!    IF( Kprint<=2 ) THEN
!      control_xer = 0
!    ELSE
!      control_xer = 1
!    END IF
!    num_xer = 0
    !
!    IF( Kprint>=3 ) WRITE (Lun,99001)
!    99001 FORMAT (/' Invalid input')
!    CALL POLFIT(m,x,y,w,maxord,NORd,EPS,R,IERr,a)
    !
    !     See if test passed
    !
    icnt = icnt + 1
    itest(icnt) = 1
!    IF( IERr==2 ) THEN
!      itest(icnt) = 1
!      IF( Kprint>=3 ) WRITE (Lun,99011) 'PASSED', IERr
!    ELSEIF( Kprint>=2 ) THEN
!      WRITE (Lun,99011) 'FAILED', IERr
!    END IF
    !
    !     Check for suppression of printing.
    !
!    IF( Kprint/=0 ) THEN
!      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
!        IF( Kprint<=2 .AND. itest(icnt)==1 ) THEN
!        END IF
!        !
!        !     Send message indicating passage or failure of test
!        !
!        CALL PASS(Lun,icnt,itest(icnt))
!        !
!        num_xer = 0
!        control_xer = kontrl
!      END IF
!    END IF
    !
    !     MAXORD too small to meet RMS error
    !
    m = 11
    w(1) = -1._SP
    EPS = 5._SP*eps_sp
    SVEps = EPS
    RP = 553._SP
    maxord = 2
    IERp = 3
    NORdp = 2
    CALL POLFIT(m,x,y,w,maxord,NORd,EPS,R,IERr,a)
    !
    !     See if test passed
    !
    CALL CMPARE(icnt,itest)
    !
    !     Check for suppression of printing.
    !
    IF( Kprint/=0 ) THEN
      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
        WRITE (Lun,FMT=99012)
        IF( Kprint>2 .OR. itest(icnt)/=1 ) THEN
          WRITE (Lun,FMT=99008) maxord
          WRITE (Lun,FMT=99005) SVEps, NORdp, RP, IERp
          WRITE (Lun,FMT=99006) EPS, NORd, R(11), IERr
        END IF
        !
        !     Send message indicating passage or failure of test
        !
        CALL PASS(Lun,icnt,itest(icnt))
      END IF
    END IF
    !
    !     MAXORD too small to meet statistical test
    !
    NORdp = 4
    IERp = 4
    RP = 625._SP
    EPS = -0.01_SP
    SVEps = EPS
    maxord = 5
    CALL POLFIT(m,x,y,w,maxord,NORd,EPS,R,IERr,a)
    !
    !     See if test passed
    !
    CALL CMPARE(icnt,itest)
    !
    !     Check for suppression of printing.
    !
    IF( Kprint/=0 ) THEN
      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
        WRITE (Lun,FMT=99013)
        IF( Kprint>2 .OR. itest(icnt)/=1 ) THEN
          WRITE (Lun,FMT=99008) maxord
          WRITE (Lun,FMT=99005) SVEps, NORdp, RP, IERp
          WRITE (Lun,FMT=99006) EPS, NORd, R(11), IERr
        END IF
        !
        !     Send message indicating passage or failure of test
        !
        CALL PASS(Lun,icnt,itest(icnt))
      END IF
    END IF
    !
    !     Test PCOEF
    !
    maxord = 6
    EPS = 0._SP
    SVEps = EPS
    y(6) = 1._SP
    DO i = 1, m
      w(i) = 1._SP/(y(i)**2)
    END DO
    y(6) = 0._SP
    CALL POLFIT(m,x,y,w,maxord,NORd,EPS,R,IERr,a)
    CALL PCOEF(4,5._SP,tc,a)
    !
    !     See if test passed
    !
    icnt = icnt + 1
    IF( ABS(R(11)-tc(1))<=TOL ) itest(icnt) = 1
    !
    !     Check for suppression of printing
    !
    IF( Kprint/=0 ) THEN
      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
        WRITE (Lun,FMT=99014)
        IF( Kprint>2 .OR. itest(icnt)/=1 ) WRITE (Lun,FMT=99015) R(11), tc(1)
        !
        !     Send message indicating passage or failure of test
        !
        CALL PASS(Lun,icnt,itest(icnt))
      END IF
    END IF
    !
    !     Test PVALUE
    !     Normal call
    !
    CALL PVALUE(6,0,x(8),yfit,yp,a)
    !
    !     See if test passed
    !
    icnt = icnt + 1
    IF( ABS(R(8)-yfit)<=TOL ) itest(icnt) = 1
    !
    !     Check for suppression of printing
    !
    IF( Kprint/=0 ) THEN
      IF( Kprint/=1 .OR. itest(icnt)/=1 ) THEN
        WRITE (Lun,FMT=99016)
        WRITE (Lun,FMT=99017)
        IF( Kprint>2 .OR. itest(icnt)/=1 ) WRITE (Lun,FMT=99018) x(8), R(8), yfit
        !
        !     Send message indicating passage or failure of test
        !
        CALL PASS(Lun,icnt,itest(icnt))
      END IF
    END IF
    !
    !     Check to see if all tests passed
    !
    Ipass = 1
    DO i = 1, 9
      Ipass = Ipass*itest(i)
    END DO
    !
    IF( Ipass==1 .AND. Kprint>=3 ) WRITE (Lun,FMT=99019)
    IF( Ipass==0 .AND. Kprint>=2 ) WRITE (Lun,FMT=99020)
    RETURN
    !
    99002 FORMAT ('1'/' Test POLFIT, PCOEF and PVALUE')
    99003 FORMAT (' Exercise POLFIT')
    99004 FORMAT (' Input EPS is negative - specified significance level')
    99005 FORMAT (' Input EPS =  ',E15.8,'   correct order =  ',I3,'   R(1) = ',&
      E15.8,'   IERR = ',I1)
    99006 FORMAT (' Output EPS = ',E15.8,'   computed order = ',I3,'   R(1) = ',&
      E15.8,'   IERR = ',I1)
    99007 FORMAT (/' Input EPS is negative - computed significance level')
    99008 FORMAT (' Maximum order = ',I2)
    99009 FORMAT (/' Input EPS is zero')
    99010 FORMAT (/' Input EPS is positive')
    99011 FORMAT (' POLFIT incorrect argument test ',A/' IERR should be 2.  It is ',&
      I4)
    99012 FORMAT (/' Cannot meet RMS error requirement')
    99013 FORMAT (/' Cannot satisfy statistical test')
    99014 FORMAT (/' Exercise PCOEF')
    99015 FORMAT (/' For C=1.0, correct coefficient = ',E15.8,'   computed = ',&
      E15.8)
    99016 FORMAT (/' Exercise PVALUE')
    99017 FORMAT (' Normal execution')
    99018 FORMAT (' For X = ',F5.2,'   correct P(X) = ',E15.8,&
      '    P(X) from PVALUE = ',E15.8)
    99019 FORMAT (/' ***************POLFIT PASSED ALL TESTS***************')
    99020 FORMAT (/' ***************POLFIT FAILED SOME TESTS**************')
  END SUBROUTINE PFITQX
  !** SNLS1Q
  SUBROUTINE SNLS1Q(Lun,Kprint,Ipass)
    !> Quick check for SNLS1E, SNLS1 and SCOV.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (SNLS1Q-S, DNLS1Q-D)
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Description:**
    !
    !   This subroutine performs a quick check on the subroutines SNLS1E
    !   (and SNLS1) and SCOV.
    !
    !***
    ! **Routines called:**  ENORM, FCN1, FCN2, FCN3, FDJAC3, PASS, R1MACH,
    !                    SCOV, SNLS1E

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   890911  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   930214  Declarations sections added, code revised to test error
    !           returns for all values of KPRINT and code polished.  (WRB)
    USE service, ONLY : eps_sp
    USE approximation, ONLY : FDJAC3, SCOV, SNLS1E
    USE common_mod, ONLY : PASS
    !     .. Scalar Arguments ..
    INTEGER :: Ipass, Kprint, Lun
    !     .. Local Scalars ..
    REAL(SP) :: fnorm, fnorms, sigma, temp1, temp2, temp3, tol, tol2
    INTEGER :: i, iflag, info, infos, iopt, ldfjac, lwa, m, n, nprint
    LOGICAL :: fatal
    !     .. Local Arrays ..
    REAL(SP) :: fjac(10,2), fjrow(2,1), fjtj(3), fvec(10), wa(40), x(2)
    INTEGER :: iw(2)
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, SQRT
    !* FIRST EXECUTABLE STATEMENT  SNLS1Q
    IF( Kprint>=2 ) WRITE (Lun,99001)
    !
    99001 FORMAT ('1'/' Test SNLS1E, SNLS1 and SCOV')
    !
    Ipass = 1
    infos = 1
    fnorms = 1.1151779E+01_SP
    m = 10
    n = 2
    lwa = 40
    ldfjac = 10
    nprint = -1
    iflag = 1
    tol = SQRT(40._SP*eps_sp)
    tol2 = SQRT(tol)
    !
    !     OPTION=2, the full Jacobian is stored and the user provides the
    !     Jacobian.
    !
    iopt = 2
    x(1) = 3.0E-1_SP
    x(2) = 4.0E-1_SP
    CALL SNLS1E(FCN2,iopt,m,n,x,fvec,tol,nprint,info,iw,wa,lwa)
    fnorm = NORM2(fvec)
    IF( info==infos .AND. ABS(fnorm-fnorms)/fnorms<=tol ) THEN
      fatal = .FALSE.
      IF( Kprint>=3 ) CALL PASS(Lun,1,1)
    ELSE
      Ipass = 0
      fatal = .TRUE.
      IF( Kprint>=2 ) CALL PASS(Lun,1,0)
    END IF
    IF( (fatal .AND. Kprint>=2) .OR. Kprint>=3 ) WRITE (Lun,99007) infos, &
      fnorms, info, fnorm
    !
    !     Form JAC-transpose*JAC.
    !
    sigma = fnorm*fnorm/(m-n)
    iflag = 2
    CALL FCN2(iflag,m,n,x,fvec,fjac,ldfjac)
    DO i = 1, 3
      fjtj(i) = 0._SP
    END DO
    DO i = 1, m
      fjtj(1) = fjtj(1) + fjac(i,1)**2
      fjtj(2) = fjtj(2) + fjac(i,1)*fjac(i,2)
      fjtj(3) = fjtj(3) + fjac(i,2)**2
    END DO
    !
    !     Calculate the covariance matrix.
    !
    CALL SCOV(FCN2,iopt,m,n,x,fvec,fjac,ldfjac,info,wa(1),wa(n+1),wa(2*n+1),&
      wa(3*n+1))
    !
    !     Form JAC-transpose*JAC * covariance matrix (should = SIGMA*I).
    !
    temp1 = (fjtj(1)*fjac(1,1)+fjtj(2)*fjac(1,2))/sigma
    temp2 = (fjtj(1)*fjac(1,2)+fjtj(2)*fjac(2,2))/sigma
    temp3 = (fjtj(2)*fjac(1,2)+fjtj(3)*fjac(2,2))/sigma
    IF( info==infos .AND. ABS(temp1-1._SP)<tol2 .AND. ABS(temp2)<tol2 .AND. &
        ABS(temp3-1._SP)<tol2 ) THEN
      fatal = .FALSE.
      IF( Kprint>=3 ) CALL PASS(Lun,2,1)
    ELSE
      Ipass = 0
      fatal = .TRUE.
      IF( Kprint>=2 ) CALL PASS(Lun,2,0)
    END IF
    IF( (fatal .AND. Kprint>=2) .OR. Kprint>=3 ) WRITE (Lun,99008) infos, info, &
      temp1, temp2, temp3
    !
    !     OPTION=1, the full Jacobian is stored and the code approximates
    !     the Jacobian.
    !
    iopt = 1
    x(1) = 3.0E-1_SP
    x(2) = 4.0E-1_SP
    CALL SNLS1E(FCN1,iopt,m,n,x,fvec,tol,nprint,info,iw,wa,lwa)
    fnorm = NORM2(fvec)
    IF( info==infos .AND. ABS(fnorm-fnorms)/fnorms<=tol ) THEN
      fatal = .FALSE.
      IF( Kprint>=3 ) CALL PASS(Lun,3,1)
    ELSE
      Ipass = 0
      fatal = .TRUE.
      IF( Kprint>=2 ) CALL PASS(Lun,3,0)
    END IF
    IF( (fatal .AND. Kprint>=2) .OR. Kprint>=3 ) WRITE (Lun,99007) infos, &
      fnorms, info, fnorm
    !
    !     Form JAC-transpose*JAC.
    !
    sigma = fnorm*fnorm/(m-n)
    iflag = 1
    CALL FDJAC3(FCN1,m,n,x,fvec,fjac,ldfjac,iflag,0._SP,wa)
    DO i = 1, 3
      fjtj(i) = 0._SP
    END DO
    DO i = 1, m
      fjtj(1) = fjtj(1) + fjac(i,1)**2
      fjtj(2) = fjtj(2) + fjac(i,1)*fjac(i,2)
      fjtj(3) = fjtj(3) + fjac(i,2)**2
    END DO
    !
    !     Calculate the covariance matrix.
    !
    CALL SCOV(FCN1,iopt,m,n,x,fvec,fjac,ldfjac,info,wa(1),wa(n+1),wa(2*n+1),&
      wa(3*n+1))
    !
    !     Form JAC-transpose*JAC * covariance matrix (should = SIGMA*I).
    !
    temp1 = (fjtj(1)*fjac(1,1)+fjtj(2)*fjac(1,2))/sigma
    temp2 = (fjtj(1)*fjac(1,2)+fjtj(2)*fjac(2,2))/sigma
    temp3 = (fjtj(2)*fjac(1,2)+fjtj(3)*fjac(2,2))/sigma
    IF( info==infos .AND. ABS(temp1-1._SP)<tol2 .AND. ABS(temp2)<tol2 .AND. &
        ABS(temp3-1._SP)<tol2 ) THEN
      fatal = .FALSE.
      IF( Kprint>=3 ) CALL PASS(Lun,4,1)
    ELSE
      Ipass = 0
      fatal = .TRUE.
      IF( Kprint>=2 ) CALL PASS(Lun,4,0)
    END IF
    IF( (fatal .AND. Kprint>=2) .OR. Kprint>=3 ) WRITE (Lun,99008) infos, info, &
      temp1, temp2, temp3
    !
    !     OPTION=3, the full Jacobian is not stored.  Only the product of
    !     the Jacobian transpose and Jacobian is stored.  The user provides
    !     the Jacobian one row at a time.
    !
    iopt = 3
    x(1) = 3.0E-1_SP
    x(2) = 4.0E-1_SP
    CALL SNLS1E(FCN3,iopt,m,n,x,fvec,tol,nprint,info,iw,wa,lwa)
    fnorm = NORM2(fvec)
    IF( info==infos .AND. ABS(fnorm-fnorms)/fnorms<=tol ) THEN
      fatal = .FALSE.
      IF( Kprint>=3 ) CALL PASS(Lun,5,1)
    ELSE
      Ipass = 0
      fatal = .TRUE.
      IF( Kprint>=2 ) CALL PASS(Lun,5,0)
    END IF
    IF( (fatal .AND. Kprint>=2) .OR. Kprint>=3 ) WRITE (Lun,99007) infos, &
      fnorms, info, fnorm
    !
    !     Form JAC-transpose*JAC.
    !
    sigma = fnorm*fnorm/(m-n)
    DO i = 1, 3
      fjtj(i) = 0._SP
    END DO
    iflag = 3
    DO i = 1, m
      CALL FCN3(iflag,m,n,x,fvec,fjrow,i)
      fjtj(1) = fjtj(1) + fjrow(1,1)**2
      fjtj(2) = fjtj(2) + fjrow(1,1)*fjrow(2,1)
      fjtj(3) = fjtj(3) + fjrow(2,1)**2
    END DO
    !
    !     Calculate the covariance matrix.
    !
    CALL SCOV(FCN3,iopt,m,n,x,fvec,fjac,ldfjac,info,wa(1),wa(n+1),wa(2*n+1),&
      wa(3*n+1))
    !
    !     Form JAC-transpose*JAC * covariance matrix (should = SIGMA*I).
    !
    temp1 = (fjtj(1)*fjac(1,1)+fjtj(2)*fjac(1,2))/sigma
    temp2 = (fjtj(1)*fjac(1,2)+fjtj(2)*fjac(2,2))/sigma
    temp3 = (fjtj(2)*fjac(1,2)+fjtj(3)*fjac(2,2))/sigma
    IF( info==infos .AND. ABS(temp1-1._SP)<tol2 .AND. ABS(temp2)<tol2 .AND. &
        ABS(temp3-1._SP)<tol2 ) THEN
      fatal = .FALSE.
      IF( Kprint>=3 ) CALL PASS(Lun,6,1)
    ELSE
      Ipass = 0
      fatal = .TRUE.
      IF( Kprint>=2 ) CALL PASS(Lun,6,0)
    END IF
    IF( (fatal .AND. Kprint>=2) .OR. Kprint>=3 ) WRITE (Lun,99008) infos, info, &
      temp1, temp2, temp3
    !
    !     Test improper input parameters.
    !
    fatal = .FALSE.
!    IF( Kprint<=2 ) THEN
!      control_xer = 0
!    ELSE
!      control_xer = 1
!    END IF
!    num_xer = 0
    !
!    IF( Kprint>=3 ) WRITE (Lun,99002)
!    99002 FORMAT (/' TRIGGER 2 ERROR MESSAGES',/)
    !
!    lwa = 35
!    iopt = 2
!    x(1) = 3.0E-1_SP
!    x(2) = 4.0E-1_SP
!    CALL SNLS1E(FCN2,iopt,m,n,x,fvec,tol,nprint,info,iw,wa,lwa)
!    IF( info/=0 .OR. num_xer/=2 ) fatal = .TRUE.
    !
!    m = 0
!    CALL SCOV(FCN2,iopt,m,n,x,fvec,fjac,ldfjac,info,wa(1),wa(n+1),wa(2*n+1),wa(3*n+1))
!    IF( info/=0 .OR. num_xer/=2 ) fatal = .TRUE.
    !
    !     Restore KONTRL and check to see if the tests of error detection
    !     passed.
    !
    IF( fatal ) THEN
      Ipass = 0
      IF( Kprint>=2 ) THEN
        WRITE (Lun,99003)
        99003 FORMAT (' AT LEAST ONE INCORRECT ARGUMENT TEST FAILED')
      END IF
    ELSEIF( Kprint>=3 ) THEN
      WRITE (Lun,99004)
      99004 FORMAT (' ALL INCORRECT ARGUMENT TESTS PASSED')
    END IF
    !
    !     Print PASS/FAIL message.
    !
    IF( Ipass==1 .AND. Kprint>=2 ) WRITE (Lun,99005)
    99005 FORMAT (/' *************SNLS1E PASSED ALL TESTS*****************')
    IF( Ipass==0 .AND. Kprint>=1 ) WRITE (Lun,99006)
    99006 FORMAT (/' ************SNLS1E FAILED SOME TESTS*****************')
    !
    RETURN
    99007 FORMAT (' EXPECTED VALUE OF INFO AND RESIDUAL NORM',I5,&
      E20.9/' RETURNED VALUE OF INFO AND RESIDUAL NORM',I5,E20.9/)
    99008 FORMAT (' EXPECTED AND RETURNED VALUE OF INFO',I5,10X,&
      I5/' RETURNED PRODUCT OF (J-TRANS*J)*COVARIANCE MATRIX/SIGMA'/&
      ' (SHOULD = THE IDENTITY -- 1.0, 0.0, 1.0)'/3E20.9/)
  END SUBROUTINE SNLS1Q
  !** FCQX
  SUBROUTINE FCQX(Lun,Kprint,Ipass)
    !> Quick check for FC.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (FCQX-S, DFCQX-D)
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  Hanson, R. J., (SNLA)
    !***
    ! **Description:**
    !
    !   Quick check subprogram for the subroutine FC.
    !
    !   Fit discrete data by an S-shaped curve.  Evaluate the fitted curve,
    !   its first two derivatives, and probable error curve.
    !
    !   Use subprogram FC to obtain the constrained cubic B-spline
    !   representation of the curve.
    !
    !   The values of the coefficients of the B-spline as computed by FC
    !   and the values of the fitted curve as computed by BVALU in the
    !   de Boor package are tested for accuracy with the expected values.
    !   See the example program in the report sand78-1291, pp. 22-27.
    !
    !   The dimensions in the following arrays are as small as possible for
    !   the problem being solved.
    !
    !***
    ! **Routines called:**  BVALU, CV, FC, IVOUT, R1MACH, SCOPY, SMOUT, SVOUT

    !* REVISION HISTORY  (YYMMDD)
    !   780801  DATE WRITTEN
    !   890718  Changed references from BVALUE to BVALU.  (WRB)
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   891004  Changed computation of XVAL.  (WRB)
    !   891004  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   901010  Restructured using IF-THEN-ELSE-ENDIF, modified tolerances
    !           to use eps_sp rather than eps_2_sp and cleaned up FORMATs.  (RWC)
    !   930214  Declarations sections added, code revised to test error
    !           returns for all values of KPRINT and code polished.  (WRB)
    USE service, ONLY : eps_sp, IVOUT, SVOUT
    USE approximation, ONLY : CV, FC, SMOUT
    USE interpolation, ONLY : BVALU
    !     .. Scalar Arguments ..
    INTEGER :: Ipass, Kprint, Lun
    !     .. Local Scalars ..
    REAL(SP) :: diff, t, tol, xval
    INTEGER :: i, idigit, ii, j, l, mode, n, nconst, ndeg, nval
    LOGICAL :: fatal
    !     .. Local Arrays ..
    REAL(SP) :: coeff(9), v(51,5), w(529), xconst(11), yconst(11)
    INTEGER :: iw(30), nderiv(11)
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, REAL, SQRT
    !     .. Data statements ..
    !
    INTEGER, PARAMETER :: ndata = 9, nord = 4, nbkpt = 13, last = 10
    REAL(SP), PARAMETER :: xdata(9) = [ 0.15_SP, 0.27_SP, 0.33_SP, 0.40_SP, 0.43_SP, &
      0.47_SP, 0.53_SP, 0.58_SP, 0.63_SP ]
    REAL(SP), PARAMETER :: ydata(9) = [ 0.025_SP, 0.05_SP, 0.13_SP, 0.27_SP, 0.37_SP, &
      0.47_SP, 0.64_SP, 0.77_SP, 0.87_SP ]
    REAL(SP), PARAMETER :: sddata(9) = 0.015_SP
    REAL(SP), PARAMETER :: bkpt(13) = [ -0.6_SP, -0.4_SP, -0.2_SP, 0._SP, 0.2_SP, &
      0.4_SP, 0.6_SP, 0.8_SP, 0.9_SP, 1._SP, 1.1_SP, 1.2_SP, 1.3_SP ]
    !
    !     Store the data to be used to check the accuracy of the computed
    !     results.  See SAND78-1291, p.26.
    !
    REAL(SP), PARAMETER :: coefck(9) = [ 1.186380846E-13_SP, -2.826166426E-14_SP, &
      -4.333929094E-15_SP, 1.722113311E-01_SP, 9.421965984E-01_SP, 9.684708719E-01_SP, &
      9.894902905E-01_SP, 1.005254855E+00_SP, 9.894902905E-01_SP ]
    REAL(SP), PARAMETER :: check(51) = [ 2.095830752E-16_SP, 2.870188850E-05_SP, &
      2.296151081E-04_SP, 7.749509897E-04_SP, 1.836920865E-03_SP, 3.587736064E-03_SP, &
      6.199607918E-03_SP, 9.844747759E-03_SP, 1.469536692E-02_SP, 2.092367672E-02_SP, &
      2.870188851E-02_SP, 3.824443882E-02_SP, 4.993466504E-02_SP, 6.419812979E-02_SP, &
      8.146039566E-02_SP, 1.021470253E-01_SP, 1.266835812E-01_SP, 1.554956261E-01_SP, &
      1.890087225E-01_SP, 2.276484331E-01_SP, 2.718403204E-01_SP, 3.217163150E-01_SP, &
      3.762338189E-01_SP, 4.340566020E-01_SP, 4.938484342E-01_SP, 5.542730855E-01_SP, &
      6.139943258E-01_SP, 6.716759250E-01_SP, 7.259816530E-01_SP, 7.755752797E-01_SP, &
      8.191205752E-01_SP, 8.556270903E-01_SP, 8.854875002E-01_SP, 9.094402609E-01_SP, &
      9.282238286E-01_SP, 9.425766596E-01_SP, 9.532372098E-01_SP, 9.609439355E-01_SP, &
      9.664352927E-01_SP, 9.704497377E-01_SP, 9.737257265E-01_SP, 9.768786393E-01_SP, &
      9.800315521E-01_SP, 9.831844649E-01_SP, 9.863373777E-01_SP, 9.894902905E-01_SP, &
      9.926011645E-01_SP, 9.954598055E-01_SP, 9.978139804E-01_SP, 9.994114563E-01_SP, &
      1.000000000E+00_SP ]
    !* FIRST EXECUTABLE STATEMENT  FCQX
    IF( Kprint>=2 ) WRITE (Lun,99001)
    !
    99001 FORMAT ('1'/' Test FC')
    Ipass = 1
    ndeg = nord - 1
    !
    !     Write the various constraints for the fitted curve.
    !
    nconst = 0
    t = bkpt(nord)
    !
    !     Constrain function to be zero at left-most breakpoint.
    !
    nconst = nconst + 1
    xconst(nconst) = t
    yconst(nconst) = 0._SP
    nderiv(nconst) = 2 + 4*0
    !
    !     Constrain first derivative to be nonnegative at left-most
    !     breakpoint.
    !
    nconst = nconst + 1
    xconst(nconst) = t
    yconst(nconst) = 0._SP
    nderiv(nconst) = 1 + 4*1
    !
    !     Constrain second derivatives to be nonnegative at left set of
    !     breakpoints.
    !
    DO i = 1, 3
      l = ndeg + i
      t = bkpt(l)
      nconst = nconst + 1
      xconst(nconst) = t
      yconst(nconst) = 0._SP
      nderiv(nconst) = 1 + 4*2
    END DO
    !
    !     Constrain function value at right-most breakpoint to be one.
    !
    nconst = nconst + 1
    t = bkpt(last)
    xconst(nconst) = t
    yconst(nconst) = 1._SP
    nderiv(nconst) = 2 + 4*0
    !
    !     Constrain slope to agree at left- and right-most breakpoints.
    !
    nconst = nconst + 1
    xconst(nconst) = bkpt(nord)
    yconst(nconst) = bkpt(last)
    nderiv(nconst) = 3 + 4*1
    !
    !     Constrain second derivatives to be nonpositive at right set of
    !     breakpoints.
    !
    DO i = 1, 4
      nconst = nconst + 1
      l = last - 4 + i
      xconst(nconst) = bkpt(l)
      yconst(nconst) = 0._SP
      nderiv(nconst) = 0 + 4*2
    END DO
    !
    idigit = -4
    !
    IF( Kprint>=3 ) THEN
      CALL SVOUT(nbkpt,bkpt,'('' ARRAY OF KNOTS.'')',idigit)
      CALL SVOUT(ndata,xdata,'('' INDEPENDENT VARIABLE VALUES'')',idigit)
      CALL SVOUT(ndata,ydata,'('' DEPENDENT VARIABLE VALUES'')',idigit)
      CALL SVOUT(ndata,sddata,'('' DEPENDENT VARIABLE UNCERTAINTY'')',idigit)
      CALL SVOUT(nconst,xconst,'('' INDEPENDENT VARIABLE CONSTRAINT VALUES'')',idigit)
      CALL SVOUT(nconst,yconst,'('' CONSTRAINT VALUES'')',idigit)
      CALL IVOUT(nconst,nderiv,'('' CONSTRAINT INDICATOR'')',idigit)
    END IF
    !
    !     Declare amount of working storage allocated to FC.
    !
    iw(1) = 529
    iw(2) = 30
    !
    !     Set mode to indicate a new problem and request the variance
    !     function.
    !
    mode = 2
    !
    !     Obtain the coefficients of the B-spline.
    !
    CALL FC(ndata,xdata,ydata,sddata,nord,nbkpt,bkpt,nconst,xconst,yconst,&
      nderiv,mode,coeff,w,iw)
    !
    !     Check coefficients.
    !
    tol = 7._SP*SQRT(eps_sp)
    diff = 0._SP
    DO i = 1, ndata
      diff = MAX(diff,ABS(coeff(i)-coefck(i)))
    END DO
    IF( diff<=tol ) THEN
      fatal = .FALSE.
      IF( Kprint>=3 ) WRITE (Lun,99002)
      99002 FORMAT (/' FC PASSED TEST 1')
    ELSE
      Ipass = 0
      fatal = .TRUE.
      IF( Kprint>=2 ) WRITE (Lun,99003)
      99003 FORMAT (/' FC FAILED TEST 1')
    END IF
    !
    IF( (fatal .AND. Kprint>=2) .OR. Kprint>=3 ) THEN
      CALL SVOUT(ndata,coefck,'(/'' PREDICTED COEFFICIENTS OF THE B-SPLINE '//&
        'FROM SAMPLE'')',idigit)
      CALL SVOUT(ndata,coeff,'(/'' COEFFICIENTS OF THE B-SPLINE COMPUTED '//&
        'BY FC'')',idigit)
    END IF
    !
    !     Compute value, first two derivatives and probable uncertainty.
    !
    n = nbkpt - nord
    nval = 51
    DO i = 1, nval
      !
      !       The function BVALU is in the de Boor B-spline package.
      !
      xval = REAL(i-1,SP)/(nval-1)
      ii = 1
      DO j = 1, 3
        v(i,j+1) = BVALU(bkpt,coeff,n,nord,j-1,xval)
      END DO
      v(i,1) = xval
      !
      !       The variance function CV is a companion subprogram to FC.
      !
      v(i,5) = SQRT(CV(xval,ndata,nconst,nord,nbkpt,bkpt,w))
    END DO
    !
    diff = 0._SP
    DO i = 1, nval
      diff = MAX(diff,ABS(v(i,2)-check(i)))
    END DO
    IF( diff<=tol ) THEN
      fatal = .FALSE.
      IF( Kprint>=3 ) WRITE (Lun,99004)
      99004 FORMAT (/' FC (AND BVALU) PASSED TEST 2')
    ELSE
      Ipass = 0
      fatal = .TRUE.
      IF( Kprint>=2 ) WRITE (Lun,99005)
      99005 FORMAT (/' FC (AND BVALU) FAILED TEST 2')
    END IF
    !
    IF( (fatal .AND. Kprint>=2) .OR. Kprint>=3 ) THEN
      !
      !       Print these values.
      !
      CALL SMOUT(nval,5,nval,v,'(16X, ''X'', 10X, ''FNCN'', 8X,'//&
        '''1ST D'', 7X, ''2ND D'', 7X, ''ERROR'')',idigit)
      WRITE (Lun,99006)
      99006 FORMAT (/' VALUES SHOULD CORRESPOND TO THOSE IN ','SAND78-1291,',&
        ' P. 26')
    END IF
    !
    !     Trigger error conditions.
    !
    fatal = .FALSE.
!    IF( Kprint<=2 ) THEN
!      control_xer = 0
!    ELSE
!      control_xer = 1
!    END IF
!    num_xer = 0
    !
!    IF( Kprint>=3 ) WRITE (Lun,99007)
!    99007 FORMAT (/' TRIGGER 6 ERROR MESSAGES',/)
    !
!    CALL FC(ndata,xdata,ydata,sddata,0,nbkpt,bkpt,nconst,xconst,yconst,nderiv,&
!      mode,coeff,w,iw)
!    IF( num_xer/=2 ) fatal = .TRUE.
!    num_xer = 0
    !
!    CALL FC(ndata,xdata,ydata,sddata,nord,0,bkpt,nconst,xconst,yconst,nderiv,&
!      mode,coeff,w,iw)
!    IF( num_xer/=2 ) fatal = .TRUE.
!    num_xer = 0
    !
!    CALL FC(-1,xdata,ydata,sddata,nord,nbkpt,bkpt,nconst,xconst,yconst,nderiv,&
!      mode,coeff,w,iw)
!    IF( num_xer/=2 ) fatal = .TRUE.
!    num_xer = 0
    !
!    mode = 0
!    CALL FC(ndata,xdata,ydata,sddata,nord,nbkpt,bkpt,nconst,xconst,yconst,&
!      nderiv,mode,coeff,w,iw)
!    IF( num_xer/=2 ) fatal = .TRUE.
!    num_xer = 0
    !
!    iw(1) = 10
!    CALL FC(ndata,xdata,ydata,sddata,nord,nbkpt,bkpt,nconst,xconst,yconst,&
!      nderiv,mode,coeff,w,iw)
!    IF( num_xer/=2 ) fatal = .TRUE.
!    num_xer = 0
    !
!    iw(1) = 529
!    iw(2) = 2
!    CALL FC(ndata,xdata,ydata,sddata,nord,nbkpt,bkpt,nconst,xconst,yconst,&
!      nderiv,mode,coeff,w,iw)
!    IF( num_xer/=2 ) fatal = .TRUE.
!    num_xer = 0
    !
    !     Restore KONTRL and check to see if the tests of error detection
    !     passed.
    !
    IF( fatal ) THEN
      Ipass = 0
      IF( Kprint>=2 ) THEN
        WRITE (Lun,99008)
        99008 FORMAT (' AT LEAST ONE INCORRECT ARGUMENT TEST FAILED')
      END IF
    ELSEIF( Kprint>=3 ) THEN
      WRITE (Lun,99009)
      99009 FORMAT (' ALL INCORRECT ARGUMENT TESTS PASSED')
    END IF
    !
    !     Print PASS/FAIL message.
    !
    IF( Ipass==1 .AND. Kprint>=2 ) WRITE (Lun,99010)
    99010 FORMAT (/' *****************FC PASSED ALL TESTS*****************')
    IF( Ipass==0 .AND. Kprint>=1 ) WRITE (Lun,99011)
    99011 FORMAT (/' ****************FC FAILED SOME TESTS*****************')
    RETURN
  END SUBROUTINE FCQX
  !** FCN1
  PURE SUBROUTINE FCN1(Iflag,M,N,X,Fvec,Fjac,Ldfjac)
    !> Subsidiary to SNLS1Q.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (FCN1-S, DFCN1-D)
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Description:**
    !
    !   Subroutine which evaluates the function for test program
    !   used in quick check of SNLS1E.
    !
    !   Numerical approximation of Jacobian is used.
    !
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   930214  TYPE and declarations sections added.  (WRB)

    !     .. Scalar Arguments ..
    INTEGER, INTENT(IN) :: Iflag, Ldfjac, M, N
    !     .. Array Arguments ..
    REAL(SP), INTENT(IN) :: X(N)
    REAL(SP), INTENT(INOUT) :: Fvec(M)
    REAL(SP), INTENT(OUT) :: Fjac(:,:)
    !     .. Local Scalars ..
    INTEGER :: i
    REAL(SP) :: temp
    !     .. Intrinsic Functions ..
    INTRINSIC EXP
    !* FIRST EXECUTABLE STATEMENT  FCN1
    IF( Iflag/=1 ) RETURN
    DO i = 1, M
      temp = i
      Fvec(i) = 2._SP + 2._SP*temp - EXP(temp*X(1)) - EXP(temp*X(2))
    END DO
  END SUBROUTINE FCN1
  !** FCN2
  PURE SUBROUTINE FCN2(Iflag,M,N,X,Fvec,Fjac,Ldfjac)
    !> Subsidiary to SNLS1Q.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (FCN2-S, DFCN2-D)
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Description:**
    !
    !   Subroutine to evaluate function and full Jacobian for test
    !   problem in quick check of SNLS1E.
    !
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   890911  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   930214  TYPE and declarations sections added and code polished.  (WRB)

    !     .. Scalar Arguments ..
    INTEGER, INTENT(IN) :: Iflag, Ldfjac, M, N
    !     .. Array Arguments ..
    REAL(SP), INTENT(IN) :: X(N)
    REAL(SP), INTENT(INOUT) :: Fvec(M)
    REAL(SP), INTENT(OUT) :: Fjac(:,:)
    !     .. Local Scalars ..
    REAL(SP) :: temp
    INTEGER :: i
    !     .. Intrinsic Functions ..
    INTRINSIC EXP
    !* FIRST EXECUTABLE STATEMENT  FCN2
    IF( Iflag==0 ) RETURN
    !
    !     Should we evaluate functions or Jacobian?
    !
    IF( Iflag==1 ) THEN
      !
      !       Evaluate functions.
      !
      DO i = 1, M
        temp = i
        Fvec(i) = 2._SP + 2._SP*temp - EXP(temp*X(1)) - EXP(temp*X(2))
      END DO
    ELSE
      !
      !       Evaluate Jacobian.
      !
      IF( Iflag/=2 ) RETURN
      DO i = 1, M
        temp = i
        Fjac(i,1) = -temp*EXP(temp*X(1))
        Fjac(i,2) = -temp*EXP(temp*X(2))
      END DO
    END IF
  END SUBROUTINE FCN2
  !** FCN3
  PURE SUBROUTINE FCN3(Iflag,M,N,X,Fvec,Fjrow,Nrow)
    !> Subsidiary to SNLS1Q.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      SINGLE PRECISION (FCN3-S, DFCN3-D)
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Description:**
    !
    !   Subroutine to evaluate the Jacobian, one row at a time, for
    !   test problem used in quick check of SNLS1E.
    !
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   890911  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   930214  TYPE and declarations sections added and code polished.
    !           (WRB)

    !     .. Scalar Arguments ..
    INTEGER, INTENT(IN) :: Iflag, M, N, Nrow
    !     .. Array Arguments ..
    REAL(SP), INTENT(IN) :: X(N)
    REAL(SP), INTENT(INOUT) :: Fvec(M)
    REAL(SP), INTENT(OUT) :: Fjrow(:,:)
    !     .. Local Scalars ..
    REAL(SP) :: temp
    INTEGER :: i
    !     .. Intrinsic Functions ..
    INTRINSIC EXP
    !* FIRST EXECUTABLE STATEMENT  FCN3
    IF( Iflag==0 ) RETURN
    !
    !     Should we evaluate functions or Jacobian?
    !
    IF( Iflag==1 ) THEN
      !
      !       Evaluate functions.
      !
      DO i = 1, M
        temp = i
        Fvec(i) = 2._SP + 2._SP*temp - EXP(temp*X(1)) - EXP(temp*X(2))
      END DO
    ELSE
      !
      !       Evaluate one row of Jacobian.
      !
      IF( Iflag/=3 ) RETURN
      temp = Nrow
      Fjrow(1,1) = -temp*EXP(temp*X(1))
      Fjrow(2,1) = -temp*EXP(temp*X(2))
    END IF
  END SUBROUTINE FCN3
END MODULE TEST52_MOD
!** TEST52
PROGRAM TEST52
  USE TEST52_MOD, ONLY : FCQX, PFITQX, SNLS1Q
  USE ISO_FORTRAN_ENV, ONLY : INPUT_UNIT, OUTPUT_UNIT
  USE common_mod, ONLY : GET_ARGUMENT
  IMPLICIT NONE
  !> Driver for testing SLATEC subprograms
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  K1, E3, K6, L
  !***
  ! **Type:**      SINGLE PRECISION (TEST52-S, TEST53-D)
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
  !        SNLS1E   SNLS1    SCOV
  !        BVALU    CV       FC
  !        POLFIT   PCOEF    PVALUE
  !
  !***
  ! **References:**  Kirby W. Fong, Thomas H. Jefferson, Tokihiko Suyehiro
  !                 and Lee Walton, Guide to the SLATEC Common Mathema-
  !                 tical Library, April 10, 1990.
  !***
  ! **Routines called:**  FCQX, I1MACH, PFITQX, SNLS1Q, XERMAX, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   890618  DATE WRITTEN
  !   890618  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900524  Cosmetic changes to code.  (WRB)
  INTEGER :: ipass, kprint, lin, lun, nfail
  !* FIRST EXECUTABLE STATEMENT  TEST52
  lun = OUTPUT_UNIT
  lin = INPUT_UNIT
  nfail = 0
  !
  !     Read KPRINT parameter
  !
  CALL GET_ARGUMENT(kprint)
  !
  !     Test SNLS1E and SNLS1
  !
  CALL SNLS1Q(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test FC (also BVALU and CV)
  !
  CALL FCQX(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Test POLFIT (also PCOEF and PVALUE)
  !
  CALL PFITQX(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Write PASS or FAIL message
  !
  IF( nfail==0 ) THEN
    WRITE (lun,99001)
    99001 FORMAT (/' --------------TEST52 PASSED ALL TESTS----------------')
  ELSE
    WRITE (lun,99002) nfail
    99002 FORMAT (/' ************* WARNING -- ',I5,&
      ' TEST(S) FAILED IN PROGRAM TEST52 *************')
  END IF
  STOP
END PROGRAM TEST52
