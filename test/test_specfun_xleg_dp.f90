MODULE TEST12_MOD
  USE service, ONLY : SP, DP
  IMPLICIT NONE

CONTAINS
  !** FCNQX2
  SUBROUTINE FCNQX2(Lun,Kprint,Ipass)
    !> THIS IS A QUICK CHECK PROGRAM FOR THE SUBROUTINES DXLEGF
    !            AND DXNRMP WHICH CALCULATE LEGENDRE FUNCTIONS
    !***
    ! **Library:**   SLATEC
    !***
    ! **Category:**  C3A2, C9
    !***
    ! **Type:**      DOUBLE PRECISION (FCNQX1-S, FCNQX2-D)
    !***
    ! **Keywords:**  LEGENDRE FUNCTIONS, QUICK CHECK
    !***
    ! **Author:**  LOZIER, DANIEL W., (NIST)
    !           SMITH, JOHN M., (NIST AND GEORGE MASON UNIVERSITY)
    !***
    ! **References:**  OLVER AND SMITH,J.COMPUT.PHYSICS,51(1983),NO.3,502-518.
    !               SMITH, OLVER AND LOZIER,ACM TRANS MATH SOFTW,7(1981),
    !                 NO.1,93-105.
    !***
    ! **Routines called:**  DXCON, DXCSRT, num_xer, DXLEGF, DXNRMP, DXSET, XSETF

    !* REVISION HISTORY  (YYMMDD)
    !   881020  DATE WRITTEN
    !   900306  Added SLATEC prologue to this routine. (DWL and JMS)
    !   901019  Revisions to prologue.  (DWL and WRB)
    !   901106  Changed all specific intrinsics to generic.  (WRB)
    !   910104  Changed to print variable number of decimals. (DWL and JMS)
    USE service, ONLY : digits_dp, max_exp_dp, radix_fp
    USE special_functions, ONLY : DXCON, DXLEGF, DXNRMP, DXSET
    !
    INTEGER :: i, ic1(10), ic2(10), ierr, ierror, ip(10), ipn(10), &
      iq(10), ir(10), irad, isig, isum, ix11, ix12, ix13, ix21, ix22, ix23
    INTEGER :: mu, mu1, mu2, nbits, ndec, nradpl, nu1, nudiff
    CHARACTER(34) :: fmt, fmtf, fmti
    INTEGER :: Lun, Kprint, Ipass
    REAL(DP) :: p(10), q(10), r(10), c1(10), c2(10), pn(10)
    REAL(DP) :: deg, theta, dnu1
    REAL(DP) :: x11, x12, x13, x21, x22, x23
    REAL(SP) :: nu
    !
    !* FIRST EXECUTABLE STATEMENT  FCNQX2
    !
    IF( Kprint>=2 ) WRITE (Lun,99001)
    99001 FORMAT (' ** TEST DOUBLE PRECISION LEGENDRE FUNCTION ROUTINES',&
      ' IN FCNPAK ** ',/)
    Ipass = 1
    irad = radix_fp
    nradpl = 0
    nbits = 0
    CALL DXSET(irad,nradpl,0._DP,nbits,ierror)
    IF( ierror/=0 ) Ipass = 0
    ierr = 0
    dnu1 = 2000.4_DP
    IF( max_exp_dp*LOG10(REAL(radix_fp))<150._SP ) dnu1 = 100.4_DP
    IF( Kprint>2 ) THEN
      IF( max_exp_dp<500 ) WRITE (Lun,99002)
      99002 FORMAT (' ON COMPUTERS WITH MAXIMUM EXPONENT LESS THAN 500, SMALL'/ &
        ' TEST VALUES FOR NU, MU ARE USED. IF LARGER THAN OR EQUAL 500,'/ &
        ' LARGER VALUES ARE USED. THIS COMPUTER USES THE SMALLER VALUES.')
      IF( max_exp_dp>=500 ) WRITE (Lun,99003)
      99003 FORMAT (' ON COMPUTERS WITH MAXIMUM EXPONENT LESS THAN 500, SMALL'/ &
        ' TEST VALUES FOR NU, MU ARE USED. IF LARGER THAN OR EQUAL 500,'/ &
        ' LARGER VALUES ARE USED. THIS COMPUTER USES THE LARGER VALUES.')
    END IF
    nudiff = 5
    mu1 = INT( dnu1 )
    mu2 = mu1
    deg = 0.1_DP
    theta = deg*4._DP*ATAN(1._DP)/180._DP
    !
    ! In TEST 1 the Legendre functions P (of both positive and negative
    ! order) and Q are calculated.  Large values of mu and nu are used
    ! so that it is necessary to use extended range arithmetic.  The
    ! values of the Casoratians should be approximately equal to 1.0.
    ! The check which is applied is to verify that the difference between
    ! the Casoratians and 1.0 is less that 10.**(6-NDEC), where NDEC =
    ! INT((D-1)*LOG10(R)), D = digits_dp = significand length, R =
    ! radix_fp = radix. The value of IERROR should always be returned
    ! as zero. This test uses the programs
    ! XLEGF, XPQNU, XPSI, XQNU, XPMUP, XSET, XADD,
    ! XADJ, XCSRT, XRED, XC210, and XCON.
    !
    isum = 0
    ndec = INT( (digits_dp-1)*LOG10(REAL(radix_fp)) )
    ! Formats that depend on NDEC ...
    fmt(1:20) = '(1X, 6X, 4H   (,E50.'
    WRITE (fmt(21:22),'(I2)') ndec
    fmt(23:34) = ',1H,,I8,1H))'
    fmtf(1:20) = '(1X,F6.1,4H   (,E50.'
    WRITE (fmtf(21:22),'(I2)') ndec
    fmtf(23:34) = ',1H,,I8,1H))'
    fmti(1:20) = '(1X, I6, 4H   (,E50.'
    WRITE (fmti(21:22),'(I2)') ndec
    fmti(23:34) = ',1H,,I8,1H))'
    IF( Kprint>2 ) WRITE (Lun,99004) mu1, deg
    99004 FORMAT (/' TEST 1, FIXED MU = ',I4,' AND THETA = ',F3.1,&
      ' DEGREES, RECURRENCE IN NU,'/'         CASORATIS SHOULD = 1.0')
    CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,1,p,ip,ierror)
    isum = isum + ierror
    CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,2,q,iq,ierror)
    isum = isum + ierror
    CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,3,r,ir,ierror)
    isum = isum + ierror
    CALL DXCSRT(dnu1,nudiff,mu1,mu2,theta,p,q,r,ip,iq,ir,c1,ic1,c2,ic2,ierror)
    isum = isum + ierror
    DO i = 1, 6
      CALL DXCON(p(i),ip(i),ierror)
      isum = isum + ierror
      CALL DXCON(q(i),iq(i),ierror)
      isum = isum + ierror
      CALL DXCON(r(i),ir(i),ierror)
      isum = isum + ierror
    END DO
    x11 = p(1)
    ix11 = ip(1)
    x12 = r(1)
    ix12 = ir(1)
    x13 = q(1)
    ix13 = iq(1)
    IF( Kprint>2 ) THEN
      WRITE (Lun,'(A)') '     NU   CASORATI 1'
      nu = REAL( dnu1, SP )
      DO i = 1, 5
        WRITE (Lun,fmtf) nu, c1(i), ic1(i)
        nu = nu + 1._SP
      END DO
      WRITE (Lun,'(A)') '     NU   CASORATI 2'
      nu = REAL( dnu1, SP )
      DO i = 1, 5
        WRITE (Lun,fmtf) nu, c2(i), ic2(i)
        nu = nu + 1._SP
      END DO
    END IF
    DO i = 1, 5
      IF( ABS(1._DP-c1(i))>=10._DP**(6-ndec) ) GOTO 100
      IF( ABS(1._DP-c2(i))>=10._DP**(6-ndec) ) GOTO 100
    END DO
    IF( isum==0 ) THEN
      IF( Kprint>=2 ) WRITE (Lun,99005)
      99005 FORMAT (' ***** TEST 1 (DOUBLE PRECISION) PASSED *****')
      GOTO 200
    END IF
    100 CONTINUE
    IF( Kprint>=1 ) WRITE (Lun,99006)
    99006 FORMAT (' ***** TEST 1 (DOUBLE PRECISION) FAILED *****')
    ierr = ierr + 1
    Ipass = 0
    200  nudiff = 0
    mu1 = mu2 - 5
    !
    ! In TEST 2 P (of positive and negative order) and Q are again
    ! calculated but in this test the recurrence is in the mu-wise direction
    ! rather than in the nu-wise direction as was the case before.  The same
    ! programs are used except that DXQNU is not used and DXQMU and DXPMU
    ! are used. Again the criterion for passing the test is that the
    ! Casoratians differ from 1.0 by less than 10.0**(6-NDEC). The value
    ! of IERROR should always be returned as zero.
    !
    isum = 0
    IF( Kprint>2 ) WRITE (Lun,99007) dnu1, deg
    99007 FORMAT (/' TEST 2, FIXED NU = ',F6.1,' AND THETA = ',F3.1,&
      ' DEGREES, RECURRENCE IN MU,'/'         CASORATIS SHOULD = 1.0')
    CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,1,p,ip,ierror)
    isum = isum + ierror
    CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,2,q,iq,ierror)
    isum = isum + ierror
    CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,3,r,ir,ierror)
    isum = isum + ierror
    CALL DXCSRT(dnu1,nudiff,mu1,mu2,theta,p,q,r,ip,iq,ir,c1,ic1,c2,ic2,ierror)
    isum = isum + ierror
    DO i = 1, 6
      CALL DXCON(p(i),ip(i),ierror)
      isum = isum + ierror
      CALL DXCON(q(i),iq(i),ierror)
      isum = isum + ierror
      CALL DXCON(r(i),ir(i),ierror)
      isum = isum + ierror
    END DO
    x21 = p(6)
    ix21 = ip(6)
    x22 = r(6)
    ix22 = ir(6)
    x23 = q(6)
    ix23 = iq(6)
    IF( Kprint>2 ) THEN
      WRITE (Lun,'(A)') '     MU   CASORATI 3'
      mu = mu1
      DO i = 1, 5
        WRITE (Lun,fmti) mu, c1(i), ic1(i)
        mu = mu + 1
      END DO
      WRITE (Lun,'(A)') '     MU   CASORATI 4'
      mu = mu1
      DO i = 1, 5
        WRITE (Lun,fmti) mu, c2(i), ic2(i)
        mu = mu + 1
      END DO
    END IF
    DO i = 1, 5
      IF( ABS(1._DP-c1(i))>=10._DP**(6-ndec) ) GOTO 300
      IF( ABS(1._DP-c2(i))>=10._DP**(6-ndec) ) GOTO 300
      IF( isum/=0 ) GOTO 300
    END DO
    IF( Kprint>=2 ) WRITE (Lun,99008)
    99008 FORMAT (' ***** TEST 2 (DOUBLE PRECISION) PASSED *****')
    GOTO 400
    300 CONTINUE
    IF( Kprint>=1 ) WRITE (Lun,99009)
    99009 FORMAT (' ***** TEST 2 (DOUBLE PRECISION) FAILED *****')
    ierr = ierr + 1
    Ipass = 0
    !
    ! In TEST 3 values of P and Q which were calculated in two different
    ! manners, one by nu-wise recurrence in TEST 1 and one by mu-wise
    ! recurrence in TEST 2, are compared.  Again, the criterion for success
    ! is a relative error of less than 10.0**(6-NDEC).
    !
    400 CONTINUE
    IF( Kprint>2 ) THEN
      WRITE (Lun,99010) deg, mu2, dnu1
      99010 FORMAT (/' TEST 3, COMPARISON OF VALUES FROM TEST 1 AND TEST 2',&
        ' WITH THETA = ',F3.1,' DEGREES,'/'         MU = ',I4,' AND NU = ',F6.1)
      WRITE (Lun,'(A)') '          P(-MU,NU)'
      WRITE (Lun,fmt) x11, ix11
      WRITE (Lun,fmt) x21, ix21
      WRITE (Lun,'(A)') '          P(MU,NU)'
      WRITE (Lun,fmt) x12, ix12
      WRITE (Lun,fmt) x22, ix22
      WRITE (Lun,'(A)') '          Q(MU,NU)'
      WRITE (Lun,fmt) x13, ix13
      WRITE (Lun,fmt) x23, ix23
    END IF
    IF( ABS((x11-x21)/x11)<10._DP**(6-ndec) ) THEN
      IF( ABS((x12-x22)/x12)<10._DP**(6-ndec) ) THEN
        IF( ABS((x13-x23)/x13)<10._DP**(6-ndec) ) THEN
          IF( ix11==ix21 ) THEN
            IF( ix12==ix22 ) THEN
              IF( ix13==ix23 ) THEN
                IF( Kprint>=2 ) WRITE (Lun,99011)
                99011 FORMAT (' ***** TEST 3 (DOUBLE PRECISION) PASSED *****')
                GOTO 500
              END IF
            END IF
          END IF
        END IF
      END IF
    END IF
    IF( Kprint>=1 ) WRITE (Lun,99012)
    99012 FORMAT (' ***** TEST 3 (DOUBLE PRECISION) FAILED *****')
    ierr = ierr + 1
    Ipass = 0
    !
    ! In TEST 4, the value of the normalized Legendre function as
    ! calculated by DXLEGF and DXPNRM is compared to the same value
    ! as calculated by the program DXNRMP.  Again the criterion is a
    ! relative error of less than 10.0**(6-NDEC). The value of IERROR
    ! should always be returned as zero.
    !
    500  isum = 0
    dnu1 = 100._DP
    nudiff = 0
    mu1 = 10
    mu2 = 10
    IF( Kprint>2 ) WRITE (Lun,99013) deg, mu1, dnu1
    99013 FORMAT (/' TEST 4, COMPARISON OF VALUES FROM DXLEGF AND DXNRMP',&
      ' WITH THETA = ',F3.1,' DEGREES,'/'         MU = ',I4,' AND NU = ',F6.1)
    CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,4,pn,ipn,ierror)
    isum = isum + ierror
    x11 = pn(1)
    ix11 = ipn(1)
    nu1 = 100
    CALL DXNRMP(nu1,mu1,mu2,theta,2,pn,ipn,isig,ierror)
    isum = isum + ierror
    x21 = pn(1)
    ix21 = ipn(1)
    IF( Kprint>2 ) THEN
      WRITE (Lun,'(A)') '          NORMALIZED P'
      WRITE (Lun,fmt) x11, ix11
      WRITE (Lun,fmt) x21, ix21
    END IF
    IF( ABS((x11-x21)/x11)<10._DP**(6-ndec) ) THEN
      IF( ix11==ix21 ) THEN
        IF( isum==0 ) THEN
          IF( Kprint>=2 ) WRITE (Lun,99014)
          99014 FORMAT (' ***** TEST 4 (DOUBLE PRECISION) PASSED *****')
          GOTO 700
        END IF
      END IF
    END IF
    IF( Kprint>=1 ) WRITE (Lun,99015)
    99015 FORMAT (' ***** TEST 4 (DOUBLE PRECISION) FAILED *****')
    ierr = ierr + 1
    Ipass = 0
    !
    ! In TEST 5 errors are purposely made in input so as to test error
    ! handling capability. First, an incorrect value of ID is given. Then
    ! both NUDIFF and MU2-MU1 are non-zero. Finally, an incorrect value
    ! of THETA is given. In each case the value of the error indicator
    ! IERROR should equal the error number as returned by the error
    ! handling package XERROR (which includes XSETF, num_xer, and NUMXER).
    !
