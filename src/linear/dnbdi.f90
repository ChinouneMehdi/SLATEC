!** DNBDI
PURE SUBROUTINE DNBDI(Abe,Lda,N,Ml,Mu,Ipvt,Det)
  !> Compute the determinant of a band matrix using the factors computed by DNBCO or DNBFA.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  D3A2
  !***
  ! **Type:**      DOUBLE PRECISION (SNBDI-S, DNBDI-D, CNBDI-C)
  !***
  ! **Keywords:**  BANDED, DETERMINANT, LINEAR EQUATIONS, NONSYMMETRIC
  !***
  ! **Author:**  Voorhees, E. A., (LANL)
  !***
  ! **Description:**
  !
  !     DNBDI computes the determinant of a band matrix
  !     using the factors computed by DNBCO or DNBFA.
  !     If the inverse is needed, use DNBSL  N  times.
  !
  !     On Entry
  !
  !        ABE     DOUBLE PRECISION(LDA, NC)
  !                the output from DNBCO or DNBFA.
  !                NC must be >= 2*ML+MU+1 .
  !
  !        LDA     INTEGER
  !                the leading dimension of the array  ABE .
  !
  !        N       INTEGER
  !                the order of the original matrix.
  !
  !        ML      INTEGER
  !                number of diagonals below the main diagonal.
  !
  !        MU      INTEGER
  !                number of diagonals above the main diagonal.
  !
  !        IPVT    INTEGER(N)
  !                the pivot vector from DNBCO or DNBFA.
  !
  !     On Return
  !
  !        DET     DOUBLE PRECISION(2)
  !                determinant of original matrix.
  !                Determinant = DET(1) * 10.0**DET(2)
  !                with  1.0 <= ABS(DET(1)) < 10.0
  !                or  DET(1) = 0.0 .
  !
  !***
  ! **References:**  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   800728  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: Lda, N, Ml, Mu, Ipvt(N)
  REAL(DP), INTENT(IN) :: Abe(Lda,2*Ml+Mu+1)
  REAL(DP), INTENT(OUT) :: Det(2)
  !
  INTEGER :: i
  !* FIRST EXECUTABLE STATEMENT  DNBDI
  Det(1) = 1._DP
  Det(2) = 0._DP
  DO i = 1, N
    IF( Ipvt(i)/=i ) Det(1) = -Det(1)
    Det(1) = Abe(i,Ml+1)*Det(1)
    IF( Det(1)==0._DP ) EXIT
    DO WHILE( ABS(Det(1))<1._DP )
      Det(1) = 10._DP*Det(1)
      Det(2) = Det(2) - 1._DP
    END DO
    DO WHILE( ABS(Det(1))>=10._DP )
      Det(1) = Det(1)/10._DP
      Det(2) = Det(2) + 1._DP
    END DO
  END DO

END SUBROUTINE DNBDI