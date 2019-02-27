!DECK CHPDI
SUBROUTINE CHPDI(Ap,N,Kpvt,Det,Inert,Work,Job)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  CHPDI
  !***PURPOSE  Compute the determinant, inertia and inverse of a complex
  !            Hermitian matrix stored in packed form using the factors
  !            obtained from CHPFA.
  !***LIBRARY   SLATEC (LINPACK)
  !***CATEGORY  D2D1A, D3D1A
  !***TYPE      COMPLEX (SSPDI-S, DSPDI-D, CHPDI-C, DSPDI-C)
  !***KEYWORDS  DETERMINANT, HERMITIAN, INVERSE, LINEAR ALGEBRA, LINPACK,
  !             MATRIX, PACKED
  !***AUTHOR  Bunch, J., (UCSD)
  !***DESCRIPTION
  !
  !     CHPDI computes the determinant, inertia and inverse
  !     of a complex Hermitian matrix using the factors from CHPFA,
  !     where the matrix is stored in packed form.
  !
  !     On Entry
  !
  !        AP      COMPLEX (N*(N+1)/2)
  !                the output from CHPFA.
  !
  !        N       INTEGER
  !                the order of the matrix A.
  !
  !        KVPT    INTEGER(N)
  !                the pivot vector from CHPFA.
  !
  !        WORK    COMPLEX(N)
  !                work vector.  Contents ignored.
  !
  !        JOB     INTEGER
  !                JOB has the decimal expansion  ABC  where
  !                   if  C .NE. 0, the inverse is computed,
  !                   if  B .NE. 0, the determinant is computed,
  !                   if  A .NE. 0, the inertia is computed.
  !
  !                For example, JOB = 111  gives all three.
  !
  !     On Return
  !
  !        Variables not requested by JOB are not used.
  !
  !        AP     contains the upper triangle of the inverse of
  !               the original matrix, stored in packed form.
  !               The columns of the upper triangle are stored
  !               sequentially in a one-dimensional array.
  !
  !        DET    REAL(2)
  !               determinant of original matrix.
  !               Determinant = DET(1) * 10.0**DET(2)
  !               with 1.0 .LE. ABS(DET(1)) .LT. 10.0
  !               or DET(1) = 0.0.
  !
  !        INERT  INTEGER(3)
  !               the inertia of the original matrix.
  !               INERT(1)  =  number of positive eigenvalues.
  !               INERT(2)  =  number of negative eigenvalues.
  !               INERT(3)  =  number of zero eigenvalues.
  !
  !     Error Condition
  !
  !        A division by zero will occur if the inverse is requested
  !        and  CHPCO  has set RCOND .EQ. 0.0
  !        or  CHPFA  has set  INFO .NE. 0 .
  !
  !***REFERENCES  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***ROUTINES CALLED  CAXPY, CCOPY, CDOTC, CSWAP
  !***REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891107  Modified routine equivalence list.  (WRB)
  !   891107  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  !***END PROLOGUE  CHPDI
  INTEGER N, Job
  COMPLEX Ap(*), Work(*)
  REAL Det(2)
  INTEGER Kpvt(*), Inert(3)
  !
  COMPLEX akkp1, CDOTC, temp
  REAL ten, d, t, ak, akp1
  INTEGER ij, ik, ikp1, iks, j, jb, jk, jkp1
  INTEGER k, kk, kkp1, km1, ks, ksj, kskp1, kstep
  LOGICAL noinv, nodet, noert
  !***FIRST EXECUTABLE STATEMENT  CHPDI
  noinv = MOD(Job,10)==0
  nodet = MOD(Job,100)/10==0
  noert = MOD(Job,1000)/100==0
  !
  IF ( .NOT.(nodet.AND.noert) ) THEN
    IF ( .NOT.(noert) ) THEN
      Inert(1) = 0
      Inert(2) = 0
      Inert(3) = 0
    ENDIF
    IF ( .NOT.(nodet) ) THEN
      Det(1) = 1.0E0
      Det(2) = 0.0E0
      ten = 10.0E0
    ENDIF
    t = 0.0E0
    ik = 0
    DO k = 1, N
      kk = ik + k
      d = REAL(Ap(kk))
      !
      !           CHECK IF 1 BY 1
      !
      IF ( Kpvt(k)<=0 ) THEN
        !
        !              2 BY 2 BLOCK
        !              USE DET (D  S)  =  (D/T * C - T) * T ,  T = ABS(S)
        !                      (S  C)
        !              TO AVOID UNDERFLOW/OVERFLOW TROUBLES.
        !              TAKE TWO PASSES THROUGH SCALING.  USE  T  FOR FLAG.
        !
        IF ( t/=0.0E0 ) THEN
          d = t
          t = 0.0E0
        ELSE
          ikp1 = ik + k
          kkp1 = ikp1 + k
          t = ABS(Ap(kkp1))
          d = (d/t)*REAL(Ap(kkp1+1)) - t
        ENDIF
      ENDIF
      !
      IF ( .NOT.(noert) ) THEN
        IF ( d>0.0E0 ) Inert(1) = Inert(1) + 1
        IF ( d<0.0E0 ) Inert(2) = Inert(2) + 1
        IF ( d==0.0E0 ) Inert(3) = Inert(3) + 1
      ENDIF
      !
      IF ( .NOT.(nodet) ) THEN
        Det(1) = d*Det(1)
        IF ( Det(1)/=0.0E0 ) THEN
          DO WHILE ( ABS(Det(1))<1.0E0 )
            Det(1) = ten*Det(1)
            Det(2) = Det(2) - 1.0E0
          ENDDO
          DO WHILE ( ABS(Det(1))>=ten )
            Det(1) = Det(1)/ten
            Det(2) = Det(2) + 1.0E0
          ENDDO
        ENDIF
      ENDIF
      ik = ik + k
    ENDDO
  ENDIF
  !
  !     COMPUTE INVERSE(A)
  !
  IF ( .NOT.(noinv) ) THEN
    k = 1
    ik = 0
    DO WHILE ( k<=N )
      km1 = k - 1
      kk = ik + k
      ikp1 = ik + k
      kkp1 = ikp1 + k
      IF ( Kpvt(k)<0 ) THEN
        !
        !              2 BY 2
        !
        t = ABS(Ap(kkp1))
        ak = REAL(Ap(kk))/t
        akp1 = REAL(Ap(kkp1+1))/t
        akkp1 = Ap(kkp1)/t
        d = t*(ak*akp1-1.0E0)
        Ap(kk) = CMPLX(akp1/d,0.0E0)
        Ap(kkp1+1) = CMPLX(ak/d,0.0E0)
        Ap(kkp1) = -akkp1/d
        IF ( km1>=1 ) THEN
          CALL CCOPY(km1,Ap(ikp1+1),1,Work,1)
          ij = 0
          DO j = 1, km1
            jkp1 = ikp1 + j
            Ap(jkp1) = CDOTC(j,Ap(ij+1),1,Work,1)
            CALL CAXPY(j-1,Work(j),Ap(ij+1),1,Ap(ikp1+1),1)
            ij = ij + j
          ENDDO
          Ap(kkp1+1) = Ap(kkp1+1)&
            + CMPLX(REAL(CDOTC(km1,Work,1,Ap(ikp1+1),1)),0.0E0)
          Ap(kkp1) = Ap(kkp1) + CDOTC(km1,Ap(ik+1),1,Ap(ikp1+1),1)
          CALL CCOPY(km1,Ap(ik+1),1,Work,1)
          ij = 0
          DO j = 1, km1
            jk = ik + j
            Ap(jk) = CDOTC(j,Ap(ij+1),1,Work,1)
            CALL CAXPY(j-1,Work(j),Ap(ij+1),1,Ap(ik+1),1)
            ij = ij + j
          ENDDO
          Ap(kk) = Ap(kk) + CMPLX(REAL(CDOTC(km1,Work,1,Ap(ik+1),1)),0.0E0)
        ENDIF
        kstep = 2
      ELSE
        !
        !              1 BY 1
        !
        Ap(kk) = CMPLX(1.0E0/REAL(Ap(kk)),0.0E0)
        IF ( km1>=1 ) THEN
          CALL CCOPY(km1,Ap(ik+1),1,Work,1)
          ij = 0
          DO j = 1, km1
            jk = ik + j
            Ap(jk) = CDOTC(j,Ap(ij+1),1,Work,1)
            CALL CAXPY(j-1,Work(j),Ap(ij+1),1,Ap(ik+1),1)
            ij = ij + j
          ENDDO
          Ap(kk) = Ap(kk) + CMPLX(REAL(CDOTC(km1,Work,1,Ap(ik+1),1)),0.0E0)
        ENDIF
        kstep = 1
      ENDIF
      !
      !           SWAP
      !
      ks = ABS(Kpvt(k))
      IF ( ks/=k ) THEN
        iks = (ks*(ks-1))/2
        CALL CSWAP(ks,Ap(iks+1),1,Ap(ik+1),1)
        ksj = ik + ks
        DO jb = ks, k
          j = k + ks - jb
          jk = ik + j
          temp = CONJG(Ap(jk))
          Ap(jk) = CONJG(Ap(ksj))
          Ap(ksj) = temp
          ksj = ksj - (j-1)
        ENDDO
        IF ( kstep/=1 ) THEN
          kskp1 = ikp1 + ks
          temp = Ap(kskp1)
          Ap(kskp1) = Ap(kkp1)
          Ap(kkp1) = temp
        ENDIF
      ENDIF
      ik = ik + k
      IF ( kstep==2 ) ik = ik + k + 1
      k = k + kstep
    ENDDO
  ENDIF
END SUBROUTINE CHPDI