!    600  control_xer = -1
!    IF( Kprint<=2 ) control_xer = 0
!    IF( Kprint>2 ) WRITE (Lun,99016)
!    99016 FORMAT (/' TEST 5, TEST OF ERROR HANDLING. 3 ERROR MESSAGES',&
!      ' SHOULD BE PRINTED.')
!    nudiff = 0
!    mu2 = mu1
!    id = 5
!    num_xer = 0
!    CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,id,p,ip,ierror)
!    n = num_xer
!    IF( n==ierror ) THEN
!      mu2 = mu1 + 5
!      nudiff = 5
!      num_xer = 0
!      CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,1,p,ip,ierror)
!      n = num_xer
!      IF( n==ierror ) THEN
!        nudiff = 0
!        theta = 2._DP
!        num_xer = 0
!        CALL DXLEGF(dnu1,nudiff,mu1,mu2,theta,1,p,ip,ierror)
!        n = num_xer
!        IF( n==ierror ) THEN
!          IF( Kprint>=2 ) WRITE (Lun,99017)
!          99017 FORMAT (' ***** TEST 5 (DOUBLE PRECISION) PASSED *****')
!          GOTO 700
!        END IF
!      END IF
!    END IF
!    IF( Kprint>=1 ) WRITE (Lun,99018)
!    99018 FORMAT (' ***** TEST 5 (DOUBLE PRECISION) FAILED *****')
!    ierr = ierr + 1
!    Ipass = 0
    700 CONTINUE
    IF( ierr/=0 ) THEN
      IF( Kprint>=2 ) WRITE (Lun,99019) ierr
      99019 FORMAT (/'  TESTS COMPLETED, NUMBER OF TESTS FAILED = ',I2)
    END IF
  END SUBROUTINE FCNQX2
  !** DXCSRT
  SUBROUTINE DXCSRT(Dnu1,Nudiff,Mu1,Mu2,Theta,P,Q,R,Ip,Iq,Ir,C1,Ic1,C2,Ic2,Ierror)
    !> TO COMPUTE CHECK VALUES FOR LEGENDRE FUNCTIONS
    !***
    ! **Library:**   SLATEC
    !***
    ! **Category:**  C3A2, C9
    !***
    ! **Type:**      SINGLE PRECISION (XCRST-S, DXCRST-D)
    !***
    ! **Keywords:**  LEGENDRE FUNCTIONS
    !***
    ! **Author:**  SMITH, JOHN M., (NBS AND GEORGE MASON UNIVERSITY)
    !***
    ! **Description:**
    !
    !        SUBROUTINE DXCSRT CALCULATES CASORATI (CROSS PRODUCT)
    !        CHECK VALUES AND STORES THEM IN ARRAYS C1 AND C2 WITH
    !        EXPONENTS IN ARRAYS IC1 AND IC2.  CALCULATIONS ARE BASED
    !        ON PREVIOUSLY CALCULATED LEGENDRE FUNCTIONS OF THE
    !        FIRST KIND (NEGATIVE ORDER) IN ARRAY P, THE SECOND KIND
    !        IN ARRAY Q, THE FIRST KIND (POSITIVE ORDER) IN ARRAY R.
    !        RESULTS SHOULD BE 1.0 TO WITHIN ROUNDOFF ERROR.
    !
    !***
    ! **See also:**  FCNQX2
    !***
    ! **References:**  OLVER AND SMITH,J.COMPUT.PHYSICS,51(1983),NO.3,502-518.
    !***
    ! **Routines called:**  DXADD, DXADJ, DXRED

    !* REVISION HISTORY  (YYMMDD)
    !   820728  DATE WRITTEN
    !   890126  Revised to meet SLATEC CML recommendations.  (DWL and JMS)
    !   901019  Revisions to prologue.  (DWL and WRB)
    !   901106  Changed all specific intrinsics to generic.  (WRB)
    USE special_functions, ONLY : DXADD, DXADJ, DXRED
    !
    INTEGER :: i, Ic1(*), Ic2(*), Ierror, Ip(*), Iq(*), Ir(*), ix1, ix2, j, k, l, &
      lm1, mu, Mu1, Mu2, Nudiff
    REAL(DP) :: C1(*), C2(*), dmu, dmu1, nu, Dnu1, P(*), Q(*), R(*), Theta, sx, x1, x2
    !
    !         PLACE ALL INPUT IN ADJUSTED FORM.
    !
    !* FIRST EXECUTABLE STATEMENT  DXCSRT
    Ierror = 0
    l = Nudiff + (Mu2-Mu1) + 1
    lm1 = l - 1
    DO i = 1, l
      CALL DXADJ(P(i),Ip(i),Ierror)
      IF( Ierror/=0 ) RETURN
      CALL DXADJ(Q(i),Iq(i),Ierror)
      IF( Ierror/=0 ) RETURN
      CALL DXADJ(R(i),Ir(i),Ierror)
      IF( Ierror/=0 ) RETURN
    END DO
    !
    !         CHECKS FOR FIXED MU, VARIABLE NU
    !
    IF( Mu2>Mu1 ) THEN
      !
      !         CHECKS FOR FIXED NU, VARIABLE MU
      !
      sx = SIN(Theta)
      DO i = 1, lm1
        C1(i) = 0._DP
        C2(i) = 0._DP
        !
        !         CASORATI 4
        !
        !         (MU+NU+1)*(MU-NU)*P(-(MU+1),NU,X)*Q(MU,NU,X)
        !              -P(-MU,NU,X)*Q(MU+1,NU,X)=COS(MU*PI)/SQRT(1-X**2)
        !
        mu = Mu1 + i - 1
        dmu = mu
        x1 = P(i+1)*Q(i)
        ix1 = Ip(i+1) + Iq(i)
        CALL DXADJ(x1,ix1,Ierror)
        IF( Ierror/=0 ) RETURN
        x2 = P(i)*Q(i+1)
        ix2 = Ip(i) + Iq(i+1)
        CALL DXADJ(x2,ix2,Ierror)
        IF( Ierror/=0 ) RETURN
        x1 = (dmu+Dnu1+1._DP)*(dmu-Dnu1)*x1
        !
        !         MULTIPLY BY SQRT(1-X**2)*(-1)**MU SO THAT CHECK VALUE IS 1.
        !
        CALL DXADD(x1,ix1,-x2,ix2,C1(i),Ic1(i),Ierror)
        IF( Ierror/=0 ) RETURN
        C1(i) = sx*C1(i)*(-1)**mu
        CALL DXADJ(C1(i),Ic1(i),Ierror)
        IF( Ierror/=0 ) RETURN
        !
        !         CASORATI 3
        !
        !         P(MU+1,NU,X)*Q(MU,NU,X)-P(MU,NU,X)*Q(MU+1,NU,X)=
        !               GAMMA(NU+MU+1)/(GAMMA(NU-MU+1)*SQRT(1-X**2))
        !
        IF( dmu<Dnu1+1._DP .OR. MOD(Dnu1,1._DP)/=0._DP ) THEN
          x1 = R(i+1)*Q(i)
          ix1 = Ir(i+1) + Iq(i)
          CALL DXADJ(x1,ix1,Ierror)
          IF( Ierror/=0 ) RETURN
          x2 = R(i)*Q(i+1)
          ix2 = Ir(i) + Iq(i+1)
          CALL DXADJ(x2,ix2,Ierror)
          IF( Ierror/=0 ) RETURN
          CALL DXADD(x1,ix1,-x2,ix2,C2(i),Ic2(i),Ierror)
          IF( Ierror/=0 ) RETURN
          !
          !         MULTIPLY BY SQRT(1-X**2) AND THEN DIVIDE BY
          !         (NU+MU),(NU+MU-1),(NU+MU-2),...,(NU-MU+1) SO THAT
          !         CHECK VALUE IS 1.
          !
          C2(i) = C2(i)*sx
          k = 2*mu
          IF( k>0 ) THEN
            DO j = 1, k
              C2(i) = C2(i)/(Dnu1+dmu+1._DP-j)
              CALL DXADJ(C2(i),Ic2(i),Ierror)
            END DO
            IF( Ierror/=0 ) RETURN
          END IF
        END IF
      END DO
    ELSE
      dmu1 = Mu1
      DO i = 1, lm1
        C1(i) = 0._DP
        C2(i) = 0._DP
        nu = Dnu1 + i - 1._DP
        !
        !         CASORATI 2
        !
        !         (MU+NU+1)*P(-MU,NU+1,X)*Q(MU,NU,X)
        !               +(MU-NU-1)*P(-MU,NU,X)*Q(MU,NU+1,X)=COS(MU*PI)
        !
        x1 = P(i+1)*Q(i)
        ix1 = Ip(i+1) + Iq(i)
        CALL DXADJ(x1,ix1,Ierror)
        IF( Ierror/=0 ) RETURN
        x2 = P(i)*Q(i+1)
        ix2 = Ip(i) + Iq(i+1)
        CALL DXADJ(x2,ix2,Ierror)
        IF( Ierror/=0 ) RETURN
        x1 = (dmu1+nu+1._DP)*x1
        x2 = (dmu1-nu-1._DP)*x2
        CALL DXADD(x1,ix1,x2,ix2,C1(i),Ic1(i),Ierror)
        IF( Ierror/=0 ) RETURN
        CALL DXADJ(C1(i),Ic1(i),Ierror)
        IF( Ierror/=0 ) RETURN
        !
        !         MULTIPLY BY (-1)**MU SO THAT CHECK VALUE IS 1.
        !
        C1(i) = C1(i)*(-1)**Mu1
        !
        !         CASORATI 1
        !
        !         P(MU,NU+1,X)*Q(MU,NU,X)-P(MU,NU,X)*Q(MU,NU+1,X)=
        !               GAMMA(NU+MU+1)/GAMMA(NU-MU+2)
        !
        IF( dmu1>=nu+1._DP .AND. MOD(nu,1._DP)==0._DP ) THEN
          C2(i) = 0._DP
          Ic2(i) = 0
        ELSE
          x1 = R(i+1)*Q(i)
          ix1 = Ir(i+1) + Iq(i)
          CALL DXADJ(x1,ix1,Ierror)
          IF( Ierror/=0 ) RETURN
          x2 = R(i)*Q(i+1)
          ix2 = Ir(i) + Iq(i+1)
          CALL DXADJ(x2,ix2,Ierror)
          IF( Ierror/=0 ) RETURN
          CALL DXADD(x1,ix1,-x2,ix2,C2(i),Ic2(i),Ierror)
          IF( Ierror/=0 ) RETURN
          !
          !         DIVIDE BY (NU+MU),(NU+MU-1),(NU+MU-2),....(NU-MU+2),
          !         SO THAT CHECK VALUE IS 1.
          !
          k = 2*Mu1 - 1
          DO j = 1, k
            IF( k>0 ) C2(i) = C2(i)/(nu+dmu1+1._DP-j)
            CALL DXADJ(C2(i),Ic2(i),Ierror)
          END DO
          IF( Ierror/=0 ) RETURN
          IF( k<=0 ) C2(i) = (nu+1._DP)*C2(i)
        END IF
      END DO
    END IF
    !
    !         PLACE RESULTS IN REDUCED FORM.
    !
    DO i = 1, lm1
      CALL DXRED(C1(i),Ic1(i),Ierror)
      IF( Ierror/=0 ) RETURN
      CALL DXRED(C2(i),Ic2(i),Ierror)
      IF( Ierror/=0 ) RETURN
    END DO
  END SUBROUTINE DXCSRT
