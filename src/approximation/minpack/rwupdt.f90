!** RWUPDT
SUBROUTINE RWUPDT(N,R,Ldr,W,B,Alpha,Cos,Sin)
  IMPLICIT NONE
  !>
  !***
  !  Subsidiary to SNLS1 and SNLS1E
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (RWUPDT-S, DWUPDT-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     Given an N by N upper triangular matrix R, this subroutine
  !     computes the QR decomposition of the matrix formed when a row
  !     is added to R. If the row is specified by the vector W, then
  !     RWUPDT determines an orthogonal matrix Q such that when the
  !     N+1 by N matrix composed of R augmented by W is premultiplied
  !     by (Q TRANSPOSE), the resulting matrix is upper trapezoidal.
  !     The orthogonal matrix Q is the product of N transformations
  !
  !           G(1)*G(2)* ... *G(N)
  !
  !     where G(I) is a Givens rotation in the (I,N+1) plane which
  !     eliminates elements in the I-th plane. RWUPDT also
  !     computes the product (Q TRANSPOSE)*C where C is the
  !     (N+1)-vector (b,alpha). Q itself is not accumulated, rather
  !     the information to recover the G rotations is supplied.
  !
  !     The subroutine statement is
  !
  !       SUBROUTINE RWUPDT(N,R,LDR,W,B,ALPHA,COS,SIN)
  !
  !     where
  !
  !       N is a positive integer input variable set to the order of R.
  !
  !       R is an N by N array. On input the upper triangular part of
  !         R must contain the matrix to be updated. On output R
  !         contains the updated triangular matrix.
  !
  !       LDR is a positive integer input variable not less than N
  !         which specifies the leading dimension of the array R.
  !
  !       W is an input array of length N which must contain the row
  !         vector to be added to R.
  !
  !       B is an array of length N. On input B must contain the
  !         first N elements of the vector C. On output B contains
  !         the first N elements of the vector (Q TRANSPOSE)*C.
  !
  !       ALPHA is a variable. On input ALPHA must contain the
  !         (N+1)-st element of the vector C. On output ALPHA contains
  !         the (N+1)-st element of the vector (Q TRANSPOSE)*C.
  !
  !       COS is an output array of length N which contains the
  !         cosines of the transforming Givens rotations.
  !
  !       SIN is an output array of length N which contains the
  !         sines of the transforming Givens rotations.
  !
  !***
  ! **See also:**  SNLS1, SNLS1E
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   800301  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900326  Removed duplicate information from DESCRIPTION section.
  !           (WRB)
  !   900328  Added TYPE section.  (WRB)

  INTEGER N, Ldr
  REAL Alpha
  REAL R(Ldr,*), W(*), B(*), Cos(*), Sin(*)
  INTEGER i, j, jm1
  REAL cotan, rowj, tan, temp
  REAL, PARAMETER :: one = 1.0E0, p5 = 5.0E-1, p25 = 2.5E-1, zero = 0.0E0
  !* FIRST EXECUTABLE STATEMENT  RWUPDT
  DO j = 1, N
    rowj = W(j)
    jm1 = j - 1
    !
    !        APPLY THE PREVIOUS TRANSFORMATIONS TO
    !        R(I,J), I=1,2,...,J-1, AND TO W(J).
    !
    IF ( jm1>=1 ) THEN
      DO i = 1, jm1
        temp = Cos(i)*R(i,j) + Sin(i)*rowj
        rowj = -Sin(i)*R(i,j) + Cos(i)*rowj
        R(i,j) = temp
      END DO
    END IF
    !
    !        DETERMINE A GIVENS ROTATION WHICH ELIMINATES W(J).
    !
    Cos(j) = one
    Sin(j) = zero
    IF ( rowj/=zero ) THEN
      IF ( ABS(R(j,j))>=ABS(rowj) ) THEN
        tan = rowj/R(j,j)
        Cos(j) = p5/SQRT(p25+p25*tan**2)
        Sin(j) = Cos(j)*tan
      ELSE
        cotan = R(j,j)/rowj
        Sin(j) = p5/SQRT(p25+p25*cotan**2)
        Cos(j) = Sin(j)*cotan
      END IF
      !
      !        APPLY THE CURRENT TRANSFORMATION TO R(J,J), B(J), AND ALPHA.
      !
      R(j,j) = Cos(j)*R(j,j) + Sin(j)*rowj
      temp = Cos(j)*B(j) + Sin(j)*Alpha
      Alpha = -Sin(j)*B(j) + Cos(j)*Alpha
      B(j) = temp
    END IF
  END DO
  !
  !     LAST CARD OF SUBROUTINE RWUPDT.
  !
END SUBROUTINE RWUPDT