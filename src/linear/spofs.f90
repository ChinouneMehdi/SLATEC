!** SPOFS
PURE SUBROUTINE SPOFS(A,Lda,N,V,Itask,Ind,Work)
  !> Solve a positive definite symmetric system of linear equations.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  D2B1B
  !***
  ! **Type:**      SINGLE PRECISION (SPOFS-S, DPOFS-D, CPOFS-C)
  !***
  ! **Keywords:**  HERMITIAN, LINEAR EQUATIONS, POSITIVE DEFINITE, SYMMETRIC
  !***
  ! **Author:**  Voorhees, E. A., (LANL)
  !***
  ! **Description:**
  !
  !    Subroutine SPOFS solves a real positive definite symmetric
  !    NxN system of single precision linear equations using
  !    LINPACK subroutines SPOCO and SPOSL.  That is, if A is an
  !    NxN real positive definite symmetric matrix and if X and B
  !    are real N-vectors, then SPOFS solves the equation
  !
  !                          A*X=B.
  !
  !    The matrix A is first factored into upper and lower tri-
  !    angular matrices R and R-TRANSPOSE.  These factors are used to
  !    find the solution vector X.  An approximate condition number is
  !    calculated to provide a rough estimate of the number of
  !    digits of accuracy in the computed solution.
  !
  !    If the equation A*X=B is to be solved for more than one vector
  !    B, the factoring of A does not need to be performed again and
  !    the option to solve only (ITASK > 1) will be faster for
  !    the succeeding solutions.  In this case, the contents of A,
  !    LDA, and N must not have been altered by the user following
  !    factorization (ITASK=1).  IND will not be changed by SPOFS
  !    in this case.
  !
  !  Argument Description ***
  !
  !    A      REAL(LDA,N)
  !             on entry, the doubly subscripted array with dimension
  !               (LDA,N) which contains the coefficient matrix.  Only
  !               the upper triangle, including the diagonal, of the
  !               coefficient matrix need be entered and will subse-
  !               quently be referenced and changed by the routine.
  !             on return, contains in its upper triangle an upper
  !               triangular matrix R such that  A = (R-TRANSPOSE) * R .
  !    LDA    INTEGER
  !             the leading dimension of the array A.  LDA must be great-
  !             er than or equal to N.  (Terminal error message IND=-1)
  !    N      INTEGER
  !             the order of the matrix A.  N must be greater
  !             than or equal to 1.  (Terminal error message IND=-2)
  !    V      REAL(N)
  !             on entry, the singly subscripted array(vector) of di-
  !               mension N which contains the right hand side B of a
  !               system of simultaneous linear equations A*X=B.
  !             on return, V contains the solution vector, X .
  !    ITASK  INTEGER
  !             If ITASK = 1, the matrix A is factored and then the
  !               linear equation is solved.
  !             If ITASK > 1, the equation is solved using the existing
  !               factored matrix A.
  !             If ITASK < 1, then terminal error message IND=-3 is
  !               printed.
  !    IND    INTEGER
  !             GT. 0  IND is a rough estimate of the number of digits
  !                     of accuracy in the solution, X.
  !             LT. 0  see error message corresponding to IND below.
  !    WORK   REAL(N)
  !             a singly subscripted array of dimension at least N.
  !
  !  Error Messages Printed ***
  !
  !    IND=-1  terminal   N is greater than LDA.
  !    IND=-2  terminal   N is less than 1.
  !    IND=-3  terminal   ITASK is less than 1.
  !    IND=-4  Terminal   The matrix A is computationally singular or
  !                         is not positive definite.  A solution
  !                         has not been computed.
  !    IND=-10 warning    The solution has no apparent significance.
  !                         The solution may be inaccurate or the
  !                         matrix A may be poorly scaled.
  !
  !               Note-  The above terminal(*fatal*) error messages are
  !                      designed to be handled by XERMSG in which
  !                      LEVEL=1 (recoverable) and IFLAG=2 .  LEVEL=0
  !                      for warning error messages from XERMSG.  Unless
  !                      the user provides otherwise, an error message
  !                      will be printed followed by an abort.
  !
  !***
  ! **References:**  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
  !                 Stewart, LINPACK Users' Guide, SIAM, 1979.
  !***
  ! **Routines called:**  R1MACH, SPOCO, SPOSL, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800509  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900510  Convert XERRWV calls to XERMSG calls.  (RWC)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE service, ONLY : eps_sp
  USE linpack, ONLY : SPOCO, SPOSL
  !
  INTEGER, INTENT(IN) :: Lda, N, Itask
  INTEGER, INTENT(OUT) :: Ind
  REAL(SP), INTENT(INOUT) :: A(Lda,N), V(N)
  REAL(SP), INTENT(OUT) :: Work(N)
  !
  INTEGER :: info
  REAL(SP) :: rcond
  CHARACTER(8) :: xern1, xern2
  !* FIRST EXECUTABLE STATEMENT  SPOFS
  IF( Lda<N ) THEN
    Ind = -1
    WRITE (xern1,'(I8)') Lda
    WRITE (xern2,'(I8)') N
    ERROR STOP 'SPOFS : LDA IS LESS THAN N'
    RETURN
  END IF
  !
  IF( N<=0 ) THEN
    Ind = -2
    WRITE (xern1,'(I8)') N
    ERROR STOP 'SPOFS : N IS LESS THAN 1'
    RETURN
  END IF
  !
  IF( Itask<1 ) THEN
    Ind = -3
    WRITE (xern1,'(I8)') Itask
    ERROR STOP 'SPOFS : ITASK IS LESS THAN 1'
    RETURN
  END IF
  !
  IF( Itask==1 ) THEN
    !
    !        FACTOR MATRIX A INTO R
    !
    CALL SPOCO(A,Lda,N,rcond,Work,info)
    !
    !        CHECK FOR POSITIVE DEFINITE MATRIX
    !
    IF( info/=0 ) THEN
      Ind = -4
      ERROR STOP 'SPOFS : SINGULAR OR NOT POSITIVE DEFINITE - NO SOLUTION'
      RETURN
    END IF
    !
    !        COMPUTE IND (ESTIMATE OF NO. OF SIGNIFICANT DIGITS)
    !        AND CHECK FOR IND GREATER THAN ZERO
    !
    Ind = INT( -LOG10(eps_sp/rcond) )
    IF( Ind<=0 ) THEN
      Ind = -10
      ! 'SPOFS : SOLUTION MAY HAVE NO SIGNIFICANCE'
    END IF
  END IF
  !
  !     SOLVE AFTER FACTORING
  !
  CALL SPOSL(A,Lda,N,V)

END SUBROUTINE SPOFS