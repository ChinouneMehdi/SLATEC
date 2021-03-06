!** DPCHIM
PURE SUBROUTINE DPCHIM(N,X,F,D,Incfd,Ierr)
  !> Set derivatives needed to determine a monotone piecewise
  !  cubic Hermite interpolant to given data.
  !  Boundary values are provided which are compatible with monotonicity.
  !  The interpolant will have an extremum at each point where monotonicity switches
  !  direction.  (See DPCHIC if user control is desired over boundary or switch conditions.)
  !***
  ! **Library:**   SLATEC (PCHIP)
  !***
  ! **Category:**  E1A
  !***
  ! **Type:**      DOUBLE PRECISION (PCHIM-S, DPCHIM-D)
  !***
  ! **Keywords:**  CUBIC HERMITE INTERPOLATION, MONOTONE INTERPOLATION,
  !             PCHIP, PIECEWISE CUBIC INTERPOLATION
  !***
  ! **Author:**  Fritsch, F. N., (LLNL)
  !             Lawrence Livermore National Laboratory
  !             P.O. Box 808  (L-316)
  !             Livermore, CA  94550
  !             FTS 532-4275, (510) 422-4275
  !***
  ! **Description:**
  !
  !          DPCHIM:  Piecewise Cubic Hermite Interpolation to Monotone data.
  !
  !     Sets derivatives needed to determine a monotone piecewise cubic
  !     Hermite interpolant to the data given in X and F.
  !
  !     Default boundary conditions are provided which are compatible
  !     with monotonicity.  (See DPCHIC if user control of boundary con-
  !     ditions is desired.)
  !
  !     If the data are only piecewise monotonic, the interpolant will
  !     have an extremum at each point where monotonicity switches direc-
  !     tion.  (See DPCHIC if user control is desired in such cases.)
  !
  !     To facilitate two-dimensional applications, includes an increment
  !     between successive values of the F- and D-arrays.
  !
  !     The resulting piecewise cubic Hermite function may be evaluated
  !     by DPCHFE or DPCHFD.
  !
  ! ----------------------------------------------------------------------
  !
  !  Calling sequence:
  !
  !        PARAMETER  (INCFD = ...)
  !        INTEGER  N, IERR
  !        DOUBLE PRECISION  X(N), F(INCFD,N), D(INCFD,N)
  !
  !        CALL  DPCHIM (N, X, F, D, INCFD, IERR)
  !
  !   Parameters:
  !
  !     N -- (input) number of data points.  (Error return if N<2 .)
  !           If N=2, simply does linear interpolation.
  !
  !     X -- (input) real*8 array of independent variable values.  The
  !           elements of X must be strictly increasing:
  !                X(I-1) < X(I),  I = 2(1)N.
  !           (Error return if not.)
  !
  !     F -- (input) real*8 array of dependent variable values to be
  !           interpolated.  F(1+(I-1)*INCFD) is value corresponding to
  !           X(I).  DPCHIM is designed for monotonic data, but it will
  !           work for any F-array.  It will force extrema at points where
  !           monotonicity switches direction.  If some other treatment of
  !           switch points is desired, DPCHIC should be used instead.
  !                                     -----
  !     D -- (output) real*8 array of derivative values at the data
  !           points.  If the data are monotonic, these values will
  !           determine a monotone cubic Hermite function.
  !           The value corresponding to X(I) is stored in
  !                D(1+(I-1)*INCFD),  I=1(1)N.
  !           No other entries in D are changed.
  !
  !     INCFD -- (input) increment between successive values in F and D.
  !           This argument is provided primarily for 2-D applications.
  !           (Error return if  INCFD<1 .)
  !
  !     IERR -- (output) error flag.
  !           Normal return:
  !              IERR = 0  (no errors).
  !           Warning error:
  !              IERR>0  means that IERR switches in the direction
  !                 of monotonicity were detected.
  !           "Recoverable" errors:
  !              IERR = -1  if N<2 .
  !              IERR = -2  if INCFD<1 .
  !              IERR = -3  if the X-array is not strictly increasing.
  !             (The D-array has not been changed in any of these cases.)
  !               NOTE:  The above errors are checked in the order listed,
  !                   and following arguments have **NOT** been validated.
  !
  !***
  ! **References:**  1. F. N. Fritsch and J. Butland, A method for construc-
  !                 ting local monotone piecewise cubic interpolants, SIAM
  !                 Journal on Scientific and Statistical Computing 5, 2
  !                 (June 1984), pp. 300-304.
  !               2. F. N. Fritsch and R. E. Carlson, Monotone piecewise
  !                 cubic interpolation, SIAM Journal on Numerical Ana-
  !                 lysis 17, 2 (April 1980), pp. 238-246.
  !***
  ! **Routines called:**  DPCHST, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   811103  DATE WRITTEN
  !   820201  1. Introduced  DPCHST  to reduce possible over/under-
  !             flow problems.
  !           2. Rearranged derivative formula for same reason.
  !   820602  1. Modified end conditions to be continuous functions
  !             of data when monotonicity switches in next interval.
  !           2. Modified formulas so end conditions are less prone
  !             of over/underflow problems.
  !   820803  Minor cosmetic changes for release 1.
  !   870707  Corrected XERROR calls for d.p. name(s).
  !   870813  Updated Reference 1.
  !   890206  Corrected XERROR calls.
  !   890411  Added SAVE statements (Vers. 3.2).
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890703  Corrected category record.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891006  Cosmetic changes to prologue.  (WRB)
  !   891006  REVISION DATE from Version 3.2
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   920429  Revised format and order of references.  (WRB,FNF)

  !  Programming notes:
  !
  !     1. The function  DPCHST(ARG1,ARG2)  is assumed to return zero if
  !        either argument is zero, +1 if they are of the same sign, and
  !        -1 if they are of opposite sign.
  !     2. To produce a single precision version, simply:
  !        a. Change DPCHIM to PCHIM wherever it occurs,
  !        b. Change DPCHST to PCHST wherever it occurs,
  !        c. Change all references to the Fortran intrinsics to their
  !           single precision equivalents,
  !        d. Change the double precision declarations to REAL(SP), and
  !        e. Change the constants ZERO and THREE to single precision.
  !
  !  DECLARE ARGUMENTS.
  !
  INTEGER, INTENT(IN) :: N, Incfd
  INTEGER, INTENT(OUT) :: Ierr
  REAL(DP), INTENT(IN) :: X(N), F(Incfd,N)
  REAL(DP), INTENT(OUT) :: D(Incfd,N)
  !
  !  DECLARE LOCAL VARIABLES.
  !
  INTEGER :: i, nless1
  REAL(DP) :: del1, del2, dmax, dmin, drat1, drat2, dsave, h1, &
    h2, hsum, hsumt3, w1, w2
  !
  !  VALIDITY-CHECK ARGUMENTS.
  !
  !* FIRST EXECUTABLE STATEMENT  DPCHIM
  IF( N<2 ) THEN
    !
    !  ERROR RETURNS.
    !
    !     N<2 RETURN.
    Ierr = -1
    ERROR STOP 'DPCHIM : NUMBER OF DATA POINTS LESS THAN TWO'
  ELSE
    IF( Incfd<1 ) THEN
      !
      !     INCFD<1 RETURN.
      Ierr = -2
      ERROR STOP 'DPCHIM : INCREMENT LESS THAN ONE'
    ELSE
      DO i = 2, N
        IF( X(i)<=X(i-1) ) GOTO 50
      END DO
      !
      !  FUNCTION DEFINITION IS OK, GO ON.
      !
      Ierr = 0
      nless1 = N - 1
      h1 = X(2) - X(1)
      del1 = (F(1,2)-F(1,1))/h1
      dsave = del1
      !
      !  SPECIAL CASE N=2 -- USE LINEAR INTERPOLATION.
      !
      IF( nless1>1 ) THEN
        !
        !  NORMAL CASE  (N >= 3).
        !
        h2 = X(3) - X(2)
        del2 = (F(1,3)-F(1,2))/h2
        !
        !  SET D(1) VIA NON-CENTERED THREE-POINT FORMULA, ADJUSTED TO BE
        !     SHAPE-PRESERVING.
        !
        hsum = h1 + h2
        w1 = (h1+hsum)/hsum
        w2 = -h1/hsum
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
            h1 = h2
            h2 = X(i+1) - X(i)
            hsum = h1 + h2
            del1 = del2
            del2 = (F(1,i+1)-F(1,i))/h2
          END IF
          !
          !        SET D(I)=0 UNLESS DATA ARE STRICTLY MONOTONIC.
          !
          D(1,i) = 0._DP
          IF( DPCHST(del1,del2)<0 ) THEN
            !
            Ierr = Ierr + 1
            dsave = del2
          ELSEIF( DPCHST(del1,del2)==0 ) THEN
            !
            !        COUNT NUMBER OF CHANGES IN DIRECTION OF MONOTONICITY.
            !
            IF( del2/=0._DP ) THEN
              IF( DPCHST(dsave,del2)<0._DP ) Ierr = Ierr + 1
              dsave = del2
            END IF
          ELSE
            !
            !        USE BRODLIE MODIFICATION OF BUTLAND FORMULA.
            !
            hsumt3 = hsum + hsum + hsum
            w1 = (hsum+h1)/hsumt3
            w2 = (hsum+h2)/hsumt3
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
        w1 = -h2/hsum
        w2 = (h2+hsum)/hsum
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
      RETURN
    END IF
    !
    !     X-ARRAY NOT STRICTLY INCREASING.
    50  Ierr = -3
    ERROR STOP 'DPCHIM : X-ARRAY NOT STRICTLY INCREASING'
  END IF
  !------------- LAST LINE OF DPCHIM FOLLOWS -----------------------------
END SUBROUTINE DPCHIM