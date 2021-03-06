!** BNSLV
PURE SUBROUTINE BNSLV(W,Nroww,Nrow,Nbandl,Nbandu,B)
  !> Subsidiary to BINT4 and BINTK
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (BNSLV-S, DBNSLV-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !  BNSLV is the BANSLV routine from
  !        * A Practical Guide to Splines *  by C. de Boor
  !
  !  Companion routine to  BNFAC . It returns the solution  X  of the
  !  linear system  A*X = B  in place of  B, given the LU-factorization
  !  for  A  in the work array  W from BNFAC.
  !
  !- ****  I N P U T  ******
  !  W, NROWW,NROW,NBANDL,NBANDU.....Describe the LU-factorization of a
  !        banded matrix  A  of order  NROW  as constructed in  BNFAC .
  !        For details, see  BNFAC .
  !  B.....Right side of the system to be solved .
  !
  !- ****  O U T P U T  ******
  !  B.....Contains the solution  X, of order  NROW .
  !
  !- ****  M E T H O D  ******
  !     (With  A = L*U, as stored in  W,) the unit lower triangular system
  !  L(U*X) = B  is solved for  Y = U*X, and  Y  stored in  B . Then the
  !  upper triangular system  U*X = Y  is solved for  X  . The calcul-
  !  ations are so arranged that the innermost loops stay within columns.
  !
  !***
  ! **See also:**  BINT4, BINTK
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)

  !
  INTEGER, INTENT(IN) :: Nbandl, Nbandu, Nrow, Nroww
  REAL(SP), INTENT(IN) :: W(Nroww,Nrow)
  REAL(SP), INTENT(INOUT) :: B(Nrow)
  INTEGER :: i, j, jmax, middle, nrowm1
  !* FIRST EXECUTABLE STATEMENT  BNSLV
  middle = Nbandu + 1
  IF( Nrow==1 ) THEN
    B(1) = B(1)/W(middle,1)
  ELSE
    nrowm1 = Nrow - 1
    IF( Nbandl/=0 ) THEN
      !                                 FORWARD PASS
      !            FOR I=1,2,...,NROW-1, SUBTRACT  RIGHT SIDE(I)*(I-TH COLUMN
      !            OF  L )  FROM RIGHT SIDE  (BELOW I-TH ROW) .
      DO i = 1, nrowm1
        jmax = MIN(Nbandl,Nrow-i)
        DO j = 1, jmax
          B(i+j) = B(i+j) - B(i)*W(middle+j,i)
        END DO
      END DO
    END IF
    !                                 BACKWARD PASS
    !            FOR I=NROW,NROW-1,...,1, DIVIDE RIGHT SIDE(I) BY I-TH DIAG-
    !            ONAL ENTRY OF  U, THEN SUBTRACT  RIGHT SIDE(I)*(I-TH COLUMN
    !            OF  U)  FROM RIGHT SIDE  (ABOVE I-TH ROW).
    IF( Nbandu>0 ) THEN
      i = Nrow
      DO
        B(i) = B(i)/W(middle,i)
        jmax = MIN(Nbandu,i-1)
        DO j = 1, jmax
          B(i-j) = B(i-j) - B(i)*W(middle-j,i)
        END DO
        i = i - 1
        IF( i<=1 ) THEN
          B(1) = B(1)/W(middle,1)
          EXIT
        END IF
      END DO
    ELSE
      !  A  IS LOWER TRIANGULAR .
      DO i = 1, Nrow
        B(i) = B(i)/W(1,i)
      END DO
      RETURN
    END IF
  END IF

END SUBROUTINE BNSLV