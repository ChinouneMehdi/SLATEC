!DECK SGEDI
SUBROUTINE SGEDI(A,Lda,N,Ipvt,Det,Work,Job)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  SGEDI
  !***PURPOSE  Compute the determinant and inverse of a matrix using the
  !            factors computed by SGECO or SGEFA.
  !***LIBRARY   SLATEC (LINPACK)
  !***CATEGORY  D2A1, D3A1
  !***TYPE      SINGLE PRECISION (SGEDI-S, DGEDI-D, CGEDI-C)
  !***KEYWORDS  DETERMINANT, INVERSE, LINEAR ALGEBRA, LINPACK, MATRIX
  !***AUTHOR  Moler, C. B., (U. of New Mexico)
  !***DESCRIPTION
  !
  !     SGEDI computes the determinant and inverse of a matrix
  !     using the factors computed by SGECO or SGEFA.
  !
  !     On Entry
  !
  !        A       REAL(LDA, N)
  !                the output from SGECO or SGEFA.
  !
  !        LDA     INTEGER
  !                the leading dimension of the array  A .
  !
  !        N       INTEGER
  !                the order of the matrix  A .
  !
  !        IPVT    INTEGER(N)
  !                the pivot vector from SGECO or SGEFA.
  !
  !        WORK    REAL(N)
  !                work vector.  Contents destroyed.
  !
  !        JOB     INTEGER
  !                = 11   both determinant and inverse.
  !                = 01   inverse only.
  !                = 10   determinant only.
  !
  !     On Return
  !
  !        A       inverse of original matrix if requested.
  !                Otherwise unchanged.
  !
  !        DET     REAL(2)
  !                determinant of original matrix if requested.
  !                Otherwise not referenced.
  !                Determinant = DET(1) * 10.0**DET(2)
  !                with  1.0 .LE. ABS(DET(1)) .LT. 10.0
  !                or  DET(1) .EQ. 0.0 .
  !
  !     Error Condition
  !
  !        A division by zero will occur if the input factor contains
  !        a zero on the diagonal and the inverse is requested.
  !        It will not occur if the subroutines are called correctly
  !        and if SGECO has set RCOND .GT. 0.0 or SGEFA has set
  !        INFO .EQ. 0 .
  !
  !***REFERENCES  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***ROUTINES CALLED  SAXPY, SSCAL, SSWAP
  !***REVISION HISTORY  (YYMMDD)
  !   780814  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  !***END PROLOGUE  SGEDI
  INTEGER Lda, N, Ipvt(*), Job
  REAL A(Lda,*), Det(2), Work(*)
  !
  REAL t
  REAL ten
  INTEGER i, j, k, kb, kp1, l, nm1
  !***FIRST EXECUTABLE STATEMENT  SGEDI
  !
  !     COMPUTE DETERMINANT
  !
  IF ( Job/10/=0 ) THEN
    Det(1) = 1.0E0
    Det(2) = 0.0E0
    ten = 10.0E0
    DO i = 1, N
      IF ( Ipvt(i)/=i ) Det(1) = -Det(1)
      Det(1) = A(i,i)*Det(1)
      IF ( Det(1)==0.0E0 ) EXIT
      DO WHILE ( ABS(Det(1))<1.0E0 )
        Det(1) = ten*Det(1)
        Det(2) = Det(2) - 1.0E0
      ENDDO
      DO WHILE ( ABS(Det(1))>=ten )
        Det(1) = Det(1)/ten
        Det(2) = Det(2) + 1.0E0
      ENDDO
    ENDDO
  ENDIF
  !
  !     COMPUTE INVERSE(U)
  !
  IF ( MOD(Job,10)/=0 ) THEN
    DO k = 1, N
      A(k,k) = 1.0E0/A(k,k)
      t = -A(k,k)
      CALL SSCAL(k-1,t,A(1,k),1)
      kp1 = k + 1
      IF ( N>=kp1 ) THEN
        DO j = kp1, N
          t = A(k,j)
          A(k,j) = 0.0E0
          CALL SAXPY(k,t,A(1,k),1,A(1,j),1)
        ENDDO
      ENDIF
    ENDDO
    !
    !        FORM INVERSE(U)*INVERSE(L)
    !
    nm1 = N - 1
    IF ( nm1>=1 ) THEN
      DO kb = 1, nm1
        k = N - kb
        kp1 = k + 1
        DO i = kp1, N
          Work(i) = A(i,k)
          A(i,k) = 0.0E0
        ENDDO
        DO j = kp1, N
          t = Work(j)
          CALL SAXPY(N,t,A(1,j),1,A(1,k),1)
        ENDDO
        l = Ipvt(k)
        IF ( l/=k ) CALL SSWAP(N,A(1,k),1,A(1,l),1)
      ENDDO
    ENDIF
  ENDIF
END SUBROUTINE SGEDI