END MODULE TEST12_MOD
!** TEST12
PROGRAM TEST12
  USE TEST12_MOD, ONLY : FCNQX2
  USE ISO_FORTRAN_ENV, ONLY : INPUT_UNIT, OUTPUT_UNIT
  USE common_mod, ONLY : GET_ARGUMENT
  IMPLICIT NONE
  !> Driver for testing SLATEC subprograms
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  A3D, C3A2, C7C, C9
  !***
  ! **Type:**      DOUBLE PRECISION (TEST11-S, TEST12-D)
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
  !     Driver for testing SLATEC subprogram
  !        DXLEGF   DXNRMP
  !
  !***
  ! **References:**  Fong, Kirby W., Jefferson, Thomas H., Suyehiro,
  !                 Tokihiko, Walton, Lee, Guidelines to the SLATEC Common
  !                 Mathematical Library, March 21, 1989.
  !***
  ! **Routines called:**  FCNQX2, I1MACH, XERMAX, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   901204  DATE WRITTEN
  INTEGER :: ipass, kprint, lin, lun, nfail
  !* FIRST EXECUTABLE STATEMENT  TEST12
  lun = OUTPUT_UNIT
  lin = INPUT_UNIT
  nfail = 0
  !
  !     Read KPRINT parameter
  !
  CALL GET_ARGUMENT(kprint)
  !
  !     Test DXLEGF and DXNRMP
  !
  CALL FCNQX2(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Write PASS or FAIL message
  !
  IF( nfail==0 ) THEN
    WRITE (lun,99001)
    99001 FORMAT (/' --------------TEST12 PASSED ALL TESTS----------------')
  ELSE
    WRITE (lun,99002) nfail
    99002 FORMAT (/' ************* WARNING -- ',I5,&
      ' TEST(S) FAILED IN PROGRAM TEST12  *************')
  END IF
  STOP
END PROGRAM TEST12
