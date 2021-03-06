!** EFCMN
SUBROUTINE EFCMN(Ndata,Xdata,Ydata,Sddata,Nord,Nbkpt,Bkptin,Mdein,Mdeout,&
    Coeff,Bf,Xtemp,Ptemp,Bkpt,G,Mdg,W,Mdw,Lw)
  !> Subsidiary to EFC
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (EFCMN-S, DEFCMN-D)
  !***
  ! **Author:**  Hanson, R. J., (SNLA)
  !***
  ! **Description:**
  !
  !     This is a companion subprogram to EFC( ).
  !     This subprogram does weighted least squares fitting of data by
  !     B-spline curves.
  !     The documentation for EFC( ) has complete usage instructions.
  !
  !***
  ! **See also:**  EFC
  !***
  ! **Routines called:**  BNDACC, BNDSOL, BSPLVN, SCOPY, SSCAL, SSORT, XERMSG

  !* REVISION HISTORY  (YYMMDD)
  !   800801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890618  Completely restructured and extensively revised (WRB & RWC)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900328  Added TYPE section.  (WRB)
  !   900510  Convert XERRWV calls to XERMSG calls.  (RWC)
  USE linear, ONLY : BNDSOL, BNDACC
  USE data_handling, ONLY : SSORT
  !
  INTEGER, INTENT(IN) :: Lw, Mdein, Mdg, Mdw, Nbkpt, Ndata, Nord
  INTEGER, INTENT(OUT) :: Mdeout
  REAL(SP), INTENT(IN) :: Bkptin(Nbkpt), Sddata(Ndata), Xdata(Ndata), Ydata(Ndata)
  REAL(SP), INTENT(INOUT) :: Bf(Nord,Nord), G(Mdg,Nord+1), W(Mdw,Nord+1)
  REAL(SP), INTENT(OUT) :: Bkpt(Nbkpt), Coeff(Nbkpt-Nord+1), Ptemp(MAX(Nbkpt,Ndata)), &
    Xtemp(MAX(Nbkpt,Ndata))
  !
  REAL(SP) :: dummy(1), rnorm, xmax, xmin, xval
  INTEGER :: i, idata, ileft, intseq, ip, ir, irow, l, mt, n, nb, nordm1, nordp1, np1
  CHARACTER(8) :: xern1, xern2
  !
  !* FIRST EXECUTABLE STATEMENT  EFCMN
  !
  !     Initialize variables and analyze input.
  !
  n = Nbkpt - Nord
  np1 = n + 1
  dummy = 0.
  !
  !     Initially set all output coefficients to zero.
  !
  Coeff(1:n) = 0._SP
  Mdeout = -1
  IF( Nord<1 .OR. Nord>20 ) THEN
    ERROR STOP 'EFCMN : IN EFC, THE ORDER OF THE B-SPLINE MUST BE 1 THRU 20.'
    RETURN
  END IF
  !
  IF( Nbkpt<2*Nord ) THEN
    ERROR STOP 'EFCMN : IN EFC, THE NUMBER OF KNOTS MUST BE AT LEAST TWICE THE &
      &B-SPLINE ORDER.'
    RETURN
  END IF
  !
  IF( Ndata<0 ) THEN
    ERROR STOP 'EFCMN : IN EFC, THE NUMBER OF DATA POINTS MUST BE NONNEGATIVE.'
    RETURN
  END IF
  !
  nb = (Nbkpt-Nord+3)*(Nord+1) + (Nbkpt+1)*(Nord+1) + 2*MAX(Nbkpt,Ndata)&
    + Nbkpt + Nord**2
  IF( Lw<nb ) THEN
    WRITE (xern1,'(I8)') nb
    WRITE (xern2,'(I8)') Lw
    ERROR STOP 'EFCMN : IN EFC, INSUFFICIENT STORAGE FOR W(*). &
      &CHECK FORMULA THAT READS LW>= ... .'
    Mdeout = -1
    RETURN
  END IF
  !
  IF( Mdein/=1 .AND. Mdein/=2 ) THEN
    ERROR STOP 'EFCMN : IN EFC, INPUT VALUE OF MDEIN MUST BE 1-2.'
    RETURN
  END IF
  !
  !     Sort the breakpoints.
  !
  Bkpt(1:Nbkpt) = Bkptin(1:Nbkpt)
  CALL SSORT(Bkpt,dummy,Nbkpt,1)
  !
  !     Save interval containing knots.
  !
  xmin = Bkpt(Nord)
  xmax = Bkpt(np1)
  nordm1 = Nord - 1
  nordp1 = Nord + 1
  !
  !     Process least squares equations.
  !
  !     Sort data and an array of pointers.
  !
  Xtemp(1:Ndata) = Xdata(1:Ndata)
  DO i = 1, Ndata
    Ptemp(i) = i
  END DO
  !
  IF( Ndata>0 ) THEN
    CALL SSORT(Xtemp,Ptemp,Ndata,2)
    xmin = MIN(xmin,Xtemp(1))
    xmax = MAX(xmax,Xtemp(Ndata))
  END IF
  !
  !     Fix breakpoint array if needed. This should only involve very
  !     minor differences with the input array of breakpoints.
  !
  DO i = 1, Nord
    Bkpt(i) = MIN(Bkpt(i),xmin)
  END DO
  !
  DO i = np1, Nbkpt
    Bkpt(i) = MAX(Bkpt(i),xmax)
  END DO
  !
  !     Initialize parameters of banded matrix processor, BNDACC( ).
  !
  mt = 0
  ip = 1
  ir = 1
  ileft = Nord
  intseq = 1
  DO idata = 1, Ndata
    !
    !        Sorted indices are in PTEMP(*).
    !
    l = INT( Ptemp(idata) )
    xval = Xdata(l)
    !
    !        When interval changes, process equations in the last block.
    !
    IF( xval>=Bkpt(ileft+1) ) THEN
      CALL BNDACC(G,Mdg,Nord,ip,ir,mt,ileft-nordm1)
      mt = 0
      !
      !           Move pointer up to have BKPT(ILEFT)<=XVAL, ILEFT<=N.
      !
      DO ileft = ileft, n
        IF( xval<Bkpt(ileft+1) ) EXIT
        IF( Mdein==2 ) THEN
          !
          !                 Data is being sequentially accumulated.
          !                 Transfer previously accumulated rows from W(*,*) to
          !                 G(*,*) and process them.
          !
          G(ir,1:nordp1) = W(intseq,1:nordp1)
          CALL BNDACC(G,Mdg,Nord,ip,ir,1,intseq)
          intseq = intseq + 1
        END IF
      END DO
    END IF
    !
    !        Obtain B-spline function value.
    !
    CALL BSPLVN(Bkpt,Nord,1,xval,ileft,Bf(:,1))
    !
    !        Move row into place.
    !
    irow = ir + mt
    mt = mt + 1
    G(irow,1:Nord) = Bf(1:Nord,1)
    G(irow,nordp1) = Ydata(l)
    !
    !        Scale data if uncertainty is nonzero.
    !
    IF( Sddata(l)/=0._SP ) G(irow,1:nordp1) = G(irow,1:nordp1)/Sddata(l)
    !
    !        When staging work area is exhausted, process rows.
    !
    IF( irow==Mdg-1 ) THEN
      CALL BNDACC(G,Mdg,Nord,ip,ir,mt,ileft-nordm1)
      mt = 0
    END IF
  END DO
  !
  !     Process last block of equations.
  !
  CALL BNDACC(G,Mdg,Nord,ip,ir,mt,ileft-nordm1)
  !
  !     Finish processing any previously accumulated rows from W(*,*)
  !     to G(*,*).
  !
  IF( Mdein==2 ) THEN
    DO i = intseq, np1
      G(ir,1:nordp1) = W(i,1:nordp1)
      CALL BNDACC(G,Mdg,Nord,ip,ir,1,MIN(n,i))
    END DO
  END IF
  !
  !     Last call to adjust block positioning.
  !
  G(ir,1:nordp1) = 0._SP
  CALL BNDACC(G,Mdg,Nord,ip,ir,1,np1)
  !
  !     Transfer accumulated rows from G(*,*) to W(*,*) for
  !     possible later sequential accumulation.
  !
  DO i = 1, np1
    W(i,1:nordp1) = G(i,1:nordp1)
  END DO
  !
  !     Solve for coefficients when possible.
  !
  DO i = 1, n
    IF( G(i,1)==0._SP ) THEN
      Mdeout = 2
      RETURN
    END IF
  END DO
  !
  !     All the diagonal terms in the accumulated triangular
  !     matrix are nonzero.  The solution can be computed but
  !     it may be unsuitable for further use due to poor
  !     conditioning or the lack of constraints.  No checking
  !     for either of these is done here.
  !
  CALL BNDSOL(1,G,Mdg,Nord,ip,ir,Coeff,n,rnorm)
  Mdeout = 1
  !
END SUBROUTINE EFCMN