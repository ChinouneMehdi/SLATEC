!** DRLCAL
PURE SUBROUTINE DRLCAL(N,Kmp,Ll,Maxl,V,Q,Rl,Snormw,Prod,R0nrm)
  !> Internal routine for DGMRES.
  !***
  ! **Library:**   SLATEC (SLAP)
  !***
  ! **Category:**  D2A4, D2B4
  !***
  ! **Type:**      DOUBLE PRECISION (SRLCAL-S, DRLCAL-D)
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
  !         This routine calculates the scaled residual RL from the
  !         V(I)'s.
  !- Usage:
  !      INTEGER N, KMP, LL, MAXL
  !      DOUBLE PRECISION V(N,LL), Q(2*MAXL), RL(N), SNORMW, PROD, R0NORM
  !
  !      CALL DRLCAL(N, KMP, LL, MAXL, V, Q, RL, SNORMW, PROD, R0NRM)
  !
  !- Arguments:
  ! N      :IN       Integer
  !         The order of the matrix A, and the lengths
  !         of the vectors SR, SZ, R0 and Z.
  ! KMP    :IN       Integer
  !         The number of previous V vectors the new vector VNEW
  !         must be made orthogonal to. (KMP <= MAXL)
  ! LL     :IN       Integer
  !         The current dimension of the Krylov subspace.
  ! MAXL   :IN       Integer
  !         The maximum dimension of the Krylov subspace.
  ! V      :IN       Double Precision V(N,LL)
  !         The N x LL array containing the orthogonal vectors
  !         V(*,1) to V(*,LL).
  ! Q      :IN       Double Precision Q(2*MAXL)
  !         A double precision array of length 2*MAXL containing the
  !         components of the Givens rotations used in the QR
  !         decomposition of HES.  It is loaded in DHEQR and used in
  !         DHELS.
  ! RL     :OUT      Double Precision RL(N)
  !         The residual vector RL.  This is either SB*(B-A*XL) if
  !         not preconditioning or preconditioning on the right,
  !         or SB*(M-inverse)*(B-A*XL) if preconditioning on the
  !         left.
  ! SNORMW :IN       Double Precision
  !         Scale factor.
  ! PROD   :IN       Double Precision
  !         The product s1*s2*...*sl = the product of the sines of the
  !         Givens rotations used in the QR factorization of
  !         the Hessenberg matrix HES.
  ! R0NRM  :IN       Double Precision
  !         The scaled norm of initial residual R0.
  !
  !***
  ! **See also:**  DGMRES
  !***
  ! **Routines called:**  DCOPY, DSCAL

  !* REVISION HISTORY  (YYMMDD)
  !   890404  DATE WRITTEN
  !   890404  Previous REVISION DATE
  !   890915  Made changes requested at July 1989 CML Meeting.  (MKS)
  !   890922  Numerous changes to prologue to make closer to SLATEC standard.  (FNF)
  !   890929  Numerous changes to reduce SP/DP differences.  (FNF)
  !   910411  Prologue converted to Version 4.0 format.  (BAB)
  !   910506  Made subsidiary to DGMRES.  (FNF)
  !   920511  Added complete declaration section.  (WRB)

  !     .. Scalar Arguments ..
  INTEGER, INTENT(IN) :: Kmp, Ll, Maxl, N
  REAL(DP), INTENT(IN) :: Prod, R0nrm, Snormw
  !     .. Array Arguments ..
  REAL(DP), INTENT(IN) :: Q(2*Maxl), V(N,Ll+1)
  REAL(DP), INTENT(OUT) :: Rl(N)
  !     .. Local Scalars ..
  REAL(DP) :: c, s, tem
  INTEGER :: i, i2, ip1, k, llm1, llp1
  !* FIRST EXECUTABLE STATEMENT  DRLCAL
  IF( Kmp==Maxl ) THEN
    !
    !         calculate RL.  Start by copying V(*,1) into RL.
    !
    Rl(1:N) = V(1:N,1)
    llm1 = Ll - 1
    DO i = 1, llm1
      ip1 = i + 1
      i2 = i*2
      s = Q(i2)
      c = Q(i2-1)
      DO k = 1, N
        Rl(k) = s*Rl(k) + c*V(k,ip1)
      END DO
    END DO
    s = Q(2*Ll)
    c = Q(2*Ll-1)/Snormw
    llp1 = Ll + 1
    DO k = 1, N
      Rl(k) = s*Rl(k) + c*V(k,llp1)
    END DO
  END IF
  !
  !         When KMP < MAXL, RL vector already partially calculated.
  !         Scale RL by R0NRM*PROD to obtain the residual RL.
  !
  tem = R0nrm*Prod
  Rl = tem*Rl
  !------------- LAST LINE OF DRLCAL FOLLOWS ----------------------------
END SUBROUTINE DRLCAL