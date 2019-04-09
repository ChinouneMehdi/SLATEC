!** BALANC
SUBROUTINE BALANC(Nm,N,A,Low,Igh,Scale)
  IMPLICIT NONE
  !>
  !***
  !  Balance a real general matrix and isolate eigenvalues
  !            whenever possible.
  !***
  ! **Library:**   SLATEC (EISPACK)
  !***
  ! **Category:**  D4C1A
  !***
  ! **Type:**      SINGLE PRECISION (BALANC-S, CBAL-C)
  !***
  ! **Keywords:**  EIGENVECTORS, EISPACK
  !***
  ! **Author:**  Smith, B. T., et al.
  !***
  ! **Description:**
  !
  !     This subroutine is a translation of the ALGOL procedure BALANCE,
  !     NUM. MATH. 13, 293-304(1969) by Parlett and Reinsch.
  !     HANDBOOK FOR AUTO. COMP., Vol.II-LINEAR ALGEBRA, 315-326(1971).
  !
  !     This subroutine balances a REAL matrix and isolates
  !     eigenvalues whenever possible.
  !
  !     On INPUT
  !
  !        NM must be set to the row dimension of the two-dimensional
  !          array parameter, A, as declared in the calling program
  !          dimension statement.  NM is an INTEGER variable.
  !
  !        N is the order of the matrix A.  N is an INTEGER variable.
  !          N must be less than or equal to NM.
  !
  !        A contains the input matrix to be balanced.  A is a
  !          two-dimensional REAL array, dimensioned A(NM,N).
  !
  !     On OUTPUT
  !
  !        A contains the balanced matrix.
  !
  !        LOW and IGH are two INTEGER variables such that A(I,J)
  !          is equal to zero if
  !           (1) I is greater than J and
  !           (2) J=1,...,LOW-1 or I=IGH+1,...,N.
  !
  !        SCALE contains information determining the permutations and
  !          scaling factors used.  SCALE is a one-dimensional REAL array,
  !          dimensioned SCALE(N).
  !
  !     Suppose that the principal submatrix in rows LOW through IGH
  !     has been balanced, that P(J) denotes the index interchanged
  !     with J during the permutation step, and that the elements
  !     of the diagonal matrix used are denoted by D(I,J).  Then
  !        SCALE(J) = P(J),    for J = 1,...,LOW-1
  !                 = D(J,J),      J = LOW,...,IGH
  !                 = P(J)         J = IGH+1,...,N.
  !     The order in which the interchanges are made is N to IGH+1,
  !     then 1 TO LOW-1.
  !
  !     Note that 1 is returned for IGH if IGH is zero formally.
  !
  !     The ALGOL procedure EXC contained in BALANCE appears in
  !     BALANC  in line.  (Note that the ALGOL roles of identifiers
  !     K,L have been reversed.)
  !
  !     Questions and comments should be directed to B. S. Garbow,
  !     Applied Mathematics Division, ARGONNE NATIONAL LABORATORY
  !     ------------------------------------------------------------------
  !
  !***
  ! **References:**  B. T. Smith, J. M. Boyle, J. J. Dongarra, B. S. Garbow,
  !                 Y. Ikebe, V. C. Klema and C. B. Moler, Matrix Eigen-
  !                 system Routines - EISPACK Guide, Springer-Verlag,
  !                 1976.
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   760101  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  !
  INTEGER i, j, k, l, m, N, jj, Nm, Igh, Low, iexc
  REAL A(Nm,*), Scale(*)
  REAL c, f, g, r, s, b2, radix
  LOGICAL noconv
  !
  !* FIRST EXECUTABLE STATEMENT  BALANC
  radix = 16
  !
  b2 = radix*radix
  k = 1
  l = N
  GOTO 200
  !     .......... IN-LINE PROCEDURE FOR ROW AND
  !                COLUMN EXCHANGE ..........
  100  Scale(m) = j
  IF ( j/=m ) THEN
    !
    DO i = 1, l
      f = A(i,j)
      A(i,j) = A(i,m)
      A(i,m) = f
    END DO
    !
    DO i = k, N
      f = A(j,i)
      A(j,i) = A(m,i)
      A(m,i) = f
    END DO
  END IF
  !
  IF ( iexc==2 ) THEN
    !     .......... SEARCH FOR COLUMNS ISOLATING AN EIGENVALUE
    !                AND PUSH THEM LEFT ..........
    k = k + 1
    GOTO 400
  ELSE
    !     .......... SEARCH FOR ROWS ISOLATING AN EIGENVALUE
    !                AND PUSH THEM DOWN ..........
    IF ( l==1 ) GOTO 600
    l = l - 1
  END IF
  !     .......... FOR J=L STEP -1 UNTIL 1 DO -- ..........
  200 CONTINUE
  DO jj = 1, l
    j = l + 1 - jj
    !
    DO i = 1, l
      IF ( i/=j ) THEN
        IF ( A(j,i)/=0.0E0 ) GOTO 300
      END IF
    END DO
    !
    m = l
    iexc = 1
    GOTO 100
    !
    300 CONTINUE
  END DO
  !
  400 CONTINUE
  DO j = k, l
    !
    DO i = k, l
      IF ( i/=j ) THEN
        IF ( A(i,j)/=0.0E0 ) GOTO 500
      END IF
    END DO
    !
    m = k
    iexc = 2
    GOTO 100
    500 CONTINUE
  END DO
  !     .......... NOW BALANCE THE SUBMATRIX IN ROWS K TO L ..........
  DO i = k, l
    Scale(i) = 1.0E0
  END DO
  DO
    !     .......... ITERATIVE LOOP FOR NORM REDUCTION ..........
    noconv = .FALSE.
    !
    DO i = k, l
      c = 0.0E0
      r = 0.0E0
      !
      DO j = k, l
        IF ( j/=i ) THEN
          c = c + ABS(A(j,i))
          r = r + ABS(A(i,j))
        END IF
      END DO
      !     .......... GUARD AGAINST ZERO C OR R DUE TO UNDERFLOW ..........
      IF ( c/=0.0E0.AND.r/=0.0E0 ) THEN
        g = r/radix
        f = 1.0E0
        s = c + r
        DO WHILE ( c<g )
          f = f*radix
          c = c*b2
        END DO
        g = r*radix
        DO WHILE ( c>=g )
          f = f/radix
          c = c/b2
        END DO
        !     .......... NOW BALANCE ..........
        IF ( (c+r)/f<0.95E0*s ) THEN
          g = 1.0E0/f
          Scale(i) = Scale(i)*f
          noconv = .TRUE.
          !
          DO j = k, N
            A(i,j) = A(i,j)*g
          END DO
          !
          DO j = 1, l
            A(j,i) = A(j,i)*f
          END DO
        END IF
      END IF
      !
    END DO
    !
    IF ( .NOT.(noconv) ) EXIT
  END DO
  !
  600  Low = k
  Igh = l
END SUBROUTINE BALANC