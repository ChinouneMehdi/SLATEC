!DECK DGTSL
SUBROUTINE DGTSL(N,C,D,E,B,Info)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  DGTSL
  !***PURPOSE  Solve a tridiagonal linear system.
  !***LIBRARY   SLATEC (LINPACK)
  !***CATEGORY  D2A2A
  !***TYPE      DOUBLE PRECISION (SGTSL-S, DGTSL-D, CGTSL-C)
  !***KEYWORDS  LINEAR ALGEBRA, LINPACK, MATRIX, SOLVE, TRIDIAGONAL
  !***AUTHOR  Dongarra, J., (ANL)
  !***DESCRIPTION
  !
  !     DGTSL given a general tridiagonal matrix and a right hand
  !     side will find the solution.
  !
  !     On Entry
  !
  !        N       INTEGER
  !                is the order of the tridiagonal matrix.
  !
  !        C       DOUBLE PRECISION(N)
  !                is the subdiagonal of the tridiagonal matrix.
  !                C(2) through C(N) should contain the subdiagonal.
  !                On output C is destroyed.
  !
  !        D       DOUBLE PRECISION(N)
  !                is the diagonal of the tridiagonal matrix.
  !                On output D is destroyed.
  !
  !        E       DOUBLE PRECISION(N)
  !                is the superdiagonal of the tridiagonal matrix.
  !                E(1) through E(N-1) should contain the superdiagonal.
  !                On output E is destroyed.
  !
  !        B       DOUBLE PRECISION(N)
  !                is the right hand side vector.
  !
  !     On Return
  !
  !        B       is the solution vector.
  !
  !        INFO    INTEGER
  !                = 0 normal value.
  !                = K if the K-th element of the diagonal becomes
  !                    exactly zero.  The subroutine returns when
  !                    this is detected.
  !
  !***REFERENCES  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  !***END PROLOGUE  DGTSL
  INTEGER N, Info
  REAL(8) :: C(*), D(*), E(*), B(*)
  !
  INTEGER k, kb, kp1, nm1, nm2
  REAL(8) :: t
  !***FIRST EXECUTABLE STATEMENT  DGTSL
  Info = 0
  C(1) = D(1)
  nm1 = N - 1
  IF ( nm1>=1 ) THEN
    D(1) = E(1)
    E(1) = 0.0D0
    E(N) = 0.0D0
    !
    DO k = 1, nm1
      kp1 = k + 1
      !
      !              FIND THE LARGEST OF THE TWO ROWS
      !
      IF ( ABS(C(kp1))>=ABS(C(k)) ) THEN
        !
        !                 INTERCHANGE ROW
        !
        t = C(kp1)
        C(kp1) = C(k)
        C(k) = t
        t = D(kp1)
        D(kp1) = D(k)
        D(k) = t
        t = E(kp1)
        E(kp1) = E(k)
        E(k) = t
        t = B(kp1)
        B(kp1) = B(k)
        B(k) = t
      ENDIF
      !
      !              ZERO ELEMENTS
      !
      IF ( C(k)/=0.0D0 ) THEN
        t = -C(kp1)/C(k)
        C(kp1) = D(kp1) + t*D(k)
        D(kp1) = E(kp1) + t*E(k)
        E(kp1) = 0.0D0
        B(kp1) = B(kp1) + t*B(k)
      ELSE
        Info = k
        GOTO 99999
      ENDIF
    ENDDO
  ENDIF
  IF ( C(N)/=0.0D0 ) THEN
    !
    !           BACK SOLVE
    !
    nm2 = N - 2
    B(N) = B(N)/C(N)
    IF ( N/=1 ) THEN
      B(nm1) = (B(nm1)-D(nm1)*B(N))/C(nm1)
      IF ( nm2>=1 ) THEN
        DO kb = 1, nm2
          k = nm2 - kb + 1
          B(k) = (B(k)-D(k)*B(k+1)-E(k)*B(k+2))/C(k)
        ENDDO
      ENDIF
    ENDIF
  ELSE
    Info = N
  ENDIF
  !
  99999 CONTINUE
  END SUBROUTINE DGTSL