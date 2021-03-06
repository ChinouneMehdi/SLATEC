MODULE TEST31_MOD
  USE service, ONLY : SP, DP
  IMPLICIT NONE

CONTAINS
  !** DBSPCK
  SUBROUTINE DBSPCK(Lun,Kprint,Ipass)
    !> Quick check for the B-Spline package.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      DOUBLE PRECISION (BSPCK-S, DBSPCK-D)
    !***
    ! **Keywords:**  QUICK CHECK
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Description:**
    !
    !   DBSPCK is a quick check routine for the B-Spline package which
    !   tests consistency between results from higher level routines.
    !   Those routines not explicitly called are exercised at some lower
    !   level.  The routines exercised are DBFQAD, DBINT4, DBINTK, DBNFAC,
    !   DBNSLV, DBSGQ8, DBSPDR, DBSPEV, DBSPPP, DBSPVD, DBSPVN, DBSQAD,
    !   DBVALU, DINTRV, DPFQAD, DPPGQ8, DPPQAD and DPPVAL.
    !
    !***
    ! **Routines called:**  D1MACH, DBFQAD, DBINT4, DBINTK, DBSPDR, DBSPEV,
    !                    DBSPPP, DBSPVD, DBSPVN, DBSQAD, DBVALU, DFB,
    !                    DINTRV, DPFQAD, DPPQAD, DPPVAL

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   890911  Removed unnecessary intrinsics.  (WRB)
    !   891004  Removed unreachable code.  (WRB)
    !   891009  Removed unreferenced variables.  (WRB)
    !   891009  REVISION DATE from Version 3.2
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   930214  Declarations sections added, code revised to test error
    !           returns for all values of KPRINT and code polished.  (WRB)
    USE service, ONLY : eps_dp
    USE interpolation, ONLY : DBFQAD, DBINT4, DBINTK, DBSPDR, DBSPEV, DBSPPP, &
      DBSPVD, DBSPVN, DBSQAD, DBVALU, DINTRV, DPPQAD, DPPVAL
    USE diff_integ, ONLY : DPFQAD
    !     .. Scalar Arguments ..
    INTEGER :: Ipass, Kprint, Lun
    !     .. Local Scalars ..
    REAL(DP) :: atol, bquad, bv, den, dn, er, fbcl, fbcr, pi, &
      spv, tol, x1, x2, xl, xx
    INTEGER :: i, ibcl, ibcr, ierr, iknt, ileft, ilo, inbv, inev, &
      inppv, j, jj, k, knt, ldc, ldcc, lxi, mflag, n, ndata, nmk, nn
    !     .. Local Arrays ..
    REAL(DP) :: adif(52), bc(13), c(4,10), cc(4,4), q(3), qq(77), &
      qsave(2), sv(4), t(17), w(65), x(11), xi(11), y(11)
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX, SIN
    !* FIRST EXECUTABLE STATEMENT  DBSPCK
    IF( Kprint>=2 ) WRITE (Lun,99001)
    !
    99001 FORMAT ('1 QUICK CHECK FOR SPLINE ROUTINES',//)
    !
    Ipass = 1
    pi = 3.14159265358979324_DP
    tol = 1000._DP*MAX(eps_dp,1.E-18_DP)
    !
    !     Generate data.
    !
    ndata = 11
    den = ndata - 1
    DO i = 1, ndata
      x(i) = (i-1)/den
      y(i) = SIN(pi*x(i))
    END DO
    x(3) = 2._DP/den
    y(3) = SIN(pi*x(3))
    !
    !     Compute splines for two knot arrays.
    !
    DO iknt = 1, 2
      knt = 3 - iknt
      ibcl = 1
      ibcr = 2
      fbcl = pi
      fbcr = 0._DP
      CALL DBINT4(x,y,ndata,ibcl,ibcr,fbcl,fbcr,knt,t,bc,n,k,w)
      !
      !       Error test on DBINT4.
      !
      inbv = 1
      DO i = 1, ndata
        xx = x(i)
        bv = DBVALU(t,bc,n,k,0,xx)
        er = ABS(y(i)-bv)
        IF( er>tol ) THEN
          Ipass = 0
          IF( Kprint>=2 ) WRITE (Lun,99002)
          99002 FORMAT (' ERROR TEST FOR INTERPOLATION BY DBINT4 NOT SATISFIED')
        END IF
      END DO
      inbv = 1
      bv = DBVALU(t,bc,n,k,1,x(1))
      er = ABS(pi-bv)
      IF( er>tol ) THEN
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99003)
        99003 FORMAT (' ERROR TEST FOR INTERPOLATION BY DBINT4 NOT SATISFIED ',&
          'BY FIRST DERIVATIVE')
      END IF
      bv = DBVALU(t,bc,n,k,2,x(ndata))
      er = ABS(bv)
      IF( er>tol ) THEN
        Ipass = 0
        IF( Kprint>=2 ) WRITE (Lun,99004)
        99004 FORMAT (' ERROR TEST FOR INTERPOLATION BY DBINT4 NOT SATISFIED ',&
          'BY SECOND DERIVATIVE')
      END IF
      !
      !       Test for equality of area from 4 routines.
      !
      x1 = x(1)
      x2 = x(ndata)
      CALL DBSQAD(t,bc,n,k,x1,x2,bquad)
      ldc = 4
      CALL DBSPPP(t,bc,n,k,ldc,c,xi,lxi,w)
      CALL DPPQAD(ldc,c,xi,lxi,k,x1,x2,q(1))
      CALL DBFQAD(DFB,t,bc,n,k,0,x1,x2,tol,q(2),ierr)
      CALL DPFQAD(DFB,ldc,c,xi,lxi,k,0,x1,x2,tol,q(3),ierr)
      !
      !       Error test for quadratures.
      !
      DO i = 1, 3
        er = ABS(bquad-q(i))
        IF( er>tol ) THEN
          Ipass = 0
          IF( Kprint>=2 ) WRITE (Lun,99005)
          99005 FORMAT (' ERROR IN QUADRATURE CHECKS')
        END IF
      END DO
      qsave(knt) = bquad
    END DO
    er = ABS(qsave(1)-qsave(2))
    IF( er>tol ) THEN
      Ipass = 0
      IF( Kprint>=2 ) WRITE (Lun,99006)
      99006 FORMAT (' ERROR IN QUADRATURE CHECK USING TWO SETS OF KNOTS')
    END IF
    !
    !     Check DBSPDR and DBSPEV against DBVALU, DPPVAL and DBSPVD.
    !
    CALL DBSPDR(t,bc,n,k,k,adif)
    inev = 1
    inbv = 1
    inppv = 1
    ilo = 1
    DO i = 1, 6
      xx = x(i+i-1)
      CALL DBSPEV(t,adif,n,k,k,xx,inev,sv,w)
      atol = tol
      DO j = 1, k
        spv = DBVALU(t,bc,n,k,j-1,xx)
        er = ABS(spv-sv(j))
        x2 = ABS(sv(j))
        IF( x2>1._DP ) er = er/x2
        IF( er>atol ) THEN
          Ipass = 0
          IF( Kprint>=2 ) WRITE (Lun,99007)
          99007 FORMAT (' COMPARISONS FROM DBSPEV AND DBVALU DO NOT AGREE')
        END IF
        atol = 10._DP*atol
      END DO
      atol = tol
      DO j = 1, k
        spv = DPPVAL(ldc,c,xi,lxi,k,j-1,xx)
        er = ABS(spv-sv(j))
        x2 = ABS(sv(j))
        IF( x2>1._DP ) er = er/x2
        IF( er>atol ) THEN
          Ipass = 0
          IF( Kprint>=2 ) WRITE (Lun,99008)
          99008 FORMAT (' COMPARISONS FROM DBSPEV AND DPPVAL DO NOT AGREE')
        END IF
        atol = 10._DP*atol
      END DO
      atol = tol
      ldcc = 4
      x1 = xx
      IF( i+i-1==ndata ) x1 = t(n)
      nn = n + k
      CALL DINTRV(t,nn,x1,ilo,ileft,mflag)
      DO j = 1, k
        CALL DBSPVD(t,k,j,xx,ileft,ldcc,cc,w)
        er = 0._DP
        DO jj = 1, k
          er = er + bc(ileft-k+jj)*cc(jj,j)
        END DO
        er = ABS(er-sv(j))
        x2 = ABS(sv(j))
        IF( x2>1._DP ) er = er/x2
        IF( er>atol ) THEN
          Ipass = 0
          IF( Kprint>=2 ) WRITE (Lun,99009)
          99009 FORMAT (' COMPARISONS FROM DBSPEV AND DBSPVD DO NOT AGREE')
        END IF
        atol = 10._DP*atol
      END DO
    END DO
    DO k = 2, 4
      n = ndata
      nmk = n - k
      DO i = 1, k
        t(i) = x(1)
        t(n+i) = x(n)
      END DO
      xl = x(n) - x(1)
      dn = n - k + 1
      DO i = 1, nmk
        t(k+i) = x(1) + i*xl/dn
      END DO
      CALL DBINTK(x,y,t,n,k,bc,qq,w)
      !
      !       Error test on DBINTK.
      !
      inbv = 1
      DO i = 1, n
        xx = x(i)
        bv = DBVALU(t,bc,n,k,0,xx)
        er = ABS(y(i)-bv)
        IF( er>tol ) THEN
          Ipass = 0
          IF( Kprint>=2 ) WRITE (Lun,99010)
          99010 FORMAT (' ERROR TEST FOR INTERPOLATION BY DBINTK NOT SATISFIED')
        END IF
      END DO
    END DO
    !
    !     Trigger error conditions.
    !
