!** ZBINU
SUBROUTINE ZBINU(Zr,Zi,Fnu,Kode,N,Cyr,Cyi,Nz,Rl,Fnul,Tol,Elim,Alim)
  IMPLICIT NONE
  !>
  !***
  !  Subsidiary to ZAIRY, ZBESH, ZBESI, ZBESJ, ZBESK and ZBIRY
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      ALL (CBINU-A, ZBINU-A)
  !***
  ! **Author:**  Amos, D. E., (SNL)
  !***
  ! **Description:**
  !
  !     ZBINU COMPUTES THE I FUNCTION IN THE RIGHT HALF Z PLANE
  !
  !***
  ! **See also:**  ZAIRY, ZBESH, ZBESI, ZBESJ, ZBESK, ZBIRY
  !***
  ! **Routines called:**  ZABS, ZASYI, ZBUNI, ZMLRI, ZSERI, ZUOIK, ZWRSK

  !* REVISION HISTORY  (YYMMDD)
  !   830501  DATE WRITTEN
  !   910415  Prologue converted to Version 4.0 format.  (BAB)

  INTEGER i, inw, Kode, N, nlast, nn, nui, nw, Nz
  REAL(8) :: Alim, az, cwi(2), cwr(2), Cyi(N), Cyr(N), dfnu, Elim, Fnu, &
    Fnul, Rl, Tol, Zi, Zr
  REAL(8), EXTERNAL :: ZABS
  REAL(8), PARAMETER :: zeror = 0.0D0, zeroi = 0.0D0
  !* FIRST EXECUTABLE STATEMENT  ZBINU
  Nz = 0
  az = ZABS(Zr,Zi)
  nn = N
  dfnu = Fnu + (N-1)
  IF ( az>2.0D0 ) THEN
    IF ( az*az*0.25D0>dfnu+1.0D0 ) GOTO 100
  ENDIF
  !-----------------------------------------------------------------------
  !     POWER SERIES
  !-----------------------------------------------------------------------
  CALL ZSERI(Zr,Zi,Fnu,Kode,nn,Cyr,Cyi,nw,Tol,Elim,Alim)
  inw = ABS(nw)
  Nz = Nz + inw
  nn = nn - inw
  IF ( nn==0 ) RETURN
  IF ( nw>=0 ) GOTO 600
  dfnu = Fnu + (nn-1)
  100 CONTINUE
  IF ( az>=Rl ) THEN
    IF ( dfnu>1.0D0 ) THEN
      IF ( az+az<dfnu*dfnu ) GOTO 200
    ENDIF
    !-----------------------------------------------------------------------
    !     ASYMPTOTIC EXPANSION FOR LARGE Z
    !-----------------------------------------------------------------------
    CALL ZASYI(Zr,Zi,Fnu,Kode,nn,Cyr,Cyi,nw,Rl,Tol,Elim,Alim)
    IF ( nw>=0 ) GOTO 600
    GOTO 700
  ELSEIF ( dfnu<=1.0D0 ) THEN
    GOTO 400
  ENDIF
  !-----------------------------------------------------------------------
  !     OVERFLOW AND UNDERFLOW TEST ON I SEQUENCE FOR MILLER ALGORITHM
  !-----------------------------------------------------------------------
  200  CALL ZUOIK(Zr,Zi,Fnu,Kode,1,nn,Cyr,Cyi,nw,Tol,Elim,Alim)
  IF ( nw<0 ) GOTO 700
  Nz = Nz + nw
  nn = nn - nw
  IF ( nn==0 ) RETURN
  dfnu = Fnu + (nn-1)
  IF ( dfnu>Fnul ) GOTO 500
  IF ( az>Fnul ) GOTO 500
  300 CONTINUE
  IF ( az>Rl ) THEN
    !-----------------------------------------------------------------------
    !     MILLER ALGORITHM NORMALIZED BY THE WRONSKIAN
    !-----------------------------------------------------------------------
    !-----------------------------------------------------------------------
    !     OVERFLOW TEST ON K FUNCTIONS USED IN WRONSKIAN
    !-----------------------------------------------------------------------
    CALL ZUOIK(Zr,Zi,Fnu,Kode,2,2,cwr,cwi,nw,Tol,Elim,Alim)
    IF ( nw>=0 ) THEN
      IF ( nw>0 ) GOTO 700
      CALL ZWRSK(Zr,Zi,Fnu,Kode,nn,Cyr,Cyi,nw,cwr,cwi,Tol,Elim,Alim)
      IF ( nw>=0 ) GOTO 600
      GOTO 700
    ELSE
      Nz = nn
      DO i = 1, nn
        Cyr(i) = zeror
        Cyi(i) = zeroi
      ENDDO
      RETURN
    ENDIF
  ENDIF
  !-----------------------------------------------------------------------
  !     MILLER ALGORITHM NORMALIZED BY THE SERIES
  !-----------------------------------------------------------------------
  400  CALL ZMLRI(Zr,Zi,Fnu,Kode,nn,Cyr,Cyi,nw,Tol)
  IF ( nw>=0 ) GOTO 600
  GOTO 700
  !-----------------------------------------------------------------------
  !     INCREMENT FNU+NN-1 UP TO FNUL, COMPUTE AND RECUR BACKWARD
  !-----------------------------------------------------------------------
  500  nui = INT( Fnul - dfnu ) + 1
  nui = MAX(nui,0)
  CALL ZBUNI(Zr,Zi,Fnu,Kode,nn,Cyr,Cyi,nw,nui,nlast,Fnul,Tol,Elim,Alim)
  IF ( nw<0 ) GOTO 700
  Nz = Nz + nw
  IF ( nlast/=0 ) THEN
    nn = nlast
    GOTO 300
  ENDIF
  600  RETURN
  700  Nz = -1
  IF ( nw==(-2) ) Nz = -2
END SUBROUTINE ZBINU
