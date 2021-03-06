!** POISTG
PURE SUBROUTINE POISTG(Nperod,N,Mperod,M,A,B,C,Idimy,Y,Ierror,W)
  !> Solve a block tridiagonal system of linear equations that results from
  !  a staggered grid finite difference approximation to 2-D elliptic PDE's.
  !***
  ! **Library:**   SLATEC (FISHPACK)
  !***
  ! **Category:**  I2B4B
  !***
  ! **Type:**      SINGLE PRECISION (POISTG-S)
  !***
  ! **Keywords:**  ELLIPTIC, FISHPACK, HELMHOLTZ, PDE, TRIDIAGONAL
  !***
  ! **Author:**  Adams, J., (NCAR)
  !           Swarztrauber, P. N., (NCAR)
  !           Sweet, R., (NCAR)
  !***
  ! **Description:**
  !
  !     Subroutine POISTG solves the linear system of equations
  !
  !       A(I)*X(I-1,J) + B(I)*X(I,J) + C(I)*X(I+1,J)
  !       + X(I,J-1) - 2.*X(I,J) + X(I,J+1) = Y(I,J)
  !
  !       for I=1,2,...,M and J=1,2,...,N.
  !
  !     The indices I+1 and I-1 are evaluated modulo M, i.e.
  !     X(0,J) = X(M,J) and X(M+1,J) = X(1,J), and X(I,0) may be equal to
  !     X(I,1) or -X(I,1) and X(I,N+1) may be equal to X(I,N) or -X(I,N)
  !     depending on an input parameter.
  !
  !
  !     * * * * * * * *    Parameter Description     * * * * * * * * * *
  !
  !             * * * * * *   On Input    * * * * * *
  !
  !   NPEROD
  !     Indicates the values which X(I,0) and X(I,N+1) are assumed
  !     to have.
  !     = 1 If X(I,0) = -X(I,1) and X(I,N+1) = -X(I,N)
  !     = 2 If X(I,0) = -X(I,1) and X(I,N+1) =  X(I,N)
  !     = 3 If X(I,0) =  X(I,1) and X(I,N+1) =  X(I,N)
  !     = 4 If X(I,0) =  X(I,1) and X(I,N+1) = -X(I,N)
  !
  !   N
  !     The number of unknowns in the J-direction.  N must
  !     be greater than 2.
  !
  !   MPEROD
  !     = 0 If A(1) and C(M) are not zero
  !     = 1 If A(1) = C(M) = 0
  !
  !   M
  !     The number of unknowns in the I-direction.  M must
  !     be greater than 2.
  !
  !   A,B,C
  !     One-dimensional arrays of length M that specify the coefficients
  !     in the linear equations given above.  If MPEROD = 0 the array
  !     elements must not depend on the index I, but must be constant.
  !     Specifically, the subroutine checks the following condition
  !
  !           A(I) = C(1)
  !           B(I) = B(1)
  !           C(I) = C(1)
  !
  !     for I = 1, 2, ..., M.
  !
  !   IDIMY
  !     The row (or first) dimension of the two-dimensional array Y as
  !     it appears in the program calling POISTG.  This parameter is
  !     used to specify the variable dimension of Y.  IDIMY must be at
  !     least M.
  !
  !   Y
  !     A two-dimensional array that specifies the values of the
  !     right side of the linear system of equations given above.
  !     Y must be dimensioned at least M X N.
  !
  !   W
  !     A one-dimensional work array that must be provided by the user
  !     for work space.  W may require up to 9M + 4N + M(INT(log2(N)))
  !     locations.  The actual number of locations used is computed by
  !     POISTG and returned in location W(1).
  !
  !
  !             * * * * * *   On Output     * * * * * *
  !
  !   Y
  !     Contains the solution X.
  !
  !   IERROR
  !     An error flag that indicates invalid input parameters.  Except
  !     for number zero, a solution is not attempted.
  !     = 0  No error
  !     = 1  If M <= 2
  !     = 2  If N <= 2
  !     = 3  IDIMY < M
  !     = 4  If NPEROD < 1 or NPEROD > 4
  !     = 5  If MPEROD < 0 or MPEROD > 1
  !     = 6  If MPEROD = 0 and
  !          A(I) /= C(1) or B(I) /= B(1) or C(I) /= C(1)
  !          for some I = 1, 2, ..., M.
  !       = 7 If MPEROD = 1 .AND. (A(1)/=0 .OR. C(M)/=0)
  !
  !   W
  !     W(1) contains the required length of W.
  !
  !- Long Description:
  !
  !     * * * * * * *   Program Specifications    * * * * * * * * * * * *
  !
  !     Dimension of   A(M),B(M),C(M),Y(IDIMY,N),
  !     Arguments      W(see argument list)
  !
  !     Latest         June 1, 1977
  !     Revision
  !
  !     Subprograms    POISTG,POSTG2,COSGEN,MERGE,TRIX,TRI3,PIMACH
  !     Required
  !
  !     Special        NONE
  !     Conditions
  !
  !     Common         NONE
  !     Blocks
  !
  !     I/O            NONE
  !
  !     Precision      Single
  !
  !     Specialist     Roland Sweet
  !
  !     Language       FORTRAN
  !
  !     History        Written by Roland Sweet in 1973
  !                    Revised by Roland Sweet in 1977
  !
  !
  !     Space          3297(decimal) = 6341(octal) locations on the
  !     Required       NCAR Control Data 7600
  !
  !     Timing and        The execution time T on the NCAR Control Data
  !     Accuracy       7600 for subroutine POISTG is roughly proportional
  !                    to M*N*log2(N).  Some typical values are listed
  !                    in the table below.  More comprehensive timing
  !                    charts may be found in the reference.
  !                       To measure the accuracy of the algorithm a
  !                    uniform random number generator was used to create
  !                    a solution array X for the system given in the
  !                    'PURPOSE ' with
  !
  !                       A(I) = C(I) = -0.5*B(I) = 1,       I=1,2,...,M
  !
  !                    and, when MPEROD = 1
  !
  !                       A(1) = C(M) = 0
  !                       B(1) = B(M) =-1.
  !
  !                    The solution X was substituted into the given sys-
  !                    tem and, using double precision, a right side Y was
  !                    computed.  Using this array Y subroutine POISTG was
  !                    called to produce an approximate solution Z.  Then
  !                    the relative error, defined as
  !
  !                       E = MAX(ABS(Z(I,J)-X(I,J)))/MAX(ABS(X(I,J)))
  !
  !                    where the two maxima are taken over all I=1,2,...,M
  !                    and J=1,2,...,N, was computed.  The value of E is
  !                    given in the table below for some typical values of
  !                    M and N.
  !
  !
  !                       M (=N)    MPEROD    NPEROD    T(MSECS)    E
  !                       ------    ------    ------    --------  ------
  !
  !                         31        0-1       1-4        45     9.E-13
  !                         31        1         1          21     4.E-13
  !                         31        1         3          41     3.E-13
  !                         32        0-1       1-4        51     3.E-12
  !                         32        1         1          32     3.E-13
  !                         32        1         3          48     1.E-13
  !                         33        0-1       1-4        42     1.E-12
  !                         33        1         1          30     4.E-13
  !                         33        1         3          34     1.E-13
  !                         63        0-1       1-4       186     3.E-12
  !                         63        1         1          91     1.E-12
  !                         63        1         3         173     2.E-13
  !                         64        0-1       1-4       209     4.E-12
  !                         64        1         1         128     1.E-12
  !                         64        1         3         199     6.E-13
  !                         65        0-1       1-4       143     2.E-13
  !                         65        1         1         160     1.E-11
  !                         65        1         3         138     4.E-13
  !
  !     Portability    American National Standards Institute FORTRAN.
  !                    The machine dependent constant PI is defined in
  !                    function PIMACH.
  !
  !     Required       COS
  !     Resident
  !     Routines
  !
  !     Reference      Schumann, U. and R. Sweet,'A Direct Method for
  !                    the Solution of Poisson's Equation With Neumann
  !                    Boundary Conditions on a Staggered Grid of
  !                    Arbitrary Size,' J. Comp. Phys. 20(1976),
  !                    pp. 171-182.
  !
  !     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  !
  !***
  ! **References:**  U. Schumann and R. Sweet, A direct method for the
  !                 solution of Poisson's equation with Neumann boundary
  !                 conditions on a staggered grid of arbitrary size,
  !                 Journal of Computational Physics 20, (1976),
  !                 pp. 171-182.
  !***
  ! **Routines called:**  POSTG2

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   861211  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER, INTENT(IN) :: Idimy, M, Mperod, N, Nperod
  INTEGER, INTENT(OUT) :: Ierror
  REAL(SP), INTENT(IN) :: A(M), B(M), C(M)
  REAL(SP), INTENT(INOUT) :: W(:), Y(Idimy,N)
  !
  INTEGER :: i, ipstor, irev, iwb2, iwb3, iwba, iwbb, iwbc, iwd, iwp, iwtcos, &
    iww1, iww2, iww3, j, k, mh, mhm1, mhmi, mhpi, modd, mp, mskip, nby2, np
  REAL(SP) :: a1
  !* FIRST EXECUTABLE STATEMENT  POISTG
  Ierror = 0
  IF( M<=2 ) Ierror = 1
  IF( N<=2 ) Ierror = 2
  IF( Idimy<M ) Ierror = 3
  IF( Nperod<1 .OR. Nperod>4 ) Ierror = 4
  IF( Mperod<0 .OR. Mperod>1 ) Ierror = 5
  IF( Mperod==1 ) THEN
    IF( A(1)/=0. .OR. C(M)/=0. ) Ierror = 7
  ELSE
    DO i = 1, M
      IF( A(i)/=C(1) ) GOTO 100
      IF( C(i)/=C(1) ) GOTO 100
      IF( B(i)/=B(1) ) GOTO 100
    END DO
  END IF
  IF( Ierror/=0 ) RETURN
  iwba = M + 1
  iwbb = iwba + M
  iwbc = iwbb + M
  iwb2 = iwbc + M
  iwb3 = iwb2 + M
  iww1 = iwb3 + M
  iww2 = iww1 + M
  iww3 = iww2 + M
  iwd = iww3 + M
  iwtcos = iwd + M
  iwp = iwtcos + 4*N
  DO i = 1, M
    k = iwba + i - 1
    W(k) = -A(i)
    k = iwbc + i - 1
    W(k) = -C(i)
    k = iwbb + i - 1
    W(k) = 2._SP - B(i)
    DO j = 1, N
      Y(i,j) = -Y(i,j)
    END DO
  END DO
  np = Nperod
  mp = Mperod + 1
  IF( mp/=1 ) GOTO 200
  GOTO 500
  100  Ierror = 6
  RETURN
  200 CONTINUE
  SELECT CASE (Nperod)
    CASE (4)
      !
      !     REVERSE COLUMNS WHEN NPEROD = 4.
      !
      irev = 1
      nby2 = N/2
      np = 2
      GOTO 600
    CASE DEFAULT
  END SELECT
  300  CALL POSTG2(np,N,M,W(iwba:iwbb-1),W(iwbb:iwbc-1),W(iwbc:iwb2-1),Idimy,Y,&
    W(1:iwba-1),W(iwb2:iwb3-1),W(iwb3:iww1-1),W(iww1:iww2-1),W(iww2:iww3-1),&
    W(iww3:iwd-1),W(iwd:iwtcos-1),W(iwtcos:iwp-1),W(iwp:))
  ipstor = INT( W(iww1) )
  irev = 2
  IF( Nperod==4 ) GOTO 600
  400 CONTINUE
  IF( mp==1 ) GOTO 700
  IF( mp==2 ) GOTO 800
  !
  !     REORDER UNKNOWNS WHEN MP =0
  !
  500  mh = (M+1)/2
  mhm1 = mh - 1
  modd = 1
  IF( mh*2==M ) modd = 2
  DO j = 1, N
    DO i = 1, mhm1
      mhpi = mh + i
      mhmi = mh - i
      W(i) = Y(mhmi,j) - Y(mhpi,j)
      W(mhpi) = Y(mhmi,j) + Y(mhpi,j)
    END DO
    W(mh) = 2._SP*Y(mh,j)
    IF( modd/=1 ) W(M) = 2._SP*Y(M,j)
    DO i = 1, M
      Y(i,j) = W(i)
    END DO
  END DO
  k = iwbc + mhm1 - 1
  i = iwba + mhm1
  W(k) = 0._SP
  W(i) = 0._SP
  W(k+1) = 2._SP*W(k+1)
  IF( modd==2 ) THEN
    W(iwbb-1) = W(k+1)
  ELSE
    k = iwbb + mhm1 - 1
    W(k) = W(k) - W(i-1)
    W(iwbc-1) = W(iwbc-1) + W(iwbb-1)
  END IF
  GOTO 200
  600 CONTINUE
  DO j = 1, nby2
    mskip = N + 1 - j
    DO i = 1, M
      a1 = Y(i,j)
      Y(i,j) = Y(i,mskip)
      Y(i,mskip) = a1
    END DO
  END DO
  IF( irev==1 ) GOTO 300
  IF( irev==2 ) GOTO 400
  700 CONTINUE
  DO j = 1, N
    DO i = 1, mhm1
      mhmi = mh - i
      mhpi = mh + i
      W(mhmi) = 0.5_SP*(Y(mhpi,j)+Y(i,j))
      W(mhpi) = 0.5_SP*(Y(mhpi,j)-Y(i,j))
    END DO
    W(mh) = 0.5_SP*Y(mh,j)
    IF( modd/=1 ) W(M) = 0.5_SP*Y(M,j)
    DO i = 1, M
      Y(i,j) = W(i)
    END DO
  END DO
  !
  !     RETURN STORAGE REQUIREMENTS FOR W ARRAY.
  !
  800  W(1) = ipstor + iwp - 1
  !
END SUBROUTINE POISTG