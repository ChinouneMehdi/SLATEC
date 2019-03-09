MODULE TEST18_MOD
  IMPLICIT NONE

CONTAINS
  !DECK SBEG
  REAL FUNCTION SBEG(Reset)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SBEG
    !***SUBSIDIARY
    !***PURPOSE  Generate random numbers.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Du Croz, J. (NAG)
    !           Hanson, R. J. (SNLA)
    !***DESCRIPTION
    !
    !  Generates random numbers uniformly distributed between -0.5 and 0.5.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  (NONE)
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SBEG
    !     .. Scalar Arguments ..
    LOGICAL Reset
    !     .. Local Scalars ..
    INTEGER i, ic, mi
    !     .. Save statement ..
    SAVE i, ic, mi
    !     .. Intrinsic Functions ..
    INTRINSIC REAL
    ! ***FIRST EXECUTABLE STATEMENT  SBEG
    IF ( Reset ) THEN
      !        Initialize local variables.
      mi = 891
      i = 7
      ic = 0
      Reset = .FALSE.
    ENDIF
    !
    !     The sequence of values of I is bounded between 1 and 999.
    !     If initial I = 1,2,3,6,7 or 9, the period will be 50.
    !     If initial I = 4 or 8, the period will be 25.
    !     If initial I = 5, the period will be 10.
    !     IC is used to break up the period by skipping 1 value of I in 6.
    !
    ic = ic + 1
    DO
      i = i*mi
      i = i - 1000*(i/1000)
      IF ( ic>=5 ) THEN
        ic = 0
        CYCLE
      ENDIF
      SBEG = REAL(i-500)/1001.0
      EXIT
    ENDDO
    !
    !     End of SBEG.
    !
  END FUNCTION SBEG
  !DECK SBLAT2
  SUBROUTINE SBLAT2(Nout,Kprint,Ipass)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SBLAT2
    !***PURPOSE  Driver for testing Level 2 BLAS single precision
    !            subroutines.
    !***LIBRARY   SLATEC (BLAS)
    !***CATEGORY  A3A
    !***TYPE      SINGLE PRECISION (SBLAT2-S, DBLAT2-D, CBLAT2-C)
    !***KEYWORDS  BLAS, QUICK CHECK DRIVER
    !***AUTHOR  Du Croz, J. J., (NAG)
    !           Hanson, R. J., (SNLA)
    !***DESCRIPTION
    !
    !  Test program for the REAL             Level 2 Blas.
    !
    !***REFERENCES  Dongarra, J. J., Du Croz, J. J., Hammarling, S. and
    !                 Hanson, R. J.  An  extended  set of Fortran Basic
    !                 Linear Algebra Subprograms. ACM TOMS, Vol. 14, No. 1,
    !                 pp. 1-17, March 1988.
    !***ROUTINES CALLED  LSE, R1MACH, SCHK12, SCHK22, SCHK32, SCHK42,
    !                    SCHK52, SCHK62, SCHKE2, SMVCH, XERCLR
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !   930315  Removed unused variables.  (WRB)
    !   930618  Code modified to improve PASS/FAIL reporting.  (BKS, WRB)
    !***END PROLOGUE  SBLAT2
    !     .. Parameters ..
    INTEGER NSUBS
    PARAMETER (NSUBS=16)
    REAL ZERO, ONE
    PARAMETER (ZERO=0.0,ONE=1.0)
    INTEGER NMAX, INCMAX
    PARAMETER (NMAX=65,INCMAX=2)
    !     .. Scalar Arguments ..
    INTEGER Ipass, Kprint
    !     .. Local Scalars ..
    LOGICAL ftl, ftl1, ftl2
    REAL eps, err, thresh
    INTEGER i, isnum, j, n, NALF, NBET, NIDIM, NINC, NKB, Nout
    PARAMETER (NIDIM=6,NKB=4,NINC=4,NALF=3,NBET=3)
    LOGICAL same, tsterr
    CHARACTER :: trans
    !     .. Local Arrays ..
    REAL a(NMAX,NMAX), aa(NMAX*NMAX), alf(NALF), as(NMAX*NMAX), bet(NBET)&
      , g(NMAX), x(NMAX), xs(NMAX*INCMAX), xx(NMAX*INCMAX), y(NMAX) ,&
      ys(NMAX*INCMAX), yt(NMAX), yy(NMAX*INCMAX), z(2*NMAX)
    INTEGER idim(NIDIM), inc(NINC), kb(NKB)
    LOGICAL ltest(NSUBS)
    CHARACTER(6) :: snames(NSUBS)
    !     .. External Functions ..
    REAL R1MACH
    EXTERNAL R1MACH
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX, MIN
    !     .. Data statements ..
    DATA snames/'SGEMV ', 'SGBMV ', 'SSYMV ', 'SSBMV ', 'SSPMV ' ,&
      'STRMV ', 'STBMV ', 'STPMV ', 'STRSV ', 'STBSV ', 'STPSV ' ,&
      'SGER  ', 'SSYR  ', 'SSPR  ', 'SSYR2 ', 'SSPR2 '/
    DATA idim/0, 1, 2, 3, 5, 9/
    DATA kb/0, 1, 2, 4/
    DATA inc/1, 2, -1, -2/
    DATA alf/0.0, 1.0, 0.7/
    DATA bet/0.0, 1.0, 0.9/
    !***FIRST EXECUTABLE STATEMENT  SBLAT2
    !
    !     Set the flag that indicates whether error exits are to be tested.
    !
    tsterr = .TRUE.
    !
    !     Set the threshold value of the test ratio
    !
    thresh = 16.0
    !
    !     Initialize IPASS to 1 assuming everything will pass.
    !
    Ipass = 1
    !
    !     Report values of parameters.
    !
    IF ( Kprint>=3 ) THEN
      WRITE (Nout,FMT=99002)
      WRITE (Nout,FMT=99003) (idim(i),i=1,NIDIM)
      WRITE (Nout,FMT=99004) (kb(i),i=1,NKB)
      WRITE (Nout,FMT=99005) (inc(i),i=1,NINC)
      WRITE (Nout,FMT=99006) (alf(i),i=1,NALF)
      WRITE (Nout,FMT=99007) (bet(i),i=1,NBET)
      IF ( .NOT.tsterr ) WRITE (Nout,FMT=99010)
      WRITE (Nout,FMT=99001) thresh
    ENDIF
    !
    !     Set names of subroutines and flags which indicate
    !     whether they are to be tested.
    !
    DO i = 1, NSUBS
      ltest(i) = .TRUE.
    ENDDO
    !
    !     Set EPS (the machine precision).
    !
    eps = R1MACH(4)
    !
    !     Check the reliability of SMVCH using exact data.
    !
    n = MIN(32,NMAX)
    DO j = 1, n
      DO i = 1, n
        a(i,j) = MAX(i-j+1,0)
      ENDDO
      x(j) = j
      y(j) = ZERO
    ENDDO
    DO j = 1, n
      yy(j) = j*((j+1)*j)/2 - ((j+1)*j*(j-1))/3
    ENDDO
    !     YY holds the exact result. On exit from SMVCH YT holds
    !     the result computed by SMVCH.
    trans = 'N'
    ftl = .FALSE.
    CALL SMVCH(trans,n,n,ONE,a,NMAX,x,1,ZERO,y,1,yt,g,yy,eps,err,ftl,Nout,&
      .TRUE.,Kprint)
    same = LSE(yy,yt,n)
    IF ( .NOT.same.OR.err/=ZERO ) THEN
      Ipass = 0
      IF ( Kprint>=2 ) WRITE (Nout,FMT=99008) trans, same, err
    ENDIF
    trans = 'T'
    ftl = .FALSE.
    CALL SMVCH(trans,n,n,ONE,a,NMAX,x,-1,ZERO,y,-1,yt,g,yy,eps,err,ftl,Nout,&
      .TRUE.,Kprint)
    same = LSE(yy,yt,n)
    IF ( .NOT.same.OR.err/=ZERO ) THEN
      Ipass = 0
      IF ( Kprint>=2 ) WRITE (Nout,FMT=99008) trans, same, err
    ENDIF
    !
    !     Test each subroutine in turn.
    !
    DO isnum = 1, NSUBS
      IF ( .NOT.ltest(isnum) ) THEN
        !           Subprogram is not to be tested.
        WRITE (Nout,FMT=99009) snames(isnum)
      ELSE
        !           Test error exits.
        ftl1 = .FALSE.
        IF ( tsterr ) CALL SCHKE2(isnum,snames(isnum),Nout,Kprint,ftl1)
        !           Test computations.
        ftl2 = .FALSE.
        CALL XERCLR
        SELECT CASE (isnum)
          CASE (3,4,5)
            !           Test SSYMV, 03, SSBMV, 04, and SSPMV, 05.
            CALL SCHK22(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NKB,kb,NALF,alf,NBET,bet,NINC,inc,NMAX,INCMAX,a,aa,as,x,&
              xx,xs,y,yy,ys,yt,g)
          CASE (6,7,8,9,10,11)
            !           Test STRMV, 06, STBMV, 07, STPMV, 08,
            !           STRSV, 09, STBSV, 10, and STPSV, 11.
            CALL SCHK32(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NKB,kb,NINC,inc,NMAX,INCMAX,a,aa,as,y,yy,ys,yt,g,z)
          CASE (12)
            !           Test SGER, 12.
            CALL SCHK42(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NALF,alf,NINC,inc,NMAX,INCMAX,a,aa,as,x,xx,xs,y,yy,ys,&
              yt,g,z)
          CASE (13,14)
            !           Test SSYR, 13, and SSPR, 14.
            CALL SCHK52(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NALF,alf,NINC,inc,NMAX,INCMAX,a,aa,as,x,xx,xs,y,yy,ys,&
              yt,g,z)
          CASE (15,16)
            !           Test SSYR2, 15, and SSPR2, 16.
            CALL SCHK62(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NALF,alf,NINC,inc,NMAX,INCMAX,a,aa,as,x,xx,xs,y,yy,ys,&
              yt,g,z)
          CASE DEFAULT
            !           Test SGEMV, 01, and SGBMV, 02.
            CALL SCHK12(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NKB,kb,NALF,alf,NBET,bet,NINC,inc,NMAX,INCMAX,a,aa,as,x,&
              xx,xs,y,yy,ys,yt,g)
        END SELECT
        !
        IF ( ftl1.OR.ftl2 ) Ipass = 0
      ENDIF
    ENDDO
    RETURN
    !
    99001 FORMAT (' ROUTINES PASS COMPUTATIONAL TESTS IF TEST RATIO IS LES',&
      'S THAN',F8.2)
    99002 FORMAT (' TESTS OF THE REAL             LEVEL 2 BLAS',//' THE F',&
      'OLLOWING PARAMETER VALUES WILL BE USED:')
    99003 FORMAT ('   FOR N              ',9I6)
    99004 FORMAT ('   FOR K              ',7I6)
    99005 FORMAT ('   FOR INCX AND INCY  ',7I6)
    99006 FORMAT ('   FOR ALPHA          ',7F6.1)
    99007 FORMAT ('   FOR BETA           ',7F6.1)
    99008 FORMAT (' ERROR IN SMVCH -  IN-LINE DOT PRODUCTS ARE BEING EVALU',&
      'ATED WRONGLY.',/' SMVCH WAS CALLED WITH TRANS = ',A1,&
      ' AND RETURNED SAME = ',L1,' AND ERR = ',F12.3,'.',&
      /' THIS MAY BE DUE TO FAULTS IN THE ARITHMETIC OR THE',&
      ' COMPILER.')
    99009 FORMAT (1X,A6,' WAS NOT TESTED')
    99010 FORMAT (' ERROR-EXITS WILL NOT BE TESTED')
    !
    !     End of SBLAT2.
    !
  END SUBROUTINE SBLAT2
  !DECK SBLAT3
  SUBROUTINE SBLAT3(Nout,Kprint,Ipass)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SBLAT3
    !***PURPOSE  Driver for testing Level 3 BLAS single precision
    !            subroutines.
    !***LIBRARY   SLATEC (BLAS)
    !***CATEGORY  A3A
    !***TYPE      SINGLE PRECISION (SBLAT3-S, DBLAT3-D, CBLAT3-C)
    !***KEYWORDS  BLAS, QUICK CHECK DRIVER
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Test program for the REAL             Level 3 Blas.
    !
    !***REFERENCES  Dongarra, J., Du Croz, J., Duff, I., and Hammarling, S.
    !                 A set of level 3 basic linear algebra subprograms.
    !                 ACM TOMS, Vol. 16, No. 1, pp. 1-17, March 1990.
    !***ROUTINES CALLED  LSE, R1MACH, SCHK13, SCHK23, SCHK33, SCHK43,
    !                    SCHK53, SCHKE3, SMMCH, XERCLR
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !   930315  Removed unused variables.  (WRB)
    !   930618  Code modified to improve PASS/FAIL reporting.  (BKS, WRB)
    !   930701  Call to SCHKE5 changed to call to SCHKE3.  (BKS)
    !***END PROLOGUE  SBLAT3
    !     .. Parameters ..
    INTEGER NSUBS
    PARAMETER (NSUBS=6)
    REAL ZERO, ONE
    PARAMETER (ZERO=0.0,ONE=1.0)
    INTEGER NMAX, INCMAX
    PARAMETER (NMAX=65,INCMAX=2)
    !     .. Scalar Arguments ..
    INTEGER Ipass, Kprint
    !     .. Local Scalars ..
    REAL eps, err, thresh
    INTEGER i, isnum, j, n, NALF, NBET, NIDIM, Nout
    PARAMETER (NIDIM=6,NALF=3,NBET=3)
    LOGICAL same, tsterr, ftl, ftl1, ftl2
    CHARACTER :: transa, transb
    !     .. Local Arrays ..
    REAL ab(NMAX,2*NMAX), aa(NMAX*NMAX), alf(NALF), as(NMAX*NMAX) ,&
      bet(NBET), g(NMAX), bb(NMAX*NMAX), bs(NMAX*NMAX), c(NMAX,NMAX) ,&
      cc(NMAX*NMAX), cs(NMAX*NMAX), ct(NMAX), w(2*NMAX)
    INTEGER idim(NIDIM)
    LOGICAL ltest(NSUBS)
    CHARACTER(6) :: snames(NSUBS)
    !     .. External Functions ..
    REAL R1MACH
    EXTERNAL R1MACH
    !     .. Intrinsic Functions ..
    INTRINSIC MAX, MIN
    !     .. Data statements ..
    DATA snames/'SGEMM ', 'SSYMM ', 'STRMM ', 'STRSM ', 'SSYRK ' ,&
      'SSYR2K'/
    DATA idim/0, 1, 2, 3, 5, 9/
    DATA alf/0.0, 1.0, 0.7/
    DATA bet/0.0, 1.0, 1.3/
    !***FIRST EXECUTABLE STATEMENT  SBLAT3
    !
    !     Set the flag that indicates whether error exits are to be tested.
    !
    tsterr = .TRUE.
    !
    !     Set the threshold value of the test ratio
    !
    thresh = 16.0
    !
    !     Initialize IPASS to 1 assuming everything will pass.
    !
    Ipass = 1
    !
    !     Report values of parameters.
    !
    IF ( Kprint>=3 ) THEN
      WRITE (Nout,FMT=99002)
      WRITE (Nout,FMT=99003) (idim(i),i=1,NIDIM)
      WRITE (Nout,FMT=99004) (alf(i),i=1,NALF)
      WRITE (Nout,FMT=99005) (bet(i),i=1,NBET)
      IF ( .NOT.tsterr ) WRITE (Nout,FMT=99008)
      WRITE (Nout,FMT=99001) thresh
    ENDIF
    !
    !     Set names of subroutines and flags which indicate
    !     whether they are to be tested.
    !
    DO i = 1, NSUBS
      ltest(i) = .TRUE.
    ENDDO
    !
    !     Set EPS (the machine precision).
    !
    eps = R1MACH(4)
    !
    !     Check the reliability of SMMCH using exact data.
    !
    n = MIN(32,NMAX)
    DO j = 1, n
      DO i = 1, n
        ab(i,j) = MAX(i-j+1,0)
      ENDDO
      ab(j,NMAX+1) = j
      ab(1,NMAX+j) = j
      c(j,1) = ZERO
    ENDDO
    DO j = 1, n
      cc(j) = j*((j+1)*j)/2 - ((j+1)*j*(j-1))/3
    ENDDO
    !     CC holds the exact result. On exit from SMMCH CT holds
    !     the result computed by SMMCH.
    transa = 'N'
    transb = 'N'
    ftl = .FALSE.
    CALL SMMCH(transa,transb,n,1,n,ONE,ab,NMAX,ab(1,NMAX+1),NMAX,ZERO,c,NMAX,&
      ct,g,cc,NMAX,eps,err,ftl,Nout,.TRUE.,Kprint)
    same = LSE(cc,ct,n)
    IF ( .NOT.same.OR.err/=ZERO ) THEN
      Ipass = 0
      IF ( Kprint>=2 ) WRITE (Nout,FMT=99006) transa, transb, same, err
    ENDIF
    transb = 'T'
    ftl = .FALSE.
    CALL SMMCH(transa,transb,n,1,n,ONE,ab,NMAX,ab(1,NMAX+1),NMAX,ZERO,c,NMAX,&
      ct,g,cc,NMAX,eps,err,ftl,Nout,.TRUE.,Kprint)
    same = LSE(cc,ct,n)
    IF ( .NOT.same.OR.err/=ZERO ) THEN
      Ipass = 0
      IF ( Kprint>=2 ) WRITE (Nout,FMT=99006) transa, transb, same, err
    ENDIF
    DO j = 1, n
      ab(j,NMAX+1) = n - j + 1
      ab(1,NMAX+j) = n - j + 1
    ENDDO
    DO j = 1, n
      cc(n-j+1) = j*((j+1)*j)/2 - ((j+1)*j*(j-1))/3
    ENDDO
    transa = 'T'
    transb = 'N'
    ftl = .FALSE.
    CALL SMMCH(transa,transb,n,1,n,ONE,ab,NMAX,ab(1,NMAX+1),NMAX,ZERO,c,NMAX,&
      ct,g,cc,NMAX,eps,err,ftl,Nout,.TRUE.,Kprint)
    same = LSE(cc,ct,n)
    IF ( .NOT.same.OR.err/=ZERO ) THEN
      Ipass = 0
      IF ( Kprint>=2 ) WRITE (Nout,FMT=99006) transa, transb, same, err
    ENDIF
    transb = 'T'
    ftl = .FALSE.
    CALL SMMCH(transa,transb,n,1,n,ONE,ab,NMAX,ab(1,NMAX+1),NMAX,ZERO,c,NMAX,&
      ct,g,cc,NMAX,eps,err,ftl,Nout,.TRUE.,Kprint)
    same = LSE(cc,ct,n)
    IF ( .NOT.same.OR.err/=ZERO ) THEN
      Ipass = 0
      IF ( Kprint>=2 ) WRITE (Nout,FMT=99006) transa, transb, same, err
    ENDIF
    !
    !     Test each subroutine in turn.
    !
    DO isnum = 1, NSUBS
      IF ( .NOT.ltest(isnum) ) THEN
        !           Subprogram is not to be tested.
        WRITE (Nout,FMT=99007) snames(isnum)
      ELSE
        !           Test error exits.
        ftl1 = .FALSE.
        IF ( tsterr ) CALL SCHKE3(isnum,snames(isnum),Nout,Kprint,ftl1)
        !           Test computations.
        ftl2 = .FALSE.
        CALL XERCLR
        SELECT CASE (isnum)
          CASE (2)
            !           Test SSYMM, 02.
            CALL SCHK23(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NALF,alf,NBET,bet,NMAX,ab,aa,as,ab(1,NMAX+1),bb,bs,c,cc,&
              cs,ct,g)
          CASE (3,4)
            !           Test STRMM, 03, STRSM, 04.
            CALL SCHK33(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NALF,alf,NMAX,ab,aa,as,ab(1,NMAX+1),bb,bs,ct,g,c)
          CASE (5)
            !           Test SSYRK, 05.
            CALL SCHK43(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NALF,alf,NBET,bet,NMAX,ab,aa,as,ab(1,NMAX+1),bb,bs,c,cc,&
              cs,ct,g)
          CASE (6)
            !           Test SSYR2K, 06.
            CALL SCHK53(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NALF,alf,NBET,bet,NMAX,ab,aa,as,bb,bs,c,cc,cs,ct,g,w)
          CASE DEFAULT
            !           Test SGEMM, 01.
            CALL SCHK13(snames(isnum),eps,thresh,Nout,Kprint,ftl2,NIDIM,idim,&
              NALF,alf,NBET,bet,NMAX,ab,aa,as,ab(1,NMAX+1),bb,bs,c,cc,&
              cs,ct,g)
        END SELECT
        IF ( ftl1.OR.ftl2 ) Ipass = 0
      ENDIF
    ENDDO
    RETURN
    !
    99001 FORMAT (' ROUTINES PASS COMPUTATIONAL TESTS IF TEST RATIO IS LES',&
      'S THAN',F8.2)
    99002 FORMAT (' TESTS OF THE REAL             LEVEL 3 BLAS',//' THE F',&
      'OLLOWING PARAMETER VALUES WILL BE USED:')
    99003 FORMAT ('   FOR N              ',9I6)
    99004 FORMAT ('   FOR ALPHA          ',7F6.1)
    99005 FORMAT ('   FOR BETA           ',7F6.1)
    99006 FORMAT (' ERROR IN SMMCH -  IN-LINE DOT PRODUCTS ARE BEING EVALU',&
      'ATED WRONGLY.',/' SMMCH WAS CALLED WITH TRANSA = ',A1,&
      ' AND TRANSB = ',A1,' AND RETURNED SAME = ',L1,' AND ERR = ',&
      F12.3,'.',/' THIS MAY BE DUE TO FAULTS IN THE ARITHMETIC OR THE',&
      ' COMPILER.')
    99007 FORMAT (1X,A6,' WAS NOT TESTED')
    99008 FORMAT (' ERROR-EXITS WILL NOT BE TESTED')
    !
    !     End of SBLAT3.
    !
  END SUBROUTINE SBLAT3
  !DECK SMAKE2
  SUBROUTINE SMAKE2(Type,Uplo,Diag,M,N,A,Nmax,Aa,Lda,Kl,Ku,Reset,Transl)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SMAKE2
    !***SUBSIDIARY
    !***PURPOSE  Generate values for an M by N matrix A.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Du Croz, J. J., (NAG)
    !           Hanson, R. J., (SNLA)
    !***DESCRIPTION
    !
    !  Generates values for an M by N matrix A within the bandwidth
    !  defined by KL and KU.
    !  Stores the values in the array AA in the data structure required
    !  by the routine, with unwanted elements set to rogue value.
    !
    !  TYPE is 'GE', 'GB', 'SY', 'SB', 'SP', 'TR', 'TB' OR 'TP'.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  SBEG
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910620  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SMAKE2
    !     .. Parameters ..
    REAL ZERO, ONE
    PARAMETER (ZERO=0.0,ONE=1.0)
    REAL ROGUE
    PARAMETER (ROGUE=-1.0E10)
    !     .. Scalar Arguments ..
    REAL Transl
    INTEGER Kl, Ku, Lda, M, N, Nmax
    LOGICAL Reset
    CHARACTER :: Diag, Uplo
    CHARACTER(2) :: Type
    !     .. Array Arguments ..
    REAL A(Nmax,*), Aa(*)
    !     .. Local Scalars ..
    INTEGER i, i1, i2, i3, ibeg, iend, ioff, j, kk
    LOGICAL gen, lower, sym, tri, unit, upper
    !     .. Intrinsic Functions ..
    INTRINSIC MAX, MIN
    !***FIRST EXECUTABLE STATEMENT  SMAKE2
    gen = Type(1:1)=='G'
    sym = Type(1:1)=='S'
    tri = Type(1:1)=='T'
    upper = (sym.OR.tri) .AND. Uplo=='U'
    lower = (sym.OR.tri) .AND. Uplo=='L'
    unit = tri .AND. Diag=='U'
    !
    !     Generate data in array A.
    !
    DO j = 1, N
      DO i = 1, M
        IF ( gen.OR.(upper.AND.i<=j).OR.(lower.AND.i>=j) ) THEN
          IF ( (i<=j.AND.j-i<=Ku).OR.(i>=j.AND.i-j<=Kl) ) THEN
            A(i,j) = SBEG(Reset) + Transl
          ELSE
            A(i,j) = ZERO
          ENDIF
          IF ( i/=j ) THEN
            IF ( sym ) THEN
              A(j,i) = A(i,j)
            ELSEIF ( tri ) THEN
              A(j,i) = ZERO
            ENDIF
          ENDIF
        ENDIF
      ENDDO
      IF ( tri ) A(j,j) = A(j,j) + ONE
      IF ( unit ) A(j,j) = ONE
    ENDDO
    !
    !     Store elements in array AS in data structure required by routine.
    !
    IF ( Type=='GE' ) THEN
      DO j = 1, N
        DO i = 1, M
          Aa(i+(j-1)*Lda) = A(i,j)
        ENDDO
        DO i = M + 1, Lda
          Aa(i+(j-1)*Lda) = ROGUE
        ENDDO
      ENDDO
    ELSEIF ( Type=='GB' ) THEN
      DO j = 1, N
        DO i1 = 1, Ku + 1 - j
          Aa(i1+(j-1)*Lda) = ROGUE
        ENDDO
        DO i2 = i1, MIN(Kl+Ku+1,Ku+1+M-j)
          Aa(i2+(j-1)*Lda) = A(i2+j-Ku-1,j)
        ENDDO
        DO i3 = i2, Lda
          Aa(i3+(j-1)*Lda) = ROGUE
        ENDDO
      ENDDO
    ELSEIF ( Type=='SY'.OR.Type=='TR' ) THEN
      DO j = 1, N
        IF ( upper ) THEN
          ibeg = 1
          IF ( unit ) THEN
            iend = j - 1
          ELSE
            iend = j
          ENDIF
        ELSE
          IF ( unit ) THEN
            ibeg = j + 1
          ELSE
            ibeg = j
          ENDIF
          iend = N
        ENDIF
        DO i = 1, ibeg - 1
          Aa(i+(j-1)*Lda) = ROGUE
        ENDDO
        DO i = ibeg, iend
          Aa(i+(j-1)*Lda) = A(i,j)
        ENDDO
        DO i = iend + 1, Lda
          Aa(i+(j-1)*Lda) = ROGUE
        ENDDO
      ENDDO
    ELSEIF ( Type=='SB'.OR.Type=='TB' ) THEN
      DO j = 1, N
        IF ( upper ) THEN
          kk = Kl + 1
          ibeg = MAX(1,Kl+2-j)
          IF ( unit ) THEN
            iend = Kl
          ELSE
            iend = Kl + 1
          ENDIF
        ELSE
          kk = 1
          IF ( unit ) THEN
            ibeg = 2
          ELSE
            ibeg = 1
          ENDIF
          iend = MIN(Kl+1,1+M-j)
        ENDIF
        DO i = 1, ibeg - 1
          Aa(i+(j-1)*Lda) = ROGUE
        ENDDO
        DO i = ibeg, iend
          Aa(i+(j-1)*Lda) = A(i+j-kk,j)
        ENDDO
        DO i = iend + 1, Lda
          Aa(i+(j-1)*Lda) = ROGUE
        ENDDO
      ENDDO
    ELSEIF ( Type=='SP'.OR.Type=='TP' ) THEN
      ioff = 0
      DO j = 1, N
        IF ( upper ) THEN
          ibeg = 1
          iend = j
        ELSE
          ibeg = j
          iend = N
        ENDIF
        DO i = ibeg, iend
          ioff = ioff + 1
          Aa(ioff) = A(i,j)
          IF ( i==j ) THEN
            IF ( unit ) Aa(ioff) = ROGUE
          ENDIF
        ENDDO
      ENDDO
    ENDIF
    !
    !     End of SMAKE2.
    !
  END SUBROUTINE SMAKE2
  !DECK SMAKE3
  SUBROUTINE SMAKE3(Type,Uplo,Diag,M,N,A,Nmax,Aa,Lda,Reset,Transl)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SMAKE3
    !***SUBSIDIARY
    !***PURPOSE  Generate values for an M by N matrix A.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Generates values for an M by N matrix A within the bandwidth
    !  defined by KL and KU.
    !  Stores the values in the array AA in the data structure required
    !  by the routine, with unwanted elements set to rogue value.
    !
    !  TYPE is 'GE', 'SY' or  'TR'.
    !
    !  Auxiliary routine for test program for Level 3 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  SBEG
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910620  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SMAKE3
    !     .. Parameters ..
    REAL ZERO, ONE
    PARAMETER (ZERO=0.0,ONE=1.0)
    REAL ROGUE
    PARAMETER (ROGUE=-1.0E10)
    !     .. Scalar Arguments ..
    REAL Transl
    INTEGER Lda, M, N, Nmax
    LOGICAL Reset
    CHARACTER :: Diag, Uplo
    CHARACTER(2) :: Type
    !     .. Array Arguments ..
    REAL A(Nmax,*), Aa(*)
    !     .. Local Scalars ..
    INTEGER i, ibeg, iend, j
    LOGICAL gen, lower, sym, tri, unit, upper
    !***FIRST EXECUTABLE STATEMENT  SMAKE3
    gen = Type=='GE'
    sym = Type=='SY'
    tri = Type=='TR'
    upper = (sym.OR.tri) .AND. Uplo=='U'
    lower = (sym.OR.tri) .AND. Uplo=='L'
    unit = tri .AND. Diag=='U'
    !
    !     Generate data in array A.
    !
    DO j = 1, N
      DO i = 1, M
        IF ( gen.OR.(upper.AND.i<=j).OR.(lower.AND.i>=j) ) THEN
          A(i,j) = SBEG(Reset) + Transl
          IF ( i/=j ) THEN
            !                 Set some elements to zero
            IF ( N>3.AND.j==N/2 ) A(i,j) = ZERO
            IF ( sym ) THEN
              A(j,i) = A(i,j)
            ELSEIF ( tri ) THEN
              A(j,i) = ZERO
            ENDIF
          ENDIF
        ENDIF
      ENDDO
      IF ( tri ) A(j,j) = A(j,j) + ONE
      IF ( unit ) A(j,j) = ONE
    ENDDO
    !
    !     Store elements in array AS in data structure required by routine.
    !
    IF ( Type=='GE' ) THEN
      DO j = 1, N
        DO i = 1, M
          Aa(i+(j-1)*Lda) = A(i,j)
        ENDDO
        DO i = M + 1, Lda
          Aa(i+(j-1)*Lda) = ROGUE
        ENDDO
      ENDDO
    ELSEIF ( Type=='SY'.OR.Type=='TR' ) THEN
      DO j = 1, N
        IF ( upper ) THEN
          ibeg = 1
          IF ( unit ) THEN
            iend = j - 1
          ELSE
            iend = j
          ENDIF
        ELSE
          IF ( unit ) THEN
            ibeg = j + 1
          ELSE
            ibeg = j
          ENDIF
          iend = N
        ENDIF
        DO i = 1, ibeg - 1
          Aa(i+(j-1)*Lda) = ROGUE
        ENDDO
        DO i = ibeg, iend
          Aa(i+(j-1)*Lda) = A(i,j)
        ENDDO
        DO i = iend + 1, Lda
          Aa(i+(j-1)*Lda) = ROGUE
        ENDDO
      ENDDO
    ENDIF
    !
    !     End of SMAKE3.
    !
  END SUBROUTINE SMAKE3
  !DECK SMMCH
  SUBROUTINE SMMCH(Transa,Transb,M,N,Kk,Alpha,A,Lda,B,Ldb,Beta,C,Ldc,Ct,G,&
      Cc,Ldcc,Eps,Err,Ftl,Nout,Mv,Kprint)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SMMCH
    !***SUBSIDIARY
    !***PURPOSE  Check the results of the computational tests.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Checks the results of the computational tests.
    !
    !  Auxiliary routine for test program for Level 3 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  (NONE)
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910620  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SMMCH
    !     .. Parameters ..
    REAL ZERO, ONE
    PARAMETER (ZERO=0.0,ONE=1.0)
    !     .. Scalar Arguments ..
    REAL Alpha, Beta, Eps, Err
    INTEGER Kk, Kprint, Lda, Ldb, Ldc, Ldcc, M, N, Nout
    LOGICAL Mv, Ftl
    CHARACTER :: Transa, Transb
    !     .. Array Arguments ..
    REAL A(Lda,*), B(Ldb,*), C(Ldc,*), Cc(Ldcc,*), Ct(*), G(*)
    !     .. Local Scalars ..
    REAL erri
    INTEGER i, j, k
    LOGICAL trana, tranb
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX, SQRT
    !***FIRST EXECUTABLE STATEMENT  SMMCH
    trana = Transa=='T' .OR. Transa=='C'
    tranb = Transb=='T' .OR. Transb=='C'
    !
    !     Compute expected result, one column at a time, in CT using data
    !     in A, B and C.
    !     Compute gauges in G.
    !
    DO j = 1, N
      !
      DO i = 1, M
        Ct(i) = ZERO
        G(i) = ZERO
      ENDDO
      IF ( .NOT.trana.AND..NOT.tranb ) THEN
        DO k = 1, Kk
          DO i = 1, M
            Ct(i) = Ct(i) + A(i,k)*B(k,j)
            G(i) = G(i) + ABS(A(i,k))*ABS(B(k,j))
          ENDDO
        ENDDO
      ELSEIF ( trana.AND..NOT.tranb ) THEN
        DO k = 1, Kk
          DO i = 1, M
            Ct(i) = Ct(i) + A(k,i)*B(k,j)
            G(i) = G(i) + ABS(A(k,i))*ABS(B(k,j))
          ENDDO
        ENDDO
      ELSEIF ( .NOT.trana.AND.tranb ) THEN
        DO k = 1, Kk
          DO i = 1, M
            Ct(i) = Ct(i) + A(i,k)*B(j,k)
            G(i) = G(i) + ABS(A(i,k))*ABS(B(j,k))
          ENDDO
        ENDDO
      ELSEIF ( trana.AND.tranb ) THEN
        DO k = 1, Kk
          DO i = 1, M
            Ct(i) = Ct(i) + A(k,i)*B(j,k)
            G(i) = G(i) + ABS(A(k,i))*ABS(B(j,k))
          ENDDO
        ENDDO
      ENDIF
      DO i = 1, M
        Ct(i) = Alpha*Ct(i) + Beta*C(i,j)
        G(i) = ABS(Alpha)*G(i) + ABS(Beta)*ABS(C(i,j))
      ENDDO
      !
      !        Compute the error ratio for this result.
      !
      Err = ZERO
      DO i = 1, M
        erri = ABS(Ct(i)-Cc(i,j))/Eps
        IF ( G(i)/=ZERO ) erri = erri/G(i)
        Err = MAX(Err,erri)
        IF ( Err*SQRT(Eps)>=ONE ) THEN
          Ftl = .TRUE.
          IF ( Kprint>=2 ) THEN
            WRITE (Nout,FMT=99001)
            DO k = 1, M
              IF ( Mv ) THEN
                WRITE (Nout,FMT=99002) k, Ct(k), Cc(k,j)
              ELSE
                WRITE (Nout,FMT=99002) k, Cc(k,j), Ct(k)
              ENDIF
            ENDDO
          ENDIF
        ENDIF
      ENDDO
    ENDDO
    RETURN
    !
    99001 FORMAT (' ******* FATAL ERROR - COMPUTED RESULT IS LESS THAN HAL',&
      'F ACCURATE *******',/'           EXPECTED RESULT   COMPU',&
      'TED RESULT')
    99002 FORMAT (1X,I7,2G18.6)
    !
    !     End of SMMCH.
    !
  END SUBROUTINE SMMCH
  !DECK SMVCH
  SUBROUTINE SMVCH(Trans,M,N,Alpha,A,Nmax,X,Incx,Beta,Y,Incy,Yt,G,Yy,Eps,&
      Err,Ftl,Nout,Mv,Kprint)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SMVCH
    !***SUBSIDIARY
    !***PURPOSE  Check the results of the computational tests.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Du Croz, J. J., (NAG)
    !           Hanson, R. J., (SNLA)
    !***DESCRIPTION
    !
    !  Checks the results of the computational tests.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  (NONE)
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910620  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SMVCH
    !     .. Parameters ..
    REAL ZERO, ONE
    PARAMETER (ZERO=0.0,ONE=1.0)
    !     .. Scalar Arguments ..
    REAL Alpha, Beta, Eps, Err
    INTEGER Incx, Incy, Kprint, M, N, Nmax, Nout
    LOGICAL Mv, Ftl
    CHARACTER :: Trans
    !     .. Array Arguments ..
    REAL A(Nmax,*), G(*), X(*), Y(*), Yt(*), Yy(*)
    !     .. Local Scalars ..
    REAL erri
    INTEGER i, incxl, incyl, iy, j, jx, k, kx, ky, ml, nl
    LOGICAL tran
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX, SQRT
    !***FIRST EXECUTABLE STATEMENT  SMVCH
    tran = Trans=='T' .OR. Trans=='C'
    IF ( tran ) THEN
      ml = N
      nl = M
    ELSE
      ml = M
      nl = N
    ENDIF
    IF ( Incx<0 ) THEN
      kx = nl
      incxl = -1
    ELSE
      kx = 1
      incxl = 1
    ENDIF
    IF ( Incy<0 ) THEN
      ky = ml
      incyl = -1
    ELSE
      ky = 1
      incyl = 1
    ENDIF
    !
    !     Compute expected result in YT using data in A, X and Y.
    !     Compute gauges in G.
    !
    iy = ky
    DO i = 1, ml
      Yt(iy) = ZERO
      G(iy) = ZERO
      jx = kx
      IF ( tran ) THEN
        DO j = 1, nl
          Yt(iy) = Yt(iy) + A(j,i)*X(jx)
          G(iy) = G(iy) + ABS(A(j,i)*X(jx))
          jx = jx + incxl
        ENDDO
      ELSE
        DO j = 1, nl
          Yt(iy) = Yt(iy) + A(i,j)*X(jx)
          G(iy) = G(iy) + ABS(A(i,j)*X(jx))
          jx = jx + incxl
        ENDDO
      ENDIF
      Yt(iy) = Alpha*Yt(iy) + Beta*Y(iy)
      G(iy) = ABS(Alpha)*G(iy) + ABS(Beta*Y(iy))
      iy = iy + incyl
    ENDDO
    !
    !     Compute the error ratio for this result.
    !
    Err = ZERO
    DO i = 1, ml
      erri = ABS(Yt(i)-Yy(1+(i-1)*ABS(Incy)))/Eps
      IF ( G(i)/=ZERO ) erri = erri/G(i)
      Err = MAX(Err,erri)
      IF ( Err*SQRT(Eps)>=ONE ) THEN
        Ftl = .TRUE.
        IF ( Kprint>=2 ) THEN
          WRITE (Nout,FMT=99001)
          DO k = 1, ml
            IF ( Mv ) THEN
              WRITE (Nout,FMT=99002) k, Yt(k), Yy(1+(k-1)*ABS(Incy))
            ELSE
              WRITE (Nout,FMT=99002) k, Yy(1+(k-1)*ABS(Incy)), Yt(k)
            ENDIF
          ENDDO
        ENDIF
      ENDIF
    ENDDO
    RETURN
    !
    99001 FORMAT (' ******* FATAL ERROR - COMPUTED RESULT IS LESS THAN HAL',&
      'F ACCURATE *******',/'           EXPECTED RESULT   COMPU',&
      'TED RESULT')
    99002 FORMAT (1X,I7,2G18.6)
    !
    !     End of SMVCH.
    !
  END SUBROUTINE SMVCH
  !DECK LSE
  LOGICAL FUNCTION LSE(Ri,Rj,Lr)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  LSE
    !***SUBSIDIARY
    !***PURPOSE  Test if two arrays are identical.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Du Croz, J. J., (NAG)
    !           Hanson, R. J., (SNLA)
    !***DESCRIPTION
    !
    !  Tests if two arrays are identical.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  (NONE)
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910620  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  LSE
    !     .. Scalar Arguments ..
    INTEGER Lr
    !     .. Array Arguments ..
    REAL Ri(*), Rj(*)
    !     .. Local Scalars ..
    INTEGER i
    !***FIRST EXECUTABLE STATEMENT  LSE
    LSE = .TRUE.
    DO i = 1, Lr
      IF ( Ri(i)/=Rj(i) ) THEN
        LSE = .FALSE.
        EXIT
      ENDIF
    ENDDO
    !
    !     End of LSE.
    !
  END FUNCTION LSE
  !DECK LSERES
  LOGICAL FUNCTION LSERES(Type,Uplo,M,N,Aa,As,Lda)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  LSERES
    !***SUBSIDIARY
    !***PURPOSE  Test if selected elements in two arrays are equal.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Du Croz, J. J., (NAG)
    !           Hanson, R. J., (SNLA)
    !***DESCRIPTION
    !
    !  Tests if selected elements in two arrays are equal.
    !
    !  TYPE is 'GE', 'SY' or 'SP'.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  (NONE)
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910620  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  LSERES
    !     .. Scalar Arguments ..
    INTEGER Lda, M, N
    CHARACTER :: Uplo
    CHARACTER(2) :: Type
    !     .. Array Arguments ..
    REAL Aa(Lda,*), As(Lda,*)
    !     .. Local Scalars ..
    INTEGER i, ibeg, iend, j
    LOGICAL upper
    !***FIRST EXECUTABLE STATEMENT  LSERES
    upper = Uplo=='U'
    IF ( Type=='GE' ) THEN
      DO j = 1, N
        DO i = M + 1, Lda
          IF ( Aa(i,j)/=As(i,j) ) GOTO 100
        ENDDO
      ENDDO
    ELSEIF ( Type=='SY' ) THEN
      DO j = 1, N
        IF ( upper ) THEN
          ibeg = 1
          iend = j
        ELSE
          ibeg = j
          iend = N
        ENDIF
        DO i = 1, ibeg - 1
          IF ( Aa(i,j)/=As(i,j) ) GOTO 100
        ENDDO
        DO i = iend + 1, Lda
          IF ( Aa(i,j)/=As(i,j) ) GOTO 100
        ENDDO
      ENDDO
    ENDIF
    !
    LSERES = .TRUE.
    RETURN
    100  LSERES = .FALSE.
    !
    !     End of LSERES.
    !
    RETURN
  END FUNCTION LSERES
  !DECK SCHK12
  SUBROUTINE SCHK12(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nkb,Kb,&
      Nalf,Alf,Nbet,Bet,Ninc,Inc,Nmax,Incmax,A,Aa,As,X,Xx,Xs,&
      Y,Yy,Ys,Yt,G)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK12
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SGEMV and SGBMV.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Du Croz, J. (NAG)
    !           Hanson, R. J. (SNLA)
    !***DESCRIPTION
    !
    !  Quick check for SGEMV and SGBMV.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SGBMV, SGEMV, SMAKE2, SMVCH
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK12
    !     .. Parameters ..
    REAL ZERO, HALF
    PARAMETER (ZERO=0.0,HALF=0.5)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Incmax, Kprint, Nalf, Nbet, Nidim, Ninc, Nkb, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), Bet(Nbet)&
      , G(Nmax), X(Nmax), Xs(Nmax*Incmax), Xx(Nmax*Incmax), Y(Nmax) ,&
      Ys(Nmax*Incmax), Yt(Nmax), Yy(Nmax*Incmax)
    INTEGER Idim(Nidim), Inc(Ninc), Kb(Nkb)
    !     .. Local Scalars ..
    REAL alpha, als, beta, bls, err, errmax, transl
    INTEGER i, ia, ib, ic, iku, im, in, incx, incxs, incy, incys ,&
      ix, iy, kl, kls, ku, kus, laa, lda, ldas, lx, ly, m ,&
      ml, ms, n, nargs, nc, nd, nk, nl, ns, nerr
    LOGICAL banded, ftl, full, null, reset, tran
    CHARACTER :: trans, transs
    CHARACTER(3) :: ich
    !     .. Local Arrays ..
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SGBMV, SGEMV
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX, MIN
    !     .. Data statements ..
    DATA ich/'NTC'/
    !***FIRST EXECUTABLE STATEMENT  SCHK12
    full = Sname(3:3)=='E'
    banded = Sname(3:3)=='B'
    !     Define the number of arguments.
    IF ( full ) THEN
      nargs = 11
    ELSEIF ( banded ) THEN
      nargs = 13
    ENDIF
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    DO in = 1, Nidim
      n = Idim(in)
      nd = n/2 + 1
      !
      DO im = 1, 2
        IF ( im==1 ) m = MAX(n-nd,0)
        IF ( im==2 ) m = MIN(n+nd,Nmax)
        !
        IF ( banded ) THEN
          nk = Nkb
        ELSE
          nk = 1
        ENDIF
        DO iku = 1, nk
          IF ( banded ) THEN
            ku = Kb(iku)
            kl = MAX(ku-1,0)
          ELSE
            ku = n - 1
            kl = m - 1
          ENDIF
          !              Set LDA to 1 more than minimum value if room.
          IF ( banded ) THEN
            lda = kl + ku + 1
          ELSE
            lda = m
          ENDIF
          IF ( lda<Nmax ) lda = lda + 1
          !              Skip tests if not enough room.
          IF ( lda<=Nmax ) THEN
            laa = lda*n
            null = n<=0 .OR. m<=0
            !
            !              Generate the matrix A.
            !
            transl = ZERO
            CALL SMAKE2(Sname(2:3),' ',' ',m,n,A,Nmax,Aa,lda,kl,ku,reset,&
              transl)
            !
            DO ic = 1, 3
              trans = ich(ic:ic)
              tran = trans=='T' .OR. trans=='C'
              !
              IF ( tran ) THEN
                ml = n
                nl = m
              ELSE
                ml = m
                nl = n
              ENDIF
              !
              DO ix = 1, Ninc
                incx = Inc(ix)
                lx = ABS(incx)*nl
                !
                !                    Generate the vector X.
                !
                transl = HALF
                CALL SMAKE2('GE',' ',' ',1,nl,X,1,Xx,ABS(incx),0,nl-1,reset,&
                  transl)
                IF ( nl>1 ) THEN
                  X(nl/2) = ZERO
                  Xx(1+ABS(incx)*(nl/2-1)) = ZERO
                ENDIF
                !
                DO iy = 1, Ninc
                  incy = Inc(iy)
                  ly = ABS(incy)*ml
                  !
                  DO ia = 1, Nalf
                    alpha = Alf(ia)
                    !
                    DO ib = 1, Nbet
                      beta = Bet(ib)
                      !
                      !                             Generate the vector Y.
                      !
                      transl = ZERO
                      CALL SMAKE2('GE',' ',' ',1,ml,Y,1,Yy,ABS(incy),0,ml-1,&
                        reset,transl)
                      !
                      nc = nc + 1
                      !
                      !                             Save every datum before calling the
                      !                             subroutine.
                      !
                      transs = trans
                      ms = m
                      ns = n
                      kls = kl
                      kus = ku
                      als = alpha
                      DO i = 1, laa
                        As(i) = Aa(i)
                      ENDDO
                      ldas = lda
                      DO i = 1, lx
                        Xs(i) = Xx(i)
                      ENDDO
                      incxs = incx
                      bls = beta
                      DO i = 1, ly
                        Ys(i) = Yy(i)
                      ENDDO
                      incys = incy
                      !
                      !                             Call the subroutine.
                      !
                      IF ( full ) THEN
                        CALL SGEMV(trans,m,n,alpha,Aa,lda,Xx,incx,beta,Yy,&
                          incy)
                      ELSEIF ( banded ) THEN
                        CALL SGBMV(trans,m,n,kl,ku,alpha,Aa,lda,Xx,incx,beta,&
                          Yy,incy)
                      ENDIF
                      !
                      !                             Check if error-exit was taken incorrectly.
                      !
                      IF ( NUMXER(nerr)/=0 ) THEN
                        IF ( Kprint>=2 ) WRITE (Nout,FMT=99007)
                        Fatal = .TRUE.
                      ENDIF
                      !
                      !                             See what data changed inside subroutines.
                      !
                      isame(1) = trans==transs
                      isame(2) = ms==m
                      isame(3) = ns==n
                      IF ( full ) THEN
                        isame(4) = als==alpha
                        isame(5) = LSE(As,Aa,laa)
                        isame(6) = ldas==lda
                        isame(7) = LSE(Xs,Xx,lx)
                        isame(8) = incxs==incx
                        isame(9) = bls==beta
                        IF ( null ) THEN
                          isame(10) = LSE(Ys,Yy,ly)
                        ELSE
                          isame(10) = LSERES('GE',' ',1,ml,Ys,Yy,ABS(incy))
                        ENDIF
                        isame(11) = incys==incy
                      ELSEIF ( banded ) THEN
                        isame(4) = kls==kl
                        isame(5) = kus==ku
                        isame(6) = als==alpha
                        isame(7) = LSE(As,Aa,laa)
                        isame(8) = ldas==lda
                        isame(9) = LSE(Xs,Xx,lx)
                        isame(10) = incxs==incx
                        isame(11) = bls==beta
                        IF ( null ) THEN
                          isame(12) = LSE(Ys,Yy,ly)
                        ELSE
                          isame(12) = LSERES('GE',' ',1,ml,Ys,Yy,ABS(incy))
                        ENDIF
                        isame(13) = incys==incy
                      ENDIF
                      !
                      !                             If data was incorrectly changed, report
                      !                             and return.
                      !
                      DO i = 1, nargs
                        IF ( .NOT.isame(i) ) THEN
                          Fatal = .TRUE.
                          IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                        ENDIF
                      ENDDO
                      !
                      ftl = .FALSE.
                      IF ( .NOT.null ) THEN
                        !
                        !                                Check the result.
                        !
                        CALL SMVCH(trans,m,n,alpha,A,Nmax,X,incx,beta,Y,incy,&
                          Yt,G,Yy,Eps,err,ftl,Nout,.TRUE.,Kprint)
                        errmax = MAX(errmax,err)
                      ENDIF
                      IF ( ftl ) THEN
                        Fatal = .TRUE.
                        IF ( Kprint>=3 ) THEN
                          WRITE (Nout,FMT=99004) Sname
                          IF ( full ) THEN
                            WRITE (Nout,FMT=99006) nc, Sname, trans, m ,&
                              n, alpha, lda, incx, beta, incy
                          ELSEIF ( banded ) THEN
                            WRITE (Nout,FMT=99005) nc, Sname, trans, m ,&
                              n, kl, ku, alpha, lda, incx, beta ,&
                              incy
                          ENDIF
                        ENDIF
                      ENDIF
                      !
                    ENDDO
                    !
                  ENDDO
                  !
                ENDDO
                !
              ENDDO
              !
            ENDDO
          ENDIF
          !
        ENDDO
        !
      ENDDO
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT (1X,I6,': ',A6,'(''',A1,''',',4(I3,','),F4.1,', A,',I3,', X,',I2,&
      ',',F4.1,', Y,',I2,') .')
    99006 FORMAT (1X,I6,': ',A6,'(''',A1,''',',2(I3,','),F4.1,', A,',I3,', X,',I2,&
      ',',F4.1,', Y,',I2,')         .')
    99007 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK12.
    !
  END SUBROUTINE SCHK12
  !DECK SCHK13
  SUBROUTINE SCHK13(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nalf,Alf,&
      Nbet,Bet,Nmax,A,Aa,As,B,Bb,Bs,C,Cc,Cs,Ct,G)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK13
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SGEMM.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Quick check for SGEMM.
    !
    !  Auxiliary routine for test program for Level 3 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SGEMM, SMAKE3, SMMCH
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK13
    !     .. Parameters ..
    REAL ZERO
    PARAMETER (ZERO=0.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Kprint, Nalf, Nbet, Nidim, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), Bet(Nbet)&
      , G(Nmax), B(Nmax,Nmax), Bb(Nmax*Nmax), Bs(Nmax*Nmax) ,&
      C(Nmax,Nmax), Cc(Nmax*Nmax), Cs(Nmax*Nmax), Ct(Nmax)
    INTEGER Idim(Nidim)
    !     .. Local Scalars ..
    REAL alpha, als, beta, bls, err, errmax
    INTEGER i, ia, ib, ica, icb, ik, im, in, k, ks, laa, lbb ,&
      lcc, lda, ldas, ldb, ldbs, ldc, ldcs, m, ma, mb, ms ,&
      n, na, nargs, nb, nc, nerr, ns
    LOGICAL ftl, null, reset, trana, tranb
    CHARACTER :: tranas, tranbs, transa, transb
    CHARACTER(3) :: ich
    !     .. Local Arrays ..
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SGEMM
    !     .. Intrinsic Functions ..
    INTRINSIC MAX
    !     .. Data statements ..
    DATA ich/'NTC'/
    !***FIRST EXECUTABLE STATEMENT  SCHK13
    nargs = 13
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    !
    DO im = 1, Nidim
      m = Idim(im)
      !
      DO in = 1, Nidim
        n = Idim(in)
        !           Set LDC to 1 more than minimum value if room.
        ldc = m
        IF ( ldc<Nmax ) ldc = ldc + 1
        !           Skip tests if not enough room.
        IF ( ldc<=Nmax ) THEN
          lcc = ldc*n
          null = n<=0 .OR. m<=0
          !
          DO ik = 1, Nidim
            k = Idim(ik)
            !
            DO ica = 1, 3
              transa = ich(ica:ica)
              trana = transa=='T' .OR. transa=='C'
              !
              IF ( trana ) THEN
                ma = k
                na = m
              ELSE
                ma = m
                na = k
              ENDIF
              !                 Set LDA to 1 more than minimum value if room.
              lda = ma
              IF ( lda<Nmax ) lda = lda + 1
              !                 Skip tests if not enough room.
              IF ( lda<=Nmax ) THEN
                laa = lda*na
                !
                !                 Generate the matrix A.
                !
                CALL SMAKE3('GE',' ',' ',ma,na,A,Nmax,Aa,lda,reset,ZERO)
                !
                DO icb = 1, 3
                  transb = ich(icb:icb)
                  tranb = transb=='T' .OR. transb=='C'
                  !
                  IF ( tranb ) THEN
                    mb = n
                    nb = k
                  ELSE
                    mb = k
                    nb = n
                  ENDIF
                  !                    Set LDB to 1 more than minimum value if room.
                  ldb = mb
                  IF ( ldb<Nmax ) ldb = ldb + 1
                  !                    Skip tests if not enough room.
                  IF ( ldb<=Nmax ) THEN
                    lbb = ldb*nb
                    !
                    !                    Generate the matrix B.
                    !
                    CALL SMAKE3('GE',' ',' ',mb,nb,B,Nmax,Bb,ldb,reset,ZERO)
                    !
                    DO ia = 1, Nalf
                      alpha = Alf(ia)
                      !
                      DO ib = 1, Nbet
                        beta = Bet(ib)
                        !
                        !                          Generate the matrix C.
                        !
                        CALL SMAKE3('GE',' ',' ',m,n,C,Nmax,Cc,ldc,reset,ZERO)
                        !
                        nc = nc + 1
                        !
                        !                          Save every datum before calling the
                        !                          subroutine.
                        !
                        tranas = transa
                        tranbs = transb
                        ms = m
                        ns = n
                        ks = k
                        als = alpha
                        DO i = 1, laa
                          As(i) = Aa(i)
                        ENDDO
                        ldas = lda
                        DO i = 1, lbb
                          Bs(i) = Bb(i)
                        ENDDO
                        ldbs = ldb
                        bls = beta
                        DO i = 1, lcc
                          Cs(i) = Cc(i)
                        ENDDO
                        ldcs = ldc
                        !
                        !                          Call the subroutine.
                        !
                        CALL SGEMM(transa,transb,m,n,k,alpha,Aa,lda,Bb,ldb,&
                          beta,Cc,ldc)
                        !
                        !                          Check if error-exit was taken incorrectly.
                        !
                        IF ( NUMXER(nerr)/=0 ) THEN
                          IF ( Kprint>=2 ) WRITE (Nout,FMT=99006)
                          Fatal = .TRUE.
                        ENDIF
                        !
                        !                          See what data changed inside subroutines.
                        !
                        isame(1) = transa==tranas
                        isame(2) = transb==tranbs
                        isame(3) = ms==m
                        isame(4) = ns==n
                        isame(5) = ks==k
                        isame(6) = als==alpha
                        isame(7) = LSE(As,Aa,laa)
                        isame(8) = ldas==lda
                        isame(9) = LSE(Bs,Bb,lbb)
                        isame(10) = ldbs==ldb
                        isame(11) = bls==beta
                        IF ( null ) THEN
                          isame(12) = LSE(Cs,Cc,lcc)
                        ELSE
                          isame(12) = LSERES('GE',' ',m,n,Cs,Cc,ldc)
                        ENDIF
                        isame(13) = ldcs==ldc
                        !
                        !                          If data was incorrectly changed, report
                        !                          and return.
                        !
                        DO i = 1, nargs
                          IF ( .NOT.isame(i) ) THEN
                            Fatal = .TRUE.
                            IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                          ENDIF
                        ENDDO
                        !
                        ftl = .FALSE.
                        IF ( .NOT.null ) THEN
                          !
                          !                             Check the result.
                          !
                          CALL SMMCH(transa,transb,m,n,k,alpha,A,Nmax,B,Nmax,&
                            beta,C,Nmax,Ct,G,Cc,ldc,Eps,err,ftl,Nout,&
                            .TRUE.,Kprint)
                          errmax = MAX(errmax,err)
                        ENDIF
                        IF ( ftl ) THEN
                          Fatal = .TRUE.
                          IF ( Kprint>=3 ) THEN
                            WRITE (Nout,FMT=99004) Sname
                            WRITE (Nout,FMT=99005) nc, Sname, transa ,&
                              transb, m, n, k, alpha, lda, ldb ,&
                              beta, ldc
                          ENDIF
                        ENDIF
                        !
                      ENDDO
                      !
                    ENDDO
                  ENDIF
                  !
                ENDDO
              ENDIF
              !
            ENDDO
            !
          ENDDO
        ENDIF
        !
      ENDDO
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT (1X,I6,': ',A6,'(''',A1,''',''',A1,''',',3(I3,','),F4.1,', A,',I3,&
      ', B,',I3,',',F4.1,', ','C,',I3,').')
    99006 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK13.
    !
  END SUBROUTINE SCHK13
  !DECK SCHK22
  SUBROUTINE SCHK22(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nkb,Kb,&
      Nalf,Alf,Nbet,Bet,Ninc,Inc,Nmax,Incmax,A,Aa,As,X,Xx,Xs,&
      Y,Yy,Ys,Yt,G)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK22
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SSYMV, SSBMV and SSPMV.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Du Croz, J. (NAG)
    !           Hanson, R. J. (SNLA)
    !***DESCRIPTION
    !
    !  Quick check for SSYMV, SSBMV and SSPMV.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SMAKE2, SMVCH, SSBMV, SSPMV,
    !                    SSYMV
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK22
    !     .. Parameters ..
    REAL ZERO, HALF
    PARAMETER (ZERO=0.0,HALF=0.5)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Incmax, Kprint, Nalf, Nbet, Nidim, Ninc, Nkb, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), Bet(Nbet)&
      , G(Nmax), X(Nmax), Xs(Nmax*Incmax), Xx(Nmax*Incmax), Y(Nmax) ,&
      Ys(Nmax*Incmax), Yt(Nmax), Yy(Nmax*Incmax)
    INTEGER Idim(Nidim), Inc(Ninc), Kb(Nkb)
    !     .. Local Scalars ..
    REAL alpha, als, beta, bls, err, errmax, transl
    INTEGER i, ia, ib, ic, ik, in, incx, incxs, incy, incys, ix ,&
      iy, k, ks, laa, lda, ldas, lx, ly, n, nargs, nc, nk ,&
      ns, nerr
    LOGICAL banded, ftl, full, null, packed, reset
    CHARACTER :: uplo, uplos
    CHARACTER(2) :: ich
    !     .. Local Arrays ..
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SSBMV, SSPMV, SSYMV
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX
    !     .. Data statements ..
    DATA ich/'UL'/
    !***FIRST EXECUTABLE STATEMENT  SCHK22
    full = Sname(3:3)=='Y'
    banded = Sname(3:3)=='B'
    packed = Sname(3:3)=='P'
    !     Define the number of arguments.
    IF ( full ) THEN
      nargs = 10
    ELSEIF ( banded ) THEN
      nargs = 11
    ELSEIF ( packed ) THEN
      nargs = 9
    ENDIF
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    DO in = 1, Nidim
      n = Idim(in)
      !
      IF ( banded ) THEN
        nk = Nkb
      ELSE
        nk = 1
      ENDIF
      DO ik = 1, nk
        IF ( banded ) THEN
          k = Kb(ik)
        ELSE
          k = n - 1
        ENDIF
        !           Set LDA to 1 more than minimum value if room.
        IF ( banded ) THEN
          lda = k + 1
        ELSE
          lda = n
        ENDIF
        IF ( lda<Nmax ) lda = lda + 1
        !           Skip tests if not enough room.
        IF ( lda<=Nmax ) THEN
          IF ( packed ) THEN
            laa = (n*(n+1))/2
          ELSE
            laa = lda*n
          ENDIF
          null = n<=0
          !
          DO ic = 1, 2
            uplo = ich(ic:ic)
            !
            !              Generate the matrix A.
            !
            transl = ZERO
            CALL SMAKE2(Sname(2:3),uplo,' ',n,n,A,Nmax,Aa,lda,k,k,reset,&
              transl)
            !
            DO ix = 1, Ninc
              incx = Inc(ix)
              lx = ABS(incx)*n
              !
              !                 Generate the vector X.
              !
              transl = HALF
              CALL SMAKE2('GE',' ',' ',1,n,X,1,Xx,ABS(incx),0,n-1,reset,&
                transl)
              IF ( n>1 ) THEN
                X(n/2) = ZERO
                Xx(1+ABS(incx)*(n/2-1)) = ZERO
              ENDIF
              !
              DO iy = 1, Ninc
                incy = Inc(iy)
                ly = ABS(incy)*n
                !
                DO ia = 1, Nalf
                  alpha = Alf(ia)
                  !
                  DO ib = 1, Nbet
                    beta = Bet(ib)
                    !
                    !                          Generate the vector Y.
                    !
                    transl = ZERO
                    CALL SMAKE2('GE',' ',' ',1,n,Y,1,Yy,ABS(incy),0,n-1,reset,&
                      transl)
                    !
                    nc = nc + 1
                    !
                    !                          Save every datum before calling the
                    !                          subroutine.
                    !
                    uplos = uplo
                    ns = n
                    ks = k
                    als = alpha
                    DO i = 1, laa
                      As(i) = Aa(i)
                    ENDDO
                    ldas = lda
                    DO i = 1, lx
                      Xs(i) = Xx(i)
                    ENDDO
                    incxs = incx
                    bls = beta
                    DO i = 1, ly
                      Ys(i) = Yy(i)
                    ENDDO
                    incys = incy
                    !
                    !                          Call the subroutine.
                    !
                    IF ( full ) THEN
                      CALL SSYMV(uplo,n,alpha,Aa,lda,Xx,incx,beta,Yy,incy)
                    ELSEIF ( banded ) THEN
                      CALL SSBMV(uplo,n,k,alpha,Aa,lda,Xx,incx,beta,Yy,incy)
                    ELSEIF ( packed ) THEN
                      CALL SSPMV(uplo,n,alpha,Aa,Xx,incx,beta,Yy,incy)
                    ENDIF
                    !
                    !                          Check if error-exit was taken incorrectly.
                    !
                    IF ( NUMXER(nerr)/=0 ) THEN
                      IF ( Kprint>=2 ) WRITE (Nout,FMT=99008)
                      Fatal = .TRUE.
                    ENDIF
                    !
                    !                          See what data changed inside subroutines.
                    !
                    isame(1) = uplo==uplos
                    isame(2) = ns==n
                    IF ( full ) THEN
                      isame(3) = als==alpha
                      isame(4) = LSE(As,Aa,laa)
                      isame(5) = ldas==lda
                      isame(6) = LSE(Xs,Xx,lx)
                      isame(7) = incxs==incx
                      isame(8) = bls==beta
                      IF ( null ) THEN
                        isame(9) = LSE(Ys,Yy,ly)
                      ELSE
                        isame(9) = LSERES('GE',' ',1,n,Ys,Yy,ABS(incy))
                      ENDIF
                      isame(10) = incys==incy
                    ELSEIF ( banded ) THEN
                      isame(3) = ks==k
                      isame(4) = als==alpha
                      isame(5) = LSE(As,Aa,laa)
                      isame(6) = ldas==lda
                      isame(7) = LSE(Xs,Xx,lx)
                      isame(8) = incxs==incx
                      isame(9) = bls==beta
                      IF ( null ) THEN
                        isame(10) = LSE(Ys,Yy,ly)
                      ELSE
                        isame(10) = LSERES('GE',' ',1,n,Ys,Yy,ABS(incy))
                      ENDIF
                      isame(11) = incys==incy
                    ELSEIF ( packed ) THEN
                      isame(3) = als==alpha
                      isame(4) = LSE(As,Aa,laa)
                      isame(5) = LSE(Xs,Xx,lx)
                      isame(6) = incxs==incx
                      isame(7) = bls==beta
                      IF ( null ) THEN
                        isame(8) = LSE(Ys,Yy,ly)
                      ELSE
                        isame(8) = LSERES('GE',' ',1,n,Ys,Yy,ABS(incy))
                      ENDIF
                      isame(9) = incys==incy
                    ENDIF
                    !
                    !                          If data was incorrectly changed, report and
                    !                          return.
                    !
                    DO i = 1, nargs
                      IF ( .NOT.isame(i) ) THEN
                        Fatal = .TRUE.
                        IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                      ENDIF
                    ENDDO
                    !
                    ftl = .FALSE.
                    IF ( .NOT.null ) THEN
                      !
                      !                             Check the result.
                      !
                      CALL SMVCH('N',n,n,alpha,A,Nmax,X,incx,beta,Y,incy,Yt,G,&
                        Yy,Eps,err,ftl,Nout,.TRUE.,Kprint)
                      errmax = MAX(errmax,err)
                    ENDIF
                    IF ( ftl ) THEN
                      Fatal = .TRUE.
                      IF ( Kprint>=3 ) THEN
                        WRITE (Nout,FMT=99004) Sname
                        IF ( full ) THEN
                          WRITE (Nout,FMT=99007) nc, Sname, uplo, n ,&
                            alpha, lda, incx, beta, incy
                        ELSEIF ( banded ) THEN
                          WRITE (Nout,FMT=99006) nc, Sname, uplo, n, k ,&
                            alpha, lda, incx, beta, incy
                        ELSEIF ( packed ) THEN
                          WRITE (Nout,FMT=99005) nc, Sname, uplo, n ,&
                            alpha, incx, beta, incy
                        ENDIF
                      ENDIF
                    ENDIF
                    !
                  ENDDO
                  !
                ENDDO
                !
              ENDDO
              !
            ENDDO
            !
          ENDDO
        ENDIF
        !
      ENDDO
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT (1X,I6,': ',A6,'(''',A1,''',',I3,',',F4.1,', AP',', X,',I2,',',&
      F4.1,', Y,',I2,')                .')
    99006 FORMAT (1X,I6,': ',A6,'(''',A1,''',',2(I3,','),F4.1,', A,',I3,', X,',I2,&
      ',',F4.1,', Y,',I2,')         .')
    99007 FORMAT (1X,I6,': ',A6,'(''',A1,''',',I3,',',F4.1,', A,',I3,', X,',I2,',',&
      F4.1,', Y,',I2,')             .')
    99008 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK22.
    !
  END SUBROUTINE SCHK22
  !DECK SCHK23
  SUBROUTINE SCHK23(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nalf,Alf,&
      Nbet,Bet,Nmax,A,Aa,As,B,Bb,Bs,C,Cc,Cs,Ct,G)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK23
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SSYMM.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Quick check for SSYMM.
    !
    !  Auxiliary routine for test program for Level 3 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SMAKE3, SMMCH, SSYMM
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK23
    !     .. Parameters ..
    REAL ZERO
    PARAMETER (ZERO=0.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Kprint, Nalf, Nbet, Nidim, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), Bet(Nbet)&
      , G(Nmax), B(Nmax,Nmax), Bb(Nmax*Nmax), Bs(Nmax*Nmax) ,&
      C(Nmax,Nmax), Cc(Nmax*Nmax), Cs(Nmax*Nmax), Ct(Nmax)
    INTEGER Idim(Nidim)
    !     .. Local Scalars ..
    REAL alpha, als, beta, bls, err, errmax
    INTEGER i, ia, ib, ics, icu, im, in, laa, lbb, lcc, lda, ldas ,&
      ldb, ldbs, ldc, ldcs, m, ms, n, na, nargs, nc, nerr, ns
    LOGICAL ftl, null, reset, left
    CHARACTER :: side, sides, uplo, uplos
    CHARACTER(2) :: ichs, ichu
    !     .. Local Arrays ..
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SSYMM
    !     .. Intrinsic Functions ..
    INTRINSIC MAX
    !     .. Data statements ..
    DATA ichs/'LR'/, ichu/'UL'/
    !***FIRST EXECUTABLE STATEMENT  SCHK23
    nargs = 12
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    DO im = 1, Nidim
      m = Idim(im)
      !
      DO in = 1, Nidim
        n = Idim(in)
        !           Set LDC to 1 more than minimum value if room.
        ldc = m
        IF ( ldc<Nmax ) ldc = ldc + 1
        !           Skip tests if not enough room.
        IF ( ldc<=Nmax ) THEN
          lcc = ldc*n
          null = n<=0 .OR. m<=0
          !
          !           Set LDB to 1 more than minimum value if room.
          ldb = m
          IF ( ldb<Nmax ) ldb = ldb + 1
          !           Skip tests if not enough room.
          IF ( ldb<=Nmax ) THEN
            lbb = ldb*n
            !
            !           Generate the matrix B.
            !
            CALL SMAKE3('GE',' ',' ',m,n,B,Nmax,Bb,ldb,reset,ZERO)
            !
            DO ics = 1, 2
              side = ichs(ics:ics)
              left = side=='L'
              !
              IF ( left ) THEN
                na = m
              ELSE
                na = n
              ENDIF
              !              Set LDA to 1 more than minimum value if room.
              lda = na
              IF ( lda<Nmax ) lda = lda + 1
              !              Skip tests if not enough room.
              IF ( lda<=Nmax ) THEN
                laa = lda*na
                !
                DO icu = 1, 2
                  uplo = ichu(icu:icu)
                  !
                  !                 Generate the symmetric matrix A.
                  !
                  CALL SMAKE3('SY',uplo,' ',na,na,A,Nmax,Aa,lda,reset,ZERO)
                  !
                  DO ia = 1, Nalf
                    alpha = Alf(ia)
                    !
                    DO ib = 1, Nbet
                      beta = Bet(ib)
                      !
                      !                       Generate the matrix C.
                      !
                      CALL SMAKE3('GE',' ',' ',m,n,C,Nmax,Cc,ldc,reset,ZERO)
                      !
                      nc = nc + 1
                      !
                      !                       Save every datum before calling the
                      !                       subroutine.
                      !
                      sides = side
                      uplos = uplo
                      ms = m
                      ns = n
                      als = alpha
                      DO i = 1, laa
                        As(i) = Aa(i)
                      ENDDO
                      ldas = lda
                      DO i = 1, lbb
                        Bs(i) = Bb(i)
                      ENDDO
                      ldbs = ldb
                      bls = beta
                      DO i = 1, lcc
                        Cs(i) = Cc(i)
                      ENDDO
                      ldcs = ldc
                      !
                      !                       Call the subroutine.
                      !
                      CALL SSYMM(side,uplo,m,n,alpha,Aa,lda,Bb,ldb,beta,Cc,&
                        ldc)
                      !
                      !                       Check if error-exit was taken incorrectly.
                      !
                      IF ( NUMXER(nerr)/=0 ) THEN
                        IF ( Kprint>=2 ) WRITE (Nout,FMT=99006)
                        Fatal = .TRUE.
                      ENDIF
                      !
                      !                       See what data changed inside subroutines.
                      !
                      isame(1) = sides==side
                      isame(2) = uplos==uplo
                      isame(3) = ms==m
                      isame(4) = ns==n
                      isame(5) = als==alpha
                      isame(6) = LSE(As,Aa,laa)
                      isame(7) = ldas==lda
                      isame(8) = LSE(Bs,Bb,lbb)
                      isame(9) = ldbs==ldb
                      isame(10) = bls==beta
                      IF ( null ) THEN
                        isame(11) = LSE(Cs,Cc,lcc)
                      ELSE
                        isame(11) = LSERES('GE',' ',m,n,Cs,Cc,ldc)
                      ENDIF
                      isame(12) = ldcs==ldc
                      !
                      !                       If data was incorrectly changed, report and
                      !                       return.
                      !
                      DO i = 1, nargs
                        IF ( .NOT.isame(i) ) THEN
                          Fatal = .TRUE.
                          IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                        ENDIF
                      ENDDO
                      !
                      ftl = .FALSE.
                      IF ( .NOT.null ) THEN
                        !
                        !                          Check the result.
                        !
                        IF ( left ) THEN
                          CALL SMMCH('N','N',m,n,m,alpha,A,Nmax,B,Nmax,beta,C,&
                            Nmax,Ct,G,Cc,ldc,Eps,err,ftl,Nout,.TRUE.,&
                            Kprint)
                        ELSE
                          CALL SMMCH('N','N',m,n,n,alpha,B,Nmax,A,Nmax,beta,C,&
                            Nmax,Ct,G,Cc,ldc,Eps,err,ftl,Nout,.TRUE.,&
                            Kprint)
                        ENDIF
                        errmax = MAX(errmax,err)
                      ENDIF
                      IF ( ftl ) THEN
                        Fatal = .TRUE.
                        IF ( Kprint>=3 ) THEN
                          WRITE (Nout,FMT=99004) Sname
                          WRITE (Nout,FMT=99005) nc, Sname, side, uplo ,&
                            m, n, alpha, lda, ldb, beta, ldc
                        ENDIF
                      ENDIF
                      !
                    ENDDO
                    !
                  ENDDO
                  !
                ENDDO
              ENDIF
              !
            ENDDO
          ENDIF
        ENDIF
        !
      ENDDO
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT (1X,I6,': ',A6,'(',2('''',A1,''','),2(I3,','),F4.1,', A,',I3,&
      ', B,',I3,',',F4.1,', C,',I3,')   ',' .')
    99006 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK23.
    !
  END SUBROUTINE SCHK23
  !DECK SCHK32
  SUBROUTINE SCHK32(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nkb,Kb,&
      Ninc,Inc,Nmax,Incmax,A,Aa,As,X,Xx,Xs,Xt,G,Z)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK32
    !***SUBSIDIARY
    !***PURPOSE  Quick check for STRMV, STBMV, STPMV, STRSV, STBSV and
    !            STPSV.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Du Croz, J. (NAG)
    !           Hanson, R. J. (SNLA)
    !***DESCRIPTION
    !
    !  Quick check for STRMV, STBMV, STPMV, STRSV, STBSV and STPSV.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SMAKE2, SMVCH, STBMV, STBSV,
    !                    STPMV, STPSV, STRMV, STRSV
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK32
    !     .. Parameters ..
    REAL ZERO, HALF, ONE
    PARAMETER (ZERO=0.0,HALF=0.5,ONE=1.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Incmax, Kprint, Nidim, Ninc, Nkb, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), As(Nmax*Nmax), G(Nmax), X(Nmax) ,&
      Xs(Nmax*Incmax), Xt(Nmax), Xx(Nmax*Incmax), Z(Nmax)
    INTEGER Idim(Nidim), Inc(Ninc), Kb(Nkb)
    !     .. Local Scalars ..
    REAL err, errmax, transl
    INTEGER i, icd, ict, icu, ik, in, incx, incxs, ix, k, ks, laa ,&
      lda, ldas, lx, n, nargs, nc, nk, ns, nerr
    LOGICAL banded, ftl, full, null, packed, reset
    CHARACTER :: diag, diags, trans, transs, uplo, uplos
    CHARACTER(2) :: ichd, ichu
    CHARACTER(3) :: icht
    !     .. Local Arrays ..
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL STBMV, STBSV, STPMV, STPSV, STRMV, STRSV
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX
    !     .. Data statements ..
    DATA ichu/'UL'/, icht/'NTC'/, ichd/'UN'/
    !***FIRST EXECUTABLE STATEMENT  SCHK32
    full = Sname(3:3)=='R'
    banded = Sname(3:3)=='B'
    packed = Sname(3:3)=='P'
    !     Define the number of arguments.
    IF ( full ) THEN
      nargs = 8
    ELSEIF ( banded ) THEN
      nargs = 9
    ELSEIF ( packed ) THEN
      nargs = 7
    ENDIF
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !     Set up zero vector for SMVCH.
    DO i = 1, Nmax
      Z(i) = ZERO
    ENDDO
    !
    DO in = 1, Nidim
      n = Idim(in)
      !
      IF ( banded ) THEN
        nk = Nkb
      ELSE
        nk = 1
      ENDIF
      DO ik = 1, nk
        IF ( banded ) THEN
          k = Kb(ik)
        ELSE
          k = n - 1
        ENDIF
        !           Set LDA to 1 more than minimum value if room.
        IF ( banded ) THEN
          lda = k + 1
        ELSE
          lda = n
        ENDIF
        IF ( lda<Nmax ) lda = lda + 1
        !           Skip tests if not enough room.
        IF ( lda<=Nmax ) THEN
          IF ( packed ) THEN
            laa = (n*(n+1))/2
          ELSE
            laa = lda*n
          ENDIF
          null = n<=0
          !
          DO icu = 1, 2
            uplo = ichu(icu:icu)
            !
            DO ict = 1, 3
              trans = icht(ict:ict)
              !
              DO icd = 1, 2
                diag = ichd(icd:icd)
                !
                !                    Generate the matrix A.
                !
                transl = ZERO
                CALL SMAKE2(Sname(2:3),uplo,diag,n,n,A,Nmax,Aa,lda,k,k,reset,&
                  transl)
                !
                DO ix = 1, Ninc
                  incx = Inc(ix)
                  lx = ABS(incx)*n
                  !
                  !                       Generate the vector X.
                  !
                  transl = HALF
                  CALL SMAKE2('GE',' ',' ',1,n,X,1,Xx,ABS(incx),0,n-1,reset,&
                    transl)
                  IF ( n>1 ) THEN
                    X(n/2) = ZERO
                    Xx(1+ABS(incx)*(n/2-1)) = ZERO
                  ENDIF
                  !
                  nc = nc + 1
                  !
                  !                       Save every datum before calling the subroutine.
                  !
                  uplos = uplo
                  transs = trans
                  diags = diag
                  ns = n
                  ks = k
                  DO i = 1, laa
                    As(i) = Aa(i)
                  ENDDO
                  ldas = lda
                  DO i = 1, lx
                    Xs(i) = Xx(i)
                  ENDDO
                  incxs = incx
                  !
                  !                       Call the subroutine.
                  !
                  IF ( Sname(4:5)=='MV' ) THEN
                    IF ( full ) THEN
                      CALL STRMV(uplo,trans,diag,n,Aa,lda,Xx,incx)
                    ELSEIF ( banded ) THEN
                      CALL STBMV(uplo,trans,diag,n,k,Aa,lda,Xx,incx)
                    ELSEIF ( packed ) THEN
                      CALL STPMV(uplo,trans,diag,n,Aa,Xx,incx)
                    ENDIF
                  ELSEIF ( Sname(4:5)=='SV' ) THEN
                    IF ( full ) THEN
                      CALL STRSV(uplo,trans,diag,n,Aa,lda,Xx,incx)
                    ELSEIF ( banded ) THEN
                      CALL STBSV(uplo,trans,diag,n,k,Aa,lda,Xx,incx)
                    ELSEIF ( packed ) THEN
                      CALL STPSV(uplo,trans,diag,n,Aa,Xx,incx)
                    ENDIF
                  ENDIF
                  !
                  !                       Check if error-exit was taken incorrectly.
                  !
                  IF ( NUMXER(nerr)/=0 ) THEN
                    IF ( Kprint>=2 ) WRITE (Nout,FMT=99008)
                    Fatal = .TRUE.
                  ENDIF
                  !
                  !                       See what data changed inside subroutines.
                  !
                  isame(1) = uplo==uplos
                  isame(2) = trans==transs
                  isame(3) = diag==diags
                  isame(4) = ns==n
                  IF ( full ) THEN
                    isame(5) = LSE(As,Aa,laa)
                    isame(6) = ldas==lda
                    IF ( null ) THEN
                      isame(7) = LSE(Xs,Xx,lx)
                    ELSE
                      isame(7) = LSERES('GE',' ',1,n,Xs,Xx,ABS(incx))
                    ENDIF
                    isame(8) = incxs==incx
                  ELSEIF ( banded ) THEN
                    isame(5) = ks==k
                    isame(6) = LSE(As,Aa,laa)
                    isame(7) = ldas==lda
                    IF ( null ) THEN
                      isame(8) = LSE(Xs,Xx,lx)
                    ELSE
                      isame(8) = LSERES('GE',' ',1,n,Xs,Xx,ABS(incx))
                    ENDIF
                    isame(9) = incxs==incx
                  ELSEIF ( packed ) THEN
                    isame(5) = LSE(As,Aa,laa)
                    IF ( null ) THEN
                      isame(6) = LSE(Xs,Xx,lx)
                    ELSE
                      isame(6) = LSERES('GE',' ',1,n,Xs,Xx,ABS(incx))
                    ENDIF
                    isame(7) = incxs==incx
                  ENDIF
                  !
                  !                       If data was incorrectly changed, report and
                  !                       return.
                  !
                  DO i = 1, nargs
                    IF ( .NOT.isame(i) ) THEN
                      Fatal = .TRUE.
                      IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                    ENDIF
                  ENDDO
                  !
                  ftl = .FALSE.
                  IF ( .NOT.null ) THEN
                    IF ( Sname(4:5)=='MV' ) THEN
                      !
                      !                             Check the result.
                      !
                      CALL SMVCH(trans,n,n,ONE,A,Nmax,X,incx,ZERO,Z,incx,Xt,G,&
                        Xx,Eps,err,ftl,Nout,.TRUE.,Kprint)
                    ELSEIF ( Sname(4:5)=='SV' ) THEN
                      !
                      !                             Compute approximation to original vector.
                      !
                      DO i = 1, n
                        Z(i) = Xx(1+(i-1)*ABS(incx))
                        Xx(1+(i-1)*ABS(incx)) = X(i)
                      ENDDO
                      CALL SMVCH(trans,n,n,ONE,A,Nmax,Z,incx,ZERO,X,incx,Xt,G,&
                        Xx,Eps,err,ftl,Nout,.FALSE.,Kprint)
                    ENDIF
                    errmax = MAX(errmax,err)
                  ENDIF
                  IF ( ftl ) THEN
                    Fatal = .TRUE.
                    IF ( Kprint>=3 ) THEN
                      WRITE (Nout,FMT=99004) Sname
                      IF ( full ) THEN
                        WRITE (Nout,FMT=99007) nc, Sname, uplo, trans ,&
                          diag, n, lda, incx
                      ELSEIF ( banded ) THEN
                        WRITE (Nout,FMT=99006) nc, Sname, uplo, trans ,&
                          diag, n, k, lda, incx
                      ELSEIF ( packed ) THEN
                        WRITE (Nout,FMT=99005) nc, Sname, uplo, trans ,&
                          diag, n, incx
                      ENDIF
                    ENDIF
                  ENDIF
                  !
                ENDDO
                !
              ENDDO
              !
            ENDDO
            !
          ENDDO
        ENDIF
        !
      ENDDO
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT (1X,I6,': ',A6,'(',3('''',A1,''','),I3,', AP, ','X,',I2,&
      ')                        .')
    99006 FORMAT (1X,I6,': ',A6,'(',3('''',A1,''','),2(I3,','),' A,',I3,', X,',I2,&
      ')                 .')
    99007 FORMAT (1X,I6,': ',A6,'(',3('''',A1,''','),I3,', A,',I3,', X,',I2,&
      ')                     .')
    99008 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK32.
    !
  END SUBROUTINE SCHK32
  !DECK SCHK33
  SUBROUTINE SCHK33(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nalf,Alf,&
      Nmax,A,Aa,As,B,Bb,Bs,Ct,G,C)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK33
    !***SUBSIDIARY
    !***PURPOSE  Quick check for STRMM and STRSM.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Quick check for STRMM and STRSM.
    !
    !  Auxiliary routine for test program for Level 3 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SMAKE3, SMMCH, STRMM, STRSM
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK33
    !     .. Parameters ..
    REAL ZERO, ONE
    PARAMETER (ZERO=0.0,ONE=1.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Kprint, Nalf, Nidim, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), G(Nmax) ,&
      B(Nmax,Nmax), Bb(Nmax*Nmax), Bs(Nmax*Nmax), C(Nmax,Nmax) ,&
      Ct(Nmax)
    INTEGER Idim(Nidim)
    !     .. Local Scalars ..
    REAL alpha, als, err, errmax
    INTEGER i, ia, icd, ics, ict, icu, im, in, j, laa, lbb, lda ,&
      ldas, ldb, ldbs, m, ms, n, na, nargs, nc, nerr, ns
    LOGICAL ftl, null, reset, left
    CHARACTER :: side, sides, uplo, uplos, tranas, transa, diag, diags
    CHARACTER(2) :: ichs, ichu, ichd
    CHARACTER(3) :: icht
    !     .. Local Arrays ..
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL STRMM, STRSM
    !     .. Intrinsic Functions ..
    INTRINSIC MAX
    !     .. Data statements ..
    DATA icht/'NTC'/, ichu/'UL'/, ichd/'UN'/, ichs/'LR'/
    !***FIRST EXECUTABLE STATEMENT  SCHK33
    nargs = 11
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    !     Set up zero matrix for SMMCH.
    DO j = 1, Nmax
      DO i = 1, Nmax
        C(i,j) = ZERO
      ENDDO
    ENDDO
    !
    DO im = 1, Nidim
      m = Idim(im)
      !
      DO in = 1, Nidim
        n = Idim(in)
        !           Set LDB to 1 more than minimum value if room.
        ldb = m
        IF ( ldb<Nmax ) ldb = ldb + 1
        !           Skip tests if not enough room.
        IF ( ldb<=Nmax ) THEN
          lbb = ldb*n
          null = m<=0 .OR. n<=0
          !
          DO ics = 1, 2
            side = ichs(ics:ics)
            left = side=='L'
            IF ( left ) THEN
              na = m
            ELSE
              na = n
            ENDIF
            !              Set LDA to 1 more than minimum value if room.
            lda = na
            IF ( lda<Nmax ) lda = lda + 1
            !              Skip tests if not enough room.
            IF ( lda>Nmax ) EXIT
            laa = lda*na
            !
            DO icu = 1, 2
              uplo = ichu(icu:icu)
              !
              DO ict = 1, 3
                transa = icht(ict:ict)
                !
                DO icd = 1, 2
                  diag = ichd(icd:icd)
                  !
                  DO ia = 1, Nalf
                    alpha = Alf(ia)
                    !
                    !                          Generate the matrix A.
                    !
                    CALL SMAKE3('TR',uplo,diag,na,na,A,Nmax,Aa,lda,reset,ZERO)
                    !
                    !                          Generate the matrix B.
                    !
                    CALL SMAKE3('GE',' ',' ',m,n,B,Nmax,Bb,ldb,reset,ZERO)
                    !
                    nc = nc + 1
                    !
                    !                          Save every datum before calling the
                    !                          subroutine.
                    !
                    sides = side
                    uplos = uplo
                    tranas = transa
                    diags = diag
                    ms = m
                    ns = n
                    als = alpha
                    DO i = 1, laa
                      As(i) = Aa(i)
                    ENDDO
                    ldas = lda
                    DO i = 1, lbb
                      Bs(i) = Bb(i)
                    ENDDO
                    ldbs = ldb
                    !
                    !                          Call the subroutine.
                    !
                    IF ( Sname(4:5)=='MM' ) THEN
                      CALL STRMM(side,uplo,transa,diag,m,n,alpha,Aa,lda,Bb,&
                        ldb)
                    ELSEIF ( Sname(4:5)=='SM' ) THEN
                      CALL STRSM(side,uplo,transa,diag,m,n,alpha,Aa,lda,Bb,&
                        ldb)
                    ENDIF
                    !
                    !                          Check if error-exit was taken incorrectly.
                    !
                    IF ( NUMXER(nerr)/=0 ) THEN
                      IF ( Kprint>=2 ) WRITE (Nout,FMT=99006)
                      Fatal = .TRUE.
                    ENDIF
                    !
                    !                          See what data changed inside subroutines.
                    !
                    isame(1) = sides==side
                    isame(2) = uplos==uplo
                    isame(3) = tranas==transa
                    isame(4) = diags==diag
                    isame(5) = ms==m
                    isame(6) = ns==n
                    isame(7) = als==alpha
                    isame(8) = LSE(As,Aa,laa)
                    isame(9) = ldas==lda
                    IF ( null ) THEN
                      isame(10) = LSE(Bs,Bb,lbb)
                    ELSE
                      isame(10) = LSERES('GE',' ',m,n,Bs,Bb,ldb)
                    ENDIF
                    isame(11) = ldbs==ldb
                    !
                    !                          If data was incorrectly changed, report and
                    !                          return.
                    !
                    DO i = 1, nargs
                      IF ( .NOT.isame(i) ) THEN
                        Fatal = .TRUE.
                        IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                      ENDIF
                    ENDDO
                    !
                    ftl = .FALSE.
                    IF ( .NOT.null ) THEN
                      IF ( Sname(4:5)=='MM' ) THEN
                        !
                        !                                Check the result.
                        !
                        IF ( left ) THEN
                          CALL SMMCH(transa,'N',m,n,m,alpha,A,Nmax,B,Nmax,&
                            ZERO,C,Nmax,Ct,G,Bb,ldb,Eps,err,ftl,Nout,&
                            .TRUE.,Kprint)
                        ELSE
                          CALL SMMCH('N',transa,m,n,n,alpha,B,Nmax,A,Nmax,&
                            ZERO,C,Nmax,Ct,G,Bb,ldb,Eps,err,ftl,Nout,&
                            .TRUE.,Kprint)
                        ENDIF
                      ELSEIF ( Sname(4:5)=='SM' ) THEN
                        !
                        !                                Compute approximation to original
                        !                                matrix.
                        !
                        DO j = 1, n
                          DO i = 1, m
                            C(i,j) = Bb(i+(j-1)*ldb)
                            Bb(i+(j-1)*ldb) = alpha*B(i,j)
                          ENDDO
                        ENDDO
                        !
                        IF ( left ) THEN
                          CALL SMMCH(transa,'N',m,n,m,ONE,A,Nmax,C,Nmax,ZERO,&
                            B,Nmax,Ct,G,Bb,ldb,Eps,err,ftl,Nout,&
                            .FALSE.,Kprint)
                        ELSE
                          CALL SMMCH('N',transa,m,n,n,ONE,C,Nmax,A,Nmax,ZERO,&
                            B,Nmax,Ct,G,Bb,ldb,Eps,err,ftl,Nout,&
                            .FALSE.,Kprint)
                        ENDIF
                      ENDIF
                      errmax = MAX(errmax,err)
                    ENDIF
                    IF ( ftl ) THEN
                      Fatal = .TRUE.
                      IF ( Kprint>=3 ) THEN
                        WRITE (Nout,FMT=99004) Sname
                        WRITE (Nout,FMT=99005) nc, Sname, side, uplo ,&
                          transa, diag, m, n, alpha, lda, ldb
                      ENDIF
                    ENDIF
                    !
                  ENDDO
                  !
                ENDDO
                !
              ENDDO
              !
            ENDDO
            !
          ENDDO
        ENDIF
        !
      ENDDO
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    !
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT (1X,I6,': ',A6,'(',4('''',A1,''','),2(I3,','),F4.1,', A,',I3,&
      ', B,',I3,')        .')
    99006 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK33.
    !
  END SUBROUTINE SCHK33
  !DECK SCHK42
  SUBROUTINE SCHK42(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nalf,Alf,&
      Ninc,Inc,Nmax,Incmax,A,Aa,As,X,Xx,Xs,Y,Yy,Ys,Yt,G,Z)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK42
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SGER.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Du Croz, J. (NAG)
    !           Hanson, R. J. (SNLA)
    !***DESCRIPTION
    !
    !  Quick check for SGER.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SGER, SMAKE2, SMVCH
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK42
    !     .. Parameters ..
    REAL ZERO, HALF, ONE
    PARAMETER (ZERO=0.0,HALF=0.5,ONE=1.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Incmax, Kprint, Nalf, Nidim, Ninc, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), G(Nmax) ,&
      X(Nmax), Xs(Nmax*Incmax), Xx(Nmax*Incmax), Y(Nmax) ,&
      Ys(Nmax*Incmax), Yt(Nmax), Yy(Nmax*Incmax), Z(Nmax)
    INTEGER Idim(Nidim), Inc(Ninc)
    !     .. Local Scalars ..
    REAL alpha, als, err, errmax, transl
    INTEGER i, ia, im, in, incx, incxs, incy, incys, ix, iy, j ,&
      laa, lda, ldas, lx, ly, m, ms, n, nargs, nc, nd, ns ,&
      nerr
    LOGICAL ftl, null, reset
    !     .. Local Arrays ..
    REAL w(1)
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SGER
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX, MIN
    !***FIRST EXECUTABLE STATEMENT SCHK42
    !     Define the number of arguments.
    nargs = 9
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    DO in = 1, Nidim
      n = Idim(in)
      nd = n/2 + 1
      !
      DO im = 1, 2
        IF ( im==1 ) m = MAX(n-nd,0)
        IF ( im==2 ) m = MIN(n+nd,Nmax)
        !
        !           Set LDA to 1 more than minimum value if room.
        lda = m
        IF ( lda<Nmax ) lda = lda + 1
        !           Skip tests if not enough room.
        IF ( lda<=Nmax ) THEN
          laa = lda*n
          null = n<=0 .OR. m<=0
          !
          DO ix = 1, Ninc
            incx = Inc(ix)
            lx = ABS(incx)*m
            !
            !              Generate the vector X.
            !
            transl = HALF
            CALL SMAKE2('GE',' ',' ',1,m,X,1,Xx,ABS(incx),0,m-1,reset,transl)
            IF ( m>1 ) THEN
              X(m/2) = ZERO
              Xx(1+ABS(incx)*(m/2-1)) = ZERO
            ENDIF
            !
            DO iy = 1, Ninc
              incy = Inc(iy)
              ly = ABS(incy)*n
              !
              !                 Generate the vector Y.
              !
              transl = ZERO
              CALL SMAKE2('GE',' ',' ',1,n,Y,1,Yy,ABS(incy),0,n-1,reset,&
                transl)
              IF ( n>1 ) THEN
                Y(n/2) = ZERO
                Yy(1+ABS(incy)*(n/2-1)) = ZERO
              ENDIF
              !
              DO ia = 1, Nalf
                alpha = Alf(ia)
                !
                !                    Generate the matrix A.
                !
                transl = ZERO
                CALL SMAKE2(Sname(2:3),' ',' ',m,n,A,Nmax,Aa,lda,m-1,n-1,&
                  reset,transl)
                !
                nc = nc + 1
                !
                !                    Save every datum before calling the subroutine.
                !
                ms = m
                ns = n
                als = alpha
                DO i = 1, laa
                  As(i) = Aa(i)
                ENDDO
                ldas = lda
                DO i = 1, lx
                  Xs(i) = Xx(i)
                ENDDO
                incxs = incx
                DO i = 1, ly
                  Ys(i) = Yy(i)
                ENDDO
                incys = incy
                !
                !                    Call the subroutine.
                !
                CALL SGER(m,n,alpha,Xx,incx,Yy,incy,Aa,lda)
                !
                !                    Check if error-exit was taken incorrectly.
                !
                IF ( NUMXER(nerr)/=0 ) THEN
                  IF ( Kprint>=2 ) WRITE (Nout,FMT=99007)
                  Fatal = .TRUE.
                ENDIF
                !
                !                    See what data changed inside subroutine.
                !
                isame(1) = ms==m
                isame(2) = ns==n
                isame(3) = als==alpha
                isame(4) = LSE(Xs,Xx,lx)
                isame(5) = incxs==incx
                isame(6) = LSE(Ys,Yy,ly)
                isame(7) = incys==incy
                IF ( null ) THEN
                  isame(8) = LSE(As,Aa,laa)
                ELSE
                  isame(8) = LSERES('GE',' ',m,n,As,Aa,lda)
                ENDIF
                isame(9) = ldas==lda
                !
                !                    If data was incorrectly changed, report and return.
                !
                DO i = 1, nargs
                  IF ( .NOT.isame(i) ) THEN
                    Fatal = .TRUE.
                    IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                  ENDIF
                ENDDO
                !
                ftl = .FALSE.
                IF ( .NOT.null ) THEN
                  !
                  !                       Check the result column by column.
                  !
                  IF ( incx>0 ) THEN
                    DO i = 1, m
                      Z(i) = X(i)
                    ENDDO
                  ELSE
                    DO i = 1, m
                      Z(i) = X(m-i+1)
                    ENDDO
                  ENDIF
                  DO j = 1, n
                    IF ( incy>0 ) THEN
                      w(1) = Y(j)
                    ELSE
                      w(1) = Y(n-j+1)
                    ENDIF
                    CALL SMVCH('N',m,1,alpha,Z,Nmax,w,1,ONE,A(1,j),1,Yt,G,&
                      Aa(1+(j-1)*lda),Eps,err,ftl,Nout,.TRUE.,Kprint)
                    errmax = MAX(errmax,err)
                  ENDDO
                ENDIF
                IF ( ftl ) THEN
                  Fatal = .TRUE.
                  IF ( Kprint>=3 ) THEN
                    WRITE (Nout,FMT=99005) j
                    WRITE (Nout,FMT=99004) Sname
                    WRITE (Nout,FMT=99006) nc, Sname, m, n, alpha, incx ,&
                      incy, lda
                  ENDIF
                ENDIF
                !
              ENDDO
              !
            ENDDO
            !
          ENDDO
        ENDIF
        !
      ENDDO
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT ('      THESE ARE THE RESULTS FOR COLUMN ',I3)
    99006 FORMAT (1X,I6,': ',A6,'(',2(I3,','),F4.1,', X,',I2,', Y,',I2,', A,',I3,&
      ')                  .')
    99007 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK42.
    !
  END SUBROUTINE SCHK42
  !DECK SCHK43
  SUBROUTINE SCHK43(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nalf,Alf,&
      Nbet,Bet,Nmax,A,Aa,As,B,Bb,Bs,C,Cc,Cs,Ct,G)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK43
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SSYRK.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Quick check for SSYRK.
    !
    !  Auxiliary routine for test program for Level 3 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SMAKE3, SMMCH, SSYRK
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK43
    !     .. Parameters ..
    REAL ZERO, ONE
    PARAMETER (ZERO=0.0,ONE=1.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Kprint, Nalf, Nbet, Nidim, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), Bet(Nbet)&
      , G(Nmax), B(Nmax,Nmax), Bb(Nmax*Nmax), Bs(Nmax*Nmax) ,&
      C(Nmax,Nmax), Cc(Nmax*Nmax), Cs(Nmax*Nmax), Ct(Nmax)
    INTEGER Idim(Nidim)
    !     .. Local Scalars ..
    REAL alpha, als, beta, bets, err, errmax
    INTEGER i, ia, ib, ict, icu, ik, in, j, jc, jj, k, laa, lcc ,&
      lda, ldas, ldc, ldcs, n, na, nargs, nc, nerr, ns, ks ,&
      lj, ma
    LOGICAL ftl, null, reset, tran, upper
    CHARACTER :: uplo, uplos, trans, transs
    CHARACTER(2) :: ichu
    CHARACTER(3) :: icht
    !     .. Local Arrays ..
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SSYRK
    !     .. Intrinsic Functions ..
    INTRINSIC MAX
    !     .. Data statements ..
    DATA icht/'NTC'/, ichu/'UL'/
    !***FIRST EXECUTABLE STATEMENT  SCHK43
    nargs = 10
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    !
    DO in = 1, Nidim
      n = Idim(in)
      !        Set LDC to 1 more than minimum value if room.
      ldc = n
      IF ( ldc<Nmax ) ldc = ldc + 1
      !        Skip tests if not enough room.
      IF ( ldc<=Nmax ) THEN
        lcc = ldc*n
        null = n<=0
        !
        DO ik = 1, Nidim
          k = Idim(ik)
          !
          DO ict = 1, 3
            trans = icht(ict:ict)
            tran = trans=='T' .OR. trans=='C'
            IF ( tran ) THEN
              ma = k
              na = n
            ELSE
              ma = n
              na = k
            ENDIF
            !              Set LDA to 1 more than minimum value if room.
            lda = ma
            IF ( lda<Nmax ) lda = lda + 1
            !              Skip tests if not enough room.
            IF ( lda<=Nmax ) THEN
              laa = lda*na
              !
              !              Generate the matrix A.
              !
              CALL SMAKE3('GE',' ',' ',ma,na,A,Nmax,Aa,lda,reset,ZERO)
              !
              DO icu = 1, 2
                uplo = ichu(icu:icu)
                upper = uplo=='U'
                !
                DO ia = 1, Nalf
                  alpha = Alf(ia)
                  !
                  DO ib = 1, Nbet
                    beta = Bet(ib)
                    !
                    !                       Generate the matrix C.
                    !
                    CALL SMAKE3('SY',uplo,' ',n,n,C,Nmax,Cc,ldc,reset,ZERO)
                    !
                    nc = nc + 1
                    !
                    !                       Save every datum before calling the subroutine.
                    !
                    uplos = uplo
                    transs = trans
                    ns = n
                    ks = k
                    als = alpha
                    DO i = 1, laa
                      As(i) = Aa(i)
                    ENDDO
                    ldas = lda
                    bets = beta
                    DO i = 1, lcc
                      Cs(i) = Cc(i)
                    ENDDO
                    ldcs = ldc
                    !
                    !                       Call the subroutine.
                    !
                    CALL SSYRK(uplo,trans,n,k,alpha,Aa,lda,beta,Cc,ldc)
                    !
                    !                       Check if error-exit was taken incorrectly.
                    !
                    IF ( NUMXER(nerr)/=0 ) THEN
                      IF ( Kprint>=2 ) WRITE (Nout,FMT=99006)
                      Fatal = .TRUE.
                    ENDIF
                    !
                    !                       See what data changed inside subroutines.
                    !
                    isame(1) = uplos==uplo
                    isame(2) = transs==trans
                    isame(3) = ns==n
                    isame(4) = ks==k
                    isame(5) = als==alpha
                    isame(6) = LSE(As,Aa,laa)
                    isame(7) = ldas==lda
                    isame(8) = bets==beta
                    IF ( null ) THEN
                      isame(9) = LSE(Cs,Cc,lcc)
                    ELSE
                      isame(9) = LSERES('SY',uplo,n,n,Cs,Cc,ldc)
                    ENDIF
                    isame(10) = ldcs==ldc
                    !
                    !                       If data was incorrectly changed, report and
                    !                       return.
                    !
                    DO i = 1, nargs
                      IF ( .NOT.isame(i) ) THEN
                        Fatal = .TRUE.
                        IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                      ENDIF
                    ENDDO
                    !
                    ftl = .FALSE.
                    IF ( .NOT.null ) THEN
                      !
                      !                          Check the result column by column.
                      !
                      jc = 1
                      DO j = 1, n
                        IF ( upper ) THEN
                          jj = 1
                          lj = j
                        ELSE
                          jj = j
                          lj = n - j + 1
                        ENDIF
                        IF ( tran ) THEN
                          CALL SMMCH('T','N',lj,1,k,alpha,A(1,jj),Nmax,A(1,j),&
                            Nmax,beta,C(jj,j),Nmax,Ct,G,Cc(jc),ldc,&
                            Eps,err,ftl,Nout,.TRUE.,Kprint)
                        ELSE
                          CALL SMMCH('N','T',lj,1,k,alpha,A(jj,1),Nmax,A(j,1),&
                            Nmax,beta,C(jj,j),Nmax,Ct,G,Cc(jc),ldc,&
                            Eps,err,ftl,Nout,.TRUE.,Kprint)
                        ENDIF
                        IF ( upper ) THEN
                          jc = jc + ldc
                        ELSE
                          jc = jc + ldc + 1
                        ENDIF
                        errmax = MAX(errmax,err)
                      ENDDO
                    ENDIF
                    IF ( ftl ) THEN
                      Fatal = .TRUE.
                      IF ( Kprint>=3 ) THEN
                        WRITE (Nout,FMT=99004) Sname
                        WRITE (Nout,FMT=99005) nc, Sname, uplo, trans, n ,&
                          k, alpha, lda, beta, ldc
                      ENDIF
                    ENDIF
                    !
                  ENDDO
                  !
                ENDDO
                !
              ENDDO
            ENDIF
            !
          ENDDO
          !
        ENDDO
      ENDIF
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT (1X,I6,': ',A6,'(',2('''',A1,''','),2(I3,','),F4.1,', A,',I3,',',&
      F4.1,', C,',I3,')           .')
    99006 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK43.
    !
  END SUBROUTINE SCHK43
  !DECK SCHK52
  SUBROUTINE SCHK52(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nalf,Alf,&
      Ninc,Inc,Nmax,Incmax,A,Aa,As,X,Xx,Xs,Y,Yy,Ys,Yt,G,Z)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK52
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SSYR and SSPR.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Du Croz, J. (NAG)
    !           Hanson, R. J. (SNLA)
    !***DESCRIPTION
    !
    !  Quick check for SSYR and SSPR.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SMAKE2, SMVCH, SSPR, SSYR
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK52
    !     .. Parameters ..
    REAL ZERO, HALF, ONE
    PARAMETER (ZERO=0.0,HALF=0.5,ONE=1.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Incmax, Kprint, Nalf, Nidim, Ninc, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), G(Nmax) ,&
      X(Nmax), Xs(Nmax*Incmax), Xx(Nmax*Incmax), Y(Nmax) ,&
      Ys(Nmax*Incmax), Yt(Nmax), Yy(Nmax*Incmax), Z(Nmax)
    INTEGER Idim(Nidim), Inc(Ninc)
    !     .. Local Scalars ..
    REAL alpha, als, err, errmax, transl
    INTEGER i, ia, ic, in, incx, incxs, ix, j, ja, jj, laa, lda ,&
      ldas, lj, lx, n, nargs, nc, ns, nerr
    LOGICAL ftl, full, null, packed, reset, upper
    CHARACTER :: uplo, uplos
    CHARACTER(2) :: ich
    !     .. Local Arrays ..
    REAL w(1)
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SSPR, SSYR
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX
    !     .. Data statements ..
    DATA ich/'UL'/
    !***FIRST EXECUTABLE STATEMENT  SCHK52
    full = Sname(3:3)=='Y'
    packed = Sname(3:3)=='P'
    !     Define the number of arguments.
    IF ( full ) THEN
      nargs = 7
    ELSEIF ( packed ) THEN
      nargs = 6
    ENDIF
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    DO in = 1, Nidim
      n = Idim(in)
      !        Set LDA to 1 more than minimum value if room.
      lda = n
      IF ( lda<Nmax ) lda = lda + 1
      !        Skip tests if not enough room.
      IF ( lda<=Nmax ) THEN
        IF ( packed ) THEN
          laa = (n*(n+1))/2
        ELSE
          laa = lda*n
        ENDIF
        !
        DO ic = 1, 2
          uplo = ich(ic:ic)
          upper = uplo=='U'
          !
          DO ix = 1, Ninc
            incx = Inc(ix)
            lx = ABS(incx)*n
            !
            !              Generate the vector X.
            !
            transl = HALF
            CALL SMAKE2('GE',' ',' ',1,n,X,1,Xx,ABS(incx),0,n-1,reset,transl)
            IF ( n>1 ) THEN
              X(n/2) = ZERO
              Xx(1+ABS(incx)*(n/2-1)) = ZERO
            ENDIF
            !
            DO ia = 1, Nalf
              alpha = Alf(ia)
              null = n<=0 .OR. alpha==ZERO
              !
              !                 Generate the matrix A.
              !
              transl = ZERO
              CALL SMAKE2(Sname(2:3),uplo,' ',n,n,A,Nmax,Aa,lda,n-1,n-1,reset,&
                transl)
              !
              nc = nc + 1
              !
              !                 Save every datum before calling the subroutine.
              !
              uplos = uplo
              ns = n
              als = alpha
              DO i = 1, laa
                As(i) = Aa(i)
              ENDDO
              ldas = lda
              DO i = 1, lx
                Xs(i) = Xx(i)
              ENDDO
              incxs = incx
              !
              !                 Call the subroutine.
              !
              IF ( full ) THEN
                CALL SSYR(uplo,n,alpha,Xx,incx,Aa,lda)
              ELSEIF ( packed ) THEN
                CALL SSPR(uplo,n,alpha,Xx,incx,Aa)
              ENDIF
              !
              !                 Check if error-exit was taken incorrectly.
              !
              IF ( NUMXER(nerr)/=0 ) THEN
                IF ( Kprint>=2 ) WRITE (Nout,FMT=99008)
                Fatal = .TRUE.
              ENDIF
              !
              !                 See what data changed inside subroutines.
              !
              isame(1) = uplo==uplos
              isame(2) = ns==n
              isame(3) = als==alpha
              isame(4) = LSE(Xs,Xx,lx)
              isame(5) = incxs==incx
              IF ( null ) THEN
                isame(6) = LSE(As,Aa,laa)
              ELSE
                isame(6) = LSERES(Sname(2:3),uplo,n,n,As,Aa,lda)
              ENDIF
              IF ( .NOT.packed ) isame(7) = ldas==lda
              !
              !                 If data was incorrectly changed, report and return.
              !
              DO i = 1, nargs
                IF ( .NOT.isame(i) ) THEN
                  Fatal = .TRUE.
                  IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                ENDIF
              ENDDO
              !
              IF ( .NOT.null ) THEN
                !
                !                    Check the result column by column.
                !
                IF ( incx>0 ) THEN
                  DO i = 1, n
                    Z(i) = X(i)
                  ENDDO
                ELSE
                  DO i = 1, n
                    Z(i) = X(n-i+1)
                  ENDDO
                ENDIF
                ja = 1
                DO j = 1, n
                  w(1) = Z(j)
                  IF ( upper ) THEN
                    jj = 1
                    lj = j
                  ELSE
                    jj = j
                    lj = n - j + 1
                  ENDIF
                  ftl = .FALSE.
                  CALL SMVCH('N',lj,1,alpha,Z(jj),lj,w,1,ONE,A(jj,j),1,Yt,G,&
                    Aa(ja),Eps,err,ftl,Nout,.TRUE.,Kprint)
                  IF ( .NOT.(full) ) THEN
                    ja = ja + lj
                  ELSEIF ( upper ) THEN
                    ja = ja + lda
                  ELSE
                    ja = ja + lda + 1
                  ENDIF
                  errmax = MAX(errmax,err)
                  IF ( ftl ) THEN
                    Fatal = .TRUE.
                    IF ( Kprint>=3 ) THEN
                      WRITE (Nout,FMT=99005) j
                      WRITE (Nout,FMT=99004) Sname
                      IF ( full ) THEN
                        WRITE (Nout,FMT=99007) nc, Sname, uplo, n, alpha ,&
                          incx, lda
                      ELSEIF ( packed ) THEN
                        WRITE (Nout,FMT=99006) nc, Sname, uplo, n, alpha ,&
                          incx
                      ENDIF
                    ENDIF
                  ENDIF
                ENDDO
              ENDIF
              !
            ENDDO
            !
          ENDDO
          !
        ENDDO
      ENDIF
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT ('      THESE ARE THE RESULTS FOR COLUMN ',I3)
    99006 FORMAT (1X,I6,': ',A6,'(''',A1,''',',I3,',',F4.1,', X,',I2,&
      ', AP)                           .')
    99007 FORMAT (1X,I6,': ',A6,'(''',A1,''',',I3,',',F4.1,', X,',I2,', A,',I3,&
      ')                        .')
    99008 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK52.
    !
  END SUBROUTINE SCHK52
  !DECK SCHK53
  SUBROUTINE SCHK53(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nalf,Alf,&
      Nbet,Bet,Nmax,Ab,Aa,As,Bb,Bs,C,Cc,Cs,Ct,G,W)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK53
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SSYR2K.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Quick check for SSYR2K.
    !
    !  Auxiliary routine for test program for Level 3 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SMAKE3, SMMCH, SSYR2K
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK53
    !     .. Parameters ..
    REAL ZERO
    PARAMETER (ZERO=0.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Kprint, Nalf, Nbet, Nidim, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), Bet(Nbet), G(Nmax) ,&
      Bb(Nmax*Nmax), Bs(Nmax*Nmax), C(Nmax,Nmax), Cc(Nmax*Nmax) ,&
      Cs(Nmax*Nmax), Ct(Nmax), W(2*Nmax), Ab(2*Nmax*Nmax)
    INTEGER Idim(Nidim)
    !     .. Local Scalars ..
    REAL alpha, als, beta, bets, err, errmax
    INTEGER i, ia, ib, ict, icu, ik, in, j, jc, jj, k, laa, lbb ,&
      lcc, lda, ldas, ldb, ldbs, ldc, ldcs, n, na, nargs, nc ,&
      nerr, ns, ks, lj, ma, jjab
    LOGICAL ftl, null, reset, tran, upper
    CHARACTER :: uplo, uplos, trans, transs
    CHARACTER(2) :: ichu
    CHARACTER(3) :: icht
    !     .. Local Arrays ..
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SSYR2K
    !     .. Intrinsic Functions ..
    INTRINSIC MAX
    !     .. Data statements ..
    DATA icht/'NTC'/, ichu/'UL'/
    !***FIRST EXECUTABLE STATEMENT  SCHK53
    nargs = 12
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    !
    DO in = 1, Nidim
      n = Idim(in)
      !        Set LDC to 1 more than minimum value if room.
      ldc = n
      IF ( ldc<Nmax ) ldc = ldc + 1
      !        Skip tests if not enough room.
      IF ( ldc<=Nmax ) THEN
        lcc = ldc*n
        null = n<=0
        !
        DO ik = 1, Nidim
          k = Idim(ik)
          !
          DO ict = 1, 3
            trans = icht(ict:ict)
            tran = trans=='T' .OR. trans=='C'
            IF ( tran ) THEN
              ma = k
              na = n
            ELSE
              ma = n
              na = k
            ENDIF
            !              Set LDA to 1 more than minimum value if room.
            lda = ma
            IF ( lda<Nmax ) lda = lda + 1
            !              Skip tests if not enough room.
            IF ( lda<=Nmax ) THEN
              laa = lda*na
              !
              !              Generate the matrix A.
              !
              IF ( tran ) THEN
                CALL SMAKE3('GE',' ',' ',ma,na,Ab,2*Nmax,Aa,lda,reset,ZERO)
              ELSE
                CALL SMAKE3('GE',' ',' ',ma,na,Ab,Nmax,Aa,lda,reset,ZERO)
              ENDIF
              !
              !              Generate the matrix B.
              !
              ldb = lda
              lbb = laa
              IF ( tran ) THEN
                CALL SMAKE3('GE',' ',' ',ma,na,Ab(k+1),2*Nmax,Bb,ldb,reset,&
                  ZERO)
              ELSE
                CALL SMAKE3('GE',' ',' ',ma,na,Ab(k*Nmax+1),Nmax,Bb,ldb,reset,&
                  ZERO)
              ENDIF
              !
              DO icu = 1, 2
                uplo = ichu(icu:icu)
                upper = uplo=='U'
                !
                DO ia = 1, Nalf
                  alpha = Alf(ia)
                  !
                  DO ib = 1, Nbet
                    beta = Bet(ib)
                    !
                    !                       Generate the matrix C.
                    !
                    CALL SMAKE3('SY',uplo,' ',n,n,C,Nmax,Cc,ldc,reset,ZERO)
                    !
                    nc = nc + 1
                    !
                    !                       Save every datum before calling the subroutine.
                    !
                    uplos = uplo
                    transs = trans
                    ns = n
                    ks = k
                    als = alpha
                    DO i = 1, laa
                      As(i) = Aa(i)
                    ENDDO
                    ldas = lda
                    DO i = 1, lbb
                      Bs(i) = Bb(i)
                    ENDDO
                    ldbs = ldb
                    bets = beta
                    DO i = 1, lcc
                      Cs(i) = Cc(i)
                    ENDDO
                    ldcs = ldc
                    !
                    !                       Call the subroutine.
                    !
                    CALL SSYR2K(uplo,trans,n,k,alpha,Aa,lda,Bb,ldb,beta,Cc,&
                      ldc)
                    !
                    !                       Check if error-exit was taken incorrectly.
                    !
                    IF ( NUMXER(nerr)/=0 ) THEN
                      IF ( Kprint>=2 ) WRITE (Nout,FMT=99006)
                      Fatal = .TRUE.
                    ENDIF
                    !
                    !                       See what data changed inside subroutines.
                    !
                    isame(1) = uplos==uplo
                    isame(2) = transs==trans
                    isame(3) = ns==n
                    isame(4) = ks==k
                    isame(5) = als==alpha
                    isame(6) = LSE(As,Aa,laa)
                    isame(7) = ldas==lda
                    isame(8) = LSE(Bs,Bb,lbb)
                    isame(9) = ldbs==ldb
                    isame(10) = bets==beta
                    IF ( null ) THEN
                      isame(11) = LSE(Cs,Cc,lcc)
                    ELSE
                      isame(11) = LSERES('SY',uplo,n,n,Cs,Cc,ldc)
                    ENDIF
                    isame(12) = ldcs==ldc
                    !
                    !                       If data was incorrectly changed, report and
                    !                       return.
                    !
                    DO i = 1, nargs
                      IF ( .NOT.isame(i) ) THEN
                        Fatal = .TRUE.
                        IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                      ENDIF
                    ENDDO
                    !
                    IF ( .NOT.null ) THEN
                      !
                      !                          Check the result column by column.
                      !
                      jjab = 1
                      jc = 1
                      DO j = 1, n
                        IF ( upper ) THEN
                          jj = 1
                          lj = j
                        ELSE
                          jj = j
                          lj = n - j + 1
                        ENDIF
                        IF ( tran ) THEN
                          DO i = 1, k
                            W(i) = Ab((j-1)*2*Nmax+k+i)
                            W(k+i) = Ab((j-1)*2*Nmax+i)
                          ENDDO
                          ftl = .FALSE.
                          CALL SMMCH('T','N',lj,1,2*k,alpha,Ab(jjab),2*Nmax,W,&
                            2*Nmax,beta,C(jj,j),Nmax,Ct,G,Cc(jc),ldc,&
                            Eps,err,ftl,Nout,.TRUE.,Kprint)
                        ELSE
                          DO i = 1, k
                            W(i) = Ab((k+i-1)*Nmax+j)
                            W(k+i) = Ab((i-1)*Nmax+j)
                          ENDDO
                          ftl = .FALSE.
                          CALL SMMCH('N','N',lj,1,2*k,alpha,Ab(jj),Nmax,W,&
                            2*Nmax,beta,C(jj,j),Nmax,Ct,G,Cc(jc),ldc,&
                            Eps,err,ftl,Nout,.TRUE.,Kprint)
                        ENDIF
                        IF ( upper ) THEN
                          jc = jc + ldc
                        ELSE
                          jc = jc + ldc + 1
                          IF ( tran ) jjab = jjab + 2*Nmax
                        ENDIF
                        errmax = MAX(errmax,err)
                        IF ( ftl ) THEN
                          Fatal = .TRUE.
                          IF ( Kprint>=3 ) THEN
                            WRITE (Nout,FMT=99004) Sname
                            WRITE (Nout,FMT=99005) nc, Sname, uplo, trans ,&
                              n, k, alpha, lda, ldb, beta, ldc
                          ENDIF
                        ENDIF
                      ENDDO
                    ENDIF
                    !
                  ENDDO
                  !
                ENDDO
                !
              ENDDO
            ENDIF
            !
          ENDDO
          !
        ENDDO
      ENDIF
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT (1X,I6,': ',A6,'(',2('''',A1,''','),2(I3,','),F4.1,', A,',I3,&
      ', B,',I3,',',F4.1,', C,',I3,')   ',' .')
    99006 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK53.
    !
  END SUBROUTINE SCHK53
  !DECK SCHK62
  SUBROUTINE SCHK62(Sname,Eps,Thresh,Nout,Kprint,Fatal,Nidim,Idim,Nalf,Alf,&
      Ninc,Inc,Nmax,Incmax,A,Aa,As,X,Xx,Xs,Y,Yy,Ys,Yt,G,Z)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHK62
    !***SUBSIDIARY
    !***PURPOSE  Quick check for SSYR2 and SSPR2.
    !***LIBRARY   SLATEC (BLAS)
    !***KEYWORDS  BLAS, QUICK CHECK SERVICE ROUTINE
    !***AUTHOR  Du Croz, J. (NAG)
    !           Hanson, R. J. (SNLA)
    !***DESCRIPTION
    !
    !  Quick check for SSYR2 and SSPR2.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  LSE, LSERES, NUMXER, SMAKE2, SMVCH, SSPR2, SSYR2
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910619  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHK62
    !     .. Parameters ..
    REAL ZERO, HALF, ONE
    PARAMETER (ZERO=0.0,HALF=0.5,ONE=1.0)
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    REAL Eps, Thresh
    INTEGER Incmax, Kprint, Nalf, Nidim, Ninc, Nmax, Nout
    CHARACTER(6) :: Sname
    !     .. Array Arguments ..
    REAL A(Nmax,Nmax), Aa(Nmax*Nmax), Alf(Nalf), As(Nmax*Nmax), G(Nmax) ,&
      X(Nmax), Xs(Nmax*Incmax), Xx(Nmax*Incmax), Y(Nmax) ,&
      Ys(Nmax*Incmax), Yt(Nmax), Yy(Nmax*Incmax), Z(Nmax,2)
    INTEGER Idim(Nidim), Inc(Ninc)
    !     .. Local Scalars ..
    REAL alpha, als, err, errmax, transl
    INTEGER i, ia, ic, in, incx, incxs, incy, incys, ix, iy, j ,&
      ja, jj, laa, lda, ldas, lj, lx, ly, n, nargs, nc, ns ,&
      nerr
    LOGICAL ftl, full, null, packed, reset, upper
    CHARACTER :: uplo, uplos
    CHARACTER(2) :: ich
    !     .. Local Arrays ..
    REAL w(2)
    LOGICAL isame(13)
    !     .. External Functions ..
    INTEGER NUMXER
    EXTERNAL NUMXER
    !     .. External Subroutines ..
    EXTERNAL SSPR2, SSYR2
    !     .. Intrinsic Functions ..
    INTRINSIC ABS, MAX
    !     .. Data statements ..
    DATA ich/'UL'/
    !***FIRST EXECUTABLE STATEMENT  SCHK62
    full = Sname(3:3)=='Y'
    packed = Sname(3:3)=='P'
    !     Define the number of arguments.
    IF ( full ) THEN
      nargs = 9
    ELSEIF ( packed ) THEN
      nargs = 8
    ENDIF
    !
    nc = 0
    reset = .TRUE.
    errmax = ZERO
    !
    DO in = 1, Nidim
      n = Idim(in)
      !        Set LDA to 1 more than minimum value if room.
      lda = n
      IF ( lda<Nmax ) lda = lda + 1
      !        Skip tests if not enough room.
      IF ( lda<=Nmax ) THEN
        IF ( packed ) THEN
          laa = (n*(n+1))/2
        ELSE
          laa = lda*n
        ENDIF
        !
        DO ic = 1, 2
          uplo = ich(ic:ic)
          upper = uplo=='U'
          !
          DO ix = 1, Ninc
            incx = Inc(ix)
            lx = ABS(incx)*n
            !
            !              Generate the vector X.
            !
            transl = HALF
            CALL SMAKE2('GE',' ',' ',1,n,X,1,Xx,ABS(incx),0,n-1,reset,transl)
            IF ( n>1 ) THEN
              X(n/2) = ZERO
              Xx(1+ABS(incx)*(n/2-1)) = ZERO
            ENDIF
            !
            DO iy = 1, Ninc
              incy = Inc(iy)
              ly = ABS(incy)*n
              !
              !                 Generate the vector Y.
              !
              transl = ZERO
              CALL SMAKE2('GE',' ',' ',1,n,Y,1,Yy,ABS(incy),0,n-1,reset,&
                transl)
              IF ( n>1 ) THEN
                Y(n/2) = ZERO
                Yy(1+ABS(incy)*(n/2-1)) = ZERO
              ENDIF
              !
              DO ia = 1, Nalf
                alpha = Alf(ia)
                null = n<=0 .OR. alpha==ZERO
                !
                !                    Generate the matrix A.
                !
                transl = ZERO
                CALL SMAKE2(Sname(2:3),uplo,' ',n,n,A,Nmax,Aa,lda,n-1,n-1,&
                  reset,transl)
                !
                nc = nc + 1
                !
                !                    Save every datum before calling the subroutine.
                !
                uplos = uplo
                ns = n
                als = alpha
                DO i = 1, laa
                  As(i) = Aa(i)
                ENDDO
                ldas = lda
                DO i = 1, lx
                  Xs(i) = Xx(i)
                ENDDO
                incxs = incx
                DO i = 1, ly
                  Ys(i) = Yy(i)
                ENDDO
                incys = incy
                !
                !                    Call the subroutine.
                !
                IF ( full ) THEN
                  CALL SSYR2(uplo,n,alpha,Xx,incx,Yy,incy,Aa,lda)
                ELSEIF ( packed ) THEN
                  CALL SSPR2(uplo,n,alpha,Xx,incx,Yy,incy,Aa)
                ENDIF
                !
                !                    Check if error-exit was taken incorrectly.
                !
                IF ( NUMXER(nerr)/=0 ) THEN
                  IF ( Kprint>=2 ) WRITE (Nout,FMT=99008)
                  Fatal = .TRUE.
                ENDIF
                !
                !                    See what data changed inside subroutines.
                !
                isame(1) = uplo==uplos
                isame(2) = ns==n
                isame(3) = als==alpha
                isame(4) = LSE(Xs,Xx,lx)
                isame(5) = incxs==incx
                isame(6) = LSE(Ys,Yy,ly)
                isame(7) = incys==incy
                IF ( null ) THEN
                  isame(8) = LSE(As,Aa,laa)
                ELSE
                  isame(8) = LSERES(Sname(2:3),uplo,n,n,As,Aa,lda)
                ENDIF
                IF ( .NOT.packed ) isame(9) = ldas==lda
                !
                !                    If data was incorrectly changed, report and return.
                !
                DO i = 1, nargs
                  IF ( .NOT.isame(i) ) THEN
                    Fatal = .TRUE.
                    IF ( Kprint>=2 ) WRITE (Nout,FMT=99002) i
                  ENDIF
                ENDDO
                !
                ftl = .FALSE.
                IF ( .NOT.null ) THEN
                  !
                  !                       Check the result column by column.
                  !
                  IF ( incx>0 ) THEN
                    DO i = 1, n
                      Z(i,1) = X(i)
                    ENDDO
                  ELSE
                    DO i = 1, n
                      Z(i,1) = X(n-i+1)
                    ENDDO
                  ENDIF
                  IF ( incy>0 ) THEN
                    DO i = 1, n
                      Z(i,2) = Y(i)
                    ENDDO
                  ELSE
                    DO i = 1, n
                      Z(i,2) = Y(n-i+1)
                    ENDDO
                  ENDIF
                  ja = 1
                  DO j = 1, n
                    w(1) = Z(j,2)
                    w(2) = Z(j,1)
                    IF ( upper ) THEN
                      jj = 1
                      lj = j
                    ELSE
                      jj = j
                      lj = n - j + 1
                    ENDIF
                    CALL SMVCH('N',lj,2,alpha,Z(jj,1),Nmax,w,1,ONE,A(jj,j),1,&
                      Yt,G,Aa(ja),Eps,err,ftl,Nout,.TRUE.,Kprint)
                    IF ( .NOT.(full) ) THEN
                      ja = ja + lj
                    ELSEIF ( upper ) THEN
                      ja = ja + lda
                    ELSE
                      ja = ja + lda + 1
                    ENDIF
                    errmax = MAX(errmax,err)
                    IF ( ftl ) THEN
                      Fatal = .TRUE.
                      IF ( Kprint>=3 ) THEN
                        WRITE (Nout,FMT=99005) j
                        WRITE (Nout,FMT=99004) Sname
                        IF ( full ) THEN
                          WRITE (Nout,FMT=99007) nc, Sname, uplo, n ,&
                            alpha, incx, incy, lda
                        ELSEIF ( packed ) THEN
                          WRITE (Nout,FMT=99006) nc, Sname, uplo, n ,&
                            alpha, incx, incy
                        ENDIF
                      ENDIF
                    ENDIF
                  ENDDO
                ENDIF
                !
              ENDDO
              !
            ENDDO
            !
          ENDDO
          !
        ENDDO
      ENDIF
      !
    ENDDO
    !
    !     Report result.
    !
    IF ( .NOT.(Fatal) ) THEN
      IF ( Kprint>=3 ) THEN
        IF ( errmax<Thresh ) THEN
          WRITE (Nout,FMT=99001) Sname, nc
        ELSE
          WRITE (Nout,FMT=99003) Sname, nc, errmax
        ENDIF
      ENDIF
    ENDIF
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE COMPUTATIONAL TESTS (',I6,' CALL','S)')
    99002 FORMAT (' ******* FATAL ERROR - PARAMETER NUMBER ',I2,' WAS CH',&
      'ANGED INCORRECTLY *******')
    99003 FORMAT (' ',A6,' COMPLETED THE COMPUTATIONAL TESTS (',I6,' C','ALLS)',&
      /' ******* BUT WITH MAXIMUM TEST RATIO',F8.2,' - SUSPECT *******')
    99004 FORMAT (' ******* ',A6,' FAILED ON CALL NUMBER:')
    99005 FORMAT ('      THESE ARE THE RESULTS FOR COLUMN ',I3)
    99006 FORMAT (1X,I6,': ',A6,'(''',A1,''',',I3,',',F4.1,', X,',I2,', Y,',I2,&
      ', AP)                     .')
    99007 FORMAT (1X,I6,': ',A6,'(''',A1,''',',I3,',',F4.1,', X,',I2,', Y,',I2,&
      ', A,',I3,')                  .')
    99008 FORMAT (' ******* FATAL ERROR - ERROR-EXIT TAKEN ON VALID CALL *',&
      '******')
    !
    !     End of SCHK62.
    !
  END SUBROUTINE SCHK62
  !DECK SCHKE2
  SUBROUTINE SCHKE2(Isnum,Srnamt,Nout,Kprint,Fatal)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHKE2
    !***SUBSIDIARY
    !***PURPOSE  Test the error exits from the Level 2 Blas.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Du Croz, J. J., (NAG)
    !           Hanson, R. J., (SNLA)
    !***DESCRIPTION
    !
    !  Tests the error exits from the Level 2 Blas.
    !  ALPHA, BETA, A, X and Y should not need to be defined.
    !
    !  Auxiliary routine for test program for Level 2 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  CHKXER, SGBMV, SGEMV, SGER, SSBMV, SSPMV, SSPR,
    !                    SSPR2, SSYMV, SSYR, SSYR2, STBMV, STBSV, STPMV,
    !                    STPSV, STRMV, STRSV, XERCLR, XERDMP, XGETF, XSETF
    !***REVISION HISTORY  (YYMMDD)
    !   870810  DATE WRITTEN
    !   910620  Modified to meet SLATEC code and prologue standards.  (BKS)
    !***END PROLOGUE  SCHKE2
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    INTEGER Isnum, Kprint, Nout
    CHARACTER(6) :: Srnamt
    !     .. Scalars in Common ..
    INTEGER infot
    !     .. Local Scalars ..
    REAL alpha, beta
    INTEGER kontrl
    !     .. Local Arrays ..
    REAL a(1,1), x(1), y(1)
    !     .. External Subroutines ..
    EXTERNAL CHKXER, SGBMV, SGEMV, SGER, SSBMV, SSPMV, SSPR, SSPR2 ,&
      SSYMV, SSYR, SSYR2, STBMV, STBSV, STPMV, STPSV, STRMV ,&
      STRSV
    !***FIRST EXECUTABLE STATEMENT  SCHKE2
    CALL XGETF(kontrl)
    IF ( Kprint<=2 ) THEN
      CALL XSETF(0)
    ELSE
      CALL XSETF(1)
    ENDIF
    SELECT CASE (Isnum)
      CASE (2)
        infot = 1
        CALL XERCLR
        CALL SGBMV('/',0,0,0,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SGBMV('N',-1,0,0,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SGBMV('N',0,-1,0,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SGBMV('N',0,0,-1,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SGBMV('N',2,0,0,-1,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL SGBMV('N',0,0,1,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SGBMV('N',0,0,0,0,alpha,a,1,x,0,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 13
        CALL XERCLR
        CALL SGBMV('N',0,0,0,0,alpha,a,1,x,1,beta,y,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (3)
        infot = 1
        CALL XERCLR
        CALL SSYMV('/',0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSYMV('U',-1,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SSYMV('U',2,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYMV('U',0,alpha,a,1,x,0,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SSYMV('U',0,alpha,a,1,x,1,beta,y,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (4)
        infot = 1
        CALL XERCLR
        CALL SSBMV('/',0,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSBMV('U',-1,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSBMV('U',0,-1,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL SSBMV('U',0,1,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL SSBMV('U',0,0,alpha,a,1,x,0,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL SSBMV('U',0,0,alpha,a,1,x,1,beta,y,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (5)
        infot = 1
        CALL XERCLR
        CALL SSPMV('/',0,alpha,a,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSPMV('U',-1,alpha,a,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL SSPMV('U',0,alpha,a,x,0,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSPMV('U',0,alpha,a,x,1,beta,y,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (6)
        infot = 1
        CALL XERCLR
        CALL STRMV('/','N','N',0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL STRMV('U','/','N',0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL STRMV('U','N','/',0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL STRMV('U','N','N',-1,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMV('U','N','N',2,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL STRMV('U','N','N',0,a,1,x,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (7)
        infot = 1
        CALL XERCLR
        CALL STBMV('/','N','N',0,0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL STBMV('U','/','N',0,0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL STBMV('U','N','/',0,0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL STBMV('U','N','N',-1,0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STBMV('U','N','N',0,-1,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL STBMV('U','N','N',0,1,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STBMV('U','N','N',0,0,a,1,x,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (8)
        infot = 1
        CALL XERCLR
        CALL STPMV('/','N','N',0,a,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL STPMV('U','/','N',0,a,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL STPMV('U','N','/',0,a,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL STPMV('U','N','N',-1,a,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL STPMV('U','N','N',0,a,x,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (9)
        infot = 1
        CALL XERCLR
        CALL STRSV('/','N','N',0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL STRSV('U','/','N',0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL STRSV('U','N','/',0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL STRSV('U','N','N',-1,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSV('U','N','N',2,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL STRSV('U','N','N',0,a,1,x,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (10)
        infot = 1
        CALL XERCLR
        CALL STBSV('/','N','N',0,0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL STBSV('U','/','N',0,0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL STBSV('U','N','/',0,0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL STBSV('U','N','N',-1,0,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STBSV('U','N','N',0,-1,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL STBSV('U','N','N',0,1,a,1,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STBSV('U','N','N',0,0,a,1,x,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (11)
        infot = 1
        CALL XERCLR
        CALL STPSV('/','N','N',0,a,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL STPSV('U','/','N',0,a,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL STPSV('U','N','/',0,a,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL STPSV('U','N','N',-1,a,x,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL STPSV('U','N','N',0,a,x,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (12)
        infot = 1
        CALL XERCLR
        CALL SGER(-1,0,alpha,x,1,y,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SGER(0,-1,alpha,x,1,y,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SGER(0,0,alpha,x,0,y,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SGER(0,0,alpha,x,1,y,0,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SGER(2,0,alpha,x,1,y,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (13)
        infot = 1
        CALL XERCLR
        CALL SSYR('/',0,alpha,x,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSYR('U',-1,alpha,x,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SSYR('U',0,alpha,x,0,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYR('U',2,alpha,x,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (14)
        infot = 1
        CALL XERCLR
        CALL SSPR('/',0,alpha,x,1,a)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSPR('U',-1,alpha,x,1,a)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SSPR('U',0,alpha,x,0,a)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (15)
        infot = 1
        CALL XERCLR
        CALL SSYR2('/',0,alpha,x,1,y,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSYR2('U',-1,alpha,x,1,y,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SSYR2('U',0,alpha,x,0,y,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYR2('U',0,alpha,x,1,y,0,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYR2('U',2,alpha,x,1,y,1,a,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (16)
        infot = 1
        CALL XERCLR
        CALL SSPR2('/',0,alpha,x,1,y,1,a)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSPR2('U',-1,alpha,x,1,y,1,a)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SSPR2('U',0,alpha,x,0,y,1,a)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSPR2('U',0,alpha,x,1,y,0,a)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE DEFAULT
        infot = 1
        CALL XERCLR
        CALL SGEMV('/',0,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SGEMV('N',-1,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SGEMV('N',0,-1,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL SGEMV('N',2,0,alpha,a,1,x,1,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL SGEMV('N',0,0,alpha,a,1,x,0,beta,y,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL SGEMV('N',0,0,alpha,a,1,x,1,beta,y,0)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
    END SELECT
    !
    IF ( Kprint>=2 ) THEN
      CALL XERDMP
      IF ( .NOT.Fatal ) THEN
        WRITE (Nout,FMT=99001) Srnamt
      ELSE
        WRITE (Nout,FMT=99002) Srnamt
      ENDIF
    ENDIF
    CALL XSETF(kontrl)
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE TESTS OF ERROR-EXITS')
    99002 FORMAT (' ******* ',A6,' FAILED THE TESTS OF ERROR-EXITS *****','**')
    !
    !     End of SCHKE2.
    !
  END SUBROUTINE SCHKE2
  !DECK SCHKE3
  SUBROUTINE SCHKE3(Isnum,Srnamt,Nout,Kprint,Fatal)
    IMPLICIT NONE
    !***BEGIN PROLOGUE  SCHKE3
    !***SUBSIDIARY
    !***PURPOSE  Test the error exits from the Level 3 Blas.
    !***LIBRARY   SLATEC (BLAS)
    !***AUTHOR  Dongarra, J. J., (ANL)
    !           Duff, I., (AERE)
    !           Du Croz, J., (NAG)
    !           Hammarling, S., (NAG)
    !***DESCRIPTION
    !
    !  Tests the error exits from the Level 3 Blas.
    !  ALPHA, BETA, A, X and Y should not need to be defined.
    !
    !  Auxiliary routine for test program for Level 3 Blas.
    !***REFERENCES  (NONE)
    !***ROUTINES CALLED  CHKXER, SGEMM, SSYMM, SSYR2K, SSYRK, STRMM, STRSM,
    !                    XERCLR, XERDMP, XGETF, XSETF
    !***REVISION HISTORY  (YYMMDD)
    !   890208  DATE WRITTEN
    !   910620  Modified to meet SLATEC code and prologue standards.  (BKS)
    !   930701  Name changed from SCHKE5 to SCHKE3.  (BKS)
    !***END PROLOGUE  SCHKE3
    !     .. Scalar Arguments ..
    LOGICAL Fatal
    INTEGER Isnum, Kprint, Nout
    CHARACTER(6) :: Srnamt
    !     .. Scalars in Common ..
    INTEGER infot
    !     .. Local Scalars ..
    REAL alpha, beta
    INTEGER kontrl
    !     .. Local Arrays ..
    REAL a(1,1), b(1,1), c(1,1)
    !     .. External Subroutines ..
    EXTERNAL CHKXER, SGEMM, SSYMM, SSYR2K, SSYRK, STRMM, STRSM
    !***FIRST EXECUTABLE STATEMENT  SCHKE3
    CALL XGETF(kontrl)
    IF ( Kprint<=2 ) THEN
      CALL XSETF(0)
    ELSE
      CALL XSETF(1)
    ENDIF
    SELECT CASE (Isnum)
      CASE (2)
        infot = 1
        CALL XERCLR
        CALL SSYMM('/','U',0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSYMM('L','/',0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYMM('L','U',-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYMM('R','U',-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYMM('L','L',-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYMM('R','L',-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYMM('L','U',0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYMM('R','U',0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYMM('L','L',0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYMM('R','L',0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYMM('L','U',2,0,alpha,a,1,b,2,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYMM('R','U',0,2,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYMM('L','L',2,0,alpha,a,1,b,2,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYMM('R','L',0,2,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYMM('L','U',2,0,alpha,a,2,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYMM('R','U',2,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYMM('L','L',2,0,alpha,a,2,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYMM('R','L',2,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 12
        CALL XERCLR
        CALL SSYMM('L','U',2,0,alpha,a,2,b,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 12
        CALL XERCLR
        CALL SSYMM('R','U',2,0,alpha,a,1,b,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 12
        CALL XERCLR
        CALL SSYMM('L','L',2,0,alpha,a,2,b,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 12
        CALL XERCLR
        CALL SSYMM('R','L',2,0,alpha,a,1,b,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (3)
        infot = 1
        CALL XERCLR
        CALL STRMM('/','U','N','N',0,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL STRMM('L','/','N','N',0,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL STRMM('L','U','/','N',0,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL STRMM('L','U','N','/',0,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRMM('L','U','N','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRMM('L','U','T','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRMM('R','U','N','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRMM('R','U','T','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRMM('L','L','N','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRMM('L','L','T','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRMM('R','L','N','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRMM('R','L','T','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMM('L','U','N','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMM('L','U','T','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMM('R','U','N','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMM('R','U','T','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMM('L','L','N','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMM('L','L','T','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMM('R','L','N','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRMM('R','L','T','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRMM('L','U','N','N',2,0,alpha,a,1,b,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRMM('L','U','T','N',2,0,alpha,a,1,b,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRMM('R','U','N','N',0,2,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRMM('R','U','T','N',0,2,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRMM('L','L','N','N',2,0,alpha,a,1,b,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRMM('L','L','T','N',2,0,alpha,a,1,b,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRMM('R','L','N','N',0,2,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRMM('R','L','T','N',0,2,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRMM('L','U','N','N',2,0,alpha,a,2,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRMM('L','U','T','N',2,0,alpha,a,2,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRMM('R','U','N','N',2,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRMM('R','U','T','N',2,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRMM('L','L','N','N',2,0,alpha,a,2,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRMM('L','L','T','N',2,0,alpha,a,2,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRMM('R','L','N','N',2,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRMM('R','L','T','N',2,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (4)
        infot = 1
        CALL XERCLR
        CALL STRSM('/','U','N','N',0,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL STRSM('L','/','N','N',0,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL STRSM('L','U','/','N',0,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL STRSM('L','U','N','/',0,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRSM('L','U','N','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRSM('L','U','T','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRSM('R','U','N','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRSM('R','U','T','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRSM('L','L','N','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRSM('L','L','T','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRSM('R','L','N','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL STRSM('R','L','T','N',-1,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSM('L','U','N','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSM('L','U','T','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSM('R','U','N','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSM('R','U','T','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSM('L','L','N','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSM('L','L','T','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSM('R','L','N','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 6
        CALL XERCLR
        CALL STRSM('R','L','T','N',0,-1,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRSM('L','U','N','N',2,0,alpha,a,1,b,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRSM('L','U','T','N',2,0,alpha,a,1,b,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRSM('R','U','N','N',0,2,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRSM('R','U','T','N',0,2,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRSM('L','L','N','N',2,0,alpha,a,1,b,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRSM('L','L','T','N',2,0,alpha,a,1,b,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRSM('R','L','N','N',0,2,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL STRSM('R','L','T','N',0,2,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRSM('L','U','N','N',2,0,alpha,a,2,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRSM('L','U','T','N',2,0,alpha,a,2,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRSM('R','U','N','N',2,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRSM('R','U','T','N',2,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRSM('L','L','N','N',2,0,alpha,a,2,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRSM('L','L','T','N',2,0,alpha,a,2,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRSM('R','L','N','N',2,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 11
        CALL XERCLR
        CALL STRSM('R','L','T','N',2,0,alpha,a,1,b,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (5)
        infot = 1
        CALL XERCLR
        CALL SSYRK('/','N',0,0,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSYRK('U','/',0,0,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYRK('U','N',-1,0,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYRK('U','T',-1,0,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYRK('L','N',-1,0,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYRK('L','T',-1,0,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYRK('U','N',0,-1,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYRK('U','T',0,-1,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYRK('L','N',0,-1,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYRK('L','T',0,-1,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYRK('U','N',2,0,alpha,a,1,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYRK('U','T',0,2,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYRK('L','N',2,0,alpha,a,1,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYRK('L','T',0,2,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SSYRK('U','N',2,0,alpha,a,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SSYRK('U','T',2,0,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SSYRK('L','N',2,0,alpha,a,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SSYRK('L','T',2,0,alpha,a,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE (6)
        infot = 1
        CALL XERCLR
        CALL SSYR2K('/','N',0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SSYR2K('U','/',0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYR2K('U','N',-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYR2K('U','T',-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYR2K('L','N',-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SSYR2K('L','T',-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYR2K('U','N',0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYR2K('U','T',0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYR2K('L','N',0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SSYR2K('L','T',0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYR2K('U','N',2,0,alpha,a,1,b,1,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYR2K('U','T',0,2,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYR2K('L','N',2,0,alpha,a,1,b,1,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 7
        CALL XERCLR
        CALL SSYR2K('L','T',0,2,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYR2K('U','N',2,0,alpha,a,2,b,1,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYR2K('U','T',0,2,alpha,a,2,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYR2K('L','N',2,0,alpha,a,2,b,1,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 9
        CALL XERCLR
        CALL SSYR2K('L','T',0,2,alpha,a,2,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 12
        CALL XERCLR
        CALL SSYR2K('U','N',2,0,alpha,a,2,b,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 12
        CALL XERCLR
        CALL SSYR2K('U','T',2,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 12
        CALL XERCLR
        CALL SSYR2K('L','N',2,0,alpha,a,2,b,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 12
        CALL XERCLR
        CALL SSYR2K('L','T',2,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
      CASE DEFAULT
        infot = 1
        CALL XERCLR
        CALL SGEMM('/','N',0,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 1
        CALL XERCLR
        CALL SGEMM('/','T',0,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SGEMM('N','/',0,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 2
        CALL XERCLR
        CALL SGEMM('T','/',0,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SGEMM('N','N',-1,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SGEMM('N','T',-1,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SGEMM('T','N',-1,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 3
        CALL XERCLR
        CALL SGEMM('T','T',-1,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SGEMM('N','N',0,-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SGEMM('N','T',0,-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SGEMM('T','N',0,-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 4
        CALL XERCLR
        CALL SGEMM('T','T',0,-1,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SGEMM('N','N',0,0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SGEMM('N','T',0,0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SGEMM('T','N',0,0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 5
        CALL XERCLR
        CALL SGEMM('T','T',0,0,-1,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL SGEMM('N','N',2,0,0,alpha,a,1,b,1,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL SGEMM('N','T',2,0,0,alpha,a,1,b,1,beta,c,2)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL SGEMM('T','N',0,0,2,alpha,a,1,b,2,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 8
        CALL XERCLR
        CALL SGEMM('T','T',0,0,2,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SGEMM('N','N',0,0,2,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SGEMM('T','N',0,0,2,alpha,a,2,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SGEMM('N','T',0,2,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 10
        CALL XERCLR
        CALL SGEMM('T','T',0,2,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 13
        CALL XERCLR
        CALL SGEMM('N','N',2,0,0,alpha,a,2,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 13
        CALL XERCLR
        CALL SGEMM('N','T',2,0,0,alpha,a,2,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 13
        CALL XERCLR
        CALL SGEMM('T','N',2,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
        infot = 13
        CALL XERCLR
        CALL SGEMM('T','T',2,0,0,alpha,a,1,b,1,beta,c,1)
        CALL CHKXER(Srnamt,infot,Nout,Fatal,Kprint)
    END SELECT
    !
    IF ( Kprint>=2 ) THEN
      CALL XERDMP
      IF ( .NOT.Fatal ) THEN
        WRITE (Nout,FMT=99001) Srnamt
      ELSE
        WRITE (Nout,FMT=99002) Srnamt
      ENDIF
    ENDIF
    CALL XSETF(kontrl)
    RETURN
    !
    99001 FORMAT (' ',A6,' PASSED THE TESTS OF ERROR-EXITS')
    99002 FORMAT (' ******* ',A6,' FAILED THE TESTS OF ERROR-EXITS *****','**')
    !
    !     End of SCHKE3.
    !
  END SUBROUTINE SCHKE3
END MODULE TEST18_MOD
!DECK TEST18
PROGRAM TEST18
  USE TEST18_MOD
  IMPLICIT NONE
  !***BEGIN PROLOGUE  TEST18
  !***PURPOSE  Driver for testing SLATEC subprograms
  !***LIBRARY   SLATEC
  !***CATEGORY  D1B
  !***KEYWORDS  QUICK CHECK DRIVER
  !***TYPE      SINGLE PRECISION (TEST18-S, TEST19-D, TEST20-C)
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
  !        single precision Levels 2 and 3 BLAS routines
  !
  !***REFERENCES  Kirby W. Fong,  Thomas H. Jefferson, Tokihiko Suyehiro
  !                 and Lee Walton, Guide to the SLATEC Common Mathema-
  !                 tical Library, April 10, 1990.
  !***ROUTINES CALLED  I1MACH, SBLAT2, SBLAT3, XERMAX, XSETF, XSETUN
  !***REVISION HISTORY  (YYMMDD)
  !   920601  DATE WRITTEN
  !***END PROLOGUE  TEST18
  INTEGER ipass, kprint, lin, lun, nfail
  !     .. External Functions ..
  INTEGER I1MACH
  EXTERNAL I1MACH
  !***FIRST EXECUTABLE STATEMENT  TEST18
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
  !     Test single precision Level 2 BLAS routines
  !
  CALL SBLAT2(lun,kprint,ipass)
  IF ( ipass==0 ) nfail = nfail + 1
  !
  !     Test single precision Level 3 BLAS routines
  !
  CALL SBLAT3(lun,kprint,ipass)
  IF ( ipass==0 ) nfail = nfail + 1
  !
  !     Write PASS or FAIL message
  !
  IF ( nfail==0 ) THEN
    WRITE (lun,99001)
    99001 FORMAT (/' --------------TEST18 PASSED ALL TESTS----------------')
  ELSE
    WRITE (lun,99002) nfail
    99002 FORMAT (/' ************* WARNING -- ',I5,&
      ' TEST(S) FAILED IN PROGRAM TEST18 *************')
  ENDIF
  STOP
END PROGRAM TEST18