!** CNBDI
SUBROUTINE CNBDI(Abe,Lda,N,Ml,Mu,Ipvt,Det)
  !>
  !  Compute the determinant of a band matrix using the factors
  !            computed by CNBCO or CNBFA.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  D3C2
  !***
  ! **Type:**      COMPLEX (SNBDI-S, DNBDI-D, CNBDI-C)
  !***
  ! **Keywords:**  BANDED, DETERMINANT, LINEAR EQUATIONS, NONSYMMETRIC
  !***
  ! **Author:**  Voorhees, E. A., (LANL)
  !***
  ! **Description:**
  !
  !     CNBDI computes the determinant of a band matrix
  !     using the factors computed by CNBCO or CNBFA.
  !     If the inverse is needed, use CNBSL  N  times.
  !
  !     On Entry
  !
  !        ABE     COMPLEX(LDA, NC)
  !                the output from CNBCO or CNBFA.
  !                NC must be .GE. 2*ML+MU+1 .
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
  !                the pivot vector from CNBCO or CNBFA.
  !
  !     On Return
  !
  !        DET     COMPLEX(2)
  !                determinant of original matrix.
  !                Determinant = DET(1) * 10.0**DET(2)
  !                with  1.0 .LE. CABS1(DET(1)) .LT. 10.0
  !                or  DET(1) = 0.0 .
  !
  !***
  ! **References:**  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   800730  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  USE blas, ONLY : SCABS1
  INTEGER :: Lda, N, Ml, Mu, Ipvt(N)
  COMPLEX(SP) :: Abe(Lda,2*Ml+Mu+1), Det(2)
  !
  REAL(SP) :: ten
  INTEGER :: i
  !
  !* FIRST EXECUTABLE STATEMENT  CNBDI
  Det(1) = (1.0E0,0.0E0)
  Det(2) = (0.0E0,0.0E0)
  ten = 10.0E0
  DO i = 1, N
    IF ( Ipvt(i)/=i ) Det(1) = -Det(1)
    Det(1) = Abe(i,Ml+1)*Det(1)
    IF ( SCABS1(Det(1))==0.0E0 ) EXIT
    DO WHILE ( SCABS1(Det(1))<1.0E0 )
      Det(1) = CMPLX(ten,0.0E0)*Det(1)
      Det(2) = Det(2) - (1.0E0,0.0E0)
    END DO
    DO WHILE ( SCABS1(Det(1))>=ten )
      Det(1) = Det(1)/CMPLX(ten,0.0E0)
      Det(2) = Det(2) + (1.0E0,0.0E0)
    END DO
  END DO
END SUBROUTINE CNBDI
