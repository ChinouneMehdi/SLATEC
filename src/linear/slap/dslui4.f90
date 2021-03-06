!** DSLUI4
PURE SUBROUTINE DSLUI4(N,B,X,Il,Jl,L,Dinv,Iu,Ju,U)
  !> SLAP Backsolve for LDU Factorization.
  !  Routine to solve a system of the form  (L*D*U)' X = B, where L is a unit
  !  lower triangular matrix, D is a diagonal matrix, and U is a unit upper
  !  triangular matrix and 'denotes transpose.
  !***
  ! **Library:**   SLATEC (SLAP)
  !***
  ! **Category:**  D2E
  !***
  ! **Type:**      DOUBLE PRECISION (SSLUI4-S, DSLUI4-D)
  !***
  ! **Keywords:**  ITERATIVE PRECONDITION, NON-SYMMETRIC LINEAR SYSTEM SOLVE,
  !             SLAP, SPARSE
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
  !     INTEGER N, IL(NL), JL(NL), IU(NU), JU(NU)
  !     DOUBLE PRECISION B(N), X(N), L(NL), DINV(N), U(NU)
  !
  !     CALL DSLUI4( N, B, X, IL, JL, L, DINV, IU, JU, U )
  !
  !- Arguments:
  ! N      :IN       Integer
  !         Order of the Matrix.
  ! B      :IN       Double Precision B(N).
  !         Right hand side.
  ! X      :OUT      Double Precision X(N).
  !         Solution of (L*D*U)trans x = b.
  ! IL     :IN       Integer IL(NL).
  ! JL     :IN       Integer JL(NL).
  ! L      :IN       Double Precision L(NL).
  !         IL, JL, L contain the unit lower triangular  factor of the
  !         incomplete decomposition of some matrix stored in SLAP Row
  !         format.  The diagonal of ones *IS* stored.  This structure
  !         can    be  set  up  by   the  DSILUS  routine.   See   the
  !         "Description",  below for  more  details about  the   SLAP
  !         format.  (NL is the number of non-zeros in the L array.)
  ! DINV   :IN       Double Precision DINV(N).
  !         Inverse of the diagonal matrix D.
  ! IU     :IN       Integer IU(NU).
  ! JU     :IN       Integer JU(NU).
  ! U      :IN       Double Precision U(NU).
  !         IU, JU, U contain the  unit upper triangular factor of the
  !         incomplete  decomposition of some  matrix stored  in  SLAP
  !         Column  format.   The diagonal of  ones *IS* stored.  This
  !         structure can be set up by the  DSILUS routine.  See   the
  !         "Description",  below for  more  details  about  the  SLAP
  !         format.  (NU is the number of non-zeros in the U array.)
  !
  !- Description:
  !       This routine is supplied with the SLAP package as  a routine
  !       to  perform  the  MTSOLV  operation  in  the SBCG  iteration
  !       routine for the  driver DSLUBC.   It must  be called via the
  !       SLAP  MTSOLV calling  sequence convention interface  routine
  !       DSLUTI.
  !         **** THIS ROUTINE ITSELF DOES NOT CONFORM TO THE ****
  !               **** SLAP MSOLVE CALLING CONVENTION ****
  !
  !       IL, JL, L should contain the unit lower triangular factor of
  !       the incomplete decomposition of the A matrix  stored in SLAP
  !       Row format.  IU, JU, U should contain  the unit upper factor
  !       of the  incomplete decomposition of  the A matrix  stored in
  !       SLAP Column format This ILU factorization can be computed by
  !       the DSILUS routine. The diagonals (which are all one's) are
  !       stored.
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
  !       ==================== S L A P Row format ====================
  !
  !       This routine requires  that the matrix A  be  stored  in the
  !       SLAP  Row format.   In this format  the non-zeros are stored
  !       counting across  rows (except for the diagonal  entry, which
  !       must  appear first  in each  "row")  and  are stored  in the
  !       double precision  array A.  In other words, for each row  in
  !       the matrix  put the diagonal  entry in A.   Then put in  the
  !       other  non-zero elements  going across  the row  (except the
  !       diagonal) in order.  The JA array holds the column index for
  !       each non-zero.  The IA array holds the offsets  into the JA,
  !       A  arrays  for  the   beginning  of  each  row.    That  is,
  !       JA(IA(IROW)),A(IA(IROW)) are the first elements of the IROW-
  !       th row in  JA and A,  and  JA(IA(IROW+1)-1), A(IA(IROW+1)-1)
  !       are  the last elements  of the  IROW-th row.   Note  that we
  !       always have  IA(N+1) = NELT+1, where N is the number of rows
  !       in the matrix  and  NELT is the  number of non-zeros  in the
  !       matrix.
  !
  !       Here is an example of the SLAP Row storage format for a  5x5
  !       Matrix (in the A and JA arrays '|' denotes the end of a row):
  !
  !           5x5 Matrix         SLAP Row format for 5x5 matrix on left.
  !                              1  2  3    4  5    6  7    8    9 10 11
  !       |11 12  0  0 15|   A: 11 12 15 | 22 21 | 33 35 | 44 | 55 51 53
  !       |21 22  0  0  0|  JA:  1  2  5 |  2  1 |  3  5 |  4 |  5  1  3
  !       | 0  0 33  0 35|  IA:  1  4  6    8  9   12
  !       | 0  0  0 44  0|
  !       |51  0 53  0 55|
  !
  !       With  the SLAP  format  the "inner  loops" of  this  routine
  !       should vectorize   on machines with   hardware  support  for
  !       vector gather/scatter operations.  Your compiler may require
  !       a  compiler directive  to  convince   it that there  are  no
  !       implicit vector  dependencies.  Compiler directives  for the
  !       Alliant FX/Fortran and CRI CFT/CFT77 compilers  are supplied
  !       with the standard SLAP distribution.
  !
  !***
  ! **See also:**  DSILUS
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
  !   921113  Corrected C***CATEGORY line.  (FNF)
  !   930701  Updated CATEGORY section.  (FNF, WRB)

  !     .. Scalar Arguments ..
  INTEGER, INTENT(IN) :: N
  !     .. Array Arguments ..
  INTEGER, INTENT(IN) :: Il(*), Iu(*), Jl(*), Ju(*)
  REAL(DP), INTENT(IN) :: B(N), Dinv(N), L(*), U(*)
  REAL(DP), INTENT(OUT) :: X(N)
  !     .. Local Scalars ..
  INTEGER :: i, icol, irow, j, jbgn, jend
  !* FIRST EXECUTABLE STATEMENT  DSLUI4
  DO i = 1, N
    X(i) = B(i)
  END DO
  !
  !         Solve  U'*Y = X,  storing result in X, U stored by columns.
  DO irow = 2, N
    jbgn = Ju(irow)
    jend = Ju(irow+1) - 1
    IF( jbgn<=jend ) THEN
      DO j = jbgn, jend
        X(irow) = X(irow) - U(j)*X(Iu(j))
      END DO
    END IF
  END DO
  !
  !         Solve  D*Z = Y,  storing result in X.
  DO i = 1, N
    X(i) = X(i)*Dinv(i)
  END DO
  !
  !         Solve  L'*X = Z, L stored by rows.
  DO icol = N, 2, -1
    jbgn = Il(icol)
    jend = Il(icol+1) - 1
    IF( jbgn<=jend ) THEN
      DO j = jbgn, jend
        X(Jl(j)) = X(Jl(j)) - L(j)*X(icol)
      END DO
    END IF
  END DO
  !------------- LAST LINE OF DSLUI4 FOLLOWS ----------------------------
END SUBROUTINE DSLUI4