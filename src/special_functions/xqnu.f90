!** XQNU
SUBROUTINE XQNU(Nu1,Nu2,Mu1,Theta,X,Sx,Id,Pqa,Ipqa,Ierror)
  !> To compute the values of Legendre functions for XLEGF.
  !            Method: backward nu-wise recurrence for Q(MU,NU,X) for
  !            fixed mu to obtain Q(MU1,NU1,X), Q(MU1,NU1+1,X), ...,
  !            Q(MU1,NU2,X).
  !***
  ! **Library:**   SLATEC
  !***
  ! **Category:**  C3A2, C9
  !***
  ! **Type:**      SINGLE PRECISION (XQNU-S, DXQNU-D)
  !***
  ! **Keywords:**  LEGENDRE FUNCTIONS
  !***
  ! **Author:**  Smith, John M., (NBS and George Mason University)
  !***
  ! **Routines called:**  XADD, XADJ, XPQNU

  !* REVISION HISTORY  (YYMMDD)
  !   820728  DATE WRITTEN
  !   890126  Revised to meet SLATEC CML recommendations.  (DWL and JMS)
  !   901019  Revisions to prologue.  (DWL and WRB)
  !   901106  Corrected order of sections in prologue and added TYPE
  !           section.  (WRB)
  !   920127  Revised PURPOSE section of prologue.  (DWL)

  INTEGER :: Ierror, Ipqa(*), Mu1
  REAL(SP) :: Nu1, Nu2, Pqa(*), Sx, X, Theta
  INTEGER :: Id, ipq, ipq1, ipq2, ipql1, ipql2, k, mu
  REAL(SP) :: dmu, nu, pq, pq1, pq2, x1, x2, pql1, pql2
  !* FIRST EXECUTABLE STATEMENT  XQNU
  Ierror = 0
  k = 0
  pq2 = 0._SP
  ipq2 = 0
  pql2 = 0._SP
  ipql2 = 0
  IF( Mu1/=1 ) THEN
    mu = 0
    !
    !        CALL XPQNU TO OBTAIN Q(0.,NU2,X) AND Q(0.,NU2-1,X)
    !
    CALL XPQNU(Nu1,Nu2,mu,Theta,Id,Pqa,Ipqa,Ierror)
    IF( Ierror/=0 ) RETURN
    IF( Mu1==0 ) RETURN
    k = INT( (Nu2-Nu1+1.5_SP) )
    pq2 = Pqa(k)
    ipq2 = Ipqa(k)
    pql2 = Pqa(k-1)
    ipql2 = Ipqa(k-1)
  END IF
  mu = 1
  !
  !        CALL XPQNU TO OBTAIN Q(1.,NU2,X) AND Q(1.,NU2-1,X)
  !
  CALL XPQNU(Nu1,Nu2,mu,Theta,Id,Pqa,Ipqa,Ierror)
  IF( Ierror/=0 ) RETURN
  IF( Mu1==1 ) RETURN
  nu = Nu2
  pq1 = Pqa(k)
  ipq1 = Ipqa(k)
  pql1 = Pqa(k-1)
  ipql1 = Ipqa(k-1)
  100  mu = 1
  dmu = 1._SP
  DO
    !
    !        FORWARD RECURRENCE IN MU TO OBTAIN Q(MU1,NU2,X) AND
    !              Q(MU1,NU2-1,X) USING
    !              Q(MU+1,NU,X)=-2.*MU*X*SQRT(1./(1.-X**2))*Q(MU,NU,X)
    !                   -(NU+MU)*(NU-MU+1.)*Q(MU-1,NU,X)
    !
    !              FIRST FOR NU=NU2
    !
    x1 = -2._SP*dmu*X*Sx*pq1
    x2 = (nu+dmu)*(nu-dmu+1._SP)*pq2
    CALL XADD(x1,ipq1,-x2,ipq2,pq,ipq,Ierror)
    IF( Ierror/=0 ) RETURN
    CALL XADJ(pq,ipq,Ierror)
    IF( Ierror/=0 ) RETURN
    pq2 = pq1
    ipq2 = ipq1
    pq1 = pq
    ipq1 = ipq
    mu = mu + 1
    dmu = dmu + 1._SP
    IF( mu>=Mu1 ) THEN
      Pqa(k) = pq
      Ipqa(k) = ipq
      IF( k==1 ) RETURN
      IF( nu<Nu2 ) THEN
        !
        !         BACKWARD RECURRENCE IN NU TO OBTAIN
        !              Q(MU1,NU1,X),Q(MU1,NU1+1,X),....,Q(MU1,NU2,X)
        !              USING
        !              (NU-MU+1.)*Q(MU,NU+1,X)=
        !                       (2.*NU+1.)*X*Q(MU,NU,X)-(NU+MU)*Q(MU,NU-1,X)
        !
        pq1 = Pqa(k)
        ipq1 = Ipqa(k)
        pq2 = Pqa(k+1)
        ipq2 = Ipqa(k+1)
        DO
          IF( nu<=Nu1 ) RETURN
          k = k - 1
          x1 = (2._SP*nu+1._SP)*X*pq1/(nu+dmu)
          x2 = -(nu-dmu+1._SP)*pq2/(nu+dmu)
          CALL XADD(x1,ipq1,x2,ipq2,pq,ipq,Ierror)
          IF( Ierror/=0 ) RETURN
          CALL XADJ(pq,ipq,Ierror)
          IF( Ierror/=0 ) RETURN
          pq2 = pq1
          ipq2 = ipq1
          pq1 = pq
          ipq1 = ipq
          Pqa(k) = pq
          Ipqa(k) = ipq
          nu = nu - 1._SP
        END DO
      ELSE
        !
        !              THEN FOR NU=NU2-1
        !
        nu = nu - 1._SP
        pq2 = pql2
        ipq2 = ipql2
        pq1 = pql1
        ipq1 = ipql1
        k = k - 1
        GOTO 100
      END IF
    END IF
  END DO
END SUBROUTINE XQNU
