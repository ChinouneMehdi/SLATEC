!DECK DQDOTI
REAL(8) FUNCTION DQDOTI(N,Db,Qc,Dx,Incx,Dy,Incy)
  IMPLICIT NONE
  INTEGER i, i1, Incx, Incy, ix, iy, MPB, MPLun, MPM, MPMxr, MPR, &
    MPT, N
  !***BEGIN PROLOGUE  DQDOTI
  !***PURPOSE  Compute the inner product of two vectors with extended
  !            precision accumulation and result.
  !***LIBRARY   SLATEC
  !***CATEGORY  D1A4
  !***TYPE      DOUBLE PRECISION (DQDOTI-D)
  !***KEYWORDS  DOT PRODUCT, INNER PRODUCT
  !***AUTHOR  Lawson, C. L., (JPL)
  !           Hanson, R. J., (SNLA)
  !           Kincaid, D. R., (U. of Texas)
  !           Krogh, F. T., (JPL)
  !***DESCRIPTION
  !
  !                B L A S  Subprogram
  !    Description of parameters
  !
  !     --Input--
  !        N  number of elements in input vector(s)
  !       DB  double precision scalar to be added to inner product
  !       QC  extended precision scalar to be added
  !       DX  double precision vector with N elements
  !     INCX  storage spacing between elements of DX
  !       DY  double precision vector with N elements
  !     INCY  storage spacing between elements of DY
  !
  !     --Output--
  !   DQDOTI  double precision result
  !       QC  extended precision result
  !
  !     D.P. dot product with extended precision accumulation (and result)
  !     QC and DQDOTI are set = DB + sum for I = 0 to N-1 of
  !       DX(LX+I*INCX) * DY(LY+I*INCY),  where QC is an extended
  !       precision result which can be used as input to DQDOTA,
  !       and LX = 1 if INCX .GE. 0, else LX = (-INCX)*N, and LY is
  !       defined in a similar way using INCY.  The MP package by
  !       Richard P. Brent is used for the extended precision arithmetic.
  !
  !     Fred T. Krogh,  JPL,  1977,  June 1
  !
  !     The common block for the MP package is named MPCOM.  If local
  !     variable I1 is zero, DQDOTI calls MPBLAS to initialize the MP
  !     package and reset I1 to 1.
  !
  !    The argument QC(*), and the local variables QX and QY are INTEGER
  !    arrays of size 30.  See the comments in the routine MPBLAS for the
  !    reason for this choice.
  !
  !***REFERENCES  C. L. Lawson, R. J. Hanson, D. R. Kincaid and F. T.
  !                 Krogh, Basic linear algebra subprograms for Fortran
  !                 usage, Algorithm No. 539, Transactions on Mathematical
  !                 Software 5, 3 (September 1979), pp. 308-323.
  !***ROUTINES CALLED  MPADD, MPBLAS, MPCDM, MPCMD, MPMUL
  !***COMMON BLOCKS    MPCOM
  !***REVISION HISTORY  (YYMMDD)
  !   791001  DATE WRITTEN
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   920501  Reformatted the REFERENCES section.  (WRB)
  !   930124  Increased Array sizes for SUN -r8.  (RWC)
  !***END PROLOGUE  DQDOTI
  REAL(8) :: Dx(*), Dy(*), Db
  INTEGER Qc(30), qx(30), qy(30)
  COMMON /MPCOM / MPB, MPT, MPM, MPLun, MPMxr, MPR(30)
  SAVE i1
  DATA i1/0/
  !***FIRST EXECUTABLE STATEMENT  DQDOTI
  IF ( i1==0 ) CALL MPBLAS(i1)
  Qc(1) = 0
  IF ( Db/=0.D0 ) THEN
    CALL MPCDM(Db,qx)
    CALL MPADD(Qc,qx,Qc)
  ENDIF
  IF ( N/=0 ) THEN
    ix = 1
    iy = 1
    IF ( Incx<0 ) ix = (-N+1)*Incx + 1
    IF ( Incy<0 ) iy = (-N+1)*Incy + 1
    DO i = 1, N
      CALL MPCDM(Dx(ix),qx)
      CALL MPCDM(Dy(iy),qy)
      CALL MPMUL(qx,qy,qx)
      CALL MPADD(Qc,qx,Qc)
      ix = ix + Incx
      iy = iy + Incy
    ENDDO
  ENDIF
  CALL MPCMD(Qc,DQDOTI)
END FUNCTION DQDOTI