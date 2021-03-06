!** XSET
SUBROUTINE XSET(Irad,Nradpl,Dzero,Nbits,Ierror)
  !> To provide single-precision floating-point arithmetic
  !            with an extended exponent range.
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  A3D
  !***
  ! **Type:**      SINGLE PRECISION (XSET-S, DXSET-D)
  !***
  ! **Keywords:**  EXTENDED-RANGE SINGLE-PRECISION ARITHMETIC
  !***
  ! **Author:**  Lozier, Daniel W., (National Bureau of Standards)
  !           Smith, John M., (NBS and George Mason University)
  !***
  ! **Description:**
  !
  !   SUBROUTINE  XSET  MUST BE CALLED PRIOR TO CALLING ANY OTHER
  ! EXTENDED-RANGE SUBROUTINE. IT CALCULATES AND STORES SEVERAL
  ! MACHINE-DEPENDENT CONSTANTS IN COMMON BLOCKS. THE USER MUST
  ! SUPPLY FOUR CONSTANTS THAT PERTAIN TO HIS PARTICULAR COMPUTER.
  ! THE CONSTANTS ARE
  !
  !          IRAD = THE INTERNAL BASE OF SINGLE-PRECISION
  !                 ARITHMETIC IN THE COMPUTER.
  !        NRADPL = THE NUMBER OF RADIX PLACES CARRIED IN
  !                 THE SINGLE-PRECISION REPRESENTATION.
  !         DZERO = THE SMALLEST OF 1/DMIN, DMAX, DMAXLN WHERE
  !                 DMIN = THE SMALLEST POSITIVE SINGLE-PRECISION
  !                 NUMBER OR AN UPPER BOUND TO THIS NUMBER,
  !                 DMAX = THE LARGEST SINGLE-PRECISION NUMBER
  !                 OR A LOWER BOUND TO THIS NUMBER,
  !                 DMAXLN = THE LARGEST SINGLE-PRECISION NUMBER
  !                 SUCH THAT LOG10(DMAXLN) CAN BE COMPUTED BY THE
  !                 FORTRAN SYSTEM (ON MOST SYSTEMS DMAXLN = DMAX).
  !         NBITS = THE NUMBER OF BITS (EXCLUSIVE OF SIGN) IN
  !                 AN INTEGER COMPUTER WORD.
  !
  ! ALTERNATIVELY, ANY OR ALL OF THE CONSTANTS CAN BE GIVEN
  ! THE VALUE 0 (0.0 FOR DZERO). IF A CONSTANT IS ZERO, XSET TRIES
  ! TO ASSIGN AN APPROPRIATE VALUE BY CALLING I1MACH
  ! (SEE P.A.FOX, A.D.HALL, N.L.SCHRYER, ALGORITHM 528 FRAMEWORK
  ! FOR A PORTABLE LIBRARY, ACM TRANSACTIONS ON MATH SOFTWARE,
  ! V.4, NO.2, JUNE 1978, 177-188).
  !
  !   THIS IS THE SETTING-UP SUBROUTINE FOR A PACKAGE OF SUBROUTINES
  ! THAT FACILITATE THE USE OF EXTENDED-RANGE ARITHMETIC. EXTENDED-RANGE
  ! ARITHMETIC ON A PARTICULAR COMPUTER IS DEFINED ON THE SET OF NUMBERS
  ! OF THE FORM
  !
  !               (X,IX) = X*RADIX**IX
  !
  ! WHERE X IS A SINGLE-PRECISION NUMBER CALLED THE PRINCIPAL PART,
  ! IX IS AN INTEGER CALLED THE AUXILIARY INDEX, AND RADIX IS THE
  ! INTERNAL BASE OF THE SINGLE-PRECISION ARITHMETIC.  OBVIOUSLY,
  ! EACH REAL NUMBER IS REPRESENTABLE WITHOUT ERROR BY MORE THAN ONE
  ! EXTENDED-RANGE FORM.  CONVERSIONS BETWEEN  DIFFERENT FORMS ARE
  ! ESSENTIAL IN CARRYING OUT ARITHMETIC OPERATIONS.  WITH THE CHOICE
  ! OF RADIX WE HAVE MADE, AND THE SUBROUTINES WE HAVE WRITTEN, THESE
  ! CONVERSIONS ARE PERFORMED WITHOUT ERROR (AT LEAST ON MOST COMPUTERS).
  ! (SEE SMITH, J.M., OLVER, F.W.J., AND LOZIER, D.W., EXTENDED-RANGE
  ! ARITHMETIC AND NORMALIZED LEGENDRE POLYNOMIALS, ACM TRANSACTIONS ON
  ! MATHEMATICAL SOFTWARE, MARCH 1981).
  !
  !   AN EXTENDED-RANGE NUMBER  (X,IX)  IS SAID TO BE IN ADJUSTED FORM IF
  ! X AND IX ARE ZERO OR
  !
  !           RADIX**(-L) <= ABS(X) < RADIX**L
  !
  ! IS SATISFIED, WHERE L IS A COMPUTER-DEPENDENT INTEGER DEFINED IN THIS
  ! SUBROUTINE. TWO EXTENDED-RANGE NUMBERS IN ADJUSTED FORM CAN BE ADDED,
  ! SUBTRACTED, MULTIPLIED OR DIVIDED (IF THE DIVISOR IS NONZERO) WITHOUT
  ! CAUSING OVERFLOW OR UNDERFLOW IN THE PRINCIPAL PART OF THE RESULT.
  ! WITH PROPER USE OF THE EXTENDED-RANGE SUBROUTINES, THE ONLY OVERFLOW
  ! THAT CAN OCCUR IS INTEGER OVERFLOW IN THE AUXILIARY INDEX. IF THIS
  ! IS DETECTED, THE SOFTWARE CALLS XERROR (A GENERAL ERROR-HANDLING
  ! FORTRAN SUBROUTINE PACKAGE).
  !
  !   MULTIPLICATION AND DIVISION IS PERFORMED BY SETTING
  !
  !                 (X,IX)*(Y,IY) = (X*Y,IX+IY)
  ! OR
  !                 (X,IX)/(Y,IY) = (X/Y,IX-IY).
  !
  ! PRE-ADJUSTMENT OF THE OPERANDS IS ESSENTIAL TO AVOID
  ! OVERFLOW OR  UNDERFLOW OF THE PRINCIPAL PART. SUBROUTINE
  ! XADJ (SEE BELOW) MAY BE CALLED TO TRANSFORM ANY EXTENDED-
  ! RANGE NUMBER INTO ADJUSTED FORM.
  !
  !   ADDITION AND SUBTRACTION REQUIRE THE USE OF SUBROUTINE XADD
  ! (SEE BELOW).  THE INPUT OPERANDS NEED NOT BE IN ADJUSTED FORM.
  ! HOWEVER, THE RESULT OF ADDITION OR SUBTRACTION IS RETURNED
  ! IN ADJUSTED FORM.  THUS, FOR EXAMPLE, IF(X,IX),(Y,IY),
  ! (U,IU),  AND (V,IV) ARE IN ADJUSTED FORM, THEN
  !
  !                 (X,IX)*(Y,IY) + (U,IU)*(V,IV)
  !
  ! CAN BE COMPUTED AND STORED IN ADJUSTED FORM WITH NO EXPLICIT
  ! CALLS TO XADJ.
  !
  !   WHEN AN EXTENDED-RANGE NUMBER IS TO BE PRINTED, IT MUST BE
  ! CONVERTED TO AN EXTENDED-RANGE FORM WITH DECIMAL RADIX.  SUBROUTINE
  ! XCON IS PROVIDED FOR THIS PURPOSE.
  !
  !   THE SUBROUTINES CONTAINED IN THIS PACKAGE ARE
  !
  !     SUBROUTINE XADD
  ! USAGE
  !                  CALL XADD(X,IX,Y,IY,Z,IZ,IERROR)
  !                  IF(IERROR/=0) RETURN
  ! **Description:**
  !                  FORMS THE EXTENDED-RANGE SUM  (Z,IZ) =
  !                  (X,IX) + (Y,IY).  (Z,IZ) IS ADJUSTED
  !                  BEFORE RETURNING. THE INPUT OPERANDS
  !                  NEED NOT BE IN ADJUSTED FORM, BUT THEIR
  !                  PRINCIPAL PARTS MUST SATISFY
  !                  RADIX**(-2L)<=ABS(X)<=RADIX**(2L),
  !                  RADIX**(-2L)<=ABS(Y)<=RADIX**(2L).
  !
  !     SUBROUTINE XADJ
  ! USAGE
  !                  CALL XADJ(X,IX,IERROR)
  !                  IF(IERROR/=0) RETURN
  ! **Description:**
  !                  TRANSFORMS (X,IX) SO THAT
  !                  RADIX**(-L) <= ABS(X) < RADIX**L.
  !                  ON MOST COMPUTERS THIS TRANSFORMATION DOES
  !                  NOT CHANGE THE MANTISSA OF X PROVIDED RADIX IS
  !                  THE NUMBER BASE OF SINGLE-PRECISION ARITHMETIC.
  !
  !     SUBROUTINE XC210
  ! USAGE
  !                  CALL XC210(K,Z,J,IERROR)
  !                  IF(IERROR/=0) RETURN
  ! **Description:**
  !                  GIVEN K THIS SUBROUTINE COMPUTES J AND Z
  !                  SUCH THAT  RADIX**K = Z*10**J, WHERE Z IS IN
  !                  THE RANGE 1/10 <= Z < 1.
  !                  THE VALUE OF Z WILL BE ACCURATE TO FULL
  !                  SINGLE-PRECISION PROVIDED THE NUMBER
  !                  OF DECIMAL PLACES IN THE LARGEST
  !                  INTEGER PLUS THE NUMBER OF DECIMAL
  !                  PLACES CARRIED IN SINGLE-PRECISION DOES NOT
  !                  EXCEED 60. XC210 IS CALLED BY SUBROUTINE
  !                  XCON WHEN NECESSARY. THE USER SHOULD
  !                  NEVER NEED TO CALL XC210 DIRECTLY.
  !
  !     SUBROUTINE XCON
  ! USAGE
  !                  CALL XCON(X,IX,IERROR)
  !                  IF(IERROR/=0) RETURN
  ! **Description:**
  !                  CONVERTS (X,IX) = X*RADIX**IX
  !                  TO DECIMAL FORM IN PREPARATION FOR
  !                  PRINTING, SO THAT (X,IX) = X*10**IX
  !                  WHERE 1/10 <= ABS(X) < 1
  !                  IS RETURNED, EXCEPT THAT IF
  !                  (ABS(X),IX) IS BETWEEN RADIX**(-2L)
  !                  AND RADIX**(2L) THEN THE REDUCED
  !                  FORM WITH IX = 0 IS RETURNED.
  !
  !     SUBROUTINE XRED
  ! USAGE
  !                  CALL XRED(X,IX,IERROR)
  !                  IF(IERROR/=0) RETURN
  ! **Description:**
  !                  IF
  !                  RADIX**(-2L) <= (ABS(X),IX) <= RADIX**(2L)
  !                  THEN XRED TRANSFORMS (X,IX) SO THAT IX=0.
  !                  IF(X,IX) IS OUTSIDE THE ABOVE RANGE,
  !                  THEN XRED TAKES NO ACTION.
  !                  THIS SUBROUTINE IS USEFUL IF THE
  !                  RESULTS OF EXTENDED-RANGE CALCULATIONS
  !                  ARE TO BE USED IN SUBSEQUENT ORDINARY
  !                  SINGLE-PRECISION CALCULATIONS.
  !
  !***
  ! **References:**  Smith, Olver and Lozier, Extended-Range Arithmetic and
  !                 Normalized Legendre Polynomials, ACM Trans on Math
  !                 Softw, v 7, n 1, March 1981, pp 93--105.
  !***
  ! **Routines called:**  I1MACH, XERMSG
  !***
  ! COMMON BLOCKS    XBLK1, XBLK2, XBLK3

  !* REVISION HISTORY  (YYMMDD)
  !   820712  DATE WRITTEN
  !   881020  Revised to meet SLATEC CML recommendations.  (DWL and JMS)
  !   901019  Revisions to prologue.  (DWL and WRB)
  !   901106  Changed all specific intrinsics to generic.  (WRB)
  !           Corrected order of sections in prologue and added TYPE
  !           section.  (WRB)
  !           CALLs to XERROR changed to CALLs to XERMSG.  (WRB)
  !   920127  Revised PURPOSE section of prologue.  (DWL)
  USE XBLK, ONLY : l_com, dlg10r_com, kmax_com, l2_com, mlg102_com, nbitsf_com, &
    nlg102_com, rad2l_com, radixl_com, lg102_com, radixx_com
  USE service, ONLY : digits_int, digits_sp, max_exp_sp, min_exp_sp, radix_fp
  INTEGER :: Ierror, Irad, Nradpl, Nbits
  REAL(SP) :: Dzero
  INTEGER :: i, ic, ii, imaxex, iminex, iradx, it, j, k, kk, lg102x, log2r, lx, &
    nb, nbitsx, np1, nrdplc, lgtemp(20)
  REAL(SP) :: dzerox
  !
  !   LOG102 CONTAINS THE FIRST 60 DIGITS OF LOG10(2) FOR USE IN
  ! CONVERSION OF EXTENDED-RANGE NUMBERS TO BASE 10 .
  INTEGER, PARAMETER :: log102(20) = [ 301, 029, 995, 663, 981, 195, 213, 738, &
    894, 724, 493, 026, 768, 189, 881, 462, 108, 541, 310, 428 ]
  !
  ! FOLLOWING CODING PREVENTS XSET FROM BEING EXECUTED MORE THAN ONCE.
  ! THIS IS IMPORTANT BECAUSE SOME SUBROUTINES (SUCH AS XNRMP AND
  ! XLEGF) CALL XSET TO MAKE SURE EXTENDED-RANGE ARITHMETIC HAS
  ! BEEN INITIALIZED. THE USER MAY WANT TO PRE-EMPT THIS CALL, FOR
  ! EXAMPLE WHEN I1MACH IS NOT AVAILABLE. SEE CODING BELOW.
  INTEGER, SAVE :: iflag = 0
  !* FIRST EXECUTABLE STATEMENT  XSET
  Ierror = 0
  IF( iflag/=0 ) RETURN
  iradx = Irad
  nrdplc = Nradpl
  dzerox = Dzero
  iminex = 0
  imaxex = 0
  nbitsx = Nbits
  ! FOLLOWING 5 STATEMENTS SHOULD BE DELETED IF I1MACH IS
  ! NOT AVAILABLE OR NOT CONFIGURED TO RETURN THE CORRECT
  ! MACHINE-DEPENDENT VALUES.
  IF( iradx==0 ) iradx = radix_fp
  IF( nrdplc==0 ) nrdplc = digits_sp
  IF( dzerox==0._SP ) iminex = min_exp_sp
  IF( dzerox==0._SP ) imaxex = max_exp_sp
  IF( nbitsx==0 ) nbitsx = digits_int
  IF( iradx/=2 ) THEN
    IF( iradx/=4 ) THEN
      IF( iradx/=8 ) THEN
        IF( iradx/=16 ) THEN
          ERROR STOP 'XSET : IMPROPER VALUE OF IRAD'
          Ierror = 101
          RETURN
        END IF
      END IF
    END IF
  END IF
  log2r = 0
  IF( iradx==2 ) log2r = 1
  IF( iradx==4 ) log2r = 2
  IF( iradx==8 ) log2r = 3
  IF( iradx==16 ) log2r = 4
  nbitsf_com = log2r*nrdplc
  radixx_com = iradx
  dlg10r_com = LOG10(radixx_com)
  IF( dzerox/=0._SP ) THEN
    lx = INT( 0.5_SP*LOG10(dzerox)/dlg10r_com )
    ! RADIX**(2*L) SHOULD NOT OVERFLOW, BUT REDUCE L BY 1 FOR FURTHER
    ! PROTECTION.
    lx = lx - 1
  ELSE
    lx = MIN((1-iminex)/2,(imaxex-1)/2)
  END IF
  l2_com = 2*lx
  IF( lx>=4 ) THEN
    l_com = lx
    radixl_com = radixx_com**l_com
    rad2l_com = radixl_com**2
    !    IT IS NECESSARY TO RESTRICT NBITS (OR NBITSX) TO BE LESS THAN SOME
    ! UPPER LIMIT BECAUSE OF BINARY-TO-DECIMAL CONVERSION. SUCH CONVERSION
    ! IS DONE BY XC210 AND REQUIRES A CONSTANT THAT IS STORED TO SOME FIXED
    ! PRECISION. THE STORED CONSTANT (LOG102 IN THIS ROUTINE) PROVIDES
    ! FOR CONVERSIONS ACCURATE TO THE LAST DECIMAL DIGIT WHEN THE INTEGER
    ! WORD LENGTH DOES NOT EXCEED 63. A LOWER LIMIT OF 15 BITS IS IMPOSED
    ! BECAUSE THE SOFTWARE IS DESIGNED TO RUN ON COMPUTERS WITH INTEGER WORD
    ! LENGTH OF AT LEAST 16 BITS.
    IF( 15<=nbitsx .AND. nbitsx<=63 ) THEN
      kmax_com = 2**(nbitsx-1) - l2_com
      nb = (nbitsx-1)/2
      mlg102_com = 2**nb
      IF( 1<=nrdplc*log2r .AND. nrdplc*log2r<=120 ) THEN
        nlg102_com = nrdplc*log2r/nb + 3
        np1 = nlg102_com + 1
        !
        !   AFTER COMPLETION OF THE FOLLOWING LOOP, IC CONTAINS
        ! THE INTEGER PART AND LGTEMP CONTAINS THE FRACTIONAL PART
        ! OF LOG10(IRADX) IN RADIX 1000.
        ic = 0
        DO ii = 1, 20
          i = 21 - ii
          it = log2r*log102(i) + ic
          ic = it/1000
          lgtemp(i) = MOD(it,1000)
        END DO
        !
        !   AFTER COMPLETION OF THE FOLLOWING LOOP, LG102 CONTAINS
        ! LOG10(IRADX) IN RADIX MLG102. THE RADIX POINT IS
        ! BETWEEN LG102(1) AND LG102(2).
        lg102_com(1) = ic
        DO i = 2, np1
          lg102x = 0
          DO j = 1, nb
            ic = 0
            DO kk = 1, 20
              k = 21 - kk
              it = 2*lgtemp(k) + ic
              ic = it/1000
              lgtemp(k) = MOD(it,1000)
            END DO
            lg102x = 2*lg102x + ic
          END DO
          lg102_com(i) = lg102x
        END DO
        !
        ! CHECK SPECIAL CONDITIONS REQUIRED BY SUBROUTINES...
        IF( nrdplc>=l_com ) THEN
          ERROR STOP 'XSET : NRADPL >= l_com'
          Ierror = 105
          RETURN
        ELSEIF( 6*l_com<=kmax_com ) THEN
          iflag = 1
          RETURN
        END IF
      ELSE
        ERROR STOP 'XSET : IMPROPER VALUE OF NRADPL'
        Ierror = 104
        RETURN
      END IF
    ELSE
      ERROR STOP 'XSET : IMPROPER VALUE OF NBITS'
      Ierror = 103
      RETURN
    END IF
  ELSE
    ERROR STOP 'XSET : IMPROPER VALUE OF DZERO'
    Ierror = 102
    RETURN
  END IF
  ERROR STOP 'XSET : 6*l_com > KMAX'
  Ierror = 106
  RETURN
END SUBROUTINE XSET
