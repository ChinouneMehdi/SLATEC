!** SSDI
PURE SUBROUTINE SSDI(N,B,X,Rwork,Iwork)
  !> Diagonal Matrix Vector Multiply.
  !  Routine to calculate the product  X = DIAG*B, where DIAG is a diagonal matrix.
  !***
  ! **Library:**   SLATEC (SLAP)
  !***
  ! **Category:**  D1B4
  !***
  ! **Type:**      SINGLE PRECISION (SSDI-S, DSDI-D)
  !***
  ! **Keywords:**  ITERATIVE PRECONDITION, LINEAR SYSTEM SOLVE, SLAP, SPARSE
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
  !     INTEGER  N, NELT, IA(NELT), JA(NELT), ISYM, IWORK(10)
  !     REAL B(N), X(N), A(NELT), RWORK(USER DEFINED)
  !
  !     CALL SSDI (N, B, X, NELT, IA, JA, A, ISYM, RWORK, IWORK)
  !
  !- Arguments:
  ! N      :IN       Integer
  !         Order of the Matrix.
  ! B      :IN       Real B(N).
  !         Vector to multiply the diagonal by.
  ! X      :OUT      Real X(N).
  !         Result of DIAG*B.
  ! NELT   :DUMMY    Integer.
  ! IA     :DUMMY    Integer IA(NELT).
  ! JA     :DUMMY    Integer JA(NELT).
  ! A      :DUMMY    Real A(NELT).
  ! ISYM   :DUMMY    Integer.
  !         These are for compatibility with SLAP MSOLVE calling sequence.
  ! RWORK  :IN       Real RWORK(USER DEFINED).
  !         Work array holding the diagonal of some matrix to scale
  !         B by.  This array must be set by the user or by a call
  !         to the SLAP routine SSDS or SSD2S.  The length of RWORK
  !         must be >= IWORK(4)+N.
  ! IWORK  :IN       Integer IWORK(10).
  !         IWORK(4) holds the offset into RWORK for the diagonal matrix
  !         to scale B by.  This is usually set up by the SLAP pre-
  !         conditioner setup routines SSDS or SSD2S.
  !
  !- Description:
  !         This routine is supplied with the SLAP package to perform
  !         the  MSOLVE  operation for iterative drivers that require
  !         diagonal  Scaling  (e.g., SSDCG, SSDBCG).   It  conforms
  !         to the SLAP MSOLVE CALLING CONVENTION  and hence does not
  !         require an interface routine as do some of the other pre-
  !         conditioners supplied with SLAP.
  !
  !***
  ! **See also:**  SSDS, SSD2S
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  (NONE)

  !* REVISION HISTORY  (YYMMDD)
  !   871119  DATE WRITTEN
  !   881213  Previous REVISION DATE
  !   890915  Made changes requested at July 1989 CML Meeting.  (MKS)
  !   890922  Numerous changes to prologue to make closer to SLATEC standard.  (FNF)
  !   890929  Numerous changes to reduce SP/DP differences.  (FNF)
  !   910411  Prologue converted to Version 4.0 format.  (BAB)
  !   920511  Added complete declaration section.  (WRB)
  !   930701  Updated CATEGORY section.  (FNF, WRB)

  !     .. Scalar Arguments ..
  INTEGER, INTENT(IN) :: N
  !     .. Array Arguments ..
  INTEGER, INTENT(IN) :: Iwork(*)
  REAL(SP), INTENT(IN) :: B(N), Rwork(*)
  REAL(SP), INTENT(OUT) :: X(N)
  !     .. Local Scalars ..
  INTEGER :: i, locd
  !* FIRST EXECUTABLE STATEMENT  SSDI
  !
  !         Determine where the inverse of the diagonal
  !         is in the work array and then scale by it.
  !
  locd = Iwork(4) - 1
  DO i = 1, N
    X(i) = Rwork(locd+i)*B(i)
  END DO
  !------------- LAST LINE OF SSDI FOLLOWS ----------------------------
END SUBROUTINE SSDI