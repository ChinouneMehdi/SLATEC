!** LPDP
PURE SUBROUTINE LPDP(A,Mda,M,N1,N2,Prgopt,X,Wnorm,Mode,Ws,Is)
  !> Subsidiary to LSEI
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (LPDP-S, DLPDP-D)
  !***
  ! **Author:**  Hanson, R. J., (SNLA)
  !           Haskell, K. H., (SNLA)
  !***
  ! **Description:**
  !
  !     DIMENSION A(MDA,N+1),PRGOPT(*),X(N),WS((M+2)*(N+7)),IS(M+N+1),
  !     where N=N1+N2.  This is a slight overestimate for WS(*).
  !
  !     Determine an N1-vector W, and
  !               an N2-vector Z
  !     which minimizes the Euclidean length of W
  !     subject to G*W+H*Z >= Y.
  !     This is the least projected distance problem, LPDP.
  !     The matrices G and H are of respective
  !     dimensions M by N1 and M by N2.
  !
  !     Called by subprogram LSI( ).
  !
  !     The matrix
  !                (G H Y)
  !
  !     occupies rows 1,...,M and cols 1,...,N1+N2+1 of A(*,*).
  !
  !     The solution (W) is returned in X(*).
  !                  (Z)
  !
  !     The value of MODE indicates the status of
  !     the computation after returning to the user.
  !
  !          MODE=1  The solution was successfully obtained.
  !
  !          MODE=2  The inequalities are inconsistent.
  !
  !***
  ! **See also:**  LSEI
  !***
  ! **Routines called:**  SCOPY, SDOT, SNRM2, SSCAL, WNNLS

  !* REVISION HISTORY  (YYMMDD)
  !   790701  DATE WRITTEN
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910408  Updated the AUTHOR section.  (WRB)

  !
  !     SUBROUTINES CALLED
  !
  !     WNNLS         SOLVES A NONNEGATIVELY CONSTRAINED LINEAR LEAST
  !                   SQUARES PROBLEM WITH LINEAR EQUALITY CONSTRAINTS.
  !                   PART OF THIS PACKAGE.
  !
  !++
  !     SDOT,         SUBROUTINES FROM THE BLAS PACKAGE.
  !     SSCAL,SNRM2,  SEE TRANS. MATH. SOFT., VOL. 5, NO. 3, P. 308.
  !     SCOPY
  !
  INTEGER, INTENT(IN) :: M, Mda, N1, N2
  INTEGER, INTENT(OUT) :: Mode
  INTEGER, INTENT(OUT) :: Is(M+N1+N2+1)
  REAL(SP), INTENT(IN) :: Prgopt(:)
  REAL(SP), INTENT(INOUT) :: A(Mda,N1+N2+1)
  REAL(SP), INTENT(OUT) :: Wnorm, Ws((M+2)*(N1+N2+7)), X(N1+N2)
  !
  INTEGER :: i, iw, ix, j, l, modew, n, np1
  REAL(SP) :: rnorm, sc, ynorm
  REAL(SP), PARAMETER :: fac = 0.1_SP
  !* FIRST EXECUTABLE STATEMENT  LPDP
  n = N1 + N2
  Mode = 1
  IF( M>0 ) THEN
    np1 = n + 1
    !
    !     SCALE NONZERO ROWS OF INEQUALITY MATRIX TO HAVE LENGTH ONE.
    DO i = 1, M
      sc = NORM2(A(i,1:n))
      IF( sc/=0._SP ) THEN
        sc = 1._SP/sc
        A(i,1:np1) = A(i,1:np1)*sc
      END IF
    END DO
    !
    !     SCALE RT.-SIDE VECTOR TO HAVE LENGTH ONE (OR ZERO).
    ynorm = NORM2(A(1:M,np1))
    IF( ynorm/=0._SP ) THEN
      sc = 1._SP/ynorm
      A(1:M,np1) = A(1:M,np1)*sc
    END IF
    !
    !     SCALE COLS OF MATRIX H.
    j = N1 + 1
    DO WHILE( j<=n )
      sc = NORM2(A(1:M,j))
      IF( sc/=0._SP ) sc = 1._SP/sc
      A(1:M,j) = A(1:M,j)*sc
      X(j) = sc
      j = j + 1
    END DO
    IF( N1>0 ) THEN
      !
      !     COPY TRANSPOSE OF (H G Y) TO WORK ARRAY WS(*).
      iw = 0
      DO i = 1, M
        !
        !     MOVE COL OF TRANSPOSE OF H INTO WORK ARRAY.
        Ws(iw+1:iw+N2) = A(i,N1+1:N1+N2)
        iw = iw + N2
        !
        !     MOVE COL OF TRANSPOSE OF G INTO WORK ARRAY.
        Ws(iw+1:iw+N1) = A(i,1:N1)
        iw = iw + N1
        !
        !     MOVE COMPONENT OF VECTOR Y INTO WORK ARRAY.
        Ws(iw+1) = A(i,np1)
        iw = iw + 1
      END DO
      Ws(iw+1:iw+n) = 0._SP
      iw = iw + n
      Ws(iw+1) = 1._SP
      iw = iw + 1
      !
      !     SOLVE EU=F SUBJECT TO (TRANSPOSE OF H)U=0, U>=0.  THE
      !     MATRIX E = TRANSPOSE OF (G Y), AND THE (N+1)-VECTOR
      !     F = TRANSPOSE OF (0,...,0,1).
      ix = iw + 1
      iw = iw + M
      !
      !     DO NOT CHECK LENGTHS OF WORK ARRAYS IN THIS USAGE OF WNNLS( ).
      Is(1) = 0
      Is(2) = 0
      CALL WNNLS(Ws,np1,N2,np1-N2,M,0,Prgopt,Ws(ix),rnorm,modew,Is,Ws(iw+1))
      !
      !     COMPUTE THE COMPONENTS OF THE SOLN DENOTED ABOVE BY W.
      sc = 1._SP - DOT_PRODUCT(A(1:M,np1),Ws(ix:ix+M-1))
      IF( 1._SP+fac*ABS(sc)==1._SP .OR. rnorm<=0._SP ) THEN
        Mode = 2
        RETURN
      ELSE
        sc = 1._SP/sc
        DO j = 1, N1
          X(j) = sc*DOT_PRODUCT(A(1:M,j),Ws(ix:ix+M-1))
        END DO
        !
        !     COMPUTE THE VECTOR Q=Y-GW.  OVERWRITE Y WITH THIS VECTOR.
        DO i = 1, M
          A(i,np1) = A(i,np1) - DOT_PRODUCT(A(i,1:N1),X(1:N1))
        END DO
      END IF
    END IF
    IF( N2>0 ) THEN
      !
      !     COPY TRANSPOSE OF (H Q) TO WORK ARRAY WS(*).
      iw = 0
      DO i = 1, M
        Ws(iw+1:iw+N2) = A(i,N1+1:N1+N2)
        iw = iw + N2
        Ws(iw+1) = A(i,np1)
        iw = iw + 1
      END DO
      Ws(iw+1:iw+N2) = 0._SP
      iw = iw + N2
      Ws(iw+1) = 1._SP
      iw = iw + 1
      ix = iw + 1
      iw = iw + M
      !
      !     SOLVE RV=S SUBJECT TO V>=0.  THE MATRIX R =(TRANSPOSE
      !     OF (H Q)), WHERE Q=Y-GW.  THE (N2+1)-VECTOR S =(TRANSPOSE
      !     OF (0,...,0,1)).
      !
      !     DO NOT CHECK LENGTHS OF WORK ARRAYS IN THIS USAGE OF WNNLS( ).
      Is(1) = 0
      Is(2) = 0
      CALL WNNLS(Ws,N2+1,0,N2+1,M,0,Prgopt,Ws(ix),rnorm,modew,Is,Ws(iw+1))
      !
      !     COMPUTE THE COMPONENTS OF THE SOLN DENOTED ABOVE BY Z.
      sc = 1._SP - DOT_PRODUCT(A(1:M,np1),Ws(ix:ix+M-1))
      IF( 1._SP+fac*ABS(sc)==1._SP .OR. rnorm<=0._SP ) THEN
        Mode = 2
        RETURN
      ELSE
        sc = 1._SP/sc
        DO j = 1, N2
          l = N1 + j
          X(l) = sc*DOT_PRODUCT(A(1:M,l),Ws(ix:ix+M-1))*X(l)
        END DO
      END IF
    END IF
    !
    !     ACCOUNT FOR SCALING OF RT.-SIDE VECTOR IN SOLUTION.
    X(1:n) = X(1:n)*ynorm
    Wnorm = NORM2(X(1:N1))
  ELSE
    IF( n>0 ) THEN
      X(1:n) = 0._SP
    END IF
    Wnorm = 0._SP
    RETURN
  END IF
  !
END SUBROUTINE LPDP