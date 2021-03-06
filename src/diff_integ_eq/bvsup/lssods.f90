!** LSSODS
PURE SUBROUTINE LSSODS(A,X,B,M,N,Nrda,Iflag,Irank,Iscale,Q,Diag,Kpivot,Iter,&
    Resnrm,Xnorm,Z,R,Div,Td,Scales)
  !> Subsidiary to BVSUP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (LSSODS-S)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     LSSODS solves the same problem as SODS (in fact, it is called by
  !     SODS) but is somewhat more flexible in its use. In particular,
  !     LSSODS allows for iterative refinement of the solution, makes the
  !     transformation and triangular reduction information more
  !     accessible, and enables the user to avoid destruction of the
  !     original matrix A.
  !
  !     Modeled after the ALGOL codes in the articles in the REFERENCES
  !     section.
  !
  !- *********************************************************************
  !   INPUT
  !- *********************************************************************
  !
  !     A -- Contains the matrix of M equations in N unknowns and must
  !          be dimensioned NRDA by N. A remains unchanged
  !     X -- Solution array of length at least N
  !     B -- Given constant vector of length M, B remains unchanged
  !     M -- Number of equations, M greater or equal to 1
  !     N -- Number of unknowns, N not larger than M
  !  NRDA -- Row dimension of A, NRDA greater or equal to M
  ! IFLAG -- Status indicator
  !         = 0 for the first call (and for each new problem defined by
  !             a new matrix A) when the matrix data is treated as exact
  !         =-K for the first call (and for each new problem defined by
  !             a new matrix A) when the matrix data is assumed to be
  !             accurate to about K digits
  !         = 1 for subsequent calls whenever the matrix A has already
  !             been decomposed (problems with new vectors B but
  !             same matrix a can be handled efficiently)
  ! ISCALE -- Scaling indicator
  !         =-1 if the matrix A is to be pre-scaled by
  !             columns when appropriate
  !             If the scaling indicator is not equal to -1
  !             no scaling will be attempted
  !             For most problems scaling will probably not be necessary
  !   ITER -- Maximum number of iterative improvement steps to be
  !           performed,  0 <= ITER <= 10   (SODS uses ITER=0)
  !      Q -- Matrix used for the transformation, must be dimensioned
  !           NRDA by N  (SODS puts A in the Q location which conserves
  !           storage but destroys A)
  !           When iterative improvement of the solution is requested,
  !           ITER > 0, this additional storage for Q must be
  !           made available
  ! DIAG,KPIVOT,Z,R, -- Arrays of length N (except for R which is M)
  !   DIV,TD,SCALES     used for internal storage
  !
  !- *********************************************************************
  !   OUTPUT
  !- *********************************************************************
  !
  !  IFLAG -- Status indicator
  !            =1 if solution was obtained
  !            =2 if improper input is detected
  !            =3 if rank of matrix is less than N
  !               if the minimal length least squares solution is
  !               desired, simply reset IFLAG=1 and call the code again
  !
  !       The next three IFLAG values can occur only when
  !        the iterative improvement mode is being used.
  !            =4 if the problem is ill-conditioned and maximal
  !               machine accuracy is not achievable
  !            =5 if the problem is very ill-conditioned and the solution
  !               IS likely to have no correct digits
  !            =6 if the allowable number of iterative improvement steps
  !               has been completed without getting convergence
  !      X -- Least squares solution of  A X = B
  !  IRANK -- Contains the numerically determined matrix rank
  !           the user must not alter this value on succeeding calls
  !           with input values of IFLAG=1
  !      Q -- Contains the strictly upper triangular part of the reduced
  !           matrix and the transformation information in the lower
  !           triangular part
  !   DIAG -- Contains the diagonal elements of the triangular reduced
  !           matrix
  ! KPIVOT -- Contains the pivotal information.  The column interchanges
  !           performed on the original matrix are recorded here
  !   ITER -- The actual number of iterative corrections used
  ! RESNRM -- The Euclidean norm of the residual vector  B - A X
  !  XNORM -- The Euclidean norm of the solution vector
  ! DIV,TD -- Contains transformation information for rank
  !           deficient problems
  ! SCALES -- Contains the column scaling parameters
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
  ! **Routines called:**  J4SAVE, OHTROR, ORTHOL, R1MACH, SDOT, SDSDOT,
  !                    XERMAX, XERMSG, XGETF, XSETF

  !* REVISION HISTORY  (YYMMDD)
  !   750601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900402  Added TYPE section.  (WRB)
  !   910408  Updated the REFERENCES section.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_2_sp
  !
  INTEGER, INTENT(IN) :: Iscale, M, N, Nrda
  INTEGER, INTENT(INOUT) :: Iflag, Iter
  INTEGER, INTENT(OUT) :: Irank, Kpivot(N)
  REAL(SP), INTENT(OUT) :: Resnrm, Xnorm
  REAL(SP), INTENT(IN) :: A(Nrda,N), B(M)
  REAL(SP), INTENT(INOUT) :: Q(Nrda,N), X(N)
  REAL(SP), INTENT(OUT) :: Diag(N), Div(N), R(M), Scales(N), Td(N), Z(N)
  !
  INTEGER :: irm, irp, it, iterp, j, k, kp, l, nmir, mmir, nfat
  REAL(SP) :: acc, gam, gama, uro, znrm0, znorm
  !
  !- *********************************************************************
  !
  !     MACHINE PRECISION (COMPUTER UNIT ROUNDOFF VALUE) IS DEFINED
  !     THE FUNCTION R1MACH.
  !
  !* FIRST EXECUTABLE STATEMENT  LSSODS
  uro = eps_2_sp
  !
  !- *********************************************************************
  !
  IF( N>=1 .AND. M>=N .AND. Nrda>=M ) THEN
    IF( Iter>=0 ) THEN
      IF( Iflag<=0 ) THEN
        !
        IF( Iflag/=0 ) THEN
          nfat = 0
        END IF
        !
        !     COPY MATRIX A INTO MATRIX Q
        !
        DO j = 1, N
          DO k = 1, M
            Q(k,j) = A(k,j)
          END DO
        END DO
        !
        !     USE ORTHOGONAL TRANSFORMATIONS TO REDUCE Q TO
        !     UPPER TRIANGULAR FORM
        !
        CALL ORTHOL(Q,M,N,Nrda,Iflag,Irank,Iscale,Diag,Kpivot,Scales,Z,Td)
        !
        IF( Irank==N ) THEN
          !
          !     STORE DIVISORS FOR THE TRIANGULAR SOLUTION
          !
          DO k = 1, N
            Div(k) = Diag(k)
          END DO
          GOTO 100
        ELSE
          !
          !     FOR RANK DEFICIENT PROBLEMS USE ADDITIONAL ORTHOGONAL
          !     TRANSFORMATIONS TO FURTHER REDUCE Q
          !
          IF( Irank/=0 ) CALL OHTROR(Q,N,Nrda,Diag,Irank,Div,Td)
          RETURN
        END IF
      ELSEIF( Iflag==1 ) THEN
        GOTO 100
      END IF
    END IF
  END IF
  !
  !     INVALID INPUT FOR LSSODS
  Iflag = 2
  ERROR STOP 'LSSODS : INVALID INPUT PARAMETERS.'
  RETURN
  !
  100  irm = Irank - 1
  irp = Irank + 1
  iterp = MIN(Iter+1,11)
  acc = 10._SP*uro
  !
  !     ZERO OUT SOLUTION ARRAY
  !
  DO k = 1, N
    X(k) = 0._SP
  END DO
  !
  IF( Irank>0 ) THEN
    !
    !     COPY CONSTANT VECTOR INTO R
    !
    DO k = 1, M
      R(k) = B(k)
    END DO
    !
    !- *********************************************************************
    !     SOLUTION SECTION
    !     ITERATIVE REFINEMENT OF THE RESIDUAL VECTOR
    !- *********************************************************************
    !
    DO it = 1, iterp
      Iter = it - 1
      !
      !        APPLY ORTHOGONAL TRANSFORMATION TO R
      !
      DO j = 1, Irank
        gama = DOT_PRODUCT(Q(j:M,j),R(j:M))/(Diag(j)*Q(j,j))
        DO k = j, M
          R(k) = R(k) + gama*Q(k,j)
        END DO
      END DO
      !
      !        BACKWARD SUBSTITUTION FOR TRIANGULAR SYSTEM SOLUTION
      !
      Z(Irank) = R(Irank)/Div(Irank)
      IF( irm/=0 ) THEN
        DO l = 1, irm
          k = Irank - l
          kp = k + 1
          Z(k) = (R(k)-DOT_PRODUCT(Q(k,kp:Irank),Z(kp:Irank)))/Div(k)
        END DO
      END IF
      !
      IF( Irank/=N ) THEN
        !
        !        FOR RANK DEFICIENT PROBLEMS OBTAIN THE
        !        MINIMAL LENGTH SOLUTION
        !
        nmir = N - Irank
        DO k = irp, N
          Z(k) = 0._SP
        END DO
        DO k = 1, Irank
          gam = ((Td(k)*Z(k))+DOT_PRODUCT(Q(k,irp:N),Z(irp:N)))/(Td(k)*Div(k))
          Z(k) = Z(k) + gam*Td(k)
          DO j = irp, N
            Z(j) = Z(j) + gam*Q(k,j)
          END DO
        END DO
      END IF
      !
      !        REORDER SOLUTION COMPONENTS ACCORDING TO PIVOTAL POINTS
      !        AND RESCALE ANSWERS AS DICTATED
      !
      DO k = 1, N
        Z(k) = Z(k)*Scales(k)
        l = Kpivot(k)
        X(l) = X(l) + Z(k)
      END DO
      !
      !        COMPUTE CORRECTION VECTOR NORM (SOLUTION NORM)
      !
      znorm = NORM2(Z(1:N))
      IF( it==1 ) Xnorm = znorm
      IF( iterp>1 ) THEN
        !
        !        COMPUTE RESIDUAL VECTOR FOR THE ITERATIVE IMPROVEMENT PROCESS
        !
        DO k = 1, M
          R(k) = -DOT_PRODUCT(A(k,1:N),X(1:N)) + B(k)
        END DO
        Resnrm = NORM2(R(1:M))
        IF( it/=1 ) THEN
          !
          !        TEST FOR CONVERGENCE
          !
          IF( znorm<=acc*Xnorm ) RETURN
          !
          !        COMPARE SUCCESSIVE REFINEMENT VECTOR NORMS
          !        FOR LOOP TERMINATION CRITERIA
          !
          IF( znorm>0.25_SP*znrm0 ) THEN
            IF( it==2 ) THEN
              !
              Iflag = 5
              ERROR STOP 'LSSODS : PROBLEM IS VERY ILL-CONDITIONED.&
                & ITERATIVE IMPROVEMENT IS INEFFECTIVE.'
              RETURN
            ELSE
              !
              Iflag = 4
              ERROR STOP 'LSSODS : PROBLEM MAY BE ILL-CONDITIONED.&
                & MAXIMAL MACHINE ACCURACY IS NOT ACHIEVABLE.'
              RETURN
            END IF
          END IF
        END IF
        !
        znrm0 = znorm
      ELSE
        !
        !        NO ITERATIVE CORRECTIONS TO BE PERFORMED, SO COMPUTE
        !        THE APPROXIMATE RESIDUAL NORM DEFINED BY THE EQUATIONS
        !        WHICH ARE NOT SATISFIED BY THE SOLUTION
        !        THEN WE ARE DONE
        !
        mmir = M - Irank
        IF( mmir==0 ) THEN
          Resnrm = 0._SP
          RETURN
        ELSE
          Resnrm = NORM2(R(irp:irp+mmir-1))
          RETURN
        END IF
      END IF
    END DO
    !- *********************************************************************
    !
    !- *********************************************************************
    Iflag = 6
    ERROR STOP 'LSSODS : CONVERGENCE HAS NOT BEEN OBTAINED WITH ALLOWABLE NUMBER&
      & OF ITERATIVE IMPROVEMENT STEPS.'
    RETURN
  END IF
  !
  !     SPECIAL CASE FOR THE NULL MATRIX
  Iter = 0
  Xnorm = 0._SP
  Resnrm = NORM2(B(1:M))
  !
  RETURN
END SUBROUTINE LSSODS