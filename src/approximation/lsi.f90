!** LSI
PURE SUBROUTINE LSI(W,Mdw,Ma,Mg,N,Prgopt,X,Rnorm,Mode,Ws,Ip)
  !> Subsidiary to LSEI
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (LSI-S, DLSI-D)
  !***
  ! **Author:**  Hanson, R. J., (SNLA)
  !***
  ! **Description:**
  !
  !     This is a companion subprogram to LSEI.  The documentation for
  !     LSEI has complete usage instructions.
  !
  !     Solve..
  !              AX = B,  A  MA by N  (least squares equations)
  !     subject to..
  !
  !              GX>=H, G  MG by N  (inequality constraints)
  !
  !     Input..
  !
  !      W(*,*) contains  (A B) in rows 1,...,MA+MG, cols 1,...,N+1.
  !                       (G H)
  !
  !     MDW,MA,MG,N
  !              contain (resp) var. dimension of W(*,*),
  !              and matrix dimensions.
  !
  !     PRGOPT(*),
  !              Program option vector.
  !
  !     OUTPUT..
  !
  !      X(*),RNORM
  !
  !              Solution vector(unless MODE=2), length of AX-B.
  !
  !      MODE
  !              =0   Inequality constraints are compatible.
  !              =2   Inequality constraints contradictory.
  !
  !      WS(*),
  !              Working storage of dimension K+N+(MG+2)*(N+7),
  !              where K=MAX(MA+MG,N).
  !      IP(MG+2*N+1)
  !              Integer working storage
  !
  !***
  ! **Routines called:**  H12, HFTI, LPDP, R1MACH, SASUM, SAXPY, SCOPY, SDOT,
  !                    SSCAL, SSWAP

  !* REVISION HISTORY  (YYMMDD)
  !   790701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890618  Completely restructured and extensively revised (WRB & RWC)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   920422  Changed CALL to HFTI to include variable MA.  (WRB)
  USE service, ONLY : eps_sp
  USE blas, ONLY : SAXPY, SSWAP
  USE linear, ONLY : H12, HFTI
  !
  INTEGER, INTENT(IN) :: Ma, Mdw, Mg, N
  INTEGER, INTENT(OUT) :: Mode, Ip(Mg+2*N+1)
  REAL(SP), INTENT(IN) :: Prgopt(:)
  REAL(SP), INTENT(INOUT) :: W(Mdw,N+1)
  REAL(SP), INTENT(OUT) :: Rnorm, Ws(*), X(N)
  !
  REAL(SP) :: anorm, fac, gam, rb,tau, tol, xnorm, temp(1)
  INTEGER :: i, j, k, key, krank, krm1, krp1, l, last, link, m, map1, mdlpdp, minman, &
    n1, n2, n3, next, np1
  LOGICAL :: cov, sclcov
  !
  REAL(SP), PARAMETER :: srelpr = eps_sp
  !
  !* FIRST EXECUTABLE STATEMENT  LSI
  !
  !     Set the nominal tolerance used in the code.
  !
  tol = SQRT(srelpr)
  !
  Mode = 0
  Rnorm = 0._SP
  m = Ma + Mg
  np1 = N + 1
  krank = 0
  IF( N>0 .AND. m>0 ) THEN
    !
    !     To process option vector.
    !
    cov = .FALSE.
    sclcov = .TRUE.
    last = 1
    link = INT( Prgopt(1) )
    DO
      !
      IF( link>1 ) THEN
        key = INT( Prgopt(last+1) )
        IF( key==1 ) cov = Prgopt(last+2)/=0._SP
        IF( key==10 ) sclcov = Prgopt(last+2)==0._SP
        IF( key==5 ) tol = MAX(srelpr,Prgopt(last+2))
        next = INT( Prgopt(link) )
        last = link
        link = next
        CYCLE
      END IF
      !
      !     Compute matrix norm of least squares equations.
      !
      anorm = 0._SP
      DO j = 1, N
        anorm = MAX(anorm,SUM(ABS(W(1:Ma,j))))
      END DO
      !
      !     Set tolerance for HFTI( ) rank test.
      !
      tau = tol*anorm
      !
      !     Compute Householder orthogonal decomposition of matrix.
      !
      Ws(1:N) = 0._SP
      Ws(1:Ma) = W(1:Ma,np1)
      k = MAX(m,N)
      minman = MIN(Ma,N)
      n1 = k + 1
      n2 = n1 + N
      CALL HFTI(W,Mdw,Ma,N,Ws,Ma,1,tau,krank,temp,Ws(n2),Ws(n1),Ip)
      Rnorm = temp(1)
      fac = 1._SP
      gam = Ma - krank
      IF( krank<Ma .AND. sclcov ) fac = Rnorm**2/gam
      !
      !     Reduce to LPDP and solve.
      !
      map1 = Ma + 1
      !
      !     Compute inequality rt-hand side for LPDP.
      !
      IF( Ma<m ) THEN
        IF( minman>0 ) THEN
          DO i = map1, m
            W(i,np1) = W(i,np1) - DOT_PRODUCT(W(i,1:N),Ws(1:N))
          END DO
          !
          !           Apply permutations to col. of inequality constraint matrix.
          !
          DO i = 1, minman
            CALL SSWAP(Mg,W(map1,i),1,W(map1,Ip(i)),1)
          END DO
          !
          !           Apply Householder transformations to constraint matrix.
          !
          IF( krank>0 .AND. krank<N ) THEN
            DO i = krank, 1, -1
              CALL H12(2,i,krank+1,N,W(i,1),Mdw,Ws(n1+i-1),W(map1,1),Mdw,1,Mg)
            END DO
          END IF
          !
          !           Compute permuted inequality constraint matrix times r-inv.
          !
          DO i = map1, m
            DO j = 1, krank
              W(i,j) = (W(i,j)-DOT_PRODUCT(W(1:j-1,j),W(i,1:j-1)))/W(j,j)
            END DO
          END DO
        END IF
        !
        !        Solve the reduced problem with LPDP algorithm,
        !        the least projected distance problem.
        !
        CALL LPDP(W(map1,1),Mdw,Mg,krank,N-krank,Prgopt,X,xnorm,mdlpdp,&
          Ws(n2),Ip(N+1))
        !
        !        Compute solution in original coordinates.
        !
        IF( mdlpdp==1 ) THEN
          DO i = krank, 1, -1
            X(i) = (X(i)-DOT_PRODUCT(W(i,i+1:krank),X(i+1:krank)))/W(i,i)
          END DO
          !
          !           Apply Householder transformation to solution vector.
          !
          IF( krank<N ) THEN
            DO i = 1, krank
              CALL H12(2,i,krank+1,N,W(i,1),Mdw,Ws(n1+i-1),X,1,1,1)
            END DO
          END IF
          !
          !           Repermute variables to their input order.
          !
          IF( minman>0 ) THEN
            DO i = minman, 1, -1
              CALL SSWAP(1,X(i),1,X(Ip(i)),1)
            END DO
            !
            !              Variables are now in original coordinates.
            !              Add solution of unconstrained problem.
            !
            DO i = 1, N
              X(i) = X(i) + Ws(i)
            END DO
            !
            !              Compute the residual vector norm.
            !
            Rnorm = SQRT(Rnorm**2+xnorm**2)
          END IF
        ELSE
          Mode = 2
        END IF
      ELSE
        X(1:N) = Ws(1:N)
      END IF
      !
      !     Compute covariance matrix based on the orthogonal decomposition
      !     from HFTI( ).
      !
      IF( .NOT. ( .NOT. cov .OR. krank<=0) ) THEN
        krm1 = krank - 1
        krp1 = krank + 1
        !
        !     Copy diagonal terms to working array.
        !
        DO j = 1, krank
          Ws(n2+j-1) = W(j,j)
        END DO
        !
        !     Reciprocate diagonal terms.
        !
        DO j = 1, krank
          W(j,j) = 1._SP/W(j,j)
        END DO
        !
        !     Invert the upper triangular QR factor on itself.
        !
        IF( krank>1 ) THEN
          DO i = 1, krm1
            DO j = i + 1, krank
              W(i,j) = -DOT_PRODUCT(W(i,i:j-1),W(i:j-1,j))*W(j,j)
            END DO
          END DO
        END IF
        !
        !     Compute the inverted factor times its transpose.
        !
        DO i = 1, krank
          DO j = i, krank
            W(i,j) = DOT_PRODUCT(W(i,j:krank),W(j,j:krank))
          END DO
        END DO
        !
        !     Zero out lower trapezoidal part.
        !     Copy upper triangular to lower triangular part.
        !
        IF( krank<N ) THEN
          DO j = 1, krank
            W(j,1:j) = W(1:j,j)
          END DO
          !
          DO i = krp1, N
            W(i,1:i) = 0._SP
          END DO
          !
          !        Apply right side transformations to lower triangle.
          !
          n3 = n2 + krp1
          DO i = 1, krank
            l = n1 + i
            k = n2 + i
            rb = Ws(l-1)*Ws(k-1)
            !
            !           If RB>=0.E0, transformation can be regarded as zero.
            !
            IF( rb<0._SP ) THEN
              rb = 1._SP/rb
              !
              !              Store unscaled rank one Householder update in work array.
              !
              Ws(n3:n3+N-1) = 0._SP
              l = n1 + i
              k = n3 + i
              Ws(k-1) = Ws(l-1)
              !
              DO j = krp1, N
                Ws(n3+j-1) = W(i,j)
              END DO
              !
              DO j = 1, N
                Ws(j) = rb*(DOT_PRODUCT(W(j,i:j-1),Ws(n3+i-1:n3+j-2)) &
                  + DOT_PRODUCT(W(j:N,j),Ws(n3+j-1:n3+N-1)))
              END DO
              !
              l = n3 + i
              gam = 0.5_SP*rb*DOT_PRODUCT(Ws(l-1:l+N-i-1),Ws(i:N))
              CALL SAXPY(N-i+1,gam,Ws(l-1:l+N-i-1),1,Ws(i:N),1)
              DO j = i, N
                DO l = 1, i - 1
                  W(j,l) = W(j,l) + Ws(n3+j-1)*Ws(l)
                END DO
                !
                DO l = i, j
                  W(j,l) = W(j,l) + Ws(j)*Ws(n3+l-1) + Ws(l)*Ws(n3+j-1)
                END DO
              END DO
            END IF
          END DO
          !
          !        Copy lower triangle to upper triangle to symmetrize the
          !        covariance matrix.
          !
          DO i = 1, N
            W(1:i,i) = W(i,1:i)
          END DO
        END IF
        !
        !     Repermute rows and columns.
        !
        DO i = minman, 1, -1
          k = Ip(i)
          IF( i/=k ) THEN
            CALL SSWAP(1,W(i,i),1,W(k,k),1)
            CALL SSWAP(i-1,W(1,i),1,W(1,k),1)
            CALL SSWAP(k-i-1,W(i,i+1),Mdw,W(i+1,k),1)
            CALL SSWAP(N-k,W(i,k+1),Mdw,W(k,k+1),Mdw)
          END IF
        END DO
        !
        !     Put in normalized residual sum of squares scale factor
        !     and symmetrize the resulting covariance matrix.
        !
        DO j = 1, N
          W(1:j,j) = W(1:j,j)*fac
          W(j,1:j) = W(1:j,j)
        END DO
      END IF
      EXIT
    END DO
  END IF
  !
  Ip(1) = krank
  Ip(2) = N + MAX(m,N) + (Mg+2)*(N+7)
  !
END SUBROUTINE LSI