!    kontrl = control_xer
!    IF( Kprint<=2 ) THEN
!      control_xer = 0
!    ELSE
!      control_xer = 1
!    END IF
!    fatal = .FALSE.
!    num_xer = 0
!    !
!    IF( Kprint>=3 ) WRITE (Lun,99011)
!    99011 FORMAT (/' TRIGGER 52 ERROR CONDITIONS',/)
!    !
!    w(1) = 11._DP
!    w(2) = 4._DP
!    w(3) = 2._DP
!    w(4) = 0.5_DP
!    w(5) = 4._DP
!    ilo = 1
!    inev = 1
!    inbv = 1
!    CALL DINTRV(t,n+1,w(4),ilo,ileft,mflag)
!    DO i = 1, 5
!      w(i) = -w(i)
!      n = INT(w(1))
!      k = INT(w(2))
!      id = INT(w(3))
!      xx = w(4)
!      ldc = INT(w(5))
!      IF( i<=4 ) THEN
!        bv = DBVALU(t,bc,n,k,id,xx,inbv,qq)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!        !
!        CALL DBSPEV(t,adif,n,k,id,xx,inev,sv,qq)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!        !
!        jhigh = n - 10
!        CALL DBSPVN(t,jhigh,k,id,xx,ileft,sv,qq,iwork)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!        !
!        CALL DBFQAD(DFB,t,bc,n,k,id,xx,x2,tol,quad,ierr,qq)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!      END IF
!      !
!      IF( i/=3 .AND. i/=4 ) THEN
!        CALL DBSPPP(t,bc,n,k,ldc,c,xi,lxi,qq)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!      END IF
!      !
!      IF( i<=3 ) THEN
!        CALL DBSPDR(t,bc,n,k,id,adif)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!      END IF
!      !
!      IF( i/=3 .AND. i/=5 ) THEN
!        CALL DBSQAD(t,bc,n,k,xx,x2,bquad,qq)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!      END IF
!      !
!      IF( i>1 ) THEN
!        CALL DBSPVD(t,k,id,xx,ileft,ldc,c,qq)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!      END IF
!      !
!      IF( i<=2 ) THEN
!        CALL DBINTK(x,y,t,n,k,bc,qq,adif)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!      END IF
!      !
!      IF( i/=4 ) THEN
!        kntopt = ldc - 2
!        ibcl = k - 2
!        CALL DBINT4(x,y,n,ibcl,id,fbcl,fbcr,kntopt,t,bc,nn,kk,qq)
!        IF( num_xer/=2 ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!      END IF
!      w(i) = -w(i)
!    END DO
!    kntopt = 1
!    x(1) = 1._DP
!    CALL DBINT4(x,y,n,ibcl,ibcr,fbcl,fbcr,kntopt,t,bc,n,k,qq)
!    IF( num_xer/=2 ) THEN
!      Ipass = 0
!      fatal = .TRUE.
!    END IF
!    num_xer = 0
!    !
!    CALL DBINTK(x,y,t,n,k,bc,qq,adif)
!    IF( num_xer/=2 ) THEN
!      Ipass = 0
!      fatal = .TRUE.
!    END IF
!    num_xer = 0
!    !
!    x(1) = 0._DP
!    atol = 1._DP
!    kntopt = 3
!    DO i = 1, 3
!      qq(i) = -0.30_DP + 0.10_DP*(i-1)
!      qq(i+3) = 1.1_DP + 0.10_DP*(i-1)
!    END DO
!    qq(1) = 1._DP
!    CALL DBINT4(x,y,ndata,1,1,fbcl,fbcr,3,t,bc,n,k,qq)
!    IF( num_xer/=2 ) THEN
!      Ipass = 0
!      fatal = .TRUE.
!    END IF
!    num_xer = 0
!    !
!    CALL DBFQAD(DFB,t,bc,n,k,id,x1,x2,atol,quad,ierr,qq)
!    IF( num_xer/=2 ) THEN
!      Ipass = 0
!      fatal = .TRUE.
!    END IF
!    num_xer = 0
!    !
!    inppv = 1
!    DO i = 1, 5
!      w(i) = -w(i)
!      lxi =INT(w(1))
!      k = INT(w(2))
!      id = INT(w(3))
!      xx = w(4)
!      ldc = INT(w(5))
!      spv = DPPVAL(ldc,c,xi,lxi,k,id,xx)
!      IF( (i/=4 .AND. num_xer/=2) .OR. (i==4 .AND. num_xer/=0) ) THEN
!        Ipass = 0
!        fatal = .TRUE.
!      END IF
!      num_xer = 0
!      !
!      CALL DPFQAD(DFB,ldc,c,xi,lxi,k,id,xx,x2,tol,quad,ierr)
!      IF( (i/=4 .AND. num_xer/=2) .OR. (i==4 .AND. num_xer/=0) ) THEN
!        Ipass = 0
!        fatal = .TRUE.
!      END IF
!      num_xer = 0
!      !
!      IF( i/=3 ) THEN
!        CALL DPPQAD(ldc,c,xi,lxi,k,xx,x2,pquad)
!        IF( (i/=4 .AND. num_xer/=2) .OR. (i==4 .AND. num_xer/=0) ) THEN
!          Ipass = 0
!          fatal = .TRUE.
!        END IF
!        num_xer = 0
!      END IF
!      !
!      w(i) = -w(i)
!    END DO
!    ldc = INT(w(5))
!    CALL DPFQAD(DFB,ldc,c,xi,lxi,k,id,x1,x2,atol,quad,ierr)
!    IF( num_xer/=2 ) THEN
!      Ipass = 0
!      fatal = .TRUE.
!    END IF
!    num_xer = 0
    !
    !     Restore KONTRL and check to see if the tests of error detection
    !     passed.
    !
!    control_xer = kontrl
!    IF( fatal ) THEN
!      IF( Kprint>=2 ) THEN
!        WRITE (Lun,99012)
!        99012 FORMAT (/' AT LEAST ONE INCORRECT ARGUMENT TEST FAILED')
!      END IF
!    ELSEIF( Kprint>=3 ) THEN
!      WRITE (Lun,99013)
!      99013 FORMAT (/' ALL INCORRECT ARGUMENT TESTS PASSED')
!    END IF
    !
    !     Print PASS/FAIL message.
    !
    IF( Ipass==1 .AND. Kprint>=2 ) WRITE (Lun,99014)
    99014 FORMAT (/' **********B-SPLINE PACKAGE PASSED ALL TESTS**********')
    IF( Ipass==0 .AND. Kprint>=1 ) WRITE (Lun,99015)
    99015 FORMAT (/' *********B-SPLINE PACKAGE FAILED SOME TESTS**********')
    RETURN
  END SUBROUTINE DBSPCK
  !** DFB
  REAL(DP) PURE FUNCTION DFB(X)
    !> Subsidiary to DBSPCK.
    !***
    ! **Library:**   SLATEC
    !***
    ! **Type:**      DOUBLE PRECISION (FB-S, DFB-D)
    !***
    ! **Author:**  (UNKNOWN)
    !***
    ! **Routines called:**  (NONE)

    !* REVISION HISTORY  (YYMMDD)
    !   ??????  DATE WRITTEN
    !   891214  Prologue converted to Version 4.0 format.  (BAB)
    !   930214  Added TYPE statement.  (WRB)

    REAL(DP), INTENT(IN) :: X
    !* FIRST EXECUTABLE STATEMENT  DFB
    DFB = 1._DP
  END FUNCTION DFB
END MODULE TEST31_MOD
!** TEST31
PROGRAM TEST31
  USE TEST31_MOD, ONLY : DBSPCK
  USE ISO_FORTRAN_ENV, ONLY : INPUT_UNIT, OUTPUT_UNIT
  USE common_mod, ONLY : GET_ARGUMENT
  IMPLICIT NONE
  !> Driver for testing SLATEC subprograms
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  E, E1A, E3
  !***
  ! **Type:**      DOUBLE PRECISION (TEST30-S, TEST31-D)
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
  !        DBFQAD   DBINT4   DBINTK   DBSPDR   DBSPEV   DBSPPP
  !        DBSPVD   DBSPVN   DBSQAD   DBVALU   DINTRV   DPFQAD
  !        DPPQAD   DPPVAL
  !
  !***
  ! **References:**  Kirby W. Fong, Thomas H. Jefferson, Tokihiko Suyehiro
  !                 and Lee Walton, Guide to the SLATEC Common Mathema-
  !                 tical Library, April 10, 1990.
  !***
  ! **Routines called:**  DBSPCK, I1MACH, XERMAX, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   890618  DATE WRITTEN
  !   890618  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900524  Cosmetic changes to code.  (WRB)
  INTEGER :: ipass, kprint, lin, lun, nfail
  !* FIRST EXECUTABLE STATEMENT  TEST31
  lun = OUTPUT_UNIT
  lin = INPUT_UNIT
  nfail = 0
  !
  !     Read KPRINT parameter
  !
  CALL GET_ARGUMENT(kprint)
  !
  !     Test double precision B-Spline package
  !
  CALL DBSPCK(lun,kprint,ipass)
  IF( ipass==0 ) nfail = nfail + 1
  !
  !     Write PASS or FAIL message
  !
  IF( nfail==0 ) THEN
    WRITE (lun,99001)
    99001 FORMAT (/' --------------TEST31 PASSED ALL TESTS----------------')
  ELSE
    WRITE (lun,99002) nfail
    99002 FORMAT (/' ************* WARNING -- ',I5,&
      ' TEST(S) FAILED IN PROGRAM TEST31 *************')
  END IF
  STOP
END PROGRAM TEST31
