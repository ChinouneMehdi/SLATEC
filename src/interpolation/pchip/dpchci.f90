!** DPCHCI
PURE SUBROUTINE DPCHCI(N,H,Slope,D,Incfd)
  !> Set interior derivatives for DPCHIC
  !***
  ! **Library:**   SLATEC (PCHIP)
  !***
  ! **Type:**      DOUBLE PRECISION (PCHCI-S, DPCHCI-D)
  !***
  ! **Author:**  Fritsch, F. N., (LLNL)
  !***
  ! **Description:**
  !
  !          DPCHCI:  DPCHIC Initial Derivative Setter.
  !
  !    Called by DPCHIC to set derivatives needed to determine a monotone
  !    piecewise cubic Hermite interpolant to the data.
  !
  !    Default boundary conditions are provided which are compatible
  !    with monotonicity.  If the data are only piecewise monotonic, the
  !    interpolant will have an extremum at each point where monotonicity
  !    switches direction.
  !
  !    To facilitate two-dimensional applications, includes an increment
  !    between successive values of the D-array.
  !
  !    The resulting piecewise cubic Hermite function should be identical
  !    (within roundoff error) to that produced by DPCHIM.
  !
  ! ----------------------------------------------------------------------
  !
  !  Calling sequence:
  !
  !        PARAMETER  (INCFD = ...)
  !        INTEGER  N
  !        DOUBLE PRECISION  H(N), SLOPE(N), D(INCFD,N)
  !
  !        CALL  DPCHCI (N, H, SLOPE, D, INCFD)
  !
  !   Parameters:
  !
  !     N -- (input) number of data points.
  !           If N=2, simply does linear interpolation.
  !
  !     H -- (input) real*8 array of interval lengths.
  !     SLOPE -- (input) real*8 array of data slopes.
  !           If the data are (X(I),Y(I)), I=1(1)N, then these inputs are:
  !                  H(I) =  X(I+1)-X(I),
  !              SLOPE(I) = (Y(I+1)-Y(I))/H(I),  I=1(1)N-1.
  !
  !     D -- (output) real*8 array of derivative values at data points.
  !           If the data are monotonic, these values will determine a
  !           a monotone cubic Hermite function.
  !           The value corresponding to X(I) is stored in
  !                D(1+(I-1)*INCFD),  I=1(1)N.
  !           No other entries in D are changed.
  !
  !     INCFD -- (input) increment between successive values in D.
  !           This argument is provided primarily for 2-D applications.
  !
  !    -------
  !    WARNING:  This routine does no validity-checking of arguments.
  !    -------
  !
  !  Fortran intrinsics used:  ABS, MAX, MIN.
  !
  !***
  ! **See also:**  DPCHIC
  !***
  ! **Routines called:**  DPCHST

  !* REVISION HISTORY  (YYMMDD)
  !   820218  DATE WRITTEN
  !   820601  Modified end conditions to be continuous functions of
  !           data when monotonicity switches in next interval.
  !   820602  1. Modified formulas so end conditions are less prone
  !             to over/underflow problems.
  !           2. Minor modification to HSUM calculation.
  !   820805  Converted to SLATEC library version.
  !   870813  Minor cosmetic changes.
  !   890411  Added SAVE statements (Vers. 3.2).
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   890831  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910408  Updated AUTHOR section in prologue.  (WRB)
  !   930503  Improved purpose.  (FNF)

  !
  !  Programming notes:
  !     1. The function  DPCHST(ARG1,ARG2)  is assumed to return zero if
  !        either argument is zero, +1 if they are of the same sign, and
  !        -1 if they are of opposite sign.
  !**End
  !
  !  DECLARE ARGUMENTS.
  !
  INTEGER, INTENT(IN) :: N, Incfd
  REAL(DP), INTENT(IN) :: H(N), Slope(N)
  REAL(DP), INTENT(OUT) :: D(Incfd,N)
  !
  !  DECLARE LOCAL VARIABLES.
  !
  INTEGER :: i, nless1
  REAL(DP) :: del1, del2, dmax, dmin, drat1, drat2, hsum, hsumt3, w1, w2
  !* FIRST EXECUTABLE STATEMENT  DPCHCI
  nless1 = N - 1
  del1 = Slope(1)
  !
  !  SPECIAL CASE N=2 -- USE LINEAR INTERPOLATION.
  !
  IF( nless1>1 ) THEN
    !
    !  NORMAL CASE  (N >= 3).
    !
    del2 = Slope(2)
    !
    !  SET D(1) VIA NON-CENTERED THREE-POINT FORMULA, ADJUSTED TO BE
    !     SHAPE-PRESERVING.
    !
    hsum = H(1) + H(2)
    w1 = (H(1)+hsum)/hsum
    w2 = -H(1)/hsum
    D(1,1) = w1*del1 + w2*del2
    IF( DPCHST(D(1,1),del1)<=0._DP ) THEN
      D(1,1) = 0._DP
    ELSEIF( DPCHST(del1,del2)<0._DP ) THEN
      !        NEED DO THIS CHECK ONLY IF MONOTONICITY SWITCHES.
      dmax = 3._DP*del1
      IF( ABS(D(1,1))>ABS(dmax) ) D(1,1) = dmax
    END IF
    !
    !  LOOP THROUGH INTERIOR POINTS.
    !
    DO i = 2, nless1
      IF( i/=2 ) THEN
        !
        hsum = H(i-1) + H(i)
        del1 = del2
        del2 = Slope(i)
      END IF
      !
      !        SET D(I)=0 UNLESS DATA ARE STRICTLY MONOTONIC.
      !
      D(1,i) = 0._DP
      IF( DPCHST(del1,del2)>0._DP ) THEN
        !
        !        USE BRODLIE MODIFICATION OF BUTLAND FORMULA.
        !
        hsumt3 = hsum + hsum + hsum
        w1 = (hsum+H(i-1))/hsumt3
        w2 = (hsum+H(i))/hsumt3
        dmax = MAX(ABS(del1),ABS(del2))
        dmin = MIN(ABS(del1),ABS(del2))
        drat1 = del1/dmax
        drat2 = del2/dmax
        D(1,i) = dmin/(w1*drat1+w2*drat2)
      END IF
      !
    END DO
    !
    !  SET D(N) VIA NON-CENTERED THREE-POINT FORMULA, ADJUSTED TO BE
    !     SHAPE-PRESERVING.
    !
    w1 = -H(N-1)/hsum
    w2 = (H(N-1)+hsum)/hsum
    D(1,N) = w1*del1 + w2*del2
    IF( DPCHST(D(1,N),del2)<=0._DP ) THEN
      D(1,N) = 0._DP
    ELSEIF( DPCHST(del1,del2)<0._DP ) THEN
      !        NEED DO THIS CHECK ONLY IF MONOTONICITY SWITCHES.
      dmax = 3._DP*del2
      IF( ABS(D(1,N))>ABS(dmax) ) D(1,N) = dmax
    END IF
  ELSE
    D(1,1) = del1
    D(1,N) = del1
  END IF
  !
  !  NORMAL RETURN.
  !
  !------------- LAST LINE OF DPCHCI FOLLOWS -----------------------------
END SUBROUTINE DPCHCI