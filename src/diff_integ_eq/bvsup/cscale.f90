!** CSCALE
PURE SUBROUTINE CSCALE(A,Nrda,Nrow,Ncol,Cols,Colsav,Rows,Rowsav,Anorm,Scales,Iscale,Ic)
  !> Subsidiary to BVSUP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (CSCALE-S, DCSCAL-D)
  !***
  ! **Author:**  Watts, H. A., (SNLA)
  !***
  ! **Description:**
  !
  !     This routine scales the matrix A by columns when needed
  !
  !***
  ! **See also:**  BVSUP
  !***
  ! **Routines called:**  SDOT

  !* REVISION HISTORY  (YYMMDD)
  !   750601  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900328  Added TYPE section.  (WRB)
  !   910722  Updated AUTHOR section.  (ALS)
  !
  INTEGER, INTENT(IN) :: Ic, Iscale, Ncol, Nrda, Nrow
  REAL(SP), INTENT(INOUT) :: A(Nrda,Ncol), Anorm, Cols(Ncol)
  REAL(SP), INTENT(OUT) :: Colsav(Ncol), Rows(Nrow), Rowsav(Nrow), Scales(Ncol)
  !
  INTEGER :: ip, j, k
  REAL(SP) :: alog2, ascale, cs, p, s
  !
  REAL(SP), PARAMETER :: ten4 = 1.E+4_SP, ten20 = 1.E+20_SP
  !
  !* FIRST EXECUTABLE STATEMENT  CSCALE
  IF( Iscale==(-1) ) THEN
    !
    IF( Ic/=0 ) THEN
      DO k = 1, Ncol
        Cols(k) = NORM2(A(1:Nrow,k))**2
      END DO
    END IF
    !
    ascale = Anorm/Ncol
    DO k = 1, Ncol
      cs = Cols(k)
      IF( (cs>ten4*ascale) .OR. (ten4*cs<ascale) ) GOTO 100
      IF( (cs<1._SP/ten20) .OR. (cs>ten20) ) GOTO 100
    END DO
  END IF
  !
  DO k = 1, Ncol
    Scales(k) = 1._SP
  END DO
  RETURN
  !
  100  alog2 = LOG(2._SP)
  Anorm = 0._SP
  DO k = 1, Ncol
    cs = Cols(k)
    IF( cs/=0. ) THEN
      p = LOG(cs)/alog2
      ip = INT( -0.5_SP*p )
      s = 2._SP**ip
      Scales(k) = s
      IF( Ic/=1 ) THEN
        Cols(k) = s*s*Cols(k)
        Anorm = Anorm + Cols(k)
        Colsav(k) = Cols(k)
      END IF
      DO j = 1, Nrow
        A(j,k) = s*A(j,k)
      END DO
    ELSE
      Scales(k) = 1._SP
    END IF
  END DO
  !
  IF( Ic==0 ) RETURN
  !
  DO k = 1, Nrow
    Rows(k) = NORM2(A(k,1:Ncol))**2
    Rowsav(k) = Rows(k)
    Anorm = Anorm + Rows(k)
  END DO
  !
END SUBROUTINE CSCALE