!** CSPCO
SUBROUTINE CSPCO(Ap,N,Kpvt,Rcond,Z)
  IMPLICIT NONE
  !>
  !***
  !  Factor a complex symmetric matrix stored in packed form
  !            by elimination with symmetric pivoting and estimate the
  !            condition number of the matrix.
  !***
  ! **Library:**   SLATEC (LINPACK)
  !***
  ! **Category:**  D2C1
  !***
  ! **Type:**      COMPLEX (SSPCO-S, DSPCO-D, CHPCO-C, CSPCO-C)
  !***
  ! **Keywords:**  CONDITION NUMBER, LINEAR ALGEBRA, LINPACK,
  !             MATRIX FACTORIZATION, PACKED, SYMMETRIC
  !***
  ! **Author:**  Moler, C. B., (U. of New Mexico)
  !***
  ! **Description:**
  !
  !     CSPCO factors a complex symmetric matrix stored in packed
  !     form by elimination with symmetric pivoting and estimates
  !     the condition of the matrix.
  !
  !     If  RCOND  is not needed, CSPFA is slightly faster.
  !     To solve  A*X = B, follow CSPCO by CSPSL.
  !     To compute  INVERSE(A)*C, follow CSPCO by CSPSL.
  !     To compute  INVERSE(A), follow CSPCO by CSPDI.
  !     To compute  DETERMINANT(A), follow CSPCO by CSPDI.
  !
  !     On Entry
  !
  !        AP      COMPLEX (N*(N+1)/2)
  !                the packed form of a symmetric matrix  A .  The
  !                columns of the upper triangle are stored sequentially
  !                in a one-dimensional array of length  N*(N+1)/2 .
  !                See comments below for details.
  !
  !        N       INTEGER
  !                the order of the matrix  A .
  !
  !     On Return
  !
  !        AP      a block diagonal matrix and the multipliers which
  !                were used to obtain it stored in packed form.
  !                The factorization can be written  A = U*D*TRANS(U)
  !                where  U  is a product of permutation and unit
  !                upper triangular matrices, TRANS(U) is the
  !                transpose of  U, and  D  is block diagonal
  !                with 1 by 1 and 2 by 2 blocks.
  !
  !        KVPT    INTEGER(N)
  !                an integer vector of pivot indices.
  !
  !        RCOND   REAL
  !                an estimate of the reciprocal condition of  A .
  !                For the system  A*X = B, relative perturbations
  !                in  A  and  B  of size  EPSILON  may cause
  !                relative perturbations in  X  of size  EPSILON/RCOND .
  !                If  RCOND  is so small that the logical expression
  !                           1.0 + RCOND .EQ. 1.0
  !                is true, then  A  may be singular to working
  !                precision.  In particular,  RCOND  is zero  if
  !                exact singularity is detected or the estimate
  !                underflows.
  !
  !        Z       COMPLEX(N)
  !                a work vector whose contents are usually unimportant.
  !                If  A  is close to a singular matrix, then  Z  is
  !                an approximate null vector in the sense that
  !                NORM(A*Z) = RCOND*NORM(A)*NORM(Z) .
  !
  !     Packed Storage
  !
  !          The following program segment will pack the upper
  !          triangle of a symmetric matrix.
  !
  !                K = 0
  !                DO 20 J = 1, N
  !                   DO 10 I = 1, J
  !                      K = K + 1
  !                      AP(K) = A(I,J)
  !             10    CONTINUE
  !             20 CONTINUE
  !
  !***
  ! **References:**  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***
  ! **Routines called:**  CAXPY, CDOTU, CSPFA, CSSCAL, SCASUM

  !* REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891107  Corrected category and modified routine equivalence
  !           list.  (WRB)
  !   891107  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER N, Kpvt(*)
  COMPLEX Ap(*), Z(*)
  REAL Rcond
  !
  COMPLEX ak, akm1, bk, bkm1, CDOTU, denom, ek, t
  REAL anorm, s, SCASUM, ynorm
  INTEGER i, ij, ik, ikm1, ikp1, info, j, jm1, j1
  INTEGER k, kk, km1k, km1km1, kp, kps, ks
  REAL, EXTERNAL :: CABS1
  COMPLEX, EXTERNAL :: CSIGN1
  !
  !     FIND NORM OF A USING ONLY UPPER HALF
  !
  !* FIRST EXECUTABLE STATEMENT  CSPCO
  j1 = 1
  DO j = 1, N
    Z(j) = CMPLX(SCASUM(j,Ap(j1),1),0.0E0)
    ij = j1
    j1 = j1 + j
    jm1 = j - 1
    IF ( jm1>=1 ) THEN
      DO i = 1, jm1
        Z(i) = CMPLX(REAL(Z(i))+CABS1(Ap(ij)),0.0E0)
        ij = ij + 1
      END DO
    END IF
  END DO
  anorm = 0.0E0
  DO j = 1, N
    anorm = MAX(anorm,REAL(Z(j)))
  END DO
  !
  !     FACTOR
  !
  CALL CSPFA(Ap,N,Kpvt,info)
  !
  !     RCOND = 1/(NORM(A)*(ESTIMATE OF NORM(INVERSE(A)))) .
  !     ESTIMATE = NORM(Z)/NORM(Y) WHERE  A*Z = Y  AND  A*Y = E .
  !     THE COMPONENTS OF  E  ARE CHOSEN TO CAUSE MAXIMUM LOCAL
  !     GROWTH IN THE ELEMENTS OF W  WHERE  U*D*W = E .
  !     THE VECTORS ARE FREQUENTLY RESCALED TO AVOID OVERFLOW.
  !
  !     SOLVE U*D*W = E
  !
  ek = (1.0E0,0.0E0)
  DO j = 1, N
    Z(j) = (0.0E0,0.0E0)
  END DO
  k = N
  ik = (N*(N-1))/2
  DO WHILE ( k/=0 )
    kk = ik + k
    ikm1 = ik - (k-1)
    ks = 1
    IF ( Kpvt(k)<0 ) ks = 2
    kp = ABS(Kpvt(k))
    kps = k + 1 - ks
    IF ( kp/=kps ) THEN
      t = Z(kps)
      Z(kps) = Z(kp)
      Z(kp) = t
    END IF
    IF ( CABS1(Z(k))/=0.0E0 ) ek = CSIGN1(ek,Z(k))
    Z(k) = Z(k) + ek
    CALL CAXPY(k-ks,Z(k),Ap(ik+1),1,Z(1),1)
    IF ( ks/=1 ) THEN
      IF ( CABS1(Z(k-1))/=0.0E0 ) ek = CSIGN1(ek,Z(k-1))
      Z(k-1) = Z(k-1) + ek
      CALL CAXPY(k-ks,Z(k-1),Ap(ikm1+1),1,Z(1),1)
    END IF
    IF ( ks==2 ) THEN
      km1k = ik + k - 1
      km1km1 = ikm1 + k - 1
      ak = Ap(kk)/Ap(km1k)
      akm1 = Ap(km1km1)/Ap(km1k)
      bk = Z(k)/Ap(km1k)
      bkm1 = Z(k-1)/Ap(km1k)
      denom = ak*akm1 - 1.0E0
      Z(k) = (akm1*bk-bkm1)/denom
      Z(k-1) = (ak*bkm1-bk)/denom
    ELSE
      IF ( CABS1(Z(k))>CABS1(Ap(kk)) ) THEN
        s = CABS1(Ap(kk))/CABS1(Z(k))
        CALL CSSCAL(N,s,Z,1)
        ek = CMPLX(s,0.0E0)*ek
      END IF
      IF ( CABS1(Ap(kk))/=0.0E0 ) Z(k) = Z(k)/Ap(kk)
      IF ( CABS1(Ap(kk))==0.0E0 ) Z(k) = (1.0E0,0.0E0)
    END IF
    k = k - ks
    ik = ik - k
    IF ( ks==2 ) ik = ik - (k+1)
  END DO
  s = 1.0E0/SCASUM(N,Z,1)
  CALL CSSCAL(N,s,Z,1)
  !
  !     SOLVE TRANS(U)*Y = W
  !
  k = 1
  ik = 0
  DO WHILE ( k<=N )
    ks = 1
    IF ( Kpvt(k)<0 ) ks = 2
    IF ( k/=1 ) THEN
      Z(k) = Z(k) + CDOTU(k-1,Ap(ik+1),1,Z(1),1)
      ikp1 = ik + k
      IF ( ks==2 ) Z(k+1) = Z(k+1) + CDOTU(k-1,Ap(ikp1+1),1,Z(1),1)
      kp = ABS(Kpvt(k))
      IF ( kp/=k ) THEN
        t = Z(k)
        Z(k) = Z(kp)
        Z(kp) = t
      END IF
    END IF
    ik = ik + k
    IF ( ks==2 ) ik = ik + (k+1)
    k = k + ks
  END DO
  s = 1.0E0/SCASUM(N,Z,1)
  CALL CSSCAL(N,s,Z,1)
  !
  ynorm = 1.0E0
  !
  !     SOLVE U*D*V = Y
  !
  k = N
  ik = N*(N-1)/2
  DO WHILE ( k/=0 )
    kk = ik + k
    ikm1 = ik - (k-1)
    ks = 1
    IF ( Kpvt(k)<0 ) ks = 2
    IF ( k/=ks ) THEN
      kp = ABS(Kpvt(k))
      kps = k + 1 - ks
      IF ( kp/=kps ) THEN
        t = Z(kps)
        Z(kps) = Z(kp)
        Z(kp) = t
      END IF
      CALL CAXPY(k-ks,Z(k),Ap(ik+1),1,Z(1),1)
      IF ( ks==2 ) CALL CAXPY(k-ks,Z(k-1),Ap(ikm1+1),1,Z(1),1)
    END IF
    IF ( ks==2 ) THEN
      km1k = ik + k - 1
      km1km1 = ikm1 + k - 1
      ak = Ap(kk)/Ap(km1k)
      akm1 = Ap(km1km1)/Ap(km1k)
      bk = Z(k)/Ap(km1k)
      bkm1 = Z(k-1)/Ap(km1k)
      denom = ak*akm1 - 1.0E0
      Z(k) = (akm1*bk-bkm1)/denom
      Z(k-1) = (ak*bkm1-bk)/denom
    ELSE
      IF ( CABS1(Z(k))>CABS1(Ap(kk)) ) THEN
        s = CABS1(Ap(kk))/CABS1(Z(k))
        CALL CSSCAL(N,s,Z,1)
        ynorm = s*ynorm
      END IF
      IF ( CABS1(Ap(kk))/=0.0E0 ) Z(k) = Z(k)/Ap(kk)
      IF ( CABS1(Ap(kk))==0.0E0 ) Z(k) = (1.0E0,0.0E0)
    END IF
    k = k - ks
    ik = ik - k
    IF ( ks==2 ) ik = ik - (k+1)
  END DO
  s = 1.0E0/SCASUM(N,Z,1)
  CALL CSSCAL(N,s,Z,1)
  ynorm = s*ynorm
  !
  !     SOLVE TRANS(U)*Z = V
  !
  k = 1
  ik = 0
  DO WHILE ( k<=N )
    ks = 1
    IF ( Kpvt(k)<0 ) ks = 2
    IF ( k/=1 ) THEN
      Z(k) = Z(k) + CDOTU(k-1,Ap(ik+1),1,Z(1),1)
      ikp1 = ik + k
      IF ( ks==2 ) Z(k+1) = Z(k+1) + CDOTU(k-1,Ap(ikp1+1),1,Z(1),1)
      kp = ABS(Kpvt(k))
      IF ( kp/=k ) THEN
        t = Z(k)
        Z(k) = Z(kp)
        Z(kp) = t
      END IF
    END IF
    ik = ik + k
    IF ( ks==2 ) ik = ik + (k+1)
    k = k + ks
  END DO
  !     MAKE ZNORM = 1.0
  s = 1.0E0/SCASUM(N,Z,1)
  CALL CSSCAL(N,s,Z,1)
  ynorm = s*ynorm
  !
  IF ( anorm/=0.0E0 ) Rcond = ynorm/anorm
  IF ( anorm==0.0E0 ) Rcond = 0.0E0
END SUBROUTINE CSPCO