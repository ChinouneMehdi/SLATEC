!** DORTHR
PURE SUBROUTINE DORTHR(A,N,M,Nrda,Iflag,Irank,Iscale,Diag,Kpivot,Scales,Rows,Rs)
  !> Subsidiary to DBVSUP and DSUDS
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      DOUBLE PRECISION (ORTHOR-S, DORTHR-D)
  !***
  ! **Author:**  Watts, H. A., (SNLA)
  !***
  ! **Description:**
  !
  !   Reduction of the matrix A to lower triangular form by a sequence of
  !   orthogonal HOUSEHOLDER transformations post-multiplying A.
  !
  !- ********************************************************************
  !   INPUT
  !- ********************************************************************
  !
  !     A -- Contains the matrix to be decomposed, must be dimensioned
  !           NRDA by N.
  !     N -- Number of rows in the matrix, N greater or equal to 1.
  !     M -- Number of columns in the matrix, M greater or equal to N.
  !     IFLAG -- Indicates the uncertainty in the matrix data.
  !             = 0 when the data is to be treated as exact.
  !             =-K when the data is assumed to be accurate to about
  !                 K digits.
  !     ISCALE -- Scaling indicator.
  !               =-1 if the matrix is to be pre-scaled by
  !               columns when appropriate.
  !               Otherwise no scaling will be attempted.
  !     NRDA -- Row dimension of A, NRDA greater or equal to N.
  !     DIAG,KPIVOT,ROWS, -- Arrays of length at least N used internally
  !          RS,SCALES         (except for SCALES which is M).
  !
  !- ********************************************************************
  !   OUTPUT
  !- ********************************************************************
  !
  !     IFLAG - Status indicator
  !            =1 for successful decomposition.
  !            =2 if improper input is detected.
  !            =3 if rank of the matrix is less than N.
  !     A -- Contains the reduced matrix in the strictly lower triangular
  !          part and transformation information.
  !     IRANK -- Contains the numerically determined matrix rank.
  !     DIAG -- Contains the diagonal elements of the reduced
  !             triangular matrix.
  !     KPIVOT -- Contains the pivotal information, the column
  !               interchanges performed on the original matrix are
  !               recorded here.
  !     SCALES -- Contains the column scaling parameters.
  !
  !- ********************************************************************
  !
  !***
  ! **See also:**  DBVSUP, DSUDS
  !***
  ! **References:**  G. Golub, Numerical methods for solving linear least
  !                 squares problems, Numerische Mathematik 7, (1965),
  !                 pp. 206-216.
  !               P. Businger and G. Golub, Linear least squares
  !                 solutions by Householder transformations, Numerische
  !                 Mathematik  7, (1965), pp. 269-276.
  !***
  ! **Routines called:**  D1MACH, DCSCAL, DDOT, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   750601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900328  Added TYPE section.  (WRB)
  !   910408  Updated the AUTHOR and REFERENCES sections.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_dp
  !
  INTEGER, INTENT(IN) :: Iscale, M, N, Nrda
  INTEGER, INTENT(INOUT) :: Iflag
  INTEGER, INTENT(OUT) :: Irank, Kpivot(N)
  REAL(DP), INTENT(INOUT) :: A(Nrda,M)
  REAL(DP), INTENT(OUT) :: Diag(N), Rows(N), Rs(N), Scales(M)
  !
  INTEGER :: j, jrow, k, kp, l, mk
  REAL(DP) :: acc, akk, anorm, as, asave, diagk, dum(1), rss, sad, sig, sigma, &
    sruro, uro
  !
  !     ******************************************************************
  !
  !          MACHINE PRECISION (COMPUTER UNIT ROUNDOFF VALUE) IS DEFINED
  !          BY THE FUNCTION D1MACH.
  !
  !     ******************************************************************
  !
  !* FIRST EXECUTABLE STATEMENT  DORTHR
  uro = eps_dp
  dum = 0._DP
  IF( M>=N .AND. N>=1 .AND. Nrda>=N ) THEN
    !
    acc = 10._DP*uro
    IF( Iflag<0 ) acc = MAX(acc,10._DP**Iflag)
    sruro = SQRT(uro)
    Iflag = 1
    Irank = N
    !
    !        COMPUTE NORM**2 OF JTH ROW AND A MATRIX NORM
    !
    anorm = 0._DP
    DO j = 1, N
      Kpivot(j) = j
      Rows(j) = NORM2(A(j,1:M))
      Rs(j) = Rows(j)
      anorm = anorm + Rows(j)
    END DO
    !
    !        PERFORM COLUMN SCALING ON A WHEN SPECIFIED
    !
    CALL DCSCAL(A,Nrda,N,M,Scales,dum,Rows,Rs,anorm,Scales,Iscale,1)
    !
    anorm = SQRT(anorm)
    !
    !
    !        CONSTRUCTION OF LOWER TRIANGULAR MATRIX AND RECORDING OF
    !        ORTHOGONAL TRANSFORMATIONS
    !
    !
    DO k = 1, N
      !           BEGIN BLOCK PERMITTING ...EXITS TO 80
      mk = M - k + 1
      !           ...EXIT
      IF( k/=N ) THEN
        kp = k + 1
        !
        !              SEARCHING FOR PIVOTAL ROW
        !
        DO j = k, N
          !                 BEGIN BLOCK PERMITTING ...EXITS TO 50
          IF( Rows(j)<sruro*Rs(j) ) THEN
            Rows(j) = NORM2(A(j,k:k+mk-1))**2
            Rs(j) = Rows(j)
          END IF
          IF( j/=k ) THEN
            !                 ......EXIT
            IF( sigma>=0.99_DP*Rows(j) ) CYCLE
          END IF
          sigma = Rows(j)
          jrow = j
        END DO
        !           ...EXIT
        IF( jrow/=k ) THEN
          !
          !              PERFORM ROW INTERCHANGE
          !
          l = Kpivot(k)
          Kpivot(k) = Kpivot(jrow)
          Kpivot(jrow) = l
          Rows(jrow) = Rows(k)
          Rows(k) = sigma
          rss = Rs(k)
          Rs(k) = Rs(jrow)
          Rs(jrow) = rss
          DO l = 1, M
            asave = A(k,l)
            A(k,l) = A(jrow,l)
            A(jrow,l) = asave
          END DO
        END IF
      END IF
      !
      !           CHECK RANK OF THE MATRIX
      !
      sig = NORM2(A(k,k:k+mk-1))**2
      diagk = SQRT(sig)
      IF( diagk>acc*anorm ) THEN
        !
        !           CONSTRUCT AND APPLY TRANSFORMATION TO MATRIX A
        !
        akk = A(k,k)
        IF( akk>0._DP ) diagk = -diagk
        Diag(k) = diagk
        A(k,k) = akk - diagk
        IF( k/=N ) THEN
          sad = diagk*akk - sig
          DO j = kp, N
            as = NORM2(A(k,k:k+mk-1))**2/sad
            DO l = k, M
              A(j,l) = A(j,l) + as*A(k,l)
            END DO
            Rows(j) = Rows(j) - A(j,k)**2
          END DO
        END IF
      ELSE
        !
        !              RANK DEFICIENT PROBLEM
        Iflag = 3
        Irank = k - 1
        ERROR STOP 'DORTHR : RANK OF MATRIX IS LESS THAN THE NUMBER OF ROWS.'
        !        ......EXIT
        EXIT
      END IF
    END DO
  ELSE
    Iflag = 2
    ERROR STOP 'DORTHR : INVALID INPUT PARAMETERS.'
  END IF
  !
END SUBROUTINE DORTHR