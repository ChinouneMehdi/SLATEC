!DECK SPPSL
SUBROUTINE SPPSL(Ap,N,B)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  SPPSL
  !***PURPOSE  Solve the real symmetric positive definite system using
  !            the factors computed by SPPCO or SPPFA.
  !***LIBRARY   SLATEC (LINPACK)
  !***CATEGORY  D2B1B
  !***TYPE      SINGLE PRECISION (SPPSL-S, DPPSL-D, CPPSL-C)
  !***KEYWORDS  LINEAR ALGEBRA, LINPACK, MATRIX, PACKED,
  !             POSITIVE DEFINITE, SOLVE
  !***AUTHOR  Moler, C. B., (U. of New Mexico)
  !***DESCRIPTION
  !
  !     SPPSL solves the real symmetric positive definite system
  !     A * X = B
  !     using the factors computed by SPPCO or SPPFA.
  !
  !     On Entry
  !
  !        AP      REAL (N*(N+1)/2)
  !                the output from SPPCO or SPPFA.
  !
  !        N       INTEGER
  !                the order of the matrix  A .
  !
  !        B       REAL(N)
  !                the right hand side vector.
  !
  !     On Return
  !
  !        B       the solution vector  X .
  !
  !     Error Condition
  !
  !        A division by zero will occur if the input factor contains
  !        a zero on the diagonal.  Technically, this indicates
  !        singularity, but it is usually caused by improper subroutine
  !        arguments.  It will not occur if the subroutines are called
  !        correctly and  INFO .EQ. 0 .
  !
  !     To compute  INVERSE(A) * C  where  C  is a matrix
  !     with  P  columns
  !           CALL SPPCO(AP,N,RCOND,Z,INFO)
  !           IF (RCOND is too small .OR. INFO .NE. 0) GO TO ...
  !           DO 10 J = 1, P
  !              CALL SPPSL(AP,N,C(1,J))
  !        10 CONTINUE
  !
  !***REFERENCES  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***ROUTINES CALLED  SAXPY, SDOT
  !***REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  !***END PROLOGUE  SPPSL
  INTEGER N
  REAL Ap(*), B(*)
  !
  REAL SDOT, t
  INTEGER k, kb, kk
  !***FIRST EXECUTABLE STATEMENT  SPPSL
  kk = 0
  DO k = 1, N
    t = SDOT(k-1,Ap(kk+1),1,B(1),1)
    kk = kk + k
    B(k) = (B(k)-t)/Ap(kk)
  ENDDO
  DO kb = 1, N
    k = N + 1 - kb
    B(k) = B(k)/Ap(kk)
    kk = kk - k
    t = -B(k)
    CALL SAXPY(k-1,t,Ap(kk+1),1,B(1),1)
  ENDDO
END SUBROUTINE SPPSL