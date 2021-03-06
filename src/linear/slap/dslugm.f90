!** DSLUGM
PURE SUBROUTINE DSLUGM(N,B,X,Nelt,Ia,Ja,A,Isym,Nsave,Tol,Itmax,Iter,Err,&
    Ierr,Rwork,Lenw,Iwork,Leniw)
  !> Incomplete LU GMRES iterative sparse Ax=b solver.
  !  This routine uses the generalized minimum residual (GMRES) method with
  ! incomplete LU factorization for preconditioning to solve possibly
  ! non-symmetric linear systems of the form: Ax = b.
  !***
  ! **Library:**   SLATEC (SLAP)
  !***
  ! **Category:**  D2A4, D2B4
  !***
  ! **Type:**      DOUBLE PRECISION (SSLUGM-S, DSLUGM-D)
  !***
  ! **Keywords:**  GENERALIZED MINIMUM RESIDUAL, ITERATIVE PRECONDITION,
  !             NON-SYMMETRIC LINEAR SYSTEM, SLAP, SPARSE
  !***
  ! **Author:**  Brown, Peter, (LLNL), pnbrown@llnl.gov
  !           Hindmarsh, Alan, (LLNL), alanh@llnl.gov
  !           Seager, Mark K., (LLNL), seager@llnl.gov
  !             Lawrence Livermore National Laboratory
  !             PO Box 808, L-60
  !             Livermore, CA 94550 (510) 423-3141
  !***
  ! **Description:**
  !
  !- Usage:
  !      INTEGER   N, NELT, IA(NELT), JA(NELT), ISYM, NSAVE, ITOL
  !      INTEGER   ITMAX, ITER, IERR, IUNIT, LENW, IWORK(LENIW), LENIW
  !      DOUBLE PRECISION B(N), X(N), A(NELT), TOL, ERR, RWORK(LENW)
  !
  !      CALL DSLUGM(N, B, X, NELT, IA, JA, A, ISYM, NSAVE,
  !     $     ITOL, TOL, ITMAX, ITER, ERR, IERR, IUNIT,
  !     $     RWORK, LENW, IWORK, LENIW)
  !
  !- Arguments:
  ! N      :IN       Integer.
  !         Order of the Matrix.
  ! B      :IN       Double Precision B(N).
  !         Right-hand side vector.
  ! X      :INOUT    Double Precision X(N).
  !         On input X is your initial guess for solution vector.
  !         On output X is the final approximate solution.
  ! NELT   :IN       Integer.
  !         Number of Non-Zeros stored in A.
  ! IA     :IN       Integer IA(NELT).
  ! JA     :IN       Integer JA(NELT).
  ! A      :IN       Double Precision A(NELT).
  !         These arrays should hold the matrix A in either the SLAP
  !         Triad format or the SLAP Column format.  See "Description",
  !         below.  If the SLAP Triad format is chosen it is changed
  !         internally to the SLAP Column format.
  ! ISYM   :IN       Integer.
  !         Flag to indicate symmetric storage format.
  !         If ISYM=0, all non-zero entries of the matrix are stored.
  !         If ISYM=1, the matrix is symmetric, and only the upper
  !         or lower triangle of the matrix is stored.
  ! NSAVE  :IN       Integer.
  !         Number of direction vectors to save and orthogonalize against.
  !         Must be greater than 1.
  ! ITOL   :IN       Integer.
  !         Flag to indicate the type of convergence criterion used.
  !         ITOL=0  Means the  iteration stops when the test described
  !                 below on  the  residual RL  is satisfied.  This is
  !                 the  "Natural Stopping Criteria" for this routine.
  !                 Other values  of   ITOL  cause  extra,   otherwise
  !                 unnecessary, computation per iteration and     are
  !                 therefore  much less  efficient.  See  ISDGMR (the
  !                 stop test routine) for more information.
  !         ITOL=1  Means   the  iteration stops   when the first test
  !                 described below on  the residual RL  is satisfied,
  !                 and there  is either right  or  no preconditioning
  !                 being used.
  !         ITOL=2  Implies     that   the  user    is   using    left
  !                 preconditioning, and the second stopping criterion
  !                 below is used.
  !         ITOL=3  Means the  iteration stops   when  the  third test
  !                 described below on Minv*Residual is satisfied, and
  !                 there is either left  or no  preconditioning begin
  !                 used.
  !         ITOL=11 is    often  useful  for   checking  and comparing
  !                 different routines.  For this case, the  user must
  !                 supply  the  "exact" solution or  a  very accurate
  !                 approximation (one with  an  error much less  than
  !                 TOL) through a common block,
  !                     COMMON /DSLBLK/ SOLN( )
  !                 If ITOL=11, iteration stops when the 2-norm of the
  !                 difference between the iterative approximation and
  !                 the user-supplied solution  divided by the  2-norm
  !                 of the  user-supplied solution  is  less than TOL.
  !                 Note that this requires  the  user to  set up  the
  !                 "COMMON     /DSLBLK/ SOLN(LENGTH)"  in the calling
  !                 routine.  The routine with this declaration should
  !                 be loaded before the stop test so that the correct
  !                 length is used by  the loader.  This procedure  is
  !                 not standard Fortran and may not work correctly on
  !                 your   system (although  it  has  worked  on every
  !                 system the authors have tried).  If ITOL is not 11
  !                 then this common block is indeed standard Fortran.
  ! TOL    :INOUT    Double Precision.
  !         Convergence criterion, as described below.  If TOL is set
  !         to zero on input, then a default value of 500*(the smallest
  !         positive magnitude, machine epsilon) is used.
  ! ITMAX  :IN       Integer.
  !         Maximum number of iterations.  This routine uses the default
  !         of NRMAX = ITMAX/NSAVE to determine the when each restart
  !         should occur.  See the description of NRMAX and MAXL in
  !         DGMRES for a full and frightfully interesting discussion of
  !         this topic.
  ! ITER   :OUT      Integer.
  !         Number of iterations required to reach convergence, or
  !         ITMAX+1 if convergence criterion could not be achieved in
  !         ITMAX iterations.
  ! ERR    :OUT      Double Precision.
  !         Error estimate of error in final approximate solution, as
  !         defined by ITOL.  Letting norm() denote the Euclidean
  !         norm, ERR is defined as follows...
  !         If ITOL=0, then ERR = norm(SB*(B-A*X(L)))/norm(SB*B),
  !                               for right or no preconditioning, and
  !                         ERR = norm(SB*(M-inverse)*(B-A*X(L)))/
  !                                norm(SB*(M-inverse)*B),
  !                               for left preconditioning.
  !         If ITOL=1, then ERR = norm(SB*(B-A*X(L)))/norm(SB*B),
  !                               since right or no preconditioning
  !                               being used.
  !         If ITOL=2, then ERR = norm(SB*(M-inverse)*(B-A*X(L)))/
  !                                norm(SB*(M-inverse)*B),
  !                               since left preconditioning is being
  !                               used.
  !         If ITOL=3, then ERR =  Max  |(Minv*(B-A*X(L)))(i)/x(i)|
  !                               i=1,n
  !         If ITOL=11, then ERR = norm(SB*(X(L)-SOLN))/norm(SB*SOLN).
  ! IERR   :OUT      Integer.
  !         Return error flag.
  !               IERR = 0 => All went well.
  !               IERR = 1 => Insufficient storage allocated for
  !                           RGWK or IGWK.
  !               IERR = 2 => Routine DPIGMR failed to reduce the norm
  !                           of the current residual on its last call,
  !                           and so the iteration has stalled.  In
  !                           this case, X equals the last computed
  !                           approximation.  The user must either
  !                           increase MAXL, or choose a different
  !                           initial guess.
  !               IERR =-1 => Insufficient length for RGWK array.
  !                           IGWK(6) contains the required minimum
  !                           length of the RGWK array.
  !               IERR =-2 => Inconsistent ITOL and JPRE values.
  !         For IERR <= 2, RGWK(1) = RHOL, which is the norm on the
  !         left-hand-side of the relevant stopping test defined
  !         below associated with the residual for the current
  !         approximation X(L).
  ! IUNIT  :IN       Integer.
  !         Unit number on which to write the error at each iteration,
  !         if this is desired for monitoring convergence.  If unit
  !         number is 0, no writing will occur.
  ! RWORK  :WORK    Double Precision RWORK(LENW).
  !         Double Precision array of size LENW.
  ! LENW   :IN       Integer.
  !         Length of the double precision workspace, RWORK.
  !         LENW >= 1 + N*(NSAVE+7) +  NSAVE*(NSAVE+3)+NL+NU.
  !         Here NL is the number of non-zeros in the lower triangle of
  !         the matrix (including the diagonal) and NU is the number of
  !         non-zeros in the upper triangle of the matrix (including the
  !         diagonal).
  !         For the recommended values,  RWORK  has size at least
  !         131 + 17*N + NL + NU.
  ! IWORK  :INOUT    Integer IWORK(LENIW).
  !         Used to hold pointers into the RWORK array.
  !         Upon return the following locations of IWORK hold information
  !         which may be of use to the user:
  !         IWORK(9)  Amount of Integer workspace actually used.
  !         IWORK(10) Amount of Double Precision workspace actually used.
  ! LENIW  :IN       Integer.
  !         Length of the integer workspace, IWORK.
  !         LENIW >= NL+NU+4*N+32.
  !
  !- Description:
  !       DSLUGM solves a linear system A*X = B rewritten in the form:
  !
  !        (SB*A*(M-inverse)*(SX-inverse))*(SX*M*X) = SB*B,
  !
  !       with right preconditioning, or
  !
  !        (SB*(M-inverse)*A*(SX-inverse))*(SX*X) = SB*(M-inverse)*B,
  !
  !       with left preconditioning, where A is an n-by-n double precision
  !       matrix, X and B are N-vectors, SB and SX are  diagonal scaling
  !       matrices, and M is the Incomplete LU factorization of A.  It
  !       uses preconditioned  Krylov subpace   methods  based on  the
  !       generalized minimum residual  method (GMRES).   This routine
  !       is a  driver  routine  which  assumes a SLAP   matrix   data
  !       structure   and  sets  up  the  necessary  information to do
  !       diagonal  preconditioning  and calls the main GMRES  routine
  !       DGMRES for the   solution   of the linear   system.   DGMRES
  !       optionally   performs  either  the full    orthogonalization
  !       version of the  GMRES algorithm or  an incomplete variant of
  !       it.  Both versions use restarting of the linear iteration by
  !       default, although the user can disable this feature.
  !
  !       The GMRES  algorithm generates a sequence  of approximations
  !       X(L) to the  true solution of the above  linear system.  The
  !       convergence criteria for stopping the  iteration is based on
  !       the size  of the  scaled norm of  the residual  R(L)  =  B -
  !       A*X(L).  The actual stopping test is either:
  !
  !               norm(SB*(B-A*X(L))) <= TOL*norm(SB*B),
  !
  !       for right preconditioning, or
  !
  !               norm(SB*(M-inverse)*(B-A*X(L))) <=
  !                       TOL*norm(SB*(M-inverse)*B),
  !
  !       for left preconditioning, where norm() denotes the Euclidean
  !       norm, and TOL is  a positive scalar less  than one  input by
  !       the user.  If TOL equals zero  when DSLUGM is called, then a
  !       default  value  of 500*(the   smallest  positive  magnitude,
  !       machine epsilon) is used.  If the  scaling arrays SB  and SX
  !       are used, then  ideally they  should be chosen  so  that the
  !       vectors SX*X(or SX*M*X) and  SB*B have all their  components
  !       approximately equal  to  one in  magnitude.  If one wants to
  !       use the same scaling in X  and B, then  SB and SX can be the
  !       same array in the calling program.
  !
  !       The following is a list of the other routines and their
  !       functions used by GMRES:
  !       DGMRES  Contains the matrix structure independent driver
  !               routine for GMRES.
  !       DPIGMR  Contains the main iteration loop for GMRES.
  !       DORTH   Orthogonalizes a new vector against older basis vectors.
  !       DHEQR   Computes a QR decomposition of a Hessenberg matrix.
  !       DHELS   Solves a Hessenberg least-squares system, using QR
  !               factors.
  !       RLCALC  Computes the scaled residual RL.
  !       XLCALC  Computes the solution XL.
  !       ISDGMR  User-replaceable stopping routine.
  !
  !       The Sparse Linear Algebra Package (SLAP) utilizes two matrix
  !       data structures: 1) the  SLAP Triad  format or  2)  the SLAP
  !       Column format.  The user can hand this routine either of the
  !       of these data structures and SLAP  will figure out  which on
  !       is being used and act accordingly.
  !
  !       =================== S L A P Triad format ===================
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
  !       double precision array A.   In other words,  for each column
  !       in the matrix put the diagonal entry in  A.  Then put in the
  !       other non-zero  elements going down  the column (except  the
  !       diagonal) in order.   The  IA array holds the  row index for
  !       each non-zero.  The JA array holds the offsets  into the IA,
  !       A arrays  for  the  beginning  of each   column.   That  is,
  !       IA(JA(ICOL)),  A(JA(ICOL)) points   to the beginning  of the
  !       ICOL-th   column    in    IA and   A.      IA(JA(ICOL+1)-1),
  !       A(JA(ICOL+1)-1) points to  the  end of the   ICOL-th column.
  !       Note that we always have  JA(N+1) = NELT+1,  where N is  the
  !       number of columns in  the matrix and NELT  is the number  of
  !       non-zeros in the matrix.
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
  ! **References:**  1. Peter N. Brown and A. C. Hindmarsh, Reduced Storage
  !                  Matrix Methods in Stiff ODE Systems, Lawrence Liver-
  !                  more National Laboratory Report UCRL-95088, Rev. 1,
  !                  Livermore, California, June 1987.
  !***
  ! **Routines called:**  DCHKW, DGMRES, DS2Y, DSILUS, DSLUI, DSMV

  !* REVISION HISTORY  (YYMMDD)
  !   890404  DATE WRITTEN
  !   890404  Previous REVISION DATE
  !   890915  Made changes requested at July 1989 CML Meeting.  (MKS)
  !   890922  Numerous changes to prologue to make closer to SLATEC standard.  (FNF)
  !   890929  Numerous changes to reduce SP/DP differences.  (FNF)
  !   910411  Prologue converted to Version 4.0 format.  (BAB)
  !   920407  COMMON BLOCK renamed DSLBLK.  (WRB)
  !   920511  Added complete declaration section.  (WRB)
  !   920929  Corrected format of references.  (FNF)
  !   921019  Corrected NEL to NL.  (FNF)

  !     .. Parameters ..
  INTEGER, PARAMETER :: LOCRB = 1, LOCIB = 11
  !     .. Scalar Arguments ..
  INTEGER, INTENT(IN) :: Isym, Itmax, Leniw, Lenw, N, Nelt, Nsave
  INTEGER, INTENT(OUT) :: Ierr, Iter
  REAL(DP), INTENT(INOUT) :: Tol
  REAL(DP), INTENT(OUT) :: Err
  !     .. Array Arguments ..
  INTEGER, INTENT(INOUT) :: Ia(Nelt), Iwork(Leniw), Ja(Nelt)
  REAL(DP), INTENT(IN) :: B(N)
  REAL(DP), INTENT(INOUT) :: A(Nelt), Rwork(Lenw), X(N)
  !     .. Local Scalars ..
  INTEGER :: icol, j, jbgn, jend, locdin, locigw, locil, lociu, lociw, &
    locjl, locju, locl, locnc, locnr, locrgw, locu, locw, myitol, nl, nu
  !* FIRST EXECUTABLE STATEMENT  DSLUGM
  !
  Ierr = 0
  Err = 0
  IF( Nsave<=1 ) THEN
    Ierr = 3
    RETURN
  END IF
  !
  !         Change the SLAP input matrix IA, JA, A to SLAP-Column format.
  CALL DS2Y(N,Nelt,Ia,Ja,A)
  !
  !         Count number of Non-Zero elements preconditioner ILU matrix.
  !         Then set up the work arrays.  We assume MAXL=KMP=NSAVE.
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
  locigw = LOCIB
  locil = locigw + 20
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
  locrgw = locu + nu
  locw = locrgw + 1 + N*(Nsave+6) + Nsave*(Nsave+3)
  !
  !         Check the workspace allocations.
  CALL DCHKW('DSLUGM',lociw,Leniw,locw,Lenw,Ierr,Iter,Err)
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
  CALL DSILUS(N,Nelt,Ia,Ja,A,Isym,nl,Iwork(locil),Iwork(locjl),Rwork(locl),&
    Rwork(locdin),nu,Iwork(lociu),Iwork(locju),Rwork(locu),&
    Iwork(locnr),Iwork(locnc))
  !
  !         Perform the Incomplete LU Preconditioned Generalized Minimum
  !         Residual iteration algorithm.  The following DGMRES
  !         defaults are used MAXL = KMP = NSAVE, JSCAL = 0,
  !         JPRE = -1, NRMAX = ITMAX/NSAVE
  Iwork(locigw) = Nsave
  Iwork(locigw+1) = Nsave
  Iwork(locigw+2) = 0
  Iwork(locigw+3) = -1
  Iwork(locigw+4) = Itmax/Nsave
  myitol = 0
  !
  CALL DGMRES(N,B,X,Nelt,Ia,Ja,A,Isym,DSMV,DSLUI,myitol,Tol,Iter,Err,&
    Ierr,Rwork,Rwork,Rwork(locrgw),Lenw-locrgw,Iwork(locigw),20,Rwork,Iwork)
  !
  IF( Iter>Itmax ) Ierr = 2
  !------------- LAST LINE OF DSLUGM FOLLOWS ----------------------------
END SUBROUTINE DSLUGM