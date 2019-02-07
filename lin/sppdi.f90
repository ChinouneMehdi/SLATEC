!*==SPPDI.f90  processed by SPAG 6.72Dc at 10:58 on  6 Feb 2019
!DECK SPPDI
SUBROUTINE SPPDI(Ap,N,Det,Job)
  IMPLICIT NONE
  !*--SPPDI5
  !***BEGIN PROLOGUE  SPPDI
  !***PURPOSE  Compute the determinant and inverse of a real symmetric
  !            positive definite matrix using factors from SPPCO or SPPFA.
  !***LIBRARY   SLATEC (LINPACK)
  !***CATEGORY  D2B1B, D3B1B
  !***TYPE      SINGLE PRECISION (SPPDI-S, DPPDI-D, CPPDI-C)
  !***KEYWORDS  DETERMINANT, INVERSE, LINEAR ALGEBRA, LINPACK, MATRIX,
  !             PACKED, POSITIVE DEFINITE
  !***AUTHOR  Moler, C. B., (U. of New Mexico)
  !***DESCRIPTION
  !
  !     SPPDI computes the determinant and inverse
  !     of a real symmetric positive definite matrix
  !     using the factors computed by SPPCO or SPPFA .
  !
  !     On Entry
  !
  !        AP      REAL (N*(N+1)/2)
  !                the output from SPPCO or SPPFA.
  !
  !        N       INTEGER
  !                the order of the matrix  A .
  !
  !        JOB     INTEGER
  !                = 11   both determinant and inverse.
  !                = 01   inverse only.
  !                = 10   determinant only.
  !
  !     On Return
  !
  !        AP      the upper triangular half of the inverse .
  !                The strict lower triangle is unaltered.
  !
  !        DET     REAL(2)
  !                determinant of original matrix if requested.
  !                Otherwise not referenced.
  !                Determinant = DET(1) * 10.0**DET(2)
  !                with  1.0 .LE. DET(1) .LT. 10.0
  !                or  DET(1) .EQ. 0.0 .
  !
  !     Error Condition
  !
  !        A division by zero will occur if the input factor contains
  !        a zero on the diagonal and the inverse is requested.
  !        It will not occur if the subroutines are called correctly
  !        and if SPOCO or SPOFA has set INFO .EQ. 0 .
  !
  !***REFERENCES  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***ROUTINES CALLED  SAXPY, SSCAL
  !***REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  !***END PROLOGUE  SPPDI
  INTEGER N, Job
  REAL Ap(*)
  REAL Det(2)
  !
  REAL t
  REAL s
  INTEGER i, ii, j, jj, jm1, j1, k, kj, kk, kp1, k1
  !***FIRST EXECUTABLE STATEMENT  SPPDI
  !
  !     COMPUTE DETERMINANT
  !
  IF ( Job/10/=0 ) THEN
    Det(1) = 1.0E0
    Det(2) = 0.0E0
    s = 10.0E0
    ii = 0
    DO i = 1, N
      ii = ii + i
      Det(1) = Ap(ii)**2*Det(1)
      IF ( Det(1)==0.0E0 ) EXIT
      DO WHILE ( Det(1)<1.0E0 )
        Det(1) = s*Det(1)
        Det(2) = Det(2) - 1.0E0
      ENDDO
      DO WHILE ( Det(1)>=s )
        Det(1) = Det(1)/s
        Det(2) = Det(2) + 1.0E0
      ENDDO
    ENDDO
  ENDIF
  !
  !     COMPUTE INVERSE(R)
  !
  IF ( MOD(Job,10)/=0 ) THEN
    kk = 0
    DO k = 1, N
      k1 = kk + 1
      kk = kk + k
      Ap(kk) = 1.0E0/Ap(kk)
      t = -Ap(kk)
      CALL SSCAL(k-1,t,Ap(k1),1)
      kp1 = k + 1
      j1 = kk + 1
      kj = kk + k
      IF ( N>=kp1 ) THEN
        DO j = kp1, N
          t = Ap(kj)
          Ap(kj) = 0.0E0
          CALL SAXPY(k,t,Ap(k1),1,Ap(j1),1)
          j1 = j1 + j
          kj = kj + j
        ENDDO
      ENDIF
    ENDDO
    !
    !        FORM  INVERSE(R) * TRANS(INVERSE(R))
    !
    jj = 0
    DO j = 1, N
      j1 = jj + 1
      jj = jj + j
      jm1 = j - 1
      k1 = 1
      kj = j1
      IF ( jm1>=1 ) THEN
        DO k = 1, jm1
          t = Ap(kj)
          CALL SAXPY(k,t,Ap(j1),1,Ap(k1),1)
          k1 = k1 + k
          kj = kj + 1
        ENDDO
      ENDIF
      t = Ap(jj)
      CALL SSCAL(j,t,Ap(j1),1)
    ENDDO
  ENDIF
END SUBROUTINE SPPDI
