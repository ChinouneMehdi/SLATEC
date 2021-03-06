!** HFTI
PURE SUBROUTINE HFTI(A,Mda,M,N,B,Mdb,Nb,Tau,Krank,Rnorm,H,G,Ip)
  !> Solve a linear least squares problems by performing a QR factorization of
  ! the matrix using Householder transformations.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  D9
  !***
  ! **Type:**      SINGLE PRECISION (HFTI-S, DHFTI-D)
  !***
  ! **Keywords:**  CURVE FITTING, LINEAR LEAST SQUARES, QR FACTORIZATION
  !***
  ! **Author:**  Lawson, C. L., (JPL)
  !           Hanson, R. J., (SNLA)
  !***
  ! **Description:**
  !
  !     DIMENSION A(MDA,N),(B(MDB,NB) or B(M)),RNORM(NB),H(N),G(N),IP(N)
  !
  !     This subroutine solves a linear least squares problem or a set of
  !     linear least squares problems having the same matrix but different
  !     right-side vectors.  The problem data consists of an M by N matrix
  !     A, an M by NB matrix B, and an absolute tolerance parameter TAU
  !     whose usage is described below.  The NB column vectors of B
  !     represent right-side vectors for NB distinct linear least squares
  !     problems.
  !
  !     This set of problems can also be written as the matrix least
  !     squares problem
  !
  !                       AX = B,
  !
  !     where X is the N by NB solution matrix.
  !
  !     Note that if B is the M by M identity matrix, then X will be the
  !     pseudo-inverse of A.
  !
  !     This subroutine first transforms the augmented matrix (A B) to a
  !     matrix (R C) using premultiplying Householder transformations with
  !     column interchanges.  All subdiagonal elements in the matrix R are
  !     zero and its diagonal elements satisfy
  !
  !                       ABS(R(I,I))>=ABS(R(I+1,I+1)),
  !
  !                       I = 1,...,L-1, where
  !
  !                       L = MIN(M,N).
  !
  !     The subroutine will compute an integer, KRANK, equal to the number
  !     of diagonal terms of R that exceed TAU in magnitude. Then a
  !     solution of minimum Euclidean length is computed using the first
  !     KRANK rows of (R C).
  !
  !     To be specific we suggest that the user consider an easily
  !     computable matrix norm, such as, the maximum of all column sums of
  !     magnitudes.
  !
  !     Now if the relative uncertainty of B is EPS, (norm of uncertainty/
  !     norm of B), it is suggested that TAU be set approximately equal to
  !     EPS*(norm of A).
  !
  !     The user must dimension all arrays appearing in the call list..
  !     A(MDA,N),(B(MDB,NB) or B(M)),RNORM(NB),H(N),G(N),IP(N).  This
  !     permits the solution of a range of problems in the same array
  !     space.
  !
  !     The entire set of parameters for HFTI are
  !
  !     INPUT..
  !
  !     A(*,*),MDA,M,N    The array A(*,*) initially contains the M by N
  !                       matrix A of the least squares problem AX = B.
  !                       The first dimensioning parameter of the array
  !                       A(*,*) is MDA, which must satisfy MDA>=M
  !                       Either M>=N or M<N is permitted.  There
  !                       is no restriction on the rank of A.  The
  !                       condition MDA<M is considered an error.
  !
  !     B(*),MDB,NB       If NB = 0 the subroutine will perform the
  !                       orthogonal decomposition but will make no
  !                       references to the array B(*).  If NB>0
  !                       the array B(*) must initially contain the M by
  !                       NB matrix B of the least squares problem AX =
  !                       B.  If NB>=2 the array B(*) must be doubly
  !                       subscripted with first dimensioning parameter
  !                       MDB>=MAX(M,N).  If NB = 1 the array B(*) may
  !                       be either doubly or singly subscripted.  In
  !                       the latter case the value of MDB is arbitrary
  !                       but it should be set to some valid integer
  !                       value such as MDB = M.
  !
  !                       The condition of NB>1 .AND. MDB< MAX(M,N)
  !                       is considered an error.
  !
  !     TAU               Absolute tolerance parameter provided by user
  !                       for pseudorank determination.
  !
  !     H(*),G(*),IP(*)   Arrays of working space used by HFTI.
  !
  !     OUTPUT..
  !
  !     A(*,*)            The contents of the array A(*,*) will be
  !                       modified by the subroutine. These contents
  !                       are not generally required by the user.
  !
  !     B(*)              On return the array B(*) will contain the N by
  !                       NB solution matrix X.
  !
  !     KRANK             Set by the subroutine to indicate the
  !                       pseudorank of A.
  !
  !     RNORM(*)          On return, RNORM(J) will contain the Euclidean
  !                       norm of the residual vector for the problem
  !                       defined by the J-th column vector of the array
  !                       B(*,*) for J = 1,...,NB.
  !
  !     H(*),G(*)         On return these arrays respectively contain
  !                       elements of the pre- and post-multiplying
  !                       Householder transformations used to compute
  !                       the minimum Euclidean length solution.
  !
  !     IP(*)             Array in which the subroutine records indices
  !                       describing the permutation of column vectors.
  !                       The contents of arrays H(*),G(*) and IP(*)
  !                       are not generally required by the user.
  !
  !***
  ! **References:**  C. L. Lawson and R. J. Hanson, Solving Least Squares
  !                 Problems, Prentice-Hall, Inc., 1974, Chapter 14.
  !***
  ! **Routines called:**  H12, R1MACH, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   790101  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891006  Cosmetic changes to prologue.  (WRB)
  !   891006  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   901005  Replace usage of DIFF with usage of R1MACH.  (RWC)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_sp
  !
  INTEGER, INTENT(IN) :: M, Mda, Mdb, N, Nb
  INTEGER, INTENT(INOUT) :: Ip(N)
  INTEGER, INTENT(OUT) :: Krank
  REAL(SP), INTENT(IN) :: Tau
  REAL(SP), INTENT(INOUT) :: A(Mda,N+1), B(Mdb,Nb), G(N), H(N)
  REAL(SP), INTENT(OUT) :: Rnorm(Nb)
  !
  INTEGER :: i, ii, iopt, ip1, j, jb, jj, k, kp1, l, ldiag, lmax, nerr
  REAL(SP) :: factor, hmax, sm1, tmp
  REAL(DP) :: sm
  REAL(SP), PARAMETER :: releps = eps_sp
  !* FIRST EXECUTABLE STATEMENT  HFTI
  factor = 0.001_SP
  !
  k = 0
  ldiag = MIN(M,N)
  IF( ldiag>0 ) THEN
    IF( .NOT. Mda<M ) THEN
      !
      IF( Nb<=1 .OR. MAX(M,N)<=Mdb ) THEN
        !
        DO j = 1, ldiag
          IF( j/=1 ) THEN
            !
            !     UPDATE SQUARED COLUMN LENGTHS AND FIND LMAX
            !    ..
            lmax = j
            DO l = j, N
              H(l) = H(l) - A(j-1,l)**2
              IF( H(l)>H(lmax) ) lmax = l
            END DO
            IF( factor*H(lmax)>hmax*releps ) GOTO 5
          END IF
          !
          !     COMPUTE SQUARED COLUMN LENGTHS AND FIND LMAX
          !    ..
          lmax = j
          DO l = j, N
            H(l) = 0.
            DO i = j, M
              H(l) = H(l) + A(i,l)**2
            END DO
            IF( H(l)>H(lmax) ) lmax = l
          END DO
          hmax = H(lmax)
          !    ..
          !     LMAX HAS BEEN DETERMINED
          !
          !     DO COLUMN INTERCHANGES IF NEEDED.
          !    ..
          5  Ip(j) = lmax
          IF( Ip(j)/=j ) THEN
            DO i = 1, M
              tmp = A(i,j)
              A(i,j) = A(i,lmax)
              A(i,lmax) = tmp
            END DO
            H(lmax) = H(j)
          END IF
          !
          !     COMPUTE THE J-TH TRANSFORMATION AND APPLY IT TO A AND B.
          !    ..
          CALL H12(1,j,j+1,M,A(1,j),1,H(j),A(1,j+1),1,Mda,N-j)
          CALL H12(2,j,j+1,M,A(1,j),1,H(j),B,1,Mdb,Nb)
        END DO
        !
        !     DETERMINE THE PSEUDORANK, K, USING THE TOLERANCE, TAU.
        !    ..
        DO j = 1, ldiag
          IF( ABS(A(j,j))<=Tau ) GOTO 20
        END DO
        k = ldiag
        GOTO 50
      ELSE
        nerr = 2
        iopt = 2
        ERROR STOP 'HFTI : MDB<MAX(M,N) .AND. NB>1. PROBABLE ERROR.'
        RETURN
      END IF
      20  k = j - 1
    ELSE
      nerr = 1
      iopt = 2
      ERROR STOP 'HFTI : MDA<M, PROBABLE ERROR.'
      RETURN
    END IF
    50  kp1 = k + 1
    !
    !     COMPUTE THE NORMS OF THE RESIDUAL VECTORS.
    !
    IF( Nb>0 ) THEN
      DO jb = 1, Nb
        tmp = 0._SP
        IF( kp1<=M ) THEN
          DO i = kp1, M
            tmp = tmp + B(i,jb)**2
          END DO
        END IF
        Rnorm(jb) = SQRT(tmp)
      END DO
    END IF
    !                                           SPECIAL FOR PSEUDORANK = 0
    IF( k>0 ) THEN
      !
      !     IF THE PSEUDORANK IS LESS THAN N COMPUTE HOUSEHOLDER
      !     DECOMPOSITION OF FIRST K ROWS.
      !    ..
      IF( k/=N ) THEN
        DO ii = 1, k
          i = kp1 - ii
          CALL H12(1,i,kp1,N,A(i,1),Mda,G(i),A,Mda,1,i-1)
        END DO
      END IF
      !
      !
      IF( Nb>0 ) THEN
        DO jb = 1, Nb
          !
          !     SOLVE THE K BY K TRIANGULAR SYSTEM.
          !    ..
          DO l = 1, k
            sm = 0._DP
            i = kp1 - l
            IF( i/=k ) THEN
              ip1 = i + 1
              DO j = ip1, k
                sm = sm + A(i,j)*REAL( B(j,jb), DP )
              END DO
            END IF
            sm1 = REAL( sm, SP )
            B(i,jb) = (B(i,jb)-sm1)/A(i,i)
          END DO
          !
          !     COMPLETE COMPUTATION OF SOLUTION VECTOR.
          !    ..
          IF( k/=N ) THEN
            DO j = kp1, N
              B(j,jb) = 0._SP
            END DO
            DO i = 1, k
              CALL H12(2,i,kp1,N,A(i,1),Mda,G(i),B(1,jb),1,Mdb,1)
            END DO
          END IF
          !
          !      RE-ORDER THE SOLUTION VECTOR TO COMPENSATE FOR THE
          !      COLUMN INTERCHANGES.
          !    ..
          DO jj = 1, ldiag
            j = ldiag + 1 - jj
            IF( Ip(j)/=j ) THEN
              l = Ip(j)
              tmp = B(l,jb)
              B(l,jb) = B(j,jb)
              B(j,jb) = tmp
            END IF
          END DO
        END DO
      END IF
    ELSEIF( Nb>0 ) THEN
      DO jb = 1, Nb
        DO i = 1, N
          B(i,jb) = 0._SP
        END DO
      END DO
    END IF
  END IF
  !    ..
  !     THE SOLUTION VECTORS, X, ARE NOW
  !     IN THE FIRST  N  ROWS OF THE ARRAY B(,).
  !
  Krank = k

END SUBROUTINE HFTI