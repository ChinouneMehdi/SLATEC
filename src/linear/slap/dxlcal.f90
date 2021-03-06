!** DXLCAL
PURE SUBROUTINE DXLCAL(N,Lgmr,X,Xl,Zl,Hes,Maxlp1,Q,V,R0nrm,Wk,Sz,Jscal,Jpre,&
    MSOLVE,Rpar,Ipar)
  !> Internal routine for DGMRES.
  !***
  ! **Library:**   SLATEC (SLAP)
  !***
  ! **Category:**  D2A4, D2B4
  !***
  ! **Type:**      DOUBLE PRECISION (SXLCAL-S, DXLCAL-D)
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
  !        This  routine computes the solution  XL,  the current DGMRES
  !        iterate, given the  V(I)'s and  the  QR factorization of the
  !        Hessenberg  matrix HES.   This routine  is  only called when
  !        ITOL=11.
  !
  !- Usage:
  !      INTEGER N, LGMR, MAXLP1, JSCAL, JPRE, NMSL, IPAR(USER DEFINED)
  !      INTEGER NELT, IA(NELT), JA(NELT), ISYM
  !      DOUBLE PRECISION X(N), XL(N), ZL(N), HES(MAXLP1,MAXL), Q(2*MAXL),
  !     $                 V(N,MAXLP1), R0NRM, WK(N), SZ(N),
  !     $                 RPAR(USER DEFINED), A(NELT)
  !      EXTERNAL MSOLVE
  !
  !      CALL DXLCAL(N, LGMR, X, XL, ZL, HES, MAXLP1, Q, V, R0NRM,
  !     $     WK, SZ, JSCAL, JPRE, MSOLVE, NMSL, RPAR, IPAR,
  !     $     NELT, IA, JA, A, ISYM)
  !
  !- Arguments:
  ! N      :IN       Integer
  !         The order of the matrix A, and the lengths
  !         of the vectors SR, SZ, R0 and Z.
  ! LGMR   :IN       Integer
  !         The number of iterations performed and
  !         the current order of the upper Hessenberg
  !         matrix HES.
  ! X      :IN       Double Precision X(N)
  !         The current approximate solution as of the last restart.
  ! XL     :OUT      Double Precision XL(N)
  !         An array of length N used to hold the approximate
  !         solution X(L).
  !         Warning: XL and ZL are the same array in the calling routine.
  ! ZL     :IN       Double Precision ZL(N)
  !         An array of length N used to hold the approximate
  !         solution Z(L).
  ! HES    :IN       Double Precision HES(MAXLP1,MAXL)
  !         The upper triangular factor of the QR decomposition
  !         of the (LGMR+1) by LGMR upper Hessenberg matrix whose
  !         entries are the scaled inner-products of A*V(*,i) and V(*,k).
  ! MAXLP1 :IN       Integer
  !         MAXLP1 = MAXL + 1, used for dynamic dimensioning of HES.
  !         MAXL is the maximum allowable order of the matrix HES.
  ! Q      :IN       Double Precision Q(2*MAXL)
  !         A double precision array of length 2*MAXL containing the
  !         components of the Givens rotations used in the QR
  !         decomposition of HES.  It is loaded in DHEQR.
  ! V      :IN       Double Precision V(N,MAXLP1)
  !         The N by(LGMR+1) array containing the LGMR
  !         orthogonal vectors V(*,1) to V(*,LGMR).
  ! R0NRM  :IN       Double Precision
  !         The scaled norm of the initial residual for the
  !         current call to DPIGMR.
  ! WK     :IN       Double Precision WK(N)
  !         A double precision work array of length N.
  ! SZ     :IN       Double Precision SZ(N)
  !         A vector of length N containing the non-zero
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
  ! JPRE   :IN       Integer
  !         The preconditioner type flag.
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
  ! NMSL   :IN       Integer
  !         The number of calls to MSOLVE.
  ! RPAR   :IN       Double Precision RPAR(USER DEFINED)
  !         Double Precision workspace passed directly to the MSOLVE
  !         routine.
  ! IPAR   :IN       Integer IPAR(USER DEFINED)
  !         Integer workspace passed directly to the MSOLVE routine.
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
  !         data.
  !         It is passed directly to the MATVEC and MSOLVE routines.
  ! ISYM   :IN       Integer
  !         A flag to indicate symmetric matrix storage.
  !         If ISYM=0, all non-zero entries of the matrix are
  !         stored.  If ISYM=1, the matrix is symmetric and
  !         only the upper or lower triangular part is stored.
  !
  !***
  ! **See also:**  DGMRES
  !***
  ! **Routines called:**  DAXPY, DCOPY, DHELS

  !* REVISION HISTORY  (YYMMDD)
  !   890404  DATE WRITTEN
  !   890404  Previous REVISION DATE
  !   890915  Made changes requested at July 1989 CML Meeting.  (MKS)
  !   890922  Numerous changes to prologue to make closer to SLATEC standard.  (FNF)
  !   890929  Numerous changes to reduce SP/DP differences.  (FNF)
  !   910411  Prologue converted to Version 4.0 format.  (BAB)
  !   910502  Removed MSOLVE from ROUTINES CALLED list.  (FNF)
  !   910506  Made subsidiary to DGMRES.  (FNF)
  !   920511  Added complete declaration section.  (WRB)
  USE blas, ONLY : DAXPY

  INTERFACE
    PURE SUBROUTINE MSOLVE(N,R,Z,Rwork,Iwork)
      IMPORT DP
      INTEGER, INTENT(IN) :: N, Iwork(*)
      REAL(DP), INTENT(IN) :: R(N), Rwork(*)
      REAL(DP), INTENT(OUT) :: Z(N)
    END SUBROUTINE MSOLVE
  END INTERFACE
  !     .. Scalar Arguments ..
  INTEGER, INTENT(IN) :: Jpre, Jscal, Lgmr, Maxlp1, N
  REAL(DP), INTENT(IN) :: R0nrm
  !     .. Array Arguments ..
  INTEGER, INTENT(IN) :: Ipar(*)
  REAL(DP), INTENT(IN) :: Hes(Maxlp1,Maxlp1-1), Q(2*(Maxlp1-1)), Rpar(*), Sz(N), &
    V(N,Maxlp1), X(N)
  REAL(DP), INTENT(INOUT) :: Wk(N), Zl(N)
  REAL(DP), INTENT(OUT) :: Xl(N)
  !     .. Local Scalars ..
  INTEGER :: i, k, ll, llp1
  !* FIRST EXECUTABLE STATEMENT  DXLCAL
  ll = Lgmr
  llp1 = ll + 1
  DO k = 1, llp1
    Wk(k) = 0
  END DO
  Wk(1) = R0nrm
  CALL DHELS(Hes,Maxlp1,ll,Q,Wk)
  DO k = 1, N
    Zl(k) = 0
  END DO
  DO i = 1, ll
    CALL DAXPY(N,Wk(i),V(1,i),1,Zl,1)
  END DO
  IF( (Jscal==1) .OR. (Jscal==3) ) THEN
    DO k = 1, N
      Zl(k) = Zl(k)/Sz(k)
    END DO
  END IF
  IF( Jpre>0 ) THEN
    Wk = Zl
    CALL MSOLVE(N,Wk,Zl,Rpar,Ipar)
  END IF
  !         calculate XL from X and ZL.
  DO k = 1, N
    Xl(k) = X(k) + Zl(k)
  END DO
  !------------- LAST LINE OF DXLCAL FOLLOWS ----------------------------
END SUBROUTINE DXLCAL