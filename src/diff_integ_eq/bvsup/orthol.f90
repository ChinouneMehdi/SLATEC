!** ORTHOL
PURE SUBROUTINE ORTHOL(A,M,N,Nrda,Iflag,Irank,Iscale,Diag,Kpivot,Scales,Cols,Cs)
  !> Subsidiary to BVSUP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (ORTHOL-S)
  !***
  ! **Author:**  Watts, H. A., (SNLA)
  !***
  ! **Description:**
  !
  !   Reduction of the matrix A to upper triangular form by a sequence of
  !   orthogonal HOUSEHOLDER transformations pre-multiplying A
  !
  !   Modeled after the ALGOL codes in the articles in the REFERENCES
  !   section.
  !
  !- *********************************************************************
  !   INPUT
  !- *********************************************************************
  !
  !     A -- Contains the matrix to be decomposed, must be dimensioned
  !           NRDA by N
  !     M -- Number of rows in the matrix, M greater or equal to N
  !     N -- Number of columns in the matrix, N greater or equal to 1
  !     IFLAG -- Indicates the uncertainty in the matrix data
  !             = 0 when the data is to be treated as exact
  !             =-K when the data is assumed to be accurate to about
  !                 K digits
  !     ISCALE -- Scaling indicator
  !               =-1 if the matrix A is to be pre-scaled by
  !               columns when appropriate.
  !               Otherwise no scaling will be attempted
  !     NRDA -- Row dimension of A, NRDA greater or equal to M
  !     DIAG,KPIVOT,COLS -- Arrays of length at least n used internally
  !         ,CS,SCALES
  !
  !- *********************************************************************
  !   OUTPUT
  !- *********************************************************************
  !
  !     IFLAG - Status indicator
  !            =1 for successful decomposition
  !            =2 if improper input is detected
  !            =3 if rank of the matrix is less than N
  !     A -- Contains the reduced matrix in the strictly upper triangular
  !          part and transformation information in the lower part
  !     IRANK -- Contains the numerically determined matrix rank
  !     DIAG -- Contains the diagonal elements of the reduced
  !             triangular matrix
  !     KPIVOT -- Contains the pivotal information, the column
  !               interchanges performed on the original matrix are
  !               recorded here.
  !     SCALES -- Contains the column scaling parameters
  !
  !- *********************************************************************
  !
  !***
  ! **See also:**  BVSUP
  !***
  ! **References:**  G. Golub, Numerical methods for solving linear least
  !                 squares problems, Numerische Mathematik 7, (1965),
  !                 pp. 206-216.
  !               P. Businger and G. Golub, Linear least squares
  !                 solutions by Householder transformations, Numerische
  !                 Mathematik  7, (1965), pp. 269-276.
  !***
  ! **Routines called:**  CSCALE, R1MACH, SDOT, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   750601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900402  Added TYPE section.  (WRB)
  !   910408  Updated the AUTHOR and REFERENCES sections.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_2_sp
  !
  INTEGER, INTENT(IN) :: Iscale, M, N, Nrda
  INTEGER, INTENT(INOUT) :: Iflag
  INTEGER, INTENT(OUT) :: Irank, Kpivot(N)
  REAL(SP), INTENT(INOUT) :: A(Nrda,N)
  REAL(SP), INTENT(OUT) :: Cols(N), Cs(N), Diag(N), Scales(N)
  !
  INTEGER :: j, jcol, k, kp, l, mk
  REAL(SP) :: acc, akk, anorm, as, asave, css, diagk, dum1(1), dum2(1), sad, sc, &
    sig, sigma, sruro, uro
  !
  !- *********************************************************************
  !
  !     MACHINE PRECISION (COMPUTER UNIT ROUNDOFF VALUE) IS DEFINED
  !     BY THE FUNCTION R1MACH.
  !
  !* FIRST EXECUTABLE STATEMENT  ORTHOL
  uro = eps_2_sp
  dum1 = 0._SP
  dum2 = 0._SP
  !
  !- *********************************************************************
  !
  IF( M>=N .AND. N>=1 .AND. Nrda>=M ) THEN
    !
    acc = 10._SP*uro
    IF( Iflag<0 ) acc = MAX(acc,10._SP**Iflag)
    sruro = SQRT(uro)
    Iflag = 1
    Irank = N
    !
    !     COMPUTE NORM**2 OF JTH COLUMN AND A MATRIX NORM
    !
    anorm = 0._SP
    DO j = 1, N
      Kpivot(j) = j
      Cols(j) = NORM2(A(1:M,j))**2
      Cs(j) = Cols(j)
      anorm = anorm + Cols(j)
    END DO
    !
    !     PERFORM COLUMN SCALING ON A WHEN SPECIFIED
    !
    CALL CSCALE(A,Nrda,M,N,Cols,Cs,dum1,dum2,anorm,Scales,Iscale,0)
    !
    anorm = SQRT(anorm)
    !
    !
    !     CONSTRUCTION OF UPPER TRIANGULAR MATRIX AND RECORDING OF
    !     ORTHOGONAL TRANSFORMATIONS
    !
    !
    DO k = 1, N
      mk = M - k + 1
      IF( k/=N ) THEN
        kp = k + 1
        !
        !        SEARCHING FOR PIVOTAL COLUMN
        !
        DO j = k, N
          IF( Cols(j)<sruro*Cs(j) ) THEN
            Cols(j) = NORM2(A(k:k+mk-1,j))**2
            Cs(j) = Cols(j)
          END IF
          IF( j/=k ) THEN
            IF( sigma>=0.99*Cols(j) ) CYCLE
          END IF
          sigma = Cols(j)
          jcol = j
        END DO
        IF( jcol/=k ) THEN
          !
          !        PERFORM COLUMN INTERCHANGE
          !
          l = Kpivot(k)
          Kpivot(k) = Kpivot(jcol)
          Kpivot(jcol) = l
          Cols(jcol) = Cols(k)
          Cols(k) = sigma
          css = Cs(k)
          Cs(k) = Cs(jcol)
          Cs(jcol) = css
          sc = Scales(k)
          Scales(k) = Scales(jcol)
          Scales(jcol) = sc
          DO l = 1, M
            asave = A(l,k)
            A(l,k) = A(l,jcol)
            A(l,jcol) = asave
          END DO
        END IF
      END IF
      !
      !        CHECK RANK OF THE MATRIX
      !
      sig = NORM2(A(k:k+mk-1,k))**2
      diagk = SQRT(sig)
      IF( diagk>acc*anorm ) THEN
        !
        !        CONSTRUCT AND APPLY TRANSFORMATION TO MATRIX A
        !
        akk = A(k,k)
        IF( akk>0. ) diagk = -diagk
        Diag(k) = diagk
        A(k,k) = akk - diagk
        IF( k/=N ) THEN
          sad = diagk*akk - sig
          DO j = kp, N
            as = DOT_PRODUCT(A(k:M,k),A(k:M,j))/sad
            DO l = k, M
              A(l,j) = A(l,j) + as*A(l,k)
            END DO
            Cols(j) = Cols(j) - A(k,j)**2
          END DO
        END IF
      ELSE
        !
        !        RANK DEFICIENT PROBLEM
        Iflag = 3
        Irank = k - 1
        ERROR STOP 'ORTHOL : RANK OF MATRIX IS LESS THAN THE NUMBER OF COLUMNS.'
        RETURN
      END IF
    END DO
    RETURN
  END IF
  Iflag = 2
  ERROR STOP 'ORTHOL : INVALID INPUT PARAMETERS.'
  !
  RETURN
END SUBROUTINE ORTHOL