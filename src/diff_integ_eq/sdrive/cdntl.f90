!** CDNTL
PURE SUBROUTINE CDNTL(Eps,F,FA,Hmax,Hold,Impl,Jtask,Matdim,Maxord,Mint,Miter,&
    Ml,Mu,N,Nde,Save1,T,Uround,USERS,Y,Ywt,H,Mntold,Mtrold,Nfe,Rc,Yh,A,Convrg,&
    El,Fac,Ier,Ipvt,Nq,Nwait,Rh,Rmax,Save2,Tq,Trend,Iswflg,Jstate)
  !> Subroutine CDNTL is called to set parameters on the first call to CDSTP,
  !  on an internal restart, or when the user has altered MINT, MITER, and/or H.
  !***
  ! **Library:**   SLATEC (SDRIVE)
  !***
  ! **Type:**      COMPLEX (SDNTL-S, DDNTL-D, CDNTL-C)
  !***
  ! **Author:**  Kahaner, D. K., (NIST)
  !             National Institute of Standards and Technology
  !             Gaithersburg, MD  20899
  !           Sutherland, C. D., (LANL)
  !             Mail Stop D466
  !             Los Alamos National Laboratory
  !             Los Alamos, NM  87545
  !***
  ! **Description:**
  !
  !  On the first call, the order is set to 1 and the initial derivatives
  !  are calculated.  RMAX is the maximum ratio by which H can be
  !  increased in one step.  It is initially RMINIT to compensate
  !  for the small initial H, but then is normally equal to RMNORM.
  !  If a failure occurs (in corrector convergence or error test), RMAX
  !  is set at RMFAIL for the next increase.
  !  If the caller has changed MINT, or if JTASK = 0, CDCST is called
  !  to set the coefficients of the method.  If the caller has changed H,
  !  YH must be rescaled.  If H or MINT has been changed, NWAIT is
  !  reset to NQ + 2 to prevent further increases in H for that many
  !  steps.  Also, RC is reset.  RC is the ratio of new to old values of
  !  the coefficient L(0)*H.  If the caller has changed MITER, RC is
  !  set to 0 to force the partials to be updated, if partials are used.
  !
  !***
  ! **Routines called:**  CDCST, CDSCL, CGBFA, CGBSL, CGEFA, CGESL, SCNRM2

  !* REVISION HISTORY  (YYMMDD)
  !   790601  DATE WRITTEN
  !   900329  Initial submission to SLATEC.
  USE blas, ONLY : SCNRM2
  USE linpack, ONLY : CGBFA, CGEFA
  USE lapack, ONLY : CGBTRS, CGETRS
  !
  INTERFACE
    PURE SUBROUTINE F(N,T,Y,Ydot)
      IMPORT SP
      INTEGER, INTENT(IN) :: N
      REAL(SP), INTENT(IN) :: T
      COMPLEX(SP), INTENT(IN) :: Y(:)
      COMPLEX(SP), INTENT(OUT) :: Ydot(:)
    END SUBROUTINE F
    PURE SUBROUTINE USERS(Y,Yh,Ywt,Save1,Save2,T,H,El,Impl,N,Nde,Iflag)
      IMPORT SP
      INTEGER, INTENT(IN) :: Impl, N, Nde, iflag
      REAL(SP), INTENT(IN) :: T, H, El
      COMPLEX(SP), INTENT(IN) :: Y(N), Yh(N,13), Ywt(N)
      COMPLEX(SP), INTENT(INOUT) :: Save1(N), Save2(N)
    END SUBROUTINE USERS
    PURE SUBROUTINE FA(N,T,Y,A,Matdim,Ml,Mu,Nde)
      IMPORT SP
      INTEGER, INTENT(IN) :: N, Matdim, Ml, Mu, Nde
      REAL(SP), INTENT(IN) :: T
      COMPLEX(SP), INTENT(IN) :: Y(N)
      COMPLEX(SP), INTENT(INOUT) :: A(:,:)
    END SUBROUTINE FA
  END INTERFACE
  INTEGER, INTENT(IN) :: Impl, Iswflg, Jtask, Matdim, Maxord, Mint, Miter, Ml, &
    Mu, N, Nde
  INTEGER, INTENT(INOUT) :: Mntold, Mtrold, Nfe, Nq
  INTEGER, INTENT(OUT) :: Jstate, Nwait
  INTEGER, INTENT(OUT) :: Ipvt(N)
  REAL(SP), INTENT(IN) :: Eps, Hmax, T, Uround
  REAL(SP), INTENT(INOUT) :: H, Hold, Rc, Rh, Rmax, Trend
  REAL(SP), INTENT(INOUT) :: El(13,12), Tq(3,12)
  COMPLEX(SP), INTENT(IN) :: Y(N+1), Ywt(N)
  COMPLEX(SP), INTENT(INOUT) :: A(Matdim,N), Fac(N), Save1(N), Save2(N), Yh(N,13)
  LOGICAL, INTENT(INOUT) :: Convrg
  LOGICAL, INTENT(OUT) :: Ier
  !
  INTEGER :: i, iflag, info
  REAL(SP) :: oldl0, summ
  REAL(SP), PARAMETER :: RMINIT = 10000._SP
  !* FIRST EXECUTABLE STATEMENT  CDNTL
  Ier = .FALSE.
  IF( Jtask>=0 ) THEN
    IF( Jtask==0 ) THEN
      CALL CDCST(Maxord,Mint,Iswflg,El,Tq)
      Rmax = RMINIT
    END IF
    Rc = 0._SP
    Convrg = .FALSE.
    Trend = 1._SP
    Nq = 1
    Nwait = 3
    CALL F(N,T,Y,Save2)
    IF( N==0 ) THEN
      Jstate = 6
      RETURN
    END IF
    Nfe = Nfe + 1
    IF( Impl/=0 ) THEN
      IF( Miter==3 ) THEN
        iflag = 0
        CALL USERS(Y,Yh,Ywt,Save1,Save2,T,H,El(1,1),Impl,N,Nde,iflag)
        IF( iflag==-1 ) THEN
          Ier = .TRUE.
          RETURN
        END IF
        IF( N==0 ) THEN
          Jstate = 10
          RETURN
        END IF
      ELSEIF( Impl==1 ) THEN
        IF( Miter==1 .OR. Miter==2 ) THEN
          CALL FA(N,T,Y,A,Matdim,Ml,Mu,Nde)
          IF( N==0 ) THEN
            Jstate = 9
            RETURN
          END IF
          CALL CGEFA(A,Matdim,N,Ipvt,info)
          IF( info/=0 ) THEN
            Ier = .TRUE.
            RETURN
          END IF
          CALL CGETRS('N',N,1,A,Matdim,Ipvt,Save2,N,info)
        ELSEIF( Miter==4 .OR. Miter==5 ) THEN
          CALL FA(N,T,Y,A(Ml+1:,:),Matdim,Ml,Mu,Nde)
          IF( N==0 ) THEN
            Jstate = 9
            RETURN
          END IF
          CALL CGBFA(A,Matdim,N,Ml,Mu,Ipvt,info)
          IF( info/=0 ) THEN
            Ier = .TRUE.
            RETURN
          END IF
          CALL CGBTRS('N',N,Ml,Mu,1,A,Matdim,Ipvt,Save2,N,info)
        END IF
      ELSEIF( Impl==2 ) THEN
        CALL FA(N,T,Y,A,Matdim,Ml,Mu,Nde)
        IF( N==0 ) THEN
          Jstate = 9
          RETURN
        END IF
        DO i = 1, Nde
          IF( A(i,1)==0._SP ) THEN
            Ier = .TRUE.
            RETURN
          ELSE
            Save2(i) = Save2(i)/A(i,1)
          END IF
        END DO
        DO i = Nde + 1, N
          A(i,1) = 0._SP
        END DO
      ELSEIF( Impl==3 ) THEN
        IF( Miter==1 .OR. Miter==2 ) THEN
          CALL FA(N,T,Y,A,Matdim,Ml,Mu,Nde)
          IF( N==0 ) THEN
            Jstate = 9
            RETURN
          END IF
          CALL CGEFA(A,Matdim,Nde,Ipvt,info)
          IF( info/=0 ) THEN
            Ier = .TRUE.
            RETURN
          END IF
          CALL CGETRS('N',Nde,1,A,Matdim,Ipvt,Save2,Nde,info)
        ELSEIF( Miter==4 .OR. Miter==5 ) THEN
          CALL FA(N,T,Y,A(Ml+1:,:),Matdim,Ml,Mu,Nde)
          IF( N==0 ) THEN
            Jstate = 9
            RETURN
          END IF
          CALL CGBFA(A,Matdim,Nde,Ml,Mu,Ipvt,info)
          IF( info/=0 ) THEN
            Ier = .TRUE.
            RETURN
          END IF
          CALL CGBTRS('N',Nde,Ml,Mu,1,A,Matdim,Ipvt,Save2,Nde,info)
        END IF
      END IF
    END IF
    DO i = 1, Nde
      Save1(i) = Save2(i)/MAX(1._SP,ABS(Ywt(i)))
    END DO
    summ = SCNRM2(Nde,Save1,1)/SQRT(REAL(Nde,SP))
    IF( summ>Eps/ABS(H) ) H = SIGN(Eps/summ,H)
    DO i = 1, N
      Yh(i,2) = H*Save2(i)
    END DO
    IF( Miter==2 .OR. Miter==5 .OR. Iswflg==3 ) THEN
      DO i = 1, N
        Fac(i) = SQRT(Uround)
      END DO
    END IF
  ELSE
    IF( Miter/=Mtrold ) THEN
      Mtrold = Miter
      Rc = 0._SP
      Convrg = .FALSE.
    END IF
    IF( Mint/=Mntold ) THEN
      Mntold = Mint
      oldl0 = El(1,Nq)
      CALL CDCST(Maxord,Mint,Iswflg,El,Tq)
      Rc = Rc*El(1,Nq)/oldl0
      Nwait = Nq + 2
    END IF
    IF( H/=Hold ) THEN
      Nwait = Nq + 2
      Rh = H/Hold
      CALL CDSCL(Hmax,N,Nq,Rmax,Hold,Rc,Rh,Yh)
    END IF
  END IF
  !
END SUBROUTINE CDNTL