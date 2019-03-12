!DECK DBNSLV
SUBROUTINE DBNSLV(W,Nroww,Nrow,Nbandl,Nbandu,B)
  IMPLICIT NONE
  !***BEGIN PROLOGUE  DBNSLV
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to DBINT4 and DBINTK
  !***LIBRARY   SLATEC
  !***TYPE      DOUBLE PRECISION (BNSLV-S, DBNSLV-D)
  !***AUTHOR  (UNKNOWN)
  !***DESCRIPTION
  !
  !  DBNSLV is the BANSLV routine from
  !        * A Practical Guide to Splines *  by C. de Boor
  !
  !  DBNSLV is a double precision routine
  !
  !  Companion routine to  DBNFAC . It returns the solution  X  of the
  !  linear system  A*X = B  in place of  B, given the LU-factorization
  !  for  A  in the work array  W from DBNFAC.
  !
  ! *****  I N P U T  ****** W,B are DOUBLE PRECISION
  !  W, NROWW,NROW,NBANDL,NBANDU.....Describe the LU-factorization of a
  !        banded matrix  A  of order  NROW  as constructed in  DBNFAC .
  !        For details, see  DBNFAC .
  !  B.....Right side of the system to be solved .
  !
  ! *****  O U T P U T  ****** B is DOUBLE PRECISION
  !  B.....Contains the solution  X, of order  NROW .
  !
  ! *****  M E T H O D  ******
  !     (With  A = L*U, as stored in  W,) the unit lower triangular system
  !  L(U*X) = B  is solved for  Y = U*X, and  Y  stored in  B . Then the
  !  upper triangular system  U*X = Y  is solved for  X  . The calcul-
  !  ations are so arranged that the innermost loops stay within columns.
  !
  !***SEE ALSO  DBINT4, DBINTK
  !***ROUTINES CALLED  (NONE)
  !***REVISION HISTORY  (YYMMDD)
  !   800901  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !***END PROLOGUE  DBNSLV
  !
  INTEGER Nbandl, Nbandu, Nrow, Nroww, i, j, jmax, middle, nrowm1
  REAL(8) :: W(Nroww,*), B(*)
  !***FIRST EXECUTABLE STATEMENT  DBNSLV
  middle = Nbandu + 1
  IF ( Nrow==1 ) THEN
    B(1) = B(1)/W(middle,1)
  ELSE
    nrowm1 = Nrow - 1
    IF ( Nbandl/=0 ) THEN
      !                                 FORWARD PASS
      !            FOR I=1,2,...,NROW-1, SUBTRACT  RIGHT SIDE(I)*(I-TH COLUMN
      !            OF  L )  FROM RIGHT SIDE  (BELOW I-TH ROW) .
      DO i = 1, nrowm1
        jmax = MIN(Nbandl,Nrow-i)
        DO j = 1, jmax
          B(i+j) = B(i+j) - B(i)*W(middle+j,i)
        ENDDO
      ENDDO
    ENDIF
    !                                 BACKWARD PASS
    !            FOR I=NROW,NROW-1,...,1, DIVIDE RIGHT SIDE(I) BY I-TH DIAG-
    !            ONAL ENTRY OF  U, THEN SUBTRACT  RIGHT SIDE(I)*(I-TH COLUMN
    !            OF  U)  FROM RIGHT SIDE  (ABOVE I-TH ROW).
    IF ( Nbandu>0 ) THEN
      i = Nrow
      DO
        B(i) = B(i)/W(middle,i)
        jmax = MIN(Nbandu,i-1)
        DO j = 1, jmax
          B(i-j) = B(i-j) - B(i)*W(middle-j,i)
        ENDDO
        i = i - 1
        IF ( i<=1 ) THEN
          B(1) = B(1)/W(middle,1)
          EXIT
        ENDIF
      ENDDO
    ELSE
      !                                A  IS LOWER TRIANGULAR .
      DO i = 1, Nrow
        B(i) = B(i)/W(1,i)
      ENDDO
      RETURN
    ENDIF
  ENDIF
END SUBROUTINE DBNSLV