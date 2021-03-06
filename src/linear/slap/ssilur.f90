!** SSILUR
PURE SUBROUTINE SSILUR(N,B,X,Nelt,Ia,Ja,A,Isym,Itol,Tol,Itmax,Iter,Err,Ierr,&
    Rwork,Lenw,Iwork,Leniw)
  !> Incomplete LU Iterative Refinement Sparse Ax = b Solver.
  !  Routine to solve a general linear system  Ax = b  using
  !  the incomplete LU decomposition with iterative refinement.
  !***
  ! **Library:**   SLATEC (SLAP)
  !***
  ! **Category:**  D2A4, D2B4
  !***
  ! **Type:**      SINGLE PRECISION (SSILUR-S, DSILUR-D)
  !***
  ! **Keywords:**  ITERATIVE PRECONDITION, LINEAR SYSTEM, SLAP, SPARSE
  !***
  ! **Author:**  Greenbaum, Anne, (Courant Institute)
  !           Seager, Mark K., (LLNL)
  !             Lawrence Livermore National Laboratory
  !             PO BOX 808, L-60
  !             Livermore, CA 94550 (510) 423-3141
  !             seager@llnl.gov
  !***
  ! **Description:**
  !
  !- Usage:
  !     INTEGER N, NELT, IA(NELT), JA(NELT), ISYM, ITOL, ITMAX
  !     INTEGER ITER, IERR, IUNIT, LENW, IWORK(NL+NU+4*N+2), LENIW
  !     REAL B(N), X(N), A(NELT), TOL, ERR, RWORK(NL+NU+4*N)
  !
  !     CALL SSILUR(N, B, X, NELT, IA, JA, A, ISYM, ITOL, TOL,
  !    $     ITMAX, ITER, ERR, IERR, IUNIT, RWORK, LENW, IWORK, LENIW)
  !
  !- Arguments:
  ! N      :IN       Integer
  !         Order of the Matrix.
  ! B      :IN       Real B(N).
  !         Right-hand side vector.
  ! X      :INOUT    Real X(N).
  !         On input X is your initial guess for solution vector.
  !         On output X is the final approximate solution.
  ! NELT   :IN       Integer.
  !         Number of Non-Zeros stored in A.
  ! IA     :INOUT    Integer IA(NELT).
  ! JA     :INOUT    Integer JA(NELT).
  ! A      :INOUT    Real A(NELT).
  !         These arrays should hold the matrix A in either the SLAP
  !         Triad format or the SLAP Column format.  See "Description",
  !         below.  If the SLAP Triad format is chosen it is changed
  !         internally to the SLAP Column format.
  ! ISYM   :IN       Integer.
  !         Flag to indicate symmetric storage format.
  !         If ISYM=0, all non-zero entries of the matrix are stored.
  !         If ISYM=1, the matrix is symmetric, and only the upper
  !         or lower triangle of the matrix is stored.
  ! ITOL   :IN       Integer.
  !         Flag to indicate type of convergence criterion.
  !         If ITOL=1, iteration stops when the 2-norm of the residual
  !         divided by the 2-norm of the right-hand side is less than TOL.
  !         If ITOL=2, iteration stops when the 2-norm of M-inv times the
  !         residual divided by the 2-norm of M-inv times the right hand
  !         side is less than TOL, where M-inv is the inverse of the
  !         diagonal of A.
  !         ITOL=11 is often useful for checking and comparing different
  !         routines.  For this case, the user must supply the "exact"
  !         solution or a very accurate approximation (one with an error
  !         much less than TOL) through a common block,
  !             COMMON /SSLBLK/ SOLN( )
  !         If ITOL=11, iteration stops when the 2-norm of the difference
  !         between the iterative approximation and the user-supplied
  !         solution divided by the 2-norm of the user-supplied solution
  !         is less than TOL.  Note that this requires the user to set up
  !         the "COMMON /SSLBLK/ SOLN(LENGTH)" in the calling routine.
  !         The routine with this declaration should be loaded before the
  !         stop test so that the correct length is used by the loader.
  !         This procedure is not standard Fortran and may not work
  !         correctly on your system (although it has worked on every
  !         system the authors have tried).  If ITOL is not 11 then this
  !         common block is indeed standard Fortran.
  ! TOL    :INOUT    Real.
  !         Convergence criterion, as described above.  (Reset if IERR=4.)
  ! ITMAX  :IN       Integer.
  !         Maximum number of iterations.
  ! ITER   :OUT      Integer.
  !         Number of iterations required to reach convergence, or
  !         ITMAX+1 if convergence criterion could not be achieved in
  !         ITMAX iterations.
  ! ERR    :OUT      Real.
  !         Error estimate of error in final approximate solution, as
  !         defined by ITOL.
  ! IERR   :OUT      Integer.
  !         Return error flag.
  !           IERR = 0 => All went well.
  !           IERR = 1 => Insufficient space allocated for WORK or IWORK.
  !           IERR = 2 => Method failed to converge in ITMAX steps.
  !           IERR = 3 => Error in user input.
  !                       Check input values of N, ITOL.
  !           IERR = 4 => User error tolerance set too tight.
  !                       Reset to 500*eps_2_sp.  Iteration proceeded.
  !           IERR = 5 => Preconditioning matrix, M, is not positive
  !                       definite.  (r,z) < 0.
  !           IERR = 6 => Matrix A is not positive definite.  (p,Ap) < 0.
  !           IERR = 7 => Incomplete factorization broke down and was
  !                       fudged.  Resulting preconditioning may be less
  !                       than the best.
  ! IUNIT  :IN       Integer.
  !         Unit number on which to write the error at each iteration,
  !         if this is desired for monitoring convergence.  If unit
  !         number is 0, no writing will occur.
  ! RWORK  :WORK     Real RWORK(LENW).
  !         Real array used for workspace.
  ! LENW   :IN       Integer.
  !         Length of the real workspace, RWORK.  LENW >= NL+NU+4*N.
  !         NL is the number of non-zeros in the lower triangle of the
  !         matrix (including the diagonal).
  !         NU is the number of non-zeros in the upper triangle of the
  !         matrix (including the diagonal).
  ! IWORK  :WORK     Integer IWORK(LENIW).
  !         Integer array used for workspace.
  !         Upon return the following locations of IWORK hold information
  !         which may be of use to the user:
  !         IWORK(9)  Amount of Integer workspace actually used.
  !         IWORK(10) Amount of Real workspace actually used.
  ! LENIW  :IN       Integer.
  !         Length of integer workspace, IWORK.  LENIW >= NL+NU+4*N+10.
  !         NL is the number of non-zeros in the lower triangle of the
  !         matrix (including the diagonal).
  !         NU is the number of non-zeros in the upper triangle of the
  !         matrix (including the diagonal).
  !
  !- Description
  !       The Sparse Linear Algebra Package (SLAP) utilizes two matrix
  !       data structures: 1) the  SLAP Triad  format or  2)  the SLAP
  !       Column format.  The user can hand this routine either of the
  !       of these data structures and SLAP  will figure out  which on
  !       is being used and act accordingly.
  !
  !       =================== S L A P Triad format ===================
  !
  !       This routine requires that the  matrix A be   stored in  the
  !       SLAP  Triad format.  In  this format only the non-zeros  are
  !       stored.  They may appear in  *ANY* order.  The user supplies
  !       three arrays of  length NELT, where  NELT is  the number  of
  !       non-zeros in the matrix: (IA(NELT), JA(NELT), A(NELT)).  For
  !       each non-zero the user puts the row and column index of that
  !       matrix element  in the IA and  JA arrays.  The  value of the
  !       non-zero   matrix  element is  placed  in  the corresponding
  !       location of the A array.   This is  an  extremely  easy data
  !       structure to generate.  On  the  other hand it   is  not too
  !       efficient on vector computers for  the iterative solution of
  !       linear systems.  Hence,   SLAP changes   this  input    data
  !       structure to the SLAP Column format  for  the iteration (but
  !       does not change it back).
  !
  !       Here is an example of the  SLAP Triad   storage format for a
  !       5x5 Matrix.  Recall that the entries may appear in any order.
  !
  !           5x5 Matrix      SLAP Triad format for 5x5 matrix on left.
  !                              1  2  3  4  5  6  7  8  9 10 11
  !       |11 12  0  0 15|   A: 51 12 11 33 15 53 55 22 35 44 21
  !       |21 22  0  0  0|  IA:  5  1  1  3  1  5  5  2  3  4  2
  !       | 0  0 33  0 35|  JA:  1  2  1  3  5  3  5  2  5  4  1
  !       | 0  0  0 44  0|
  !       |51  0 53  0 55|
  !
  !       =================== S L A P Column format ==================
  !
  !       This routine  requires that  the matrix A  be stored in  the
  !       SLAP Column format.  In this format the non-zeros are stored
  !       counting down columns (except for  the diagonal entry, which
  !       must appear first in each  "column")  and are stored  in the
  !       real array A.  In other words, for each column in the matrix
  !       put the diagonal entry in A.  Then put in the other non-zero
  !       elements going down   the  column (except  the diagonal)  in
  !       order.  The IA array holds the row  index for each non-zero.
  !       The JA array holds the offsets into the IA, A arrays for the
  !       beginning of   each    column.    That  is,    IA(JA(ICOL)),
  !       A(JA(ICOL)) points to the beginning of the ICOL-th column in
  !       IA and  A.  IA(JA(ICOL+1)-1),  A(JA(ICOL+1)-1) points to the
  !       end  of   the ICOL-th  column.  Note   that  we  always have
  !       JA(N+1) = NELT+1, where  N  is the number of columns in  the
  !       matrix and  NELT   is the number of non-zeros in the matrix.
  !
  !       Here is an example of the  SLAP Column  storage format for a
  !       5x5 Matrix (in the A and IA arrays '|'  denotes the end of a
  !       column):
  !
  !           5x5 Matrix      SLAP Column format for 5x5 matrix on left.
  !                              1  2  3    4  5    6  7    8    9 10 11
  !       |11 12  0  0 15|   A: 11 21 51 | 22 12 | 33 53 | 44 | 55 15 35
  !       |21 22  0  0  0|  IA:  1  2  5 |  2  1 |  3  5 |  4 |  5  1  3
  !       | 0  0 33  0 35|  JA:  1  4  6    8  9   12
  !       | 0  0  0 44  0|
  !       |51  0 53  0 55|
  !
  !- Side Effects:
  !       The SLAP Triad format (IA, JA, A) is modified internally to be
  !       the SLAP Column format.  See above.
  !
  !- Cautions:
  !     This routine will attempt to write to the Fortran logical output
  !     unit IUNIT, if IUNIT /= 0.  Thus, the user must make sure that
  !     this logical unit is attached to a file or terminal before calling
  !     this routine with a non-zero value for IUNIT.  This routine does
  !     not check for the validity of a non-zero IUNIT unit number.
  !
  !***
  ! **See also:**  SSJAC, SSGS, SIR
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  SCHKW, SIR, SS2Y, SSILUS, SSLUI, SSMV

  !* REVISION HISTORY  (YYMMDD)
  !   871119  DATE WRITTEN
  !   881213  Previous REVISION DATE
  !   890915  Made changes requested at July 1989 CML Meeting.  (MKS)
  !   890921  Removed TeX from comments.  (FNF)
  !   890922  Numerous changes to prologue to make closer to SLATEC standard.  (FNF)
  !   890929  Numerous changes to reduce SP/DP differences.  (FNF)
  !   910411  Prologue converted to Version 4.0 format.  (BAB)
  !   920407  COMMON BLOCK renamed SSLBLK.  (WRB)
  !   920511  Added complete declaration section.  (WRB)
  !   921019  Corrected NEL to NL.  (FNF)

  !     .. Parameters ..
  INTEGER, PARAMETER :: LOCRB = 1, LOCIB = 11
  !     .. Scalar Arguments ..
  INTEGER, INTENT(IN) :: Isym, Itmax, Itol, Leniw, Lenw, N, Nelt
  INTEGER, INTENT(OUT) :: Ierr, Iter
  REAL(SP), INTENT(INOUT) :: Tol
  REAL(SP), INTENT(OUT) :: Err
  !     .. Array Arguments ..
  INTEGER, INTENT(INOUT) :: Ia(Nelt), Iwork(Leniw), Ja(Nelt)
  REAL(SP), INTENT(IN) :: B(N)
  REAL(SP), INTENT(INOUT) :: A(Nelt), Rwork(Lenw), X(N)
  !     .. Local Scalars ..
  INTEGER :: icol, j, jbgn, jend, locdin, locdz, locil, lociu, lociw, &
    locjl, locju, locl, locnc, locnr, locr, locu, locw, locz, nl, nu
  !* FIRST EXECUTABLE STATEMENT  SSILUR
  !
  Ierr = 0
  IF( N<1 .OR. Nelt<1 ) THEN
    Ierr = 3
    RETURN
  END IF
  !
  !         Change the SLAP input matrix IA, JA, A to SLAP-Column format.
  CALL SS2Y(N,Nelt,Ia,Ja,A)
  !
  !         Count number of Non-Zero elements in preconditioner ILU
  !         matrix.  Then set up the work arrays.
  nl = 0
  nu = 0
  DO icol = 1, N
    !         Don't count diagonal.
    jbgn = Ja(icol) + 1
    jend = Ja(icol+1) - 1
    IF( jbgn<=jend ) THEN
      DO j = jbgn, jend
        IF( Ia(j)>icol ) THEN
          nl = nl + 1
          IF( Isym/=0 ) nu = nu + 1
        ELSE
          nu = nu + 1
        END IF
      END DO
    END IF
  END DO
  !
  locil = LOCIB
  locjl = locil + N + 1
  lociu = locjl + nl
  locju = lociu + nu
  locnr = locju + N + 1
  locnc = locnr + N
  lociw = locnc + N
  !
  locl = LOCRB
  locdin = locl + nl
  locu = locdin + N
  locr = locu + nu
  locz = locr + N
  locdz = locz + N
  locw = locdz + N
  !
  !         Check the workspace allocations.
  CALL SCHKW('SSILUR',lociw,Leniw,locw,Lenw,Ierr,Iter,Err)
  IF( Ierr/=0 ) RETURN
  !
  Iwork(1) = locil
  Iwork(2) = locjl
  Iwork(3) = lociu
  Iwork(4) = locju
  Iwork(5) = locl
  Iwork(6) = locdin
  Iwork(7) = locu
  Iwork(9) = lociw
  Iwork(10) = locw
  !
  !         Compute the Incomplete LU decomposition.
  CALL SSILUS(N,Nelt,Ia,Ja,A,Isym,nl,Iwork(locil),Iwork(locjl),Rwork(locl),&
    Rwork(locdin),nu,Iwork(lociu),Iwork(locju),Rwork(locu),&
    Iwork(locnr),Iwork(locnc))
  !
  !         Do the Preconditioned Iterative Refinement iteration.
  CALL SIR(N,B,X,Nelt,Ia,Ja,A,Isym,SSMV,SSLUI,Itol,Tol,Itmax,Iter,Ierr,&
    Rwork(locr),Rwork(locz),Rwork(locdz),Rwork,Iwork)
  !------------- LAST LINE OF SSILUR FOLLOWS ----------------------------
END SUBROUTINE SSILUR