!** DPIGMR
PURE SUBROUTINE DPIGMR(N,R0,Sr,Sz,Jscal,Maxl,Maxlp1,Kmp,Nrsts,Jpre,MATVEC,&
    MSOLVE,Z,V,Hes,Q,Lgmr,Rpar,Ipar,Wk,Dl,Rhol,Nrmax,&
    Bnrm,X,Xl,Itol,Tol,Nelt,Ia,Ja,A,Isym,Iflag)
  !> Internal routine for DGMRES.
  !***
  ! **Library:**   SLATEC (SLAP)
  !***
  ! **Category:**  D2A4, D2B4
  !***
  ! **Type:**      DOUBLE PRECISION (SPIGMR-S, DPIGMR-D)
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
  !         This routine solves the linear system A * Z = R0 using a
  !         scaled preconditioned version of the generalized minimum
  !         residual method.  An initial guess of Z = 0 is assumed.
  !
  !- Usage:
  !      INTEGER N, JSCAL, MAXL, MAXLP1, KMP, NRSTS, JPRE, NMSL, LGMR
  !      INTEGER IPAR(USER DEFINED), NRMAX, ITOL, NELT, IA(NELT), JA(NELT)
  !      INTEGER ISYM, IUNIT, IFLAG
  !      DOUBLE PRECISION R0(N), SR(N), SZ(N), Z(N), V(N,MAXLP1),
  !     $                 HES(MAXLP1,MAXL), Q(2*MAXL), RPAR(USER DEFINED),
  !     $                 WK(N), DL(N), RHOL, B(N), BNRM, X(N), XL(N),
  !     $                 TOL, A(NELT), ERR
  !      EXTERNAL MATVEC, MSOLVE
  !
  !      CALL DPIGMR(N, R0, SR, SZ, JSCAL, MAXL, MAXLP1, KMP,
  !     $     NRSTS, JPRE, MATVEC, MSOLVE, NMSL, Z, V, HES, Q, LGMR,
  !     $     RPAR, IPAR, WK, DL, RHOL, NRMAX, B, BNRM, X, XL,
  !     $     ITOL, TOL, NELT, IA, JA, A, ISYM, IUNIT, IFLAG, ERR)
  !
  !- Arguments:
  ! N      :IN       Integer
  !         The order of the matrix A, and the lengths
  !         of the vectors SR, SZ, R0 and Z.
  ! R0     :IN       Double Precision R0(N)
  !         R0 = the right hand side of the system A*Z = R0.
  !         R0 is also used as workspace when computing
  !         the final approximation.
  !         (R0 is the same as V(*,MAXL+1) in the call to DPIGMR.)
  ! SR     :IN       Double Precision SR(N)
  !         SR is a vector of length N containing the non-zero
  !         elements of the diagonal scaling matrix for R0.
  ! SZ     :IN       Double Precision SZ(N)
  !         SZ is a vector of length N containing the non-zero
  !         elements of the diagonal scaling matrix for Z.
  ! JSCAL  :IN       Integer
  !         A flag indicating whether arrays SR and SZ are used.
  !         JSCAL=0 means SR and SZ are not used and the
  !                 algorithm will perform as if all
  !                 SR(i) = 1 and SZ(i) = 1.
  !         JSCAL=1 means only SZ is used, and the algorithm
  !                 performs as if all SR(i) = 1.
  !         JSCAL=2 means only SR is used, and the algorithm
  !                 performs as if all SZ(i) = 1.
  !         JSCAL=3 means both SR and SZ are used.
  ! MAXL   :IN       Integer
  !         The maximum allowable order of the matrix H.
  ! MAXLP1 :IN       Integer
  !         MAXPL1 = MAXL + 1, used for dynamic dimensioning of HES.
  ! KMP    :IN       Integer
  !         The number of previous vectors the new vector VNEW
  !         must be made orthogonal to.  (KMP <= MAXL)
  ! NRSTS  :IN       Integer
  !         Counter for the number of restarts on the current
  !         call to DGMRES.  If NRSTS > 0, then the residual
  !         R0 is already scaled, and so scaling of it is
  !         not necessary.
  ! JPRE   :IN       Integer
  !         Preconditioner type flag.
  ! MATVEC :EXT      External.
  !         Name of a routine which performs the matrix vector multiply
  !         Y = A*X given A and X.  The name of the MATVEC routine must
  !         be declared external in the calling program.  The calling
  !         sequence to MATVEC is:
  !             CALL MATVEC(N, X, Y, NELT, IA, JA, A, ISYM)
  !         where N is the number of unknowns, Y is the product A*X
  !         upon return, X is an input vector, and NELT is the number of
  !         non-zeros in the SLAP IA, JA, A storage for the matrix A.
  !         ISYM is a flag which, if non-zero, denotes that A is
  !         symmetric and only the lower or upper triangle is stored.
  ! MSOLVE :EXT      External.
  !         Name of the routine which solves a linear system Mz = r for
  !         z given r with the preconditioning matrix M (M is supplied via
  !         RPAR and IPAR arrays.  The name of the MSOLVE routine must
  !         be declared external in the calling program.  The calling
  !         sequence to MSOLVE is:
  !             CALL MSOLVE(N, R, Z, NELT, IA, JA, A, ISYM, RPAR, IPAR)
  !         Where N is the number of unknowns, R is the right-hand side
  !         vector and Z is the solution upon return.  NELT, IA, JA, A and
  !         ISYM are defined as below.  RPAR is a double precision array
  !         that can be used to pass necessary preconditioning information
  !         and/or workspace to MSOLVE.  IPAR is an integer work array
  !         for the same purpose as RPAR.
  ! NMSL   :OUT      Integer
  !         The number of calls to MSOLVE.
  ! Z      :OUT      Double Precision Z(N)
  !         The final computed approximation to the solution
  !         of the system A*Z = R0.
  ! V      :OUT      Double Precision V(N,MAXLP1)
  !         The N by (LGMR+1) array containing the LGMR
  !         orthogonal vectors V(*,1) to V(*,LGMR).
  ! HES    :OUT      Double Precision HES(MAXLP1,MAXL)
  !         The upper triangular factor of the QR decomposition
  !         of the (LGMR+1) by LGMR upper Hessenberg matrix whose
  !         entries are the scaled inner-products of A*V(*,I)
  !         and V(*,K).
  ! Q      :OUT      Double Precision Q(2*MAXL)
  !         A double precision array of length 2*MAXL containing the
  !         components of the Givens rotations used in the QR
  !         decomposition of HES.  It is loaded in DHEQR and used in
  !         DHELS.
  ! LGMR   :OUT      Integer
  !         The number of iterations performed and
  !         the current order of the upper Hessenberg
  !         matrix HES.
  ! RPAR   :IN       Double Precision RPAR(USER DEFINED)
  !         Double Precision workspace passed directly to the MSOLVE
  !         routine.
  ! IPAR   :IN       Integer IPAR(USER DEFINED)
  !         Integer workspace passed directly to the MSOLVE routine.
  ! WK     :IN       Double Precision WK(N)
  !         A double precision work array of length N used by routines
  !         MATVEC and MSOLVE.
  ! DL     :INOUT    Double Precision DL(N)
  !         On input, a double precision work array of length N used for
  !         calculation of the residual norm RHO when the method is
  !         incomplete (KMP<MAXL), and/or when using restarting.
  !         On output, the scaled residual vector RL.  It is only loaded
  !         when performing restarts of the Krylov iteration.
  ! RHOL   :OUT      Double Precision
  !         A double precision scalar containing the norm of the final
  !         residual.
  ! NRMAX  :IN       Integer
  !         The maximum number of restarts of the Krylov iteration.
  !         NRMAX > 0 means restarting is active, while
  !         NRMAX = 0 means restarting is not being used.
  ! B      :IN       Double Precision B(N)
  !         The right hand side of the linear system A*X = b.
  ! BNRM   :IN       Double Precision
  !         The scaled norm of b.
  ! X      :IN       Double Precision X(N)
  !         The current approximate solution as of the last
  !         restart.
  ! XL     :IN       Double Precision XL(N)
  !         An array of length N used to hold the approximate
  !         solution X(L) when ITOL=11.
  ! ITOL   :IN       Integer
  !         A flag to indicate the type of convergence criterion
  !         used.  See the driver for its description.
  ! TOL    :IN       Double Precision
  !         The tolerance on residuals R0-A*Z in scaled norm.
  ! NELT   :IN       Integer
  !         The length of arrays IA, JA and A.
  ! IA     :IN       Integer IA(NELT)
  !         An integer array of length NELT containing matrix data.
  !         It is passed directly to the MATVEC and MSOLVE routines.
  ! JA     :IN       Integer JA(NELT)
  !         An integer array of length NELT containing matrix data.
  !         It is passed directly to the MATVEC and MSOLVE routines.
  ! A      :IN       Double Precision A(NELT)
  !         A double precision array of length NELT containing matrix
  !         data. It is passed directly to the MATVEC and MSOLVE routines.
  ! ISYM   :IN       Integer
  !         A flag to indicate symmetric matrix storage.
  !         If ISYM=0, all non-zero entries of the matrix are
  !         stored.  If ISYM=1, the matrix is symmetric and
  !         only the upper or lower triangular part is stored.
  ! IUNIT  :IN       Integer
  !         The i/o unit number for writing intermediate residual
  !         norm values.
  ! IFLAG  :OUT      Integer
  !         An integer error flag..
  !         0 means convergence in LGMR iterations, LGMR<=MAXL.
  !         1 means the convergence test did not pass in MAXL
  !           iterations, but the residual norm is < norm(R0),
  !           and so Z is computed.
  !         2 means the convergence test did not pass in MAXL
  !           iterations, residual >= norm(R0), and Z = 0.
  ! ERR    :OUT      Double Precision.
  !         Error estimate of error in final approximate solution, as
  !         defined by ITOL.
  !
  !- Cautions:
  !     This routine will attempt to write to the Fortran logical output
  !     unit IUNIT, if IUNIT /= 0.  Thus, the user must make sure that
  !     this logical unit is attached to a file or terminal before calling
  !     this routine with a non-zero value for IUNIT.  This routine does
  !     not check for the validity of a non-zero IUNIT unit number.
  !
  !***
  ! **See also:**  DGMRES
  !***
  ! **Routines called:**  DAXPY, DCOPY, DHELS, DHEQR, DNRM2, DORTH, DRLCAL,
  !                    DSCAL, ISDGMR

  !* REVISION HISTORY  (YYMMDD)
  !   890404  DATE WRITTEN
  !   890404  Previous REVISION DATE
  !   890915  Made changes requested at July 1989 CML Meeting.  (MKS)
  !   890922  Numerous changes to prologue to make closer to SLATEC standard.  (FNF)
  !   890929  Numerous changes to reduce SP/DP differences.  (FNF)
  !   910411  Prologue converted to Version 4.0 format.  (BAB)
  !   910502  Removed MATVEC and MSOLVE from ROUTINES CALLED list.  (FNF)
  !   910506  Made subsidiary to DGMRES.  (FNF)
  !   920511  Added complete declaration section.  (WRB)
  USE blas, ONLY : DAXPY
  USE DSLBLK, ONLY : soln_com

  INTERFACE
    PURE SUBROUTINE MSOLVE(N,R,Z,Rwork,Iwork)
      IMPORT DP
      INTEGER, INTENT(IN) :: N, Iwork(*)
      REAL(DP), INTENT(IN) :: R(N), Rwork(*)
      REAL(DP), INTENT(OUT) :: Z(N)
    END SUBROUTINE MSOLVE
    PURE SUBROUTINE MATVEC(N,X,Y,Nelt,Ia,Ja,A,Isym)
      IMPORT DP
      INTEGER, INTENT(IN) :: N, Nelt, Isym, Ia(Nelt), Ja(Nelt)
      REAL(DP), INTENT(IN) :: X(N), A(Nelt)
      REAL(DP), INTENT(OUT) :: Y(N)
    END SUBROUTINE MATVEC
  END INTERFACE
  !     .. Scalar Arguments ..
  INTEGER, INTENT(IN) :: Isym, Itol, Jpre, Jscal, Kmp, Maxl, Maxlp1, N, Nelt, Nrmax, Nrsts
  INTEGER, INTENT(OUT) :: Iflag, Lgmr
  REAL(DP), INTENT(IN) :: Bnrm, Tol
  REAL(DP), INTENT(OUT) :: Rhol
  !     .. Array Arguments ..
  INTEGER, INTENT(IN) :: Ia(Nelt), Ipar(*), Ja(Nelt)
  REAL(DP), INTENT(IN) :: A(Nelt), Rpar(*), Sr(N), Sz(N), X(N)
  REAL(DP), INTENT(INOUT) :: Dl(N), R0(N), Wk(N), Xl(N)
  REAL(DP), INTENT(OUT) :: Hes(Maxlp1,Maxl), Q(2*Maxl), V(N,Maxlp1), Z(N)
  !     .. Local Scalars ..
  REAL(DP) :: c, dlnrm, prod, r0nrm, rho, s, snormw, tem, solnrm
  INTEGER :: i, i2, info, ip1, iter, itmax, j, k, ll, llp1
  !     .. Intrinsic Functions ..
  INTRINSIC ABS
  !* FIRST EXECUTABLE STATEMENT  DPIGMR
  !
  !         Zero out the Z array.
  !
  DO i = 1, N
    Z(i) = 0
  END DO
  !
  Iflag = 0
  Lgmr = 0
  !         Load ITMAX, the maximum number of iterations.
  itmax = (Nrmax+1)*Maxl
  !   -------------------------------------------------------------------
  !         The initial residual is the vector R0.
  !         Apply left precon. if JPRE < 0 and this is not a restart.
  !         Apply scaling to R0 if JSCAL = 2 or 3.
  !   -------------------------------------------------------------------
  IF( (Jpre<0) .AND. (Nrsts==0) ) THEN
    Wk(1:N) = R0(1:N)
    CALL MSOLVE(N,Wk,R0,Rpar,Ipar)
  END IF
  IF( ((Jscal==2) .OR. (Jscal==3)) .AND. (Nrsts==0) ) THEN
    DO i = 1, N
      V(i,1) = R0(i)*Sr(i)
    END DO
  ELSE
    DO i = 1, N
      V(i,1) = R0(i)
    END DO
  END IF
  r0nrm = NORM2(V(1:N,1))
  iter = Nrsts*Maxl
  IF( Itol==11 ) THEN
    Xl(1:N) = X(1:N)
    IF( (Jscal==0) .OR. (Jscal==2) ) THEN
      solnrm = NORM2( soln_com(1:N) )
      Wk(1:N) = Xl(1:N) - soln_com(1:N)
    ELSE
      solnrm = NORM2( Sz(1:N)*soln_com(1:N) )
    END IF
  END IF
  !
  !         Call stopping routine ISDGMR.
  !
  IF( ISDGMR(N,X,Xl,MSOLVE,Itol,Tol,iter,V(1,1),Wk,Rpar,Ipar,r0nrm, &
    Bnrm,Sz,Jscal,Kmp,Lgmr,Maxl,Maxlp1,V,Q,snormw,prod,r0nrm,Hes,Jpre,solnrm)/=0 ) RETURN
  tem = 1._DP/r0nrm
  V(1:N,1) = tem*V(1:N,1)
  !
  !         Zero out the HES array.
  !
  DO j = 1, Maxl
    DO i = 1, Maxlp1
      Hes(i,j) = 0
    END DO
  END DO
  !   -------------------------------------------------------------------
  !         Main loop to compute the vectors V(*,2) to V(*,MAXL).
  !         The running product PROD is needed for the convergence test.
  !   -------------------------------------------------------------------
  prod = 1
  DO ll = 1, Maxl
    Lgmr = ll
    !   -------------------------------------------------------------------
    !        Unscale  the  current V(LL)  and store  in WK.  Call routine
    !        MSOLVE    to   compute(M-inverse)*WK,   where    M   is  the
    !        preconditioner matrix.  Save the answer in Z.   Call routine
    !        MATVEC to compute  VNEW  = A*Z,  where  A is  the the system
    !        matrix.  save the answer in  V(LL+1).  Scale V(LL+1).   Call
    !        routine DORTH  to  orthogonalize the    new vector VNEW   =
    !        V(*,LL+1).  Call routine DHEQR to update the factors of HES.
    !   -------------------------------------------------------------------
    IF( (Jscal==1) .OR. (Jscal==3) ) THEN
      DO i = 1, N
        Wk(i) = V(i,ll)/Sz(i)
      END DO
    ELSE
      Wk(1:N) = V(1:N,ll)
    END IF
    IF( Jpre>0 ) THEN
      CALL MSOLVE(N,Wk,Z,Rpar,Ipar)
      CALL MATVEC(N,Z,V(1,ll+1),Nelt,Ia,Ja,A,Isym)
    ELSE
      CALL MATVEC(N,Wk,V(1,ll+1),Nelt,Ia,Ja,A,Isym)
    END IF
    IF( Jpre<0 ) THEN
      Wk(1:N) = V(1:N,ll+1)
      CALL MSOLVE(N,Wk,V(1,ll+1),Rpar,Ipar)
    END IF
    IF( (Jscal==2) .OR. (Jscal==3) ) THEN
      DO i = 1, N
        V(i,ll+1) = V(i,ll+1)*Sr(i)
      END DO
    END IF
    CALL DORTH(V(1,ll+1),V,Hes,N,ll,Maxlp1,Kmp,snormw)
    Hes(ll+1,ll) = snormw
    CALL DHEQR(Hes,Maxlp1,ll,Q,info,ll)
    IF( info==ll ) GOTO 100
    !   -------------------------------------------------------------------
    !         Update RHO, the estimate of the norm of the residual R0-A*ZL.
    !         If KMP <  MAXL, then the vectors V(*,1),...,V(*,LL+1) are not
    !         necessarily orthogonal for LL > KMP.  The vector DL must then
    !         be computed, and its norm used in the calculation of RHO.
    !   -------------------------------------------------------------------
    prod = prod*Q(2*ll)
    rho = ABS(prod*r0nrm)
    IF( (ll>Kmp) .AND. (Kmp<Maxl) ) THEN
      IF( ll==Kmp+1 ) THEN
        Dl(1:N) = V(1:N,1)
        DO i = 1, Kmp
          ip1 = i + 1
          i2 = i*2
          s = Q(i2)
          c = Q(i2-1)
          DO k = 1, N
            Dl(k) = s*Dl(k) + c*V(k,ip1)
          END DO
        END DO
      END IF
      s = Q(2*ll)
      c = Q(2*ll-1)/snormw
      llp1 = ll + 1
      DO k = 1, N
        Dl(k) = s*Dl(k) + c*V(k,llp1)
      END DO
      dlnrm = NORM2(Dl)
      rho = rho*dlnrm
    END IF
    Rhol = rho
    !   -------------------------------------------------------------------
    !         Test for convergence.  If passed, compute approximation ZL.
    !         If failed and LL < MAXL, then continue iterating.
    !   -------------------------------------------------------------------
    iter = Nrsts*Maxl + Lgmr
    IF( Itol==11 .AND. (Jscal==0) .OR. (Jscal==2) ) Wk(1:N) = Xl(1:N) - soln_com(1:N)
    IF( ISDGMR(N,X,Xl,MSOLVE,Itol,Tol,iter,Dl,Wk,Rpar,Ipar,Rhol, &
      Bnrm,Sz,Jscal,Kmp,Lgmr,Maxl,Maxlp1,V,Q,snormw,prod,r0nrm,Hes,Jpre,solnrm)/=0 ) GOTO 200
    IF( ll==Maxl ) EXIT
    !   -------------------------------------------------------------------
    !         Rescale so that the norm of V(1,LL+1) is one.
    !   -------------------------------------------------------------------
    tem = 1._DP/snormw
    V(1:N,ll+1) = tem*V(1:N,ll+1)
  END DO
  IF( rho<r0nrm ) THEN
    Iflag = 1
    !
    !         Tolerance not met, but residual norm reduced.
    !
    !
    !        If performing restarting (NRMAX > 0)  calculate the residual
    !        vector RL and  store it in the DL  array.  If the incomplete
    !        version is being used (KMP < MAXL) then DL has  already been
    !        calculated up to a scaling factor.   Use DRLCAL to calculate
    !        the scaled residual vector.
    !
    IF( Nrmax>0 ) CALL DRLCAL(N,Kmp,Maxl,Maxl,V,Q,Dl,snormw,prod,r0nrm)
    GOTO 200
  END IF
  100 CONTINUE
  IFlag = 2
  !
  !         Load approximate solution with zero.
  !
  DO i = 1, N
    Z(i) = 0
  END DO
  RETURN
  !   -------------------------------------------------------------------
  !         Compute the approximation ZL to the solution.  Since the
  !         vector Z was used as workspace, and the initial guess
  !         of the linear iteration is zero, Z must be reset to zero.
  !   -------------------------------------------------------------------
  200  ll = Lgmr
  llp1 = ll + 1
  DO k = 1, llp1
    R0(k) = 0
  END DO
  R0(1) = r0nrm
  CALL DHELS(Hes,Maxlp1,ll,Q,R0)
  DO k = 1, N
    Z(k) = 0
  END DO
  DO i = 1, ll
    CALL DAXPY(N,R0(i),V(1,i),1,Z,1)
  END DO
  IF( (Jscal==1) .OR. (Jscal==3) ) THEN
    DO i = 1, N
      Z(i) = Z(i)/Sz(i)
    END DO
  END IF
  IF( Jpre>0 ) THEN
    Wk(1:N) = Z(1:N)
    CALL MSOLVE(N,Wk,Z,Rpar,Ipar)
  END IF
  !------------- LAST LINE OF DPIGMR FOLLOWS ----------------------------
END SUBROUTINE DPIGMR