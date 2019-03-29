!** CASIN
COMPLEX FUNCTION CASIN(Zinp)
  IMPLICIT NONE
  !>
  !***
  !  Compute the complex arc sine.
  !***
  ! **Library:**   SLATEC (FNLIB)
  !***
  ! **Category:**  C4A
  !***
  ! **Type:**      COMPLEX (CASIN-C)
  !***
  ! **Keywords:**  ARC SINE, ELEMENTARY FUNCTIONS, FNLIB, TRIGONOMETRIC
  !***
  ! **Author:**  Fullerton, W., (LANL)
  !***
  ! **Description:**
  !
  ! CASIN(ZINP) calculates the complex trigonometric arc sine of ZINP.
  ! The result is in units of radians, and the real part is in the first
  ! or fourth quadrant.
  !
  !***
  ! **References:**  (NONE)
  !***
  ! **Routines called:**  R1MACH

  !* REVISION HISTORY  (YYMMDD)
  !   770701  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890531  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)

  INTEGER i, nterms
  REAL r, R1MACH, rmin, twoi
  COMPLEX Zinp, z, z2, sqzp1
  SAVE nterms, rmin
  REAL, PARAMETER :: pi2 = 1.57079632679489661923E0
  REAL, PARAMETER :: pi = 3.14159265358979324E0
  COMPLEX, PARAMETER :: ci = (0.,1.)
  LOGICAL :: first = .TRUE.
  !* FIRST EXECUTABLE STATEMENT  CASIN
  IF ( first ) THEN
    ! NTERMS = LOG(EPS)/LOG(RMAX)  WHERE RMAX = 0.1
    nterms = INT( -0.4343*LOG(R1MACH(3)) )
    rmin = SQRT(6.0*R1MACH(3))
    first = .FALSE.
  ENDIF
  !
  z = Zinp
  r = ABS(z)
  IF ( r>0.1 ) THEN
    !
    IF ( REAL(Zinp)<0.0 ) z = -Zinp
    !
    sqzp1 = SQRT(z+1.0)
    IF ( AIMAG(sqzp1)<0. ) sqzp1 = -sqzp1
    CASIN = pi2 - ci*LOG(z+sqzp1*SQRT(z-1.0))
    !
    IF ( REAL(CASIN)>pi2 ) CASIN = pi - CASIN
    IF ( REAL(CASIN)<=(-pi2) ) CASIN = -pi - CASIN
    IF ( REAL(Zinp)<0. ) CASIN = -CASIN
    RETURN
  ENDIF
  !
  CASIN = z
  IF ( r<rmin ) RETURN
  !
  CASIN = (0.0,0.0)
  z2 = z*z
  DO i = 1, nterms
    twoi = 2*(nterms-i) + 1
    CASIN = 1.0/twoi + twoi*CASIN*z2/(twoi+1.0)
  ENDDO
  CASIN = z*CASIN
  RETURN
END FUNCTION CASIN
