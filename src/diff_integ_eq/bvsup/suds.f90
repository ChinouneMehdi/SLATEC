!** SUDS
SUBROUTINE SUDS(A,X,B,Neq,Nuk,Nrda,Iflag,Mlso,Work,Iwork)
  !> Subsidiary to BVSUP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (SUDS-S, DSUDS-D)
  !***
  ! **Author:**  Watts, H. A., (SNLA)
  !***
  ! **Description:**
  !
  !     SUDS solves the underdetermined system of linear equations A Z = B
  !     where A is NEQ by NUK and NEQ <= NUK. In particular, if rank A
  !     equals IRA, a vector X and a matrix U are determined such that
  !     X is the UNIQUE solution of smallest length, satisfying A X = B,
  !     and the columns of U form an orthonormal basis for the null
  !     space of A, satisfying A U = 0 . Then all solutions Z are
  !     given by
  !              Z = X + C(1)*U(1) + ..... + C(NUK-IRA)*U(NUK-IRA)
  !     where U(J) represents the J-th column of U and the C(J) are
  !     arbitrary constants.
  !     If the system of equations are not compatible, only the least
  !     squares solution of minimal length is computed.
  !     SUDS is an interfacing routine which calls subroutine LSSUDS
  !     for the solution. LSSUDS in turn calls subroutine ORTHOR and
  !     possibly subroutine OHTROL for the decomposition of A by
  !     orthogonal transformations. In the process, ORTHOR calls upon
  !     subroutine CSCALE for scaling.
  !
  !- *********************************************************************
  !   INPUT
  !- *********************************************************************
  !
  !     A -- Contains the matrix of NEQ equations in NUK unknowns and must
  !          be dimensioned NRDA by NUK. The original A is destroyed.
  !     X -- Solution array of length at least NUK
  !     B -- Given constant vector of length NEQ, B is destroyed
  !     NEQ -- Number of equations, NEQ greater or equal to 1
  !     NUK -- Number of columns in the matrix (which is also the number
  !            of unknowns), NUK not smaller than NEQ
  !     NRDA -- Row dimension of A, NRDA greater or equal to NEQ
  !     IFLAG -- Status indicator
  !           =0  For the first call (and for each new problem defined by
  !               a new matrix A) when the matrix data is treated as exact
  !           =-K For the first call (and for each new problem defined by
  !               a new matrix A) when the matrix data is assumed to be
  !               accurate to about K digits
  !           =1  For subsequent calls whenever the matrix A has already
  !               been decomposed (problems with new vectors B but
  !               same matrix A can be handled efficiently)
  !     MLSO -- =0 If only the minimal length solution is wanted
  !             =1 If the complete solution is wanted, includes the
  !                linear space defined by the matrix U in the abstract
  !     WORK(*),IWORK(*) -- Arrays for storage of internal information,
  !                WORK must be dimensioned at least
  !                       NUK + 3*NEQ + MLSO*NUK*(NUK-rank A)
  !                where it is possible for   0 <= rank A <= NEQ
  !                IWORK must be dimensioned at least   3 + NEQ
  !     IWORK(2) -- Scaling indicator
  !                 =-1 If the matrix is to be pre-scaled by
  !                 columns when appropriate
  !                 If the scaling indicator is not equal to -1
  !                 no scaling will be attempted
  !              For most problems scaling will probably not be necessary
  !
  !- *********************************************************************
  !   OUTPUT
  !- *********************************************************************
  !
  !     IFLAG -- Status indicator
  !            =1 If solution was obtained
  !            =2 If improper input is detected
  !            =3 If rank of matrix is less than NEQ
  !               To continue simply reset IFLAG=1 and call SUDS again
  !            =4 If the system of equations appears to be inconsistent.
  !               However, the least squares solution of minimal length
  !               was obtained.
  !     X -- Minimal length least squares solution of  A X = B
  !     A -- Contains the strictly upper triangular part of the reduced
  !           matrix and transformation information
  !     WORK(*),IWORK(*) -- Contains information needed on subsequent
  !                         calls (IFLAG=1 case on input) which must not
  !                         be altered.
  !                         The matrix U described in the abstract is
  !                         stored in the  NUK*(NUK-rank A) elements of
  !                         the work array beginning at WORK(1+NUK+3*NEQ).
  !                         However U is not defined when MLSO=0 or
  !                         IFLAG=4.
  !                         IWORK(1) Contains the numerically determined
  !                         rank of the matrix A
  !
  !- *********************************************************************
  !
  !***
  ! **See also:**  BVSUP
  !***
  ! **References:**  H. A. Watts, Solving linear least squares problems
  !                 using SODS/SUDS/CODS, Sandia Report SAND77-0683,
  !                 Sandia Laboratories, 1977.
  !***
  ! **Routines called:**  LSSUDS

  !* REVISION HISTORY  (YYMMDD)
  !   750601  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910408  Updated the AUTHOR and REFERENCES sections.  (WRB)
  !   920501  Reformatted the REFERENCES section.  (WRB)

  INTEGER :: Iflag, Mlso, Neq, Nrda, Nuk, Iwork(*)
  REAL(SP) :: A(Nrda,Nuk), B(Neq), Work(*), X(Nuk)
  INTEGER :: il, ip, is, ks, kt, ku, kv
  !* FIRST EXECUTABLE STATEMENT  SUDS
  is = 2
  ip = 3
  il = ip + Neq
  kv = 1 + Neq
  kt = kv + Neq
  ks = kt + Neq
  ku = ks + Nuk
  !
  CALL LSSUDS(A,X,B,Neq,Nuk,Nrda,Work(ku),Nuk,Iflag,Mlso,Iwork(1),Iwork(is),&
    A,Work(1),Iwork(ip),B,Work(kv),Work(kt),Iwork(il),Work(ks))
  !
END SUBROUTINE SUDS
