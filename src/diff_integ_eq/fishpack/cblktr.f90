!** CBLKTR
SUBROUTINE CBLKTR(Iflg,Np,N,An,Bn,Cn,Mp,M,Am,Bm,Cm,Idimy,Y,Ierror,W)
  !> Solve a block tridiagonal system of linear equations (usually resulting from
  !  the discretization of separable two-dimensional elliptic equations).
  !***
  ! **Library:**   SLATEC (FISHPACK)
  !***
  ! **Category:**  I2B4B
  !***
  ! **Type:**      COMPLEX (BLKTRI-S, CBLKTR-C)
  !***
  ! **Keywords:**  ELLIPTIC PDE, FISHPACK, TRIDIAGONAL LINEAR SYSTEM
  !***
  ! **Author:**  Adams, J., (NCAR)
  !           Swarztrauber, P. N., (NCAR)
  !           Sweet, R., (NCAR)
  !***
  ! **Description:**
  !
  !     Subroutine CBLKTR is a complex version of subroutine BLKTRI.
  !     Both subroutines solve a system of linear equations of the form
  !
  !          AN(J)*X(I,J-1) + AM(I)*X(I-1,J) + (BN(J)+BM(I))*X(I,J)
  !
  !          + CN(J)*X(I,J+1) + CM(I)*X(I+1,J) = Y(I,J)
  !
  !               For I = 1,2,...,M  and  J = 1,2,...,N.
  !
  !     I+1 and I-1 are evaluated modulo M and J+1 and J-1 modulo N, i.e.,
  !
  !          X(I,0) = X(I,N),  X(I,N+1) = X(I,1),
  !          X(0,J) = X(M,J),  X(M+1,J) = X(1,J).
  !
  !     These equations usually result from the discretization of
  !     separable elliptic equations.  Boundary conditions may be
  !     Dirichlet, Neumann, or periodic.
  !
  !
  !     * * * * * * * * * *     On INPUT     * * * * * * * * * *
  !
  !     IFLG
  !       = 0  Initialization only.  Certain quantities that depend on NP,
  !            N, AN, BN, and CN are computed and stored in the work
  !            array  W.
  !       = 1  The quantities that were computed in the initialization are
  !            used to obtain the solution X(I,J).
  !
  !       NOTE   A call with IFLG=0 takes approximately one half the time
  !              time as a call with IFLG = 1.  However, the
  !              initialization does not have to be repeated unless NP, N,
  !              AN, BN, or CN change.
  !
  !     NP
  !       = 0  If AN(1) and CN(N) are not zero, which corresponds to
  !            periodic boundary conditions.
  !       = 1  If AN(1) and CN(N) are zero.
  !
  !     N
  !       The number of unknowns in the J-direction. N must be greater
  !       than 4. The operation count is proportional to MNlog2(N), hence
  !       N should be selected less than or equal to M.
  !
  !     AN,BN,CN
  !       Real one-dimensional arrays of length N that specify the
  !       coefficients in the linear equations given above.
  !
  !     MP
  !       = 0  If AM(1) and CM(M) are not zero, which corresponds to
  !            periodic boundary conditions.
  !       = 1  If AM(1) = CM(M) = 0  .
  !
  !     M
  !       The number of unknowns in the I-direction. M must be greater
  !       than 4.
  !
  !     AM,BM,CM
  !       Complex one-dimensional arrays of length M that specify the
  !       coefficients in the linear equations given above.
  !
  !     IDIMY
  !       The row (or first) dimension of the two-dimensional array Y as
  !       it appears in the program calling BLKTRI.  This parameter is
  !       used to specify the variable dimension of Y.  IDIMY must be at
  !       least M.
  !
  !     Y
  !       A complex two-dimensional array that specifies the values of
  !       the right side of the linear system of equations given above.
  !       Y must be dimensioned Y(IDIMY,N) with IDIMY >= M.
  !
  !     W
  !       A one-dimensional array that must be provided by the user for
  !       work space.
  !             If NP=1 define K=INT(log2(N))+1 and set L=2**(K+1) then
  !                     W must have dimension (K-2)*L+K+5+MAX(2N,12M)
  !
  !             If NP=0 define K=INT(log2(N-1))+1 and set L=2**(K+1) then
  !                     W must have dimension (K-2)*L+K+5+2N+MAX(2N,12M)
  !
  !       **IMPORTANT** For purposes of checking, the required dimension
  !                     of W is computed by BLKTRI and stored in W(1)
  !                     in floating point format.
  !
  !     * * * * * * * * * *     On Output     * * * * * * * * * *
  !
  !     Y
  !       Contains the solution X.
  !
  !     IERROR
  !       An error flag that indicates invalid input parameters.  Except
  !       for number zero, a solution is not attempted.
  !
  !       = 0  No error.
  !       = 1  M is less than 5.
  !       = 2  N is less than 5.
  !       = 3  IDIMY is less than M.
  !       = 4  BLKTRI failed while computing results that depend on the
  !            coefficient arrays AN, BN, CN.  Check these arrays.
  !       = 5  AN(J)*CN(J-1) is less than 0 for some J. Possible reasons
  !            for this condition are
  !            1. The arrays AN and CN are not correct.
  !            2. Too large a grid spacing was used in the discretization
  !               of the elliptic equation.
  !            3. The linear equations resulted from a partial
  !               differential equation which was not elliptic.
  !
  !     W
  !       Contains intermediate values that must not be destroyed if
  !       CBLKTR will be called again with IFLG=1.  W(1) contains the
  !       number of locations required by W in floating point format.
  !
  !- Long Description:
  !
  !     * * * * * * *   Program Specifications    * * * * * * * * * * * *
  !
  !     Dimension of   AN(N),BN(N),CN(N),AM(M),BM(M),CM(M),Y(IDIMY,N)
  !     Arguments      W(see argument list)
  !
  !     Latest         June 1979
  !     Revision
  !
  !     Required       CBLKTR,CBLKT1,PROC,PROCP,CPROC,CPROCP,CCMPB,INXCA,
  !     Subprograms    INXCB,INXCC,CPADD,PGSF,PPGSF,PPPSF,BCRH,TEVLC,
  !                    R1MACH
  !
  !     Special        The algorithm may fail if ABS(BM(I)+BN(J)) is less
  !     Conditions     than ABS(AM(I))+ABS(AN(J))+ABS(CM(I))+ABS(CN(J))
  !                    for some I and J. The algorithm will also fail if
  !                    AN(J)*CN(J-1) is less than zero for some J.
  !                    See the description of the output parameter IERROR.
  !
  !     Common         CCBLK
  !     Blocks
  !
  !     I/O            NONE
  !
  !     Precision      Single
  !
  !     Specialist     Paul Swarztrauber
  !
  !     Language       FORTRAN
  !
  !     History        CBLKTR is a complex version of BLKTRI (version 3)
  !
  !     Algorithm      Generalized Cyclic Reduction (see reference below)
  !
  !     Space
  !     Required       CONTROL DATA 7600
  !
  !     Portability    American National Standards Institute FORTRAN.
  !                    The machine accuracy is set using function R1MACH.
  !
  !     Required       NONE
  !     Resident
  !     Routines
  !
  !     References     Swarztrauber,P. and R. SWEET, 'Efficient Fortran
  !                    Subprograms for the solution of elliptic equations'
  !                    NCAR TN/IA-109, July, 1975, 138 PP.
  !
  !                    SWARZTRAUBER P. ,'A Direct Method for The Discrete
  !                    Solution of Separable Elliptic Equations', SIAM
  !                    J. Numer. Anal.,11(1974) PP. 1136-1150.
  !
  !     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  !
  !***
  ! **References:**  P. N. Swarztrauber and R. Sweet, Efficient Fortran
  !                 subprograms for the solution of elliptic equations,
  !                 NCAR TN/IA-109, July 1975, 138 pp.
  !               P. N. Swarztrauber, A direct method for the discrete
  !                 solution of separable elliptic equations, SIAM Journal
  !                 on Numerical Analysis 11, (1974), pp. 1136-1150.
  !***
  ! **Routines called:**  CBLKT1, CCMPB, CPROC, CPROCP, PROC, PROCP
  !***
  ! COMMON BLOCKS    CCBLK

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  USE CCBLK, ONLY : k_com, ik_com, nm_com, npp_com
  !
  INTEGER, INTENT(IN) :: Idimy, Iflg, M, Mp, N, Np
  INTEGER, INTENT(OUT) :: Ierror
  REAL(SP), INTENT(IN) :: An(N), Bn(N), Cn(N)
  REAL(SP), INTENT(INOUT) :: W(:)
  COMPLEX(SP), INTENT(IN) :: Am(M), Bm(M), Cm(M)
  COMPLEX(SP), INTENT(INOUT) :: Y(Idimy,N)
  !
  INTEGER :: iw1, iw2, iw3, iwah, iwbh, iwd, i, iwu, iww, m2, nh, nl, nw
  COMPLEX(SP) :: wc(SIZE(W))
  !* FIRST EXECUTABLE STATEMENT  CBLKTR
  nw = SIZE(W)
  wc = [ ( CMPLX(W(i),W(i+1),SP), i=1,nw,2 ) ]
  nm_com = N
  m2 = M + M
  Ierror = 0
  IF( M<5 ) THEN
    Ierror = 1
  ELSEIF( nm_com<3 ) THEN
    Ierror = 2
  ELSEIF( Idimy<M ) THEN
    Ierror = 3
  ELSE
    nh = N
    npp_com = Np
    IF( npp_com/=0 ) nh = nh + 1
    ik_com = 2
    k_com = 1
    DO
      ik_com = ik_com + ik_com
      k_com = k_com + 1
      IF( nh<=ik_com ) THEN
        nl = ik_com
        ik_com = ik_com + ik_com
        nl = nl - 1
        iwah = (k_com-2)*ik_com + k_com + 6
        IF( npp_com/=0 ) THEN
          !
          !     DIVIDE W INTO WORKING SUB ARRAYS
          !
          iw1 = iwah
          iwbh = iw1 + nm_com
          W(1) = iw1 - 1 + MAX(2*nm_com,12*M)
        ELSE
          iwbh = iwah + nm_com + nm_com
          iw1 = iwbh
          W(1) = iw1 - 1 + MAX(2*nm_com,12*M)
          nm_com = nm_com - 1
        END IF
        !
        ! SUBROUTINE CCMPB COMPUTES THE ROOTS OF THE B POLYNOMIALS
        !
        IF( Ierror==0 ) THEN
          iw2 = iw1 + m2
          iw3 = iw2 + m2
          iwd = iw3 + m2
          iww = iwd + m2
          iwu = iww + m2
          IF( Iflg==0 ) THEN
            CALL CCMPB(Ierror,An,Bn,Cn,W(2:iwah),W(iwah:iwbh-1),W(iwbh:))
          ELSEIF( Mp/=0 ) THEN
            !
            ! SUBROUTINE CBLKT1 SOLVES THE LINEAR SYSTEM
            !
            CALL CBLKT1(An,Cn,M,Am,Bm,Cm,Idimy,Y,W(2:iw1/2-1),wc(iw1/2:iw2/2-1),&
              wc(iw2/2:iw3/2-1),wc(iw3/2:iwd-1),wc(iwd:iww-1),wc(iww:iwu-1),&
              wc(iwu:),PROC,CPROC)
            W(1:nw) = [ ( [REAL(wc(i)),AIMAG(wc(i))], i=1,nw/2 ) ]
          ELSE
            CALL CBLKT1(An,Cn,M,Am,Bm,Cm,Idimy,Y,W(2:iw1/2-1),wc(iw1/2:iw2/2-1),&
              wc(iw2/2:iw3/2-1),wc(iw3/2:iwd-1),wc(iwd:iww-1),wc(iww:iwu-1),&
              wc(iwu:),PROCP,CPROCP)
            W(1:nw) = [ ( [REAL(wc(i)),AIMAG(wc(i))], i=1,nw/2 ) ]
          END IF
        END IF
        EXIT
      END IF
    END DO
  END IF
  !
END SUBROUTINE CBLKTR