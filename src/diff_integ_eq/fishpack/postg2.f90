!** POSTG2
PURE SUBROUTINE POSTG2(Nperod,N,M,A,Bb,C,Idimq,Q,B,B2,B3,W,W2,W3,D,Tcos,P)
  !> Subsidiary to POISTG
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (POSTG2-S)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     Subroutine to solve Poisson's equation on a staggered grid.
  !
  !***
  ! **See also:**  POISTG
  !***
  ! **Routines called:**  COSGEN, S1MERG, TRI3, TRIX

  !* REVISION HISTORY  (YYMMDD)
  !   801001  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900402  Added TYPE section.  (WRB)
  !   920130  Modified to use merge routine S1MERG rather than deleted routine MERGE.  (WRB)
  USE data_handling, ONLY : S1MERG
  !
  INTEGER, INTENT(IN) :: M, N, Nperod, Idimq
  REAL(SP), INTENT(IN) :: A(M), Bb(M), C(M)
  REAL(SP), INTENT(INOUT) :: Q(Idimq,N)
  REAL(SP), INTENT(OUT) :: B(M), B2(M), B3(M), D(M), P(:), Tcos(4*N), W(M), &
    W2(M), W3(M)
  !
  INTEGER :: kr, lr, mr, nlast, nlastp, np, nr, nrod, nrodpr, i, i2r, &
    i2rby2, ii, ijump, ip, ipstor, j, jm1, jm2, jm3, jp1, jp2, jp3, jr, &
    jstart, jstep, jstop, k(4)
  REAL(SP) :: fi, fnum, fnum2, t
  !* FIRST EXECUTABLE STATEMENT  POSTG2
  np = Nperod
  fnum = 0.5_SP*(np/3)
  fnum2 = 0.5_SP*(np/2)
  mr = M
  ip = -mr
  ipstor = 0
  i2r = 1
  jr = 2
  nr = N
  nlast = N
  kr = 1
  lr = 0
  IF( nr<=3 ) GOTO 200
  100  jr = 2*i2r
  nrod = 1
  IF( (nr/2)*2==nr ) nrod = 0
  jstart = 1
  jstop = nlast - jr
  IF( nrod==0 ) jstop = jstop - i2r
  i2rby2 = i2r/2
  IF( jstop>=jstart ) THEN
    !
    !     REGULAR REDUCTION.
    !
    ijump = 1
    DO j = jstart, jstop, jr
      jp1 = j + i2rby2
      jp2 = j + i2r
      jp3 = jp2 + i2rby2
      jm1 = j - i2rby2
      jm2 = j - i2r
      jm3 = jm2 - i2rby2
      IF( j/=1 ) THEN
        IF( ijump/=2 ) THEN
          ijump = 2
          CALL COSGEN(i2r,1,0.5_SP,0._SP,Tcos)
        END IF
        IF( i2r/=1 ) THEN
          DO i = 1, mr
            fi = Q(i,j)
            Q(i,j) = Q(i,j) - Q(i,jm1) - Q(i,jp1) + Q(i,jm2) + Q(i,jp2)
            B(i) = fi + Q(i,j) - Q(i,jm3) - Q(i,jp3)
          END DO
        ELSE
          DO i = 1, mr
            B(i) = 2._SP*Q(i,j)
            Q(i,j) = Q(i,jm2) + Q(i,jp2)
          END DO
        END IF
      ELSE
        CALL COSGEN(i2r,1,fnum,0.5_SP,Tcos)
        IF( i2r/=1 ) THEN
          DO i = 1, mr
            B(i) = Q(i,1) + 0.5_SP*(Q(i,jp2)-Q(i,jp1)-Q(i,jp3))
            Q(i,1) = Q(i,jp2) + Q(i,1) - Q(i,jp1)
          END DO
        ELSE
          DO i = 1, mr
            B(i) = Q(i,1)
            Q(i,1) = Q(i,2)
          END DO
        END IF
      END IF
      CALL TRIX(i2r,0,mr,A,Bb,C,B,Tcos,D,W)
      DO i = 1, mr
        Q(i,j) = Q(i,j) + B(i)
      END DO
      !
      !     END OF REDUCTION FOR REGULAR UNKNOWNS.
      !
    END DO
    !
    !     BEGIN SPECIAL REDUCTION FOR LAST UNKNOWN.
    !
    j = jstop + jr
  ELSE
    j = jr
  END IF
  nlast = j
  jm1 = j - i2rby2
  jm2 = j - i2r
  jm3 = jm2 - i2rby2
  IF( nrod==0 ) THEN
    !
    !     EVEN NUMBER OF UNKNOWNS
    !
    jp1 = j + i2rby2
    jp2 = j + i2r
    IF( i2r/=1 ) THEN
      DO i = 1, mr
        B(i) = Q(i,j) + 0.5_SP*(Q(i,jm2)-Q(i,jm1)-Q(i,jm3))
      END DO
      IF( nrodpr/=0 ) THEN
        DO i = 1, mr
          B(i) = B(i) + Q(i,jp2) - Q(i,jp1)
        END DO
      ELSE
        DO i = 1, mr
          ii = ip + i
          B(i) = B(i) + P(ii)
        END DO
      END IF
      CALL COSGEN(i2r,1,0.5_SP,0._SP,Tcos)
      CALL TRIX(i2r,0,mr,A,Bb,C,B,Tcos,D,W)
      ip = ip + mr
      ipstor = MAX(ipstor,ip+mr)
      DO i = 1, mr
        ii = ip + i
        P(ii) = B(i) + 0.5_SP*(Q(i,j)-Q(i,jm1)-Q(i,jp1))
        B(i) = P(ii) + Q(i,jp2)
      END DO
      IF( lr==0 ) THEN
        DO i = 1, i2r
          ii = kr + i
          Tcos(ii) = Tcos(i)
        END DO
      ELSE
        CALL COSGEN(lr,1,fnum2,0.5_SP,Tcos(i2r+1))
        CALL S1MERG(Tcos,0,i2r,i2r,lr,kr)
      END IF
      CALL COSGEN(kr,1,fnum2,0.5_SP,Tcos)
      CALL TRIX(kr,kr,mr,A,Bb,C,B,Tcos,D,W)
      DO i = 1, mr
        ii = ip + i
        Q(i,j) = Q(i,jm2) + P(ii) + B(i)
      END DO
    ELSE
      DO i = 1, mr
        B(i) = Q(i,j)
      END DO
      Tcos(1) = 0._SP
      CALL TRIX(1,0,mr,A,Bb,C,B,Tcos,D,W)
      ip = 0
      ipstor = mr
      DO i = 1, mr
        P(i) = B(i)
        B(i) = B(i) + Q(i,N)
      END DO
      Tcos(1) = -1._SP + 2*(np/2)
      Tcos(2) = 0._SP
      CALL TRIX(1,1,mr,A,Bb,C,B,Tcos,D,W)
      DO i = 1, mr
        Q(i,j) = Q(i,jm2) + P(i) + B(i)
      END DO
    END IF
    lr = kr
    kr = kr + jr
  ELSE
    !
    !     ODD NUMBER OF UNKNOWNS
    !
    IF( i2r/=1 ) THEN
      DO i = 1, mr
        B(i) = Q(i,j) + 0.5_SP*(Q(i,jm2)-Q(i,jm1)-Q(i,jm3))
      END DO
      IF( nrodpr/=0 ) THEN
        DO i = 1, mr
          Q(i,j) = Q(i,j) - Q(i,jm1) + Q(i,jm2)
        END DO
      ELSE
        DO i = 1, mr
          ii = ip + i
          Q(i,j) = Q(i,jm2) + P(ii)
        END DO
        ip = ip - mr
      END IF
      IF( lr/=0 ) CALL COSGEN(lr,1,fnum2,0.5_SP,Tcos(kr+1))
    ELSE
      DO i = 1, mr
        B(i) = Q(i,j)
        Q(i,j) = Q(i,jm2)
      END DO
    END IF
    CALL COSGEN(kr,1,fnum2,0.5_SP,Tcos)
    CALL TRIX(kr,lr,mr,A,Bb,C,B,Tcos,D,W)
    DO i = 1, mr
      Q(i,j) = Q(i,j) + B(i)
    END DO
    kr = kr + i2r
  END IF
  nr = (nlast-1)/jr + 1
  IF( nr>3 ) THEN
    i2r = jr
    nrodpr = nrod
    GOTO 100
  END IF
  !
  !      BEGIN SOLUTION
  !
  200  j = 1 + jr
  jm1 = j - i2r
  jp1 = j + i2r
  jm2 = nlast - i2r
  IF( nr==2 ) THEN
    !
    !     CASE OF GENERAL N AND NR = 2 .
    !
    DO i = 1, mr
      ii = ip + i
      B3(i) = 0._SP
      B(i) = Q(i,1) + P(ii)
      Q(i,1) = Q(i,1) - Q(i,jm1)
      B2(i) = Q(i,1) + Q(i,nlast)
    END DO
    k(1) = kr + jr
    k(2) = k(1) + jr
    CALL COSGEN(jr-1,1,0._SP,1._SP,Tcos(k(1)+1))
    SELECT CASE (np)
      CASE (2)
        CALL COSGEN(kr+1,1,0.5_SP,0._SP,Tcos(k(2)))
      CASE DEFAULT
        Tcos(k(2)) = 2*np - 4
        CALL COSGEN(kr,1,0._SP,1._SP,Tcos(k(2)+1))
    END SELECT
    k(4) = 1 - np/3
    CALL S1MERG(Tcos,k(1),jr-k(4),k(2)-k(4),kr+k(4),0)
    IF( np==3 ) k(1) = k(1) - 1
    k(2) = kr
    CALL COSGEN(kr,1,fnum2,0.5_SP,Tcos(k(1)+1))
    k(4) = k(1) + kr
    CALL COSGEN(lr,1,fnum2,0.5_SP,Tcos(k(4)+1))
    k(3) = lr
    k(4) = 0
    CALL TRI3(mr,A,Bb,C,k,B,B2,B3,Tcos,D,W,W2,W3)
    DO i = 1, mr
      B(i) = B(i) + B2(i)
    END DO
    IF( np==3 ) THEN
      Tcos(1) = 2._SP
      CALL TRIX(1,0,mr,A,Bb,C,B,Tcos,D,W)
    END IF
    DO i = 1, mr
      Q(i,1) = Q(i,1) + B(i)
    END DO
  ELSEIF( lr/=0 ) THEN
    !
    !     CASE OF GENERAL N WITH NR = 3 .
    !
    DO i = 1, mr
      B(i) = Q(i,1) - Q(i,jm1) + Q(i,j)
    END DO
    IF( nrod/=0 ) THEN
      DO i = 1, mr
        B(i) = B(i) + Q(i,nlast) - Q(i,jm2)
      END DO
    ELSE
      DO i = 1, mr
        ii = ip + i
        B(i) = B(i) + P(ii)
      END DO
    END IF
    DO i = 1, mr
      t = 0.5_SP*(Q(i,j)-Q(i,jm1)-Q(i,jp1))
      Q(i,j) = t
      B2(i) = Q(i,nlast) + t
      B3(i) = Q(i,1) + t
    END DO
    k(1) = kr + 2*jr
    CALL COSGEN(jr-1,1,0._SP,1._SP,Tcos(k(1)+1))
    k(2) = k(1) + jr
    Tcos(k(2)) = 2*np - 4
    k(4) = (np-1)*(3-np)
    k(3) = k(2) + 1 - k(4)
    CALL COSGEN(kr+jr+k(4),1,k(4)/2._SP,1._SP-k(4),Tcos(k(3)))
    k(4) = 1 - np/3
    CALL S1MERG(Tcos,k(1),jr-k(4),k(2)-k(4),kr+jr+k(4),0)
    IF( np==3 ) k(1) = k(1) - 1
    k(2) = kr + jr
    k(4) = k(1) + k(2)
    CALL COSGEN(kr,1,fnum2,0.5_SP,Tcos(k(4)+1))
    k(3) = k(4) + kr
    CALL COSGEN(jr,1,fnum,0.5_SP,Tcos(k(3)+1))
    CALL S1MERG(Tcos,k(4),kr,k(3),jr,k(1))
    k(4) = k(3) + jr
    CALL COSGEN(lr,1,fnum2,0.5_SP,Tcos(k(4)+1))
    CALL S1MERG(Tcos,k(3),jr,k(4),lr,k(1)+k(2))
    CALL COSGEN(kr,1,fnum2,0.5_SP,Tcos(k(3)+1))
    k(3) = kr
    k(4) = kr
    CALL TRI3(mr,A,Bb,C,k,B,B2,B3,Tcos,D,W,W2,W3)
    DO i = 1, mr
      B(i) = B(i) + B2(i) + B3(i)
    END DO
    IF( np==3 ) THEN
      Tcos(1) = 2._SP
      CALL TRIX(1,0,mr,A,Bb,C,B,Tcos,D,W)
    END IF
    DO i = 1, mr
      Q(i,j) = Q(i,j) + B(i)
      B(i) = Q(i,1) + Q(i,j)
    END DO
    CALL COSGEN(jr,1,fnum,0.5_SP,Tcos)
    CALL TRIX(jr,0,mr,A,Bb,C,B,Tcos,D,W)
    IF( jr/=1 ) THEN
      DO i = 1, mr
        Q(i,1) = Q(i,1) - Q(i,jm1) + B(i)
      END DO
    ELSE
      DO i = 1, mr
        Q(i,1) = B(i)
      END DO
    END IF
  ELSEIF( N/=3 ) THEN
    !
    !     CASE N = 2**P+1
    !
    DO i = 1, mr
      B(i) = Q(i,j) + Q(i,1) - Q(i,jm1) + Q(i,nlast) - Q(i,jm2)
    END DO
    SELECT CASE (np)
      CASE (2)
        DO i = 1, mr
          fi = (Q(i,j)-Q(i,jm1)-Q(i,jp1))/2._SP
          B2(i) = Q(i,1) + fi
          B3(i) = Q(i,nlast) + fi
        END DO
        k(1) = nlast + jr - 1
        k(2) = k(1) + jr - 1
        CALL COSGEN(jr-1,1,0._SP,1._SP,Tcos(k(1)+1))
        CALL COSGEN(nlast,1,0.5_SP,0._SP,Tcos(k(2)+1))
        CALL S1MERG(Tcos,k(1),jr-1,k(2),nlast,0)
        k(3) = k(1) + nlast - 1
        k(4) = k(3) + jr
        CALL COSGEN(jr,1,0.5_SP,0.5_SP,Tcos(k(3)+1))
        CALL COSGEN(jr,1,0._SP,0.5_SP,Tcos(k(4)+1))
        CALL S1MERG(Tcos,k(3),jr,k(4),jr,k(1))
        k(2) = nlast - 1
        k(3) = jr
        k(4) = jr
      CASE DEFAULT
        DO i = 1, mr
          B2(i) = Q(i,1) + Q(i,nlast) + Q(i,j) - Q(i,jm1) - Q(i,jp1)
          B3(i) = 0._SP
        END DO
        k(1) = nlast - 1
        k(2) = nlast + jr - 1
        CALL COSGEN(jr-1,1,0._SP,1._SP,Tcos(nlast))
        Tcos(k(2)) = 2*np - 4
        CALL COSGEN(jr,1,0.5_SP-fnum,0.5_SP,Tcos(k(2)+1))
        k(3) = (3-np)/2
        CALL S1MERG(Tcos,k(1),jr-k(3),k(2)-k(3),jr+k(3),0)
        k(1) = k(1) - 1 + k(3)
        CALL COSGEN(jr,1,fnum,0.5_SP,Tcos(k(1)+1))
        k(2) = jr
        k(3) = 0
        k(4) = 0
    END SELECT
    CALL TRI3(mr,A,Bb,C,k,B,B2,B3,Tcos,D,W,W2,W3)
    DO i = 1, mr
      B(i) = B(i) + B2(i) + B3(i)
    END DO
    IF( np==3 ) THEN
      Tcos(1) = 2._SP
      CALL TRIX(1,0,mr,A,Bb,C,B,Tcos,D,W)
    END IF
    DO i = 1, mr
      Q(i,j) = B(i) + 0.5_SP*(Q(i,j)-Q(i,jm1)-Q(i,jp1))
      B(i) = Q(i,j) + Q(i,1)
    END DO
    CALL COSGEN(jr,1,fnum,0.5_SP,Tcos)
    CALL TRIX(jr,0,mr,A,Bb,C,B,Tcos,D,W)
    DO i = 1, mr
      Q(i,1) = Q(i,1) - Q(i,jm1) + B(i)
    END DO
  ELSE
    !
    !     CASE N = 3.
    !
    SELECT CASE (np)
      CASE (2)
        DO i = 1, mr
          B(i) = Q(i,2)
          B2(i) = Q(i,3)
          B3(i) = Q(i,1)
        END DO
        CALL COSGEN(3,1,0.5_SP,0._SP,Tcos)
        Tcos(4) = -1._SP
        Tcos(5) = 1._SP
        Tcos(6) = -1._SP
        Tcos(7) = 1._SP
        k(1) = 3
        k(2) = 2
        k(3) = 1
        k(4) = 1
      CASE DEFAULT
        DO i = 1, mr
          B(i) = Q(i,2)
          B2(i) = Q(i,1) + Q(i,3)
          B3(i) = 0._SP
        END DO
        SELECT CASE (np)
          CASE (1,2)
            Tcos(1) = -2._SP
            Tcos(2) = 1._SP
            Tcos(3) = -1._SP
            k(1) = 2
          CASE DEFAULT
            Tcos(1) = -1._SP
            Tcos(2) = 1._SP
            k(1) = 1
        END SELECT
        k(2) = 1
        k(3) = 0
        k(4) = 0
    END SELECT
    CALL TRI3(mr,A,Bb,C,k,B,B2,B3,Tcos,D,W,W2,W3)
    DO i = 1, mr
      B(i) = B(i) + B2(i) + B3(i)
    END DO
    SELECT CASE (np)
      CASE (1,2)
      CASE DEFAULT
        Tcos(1) = 2._SP
        CALL TRIX(1,0,mr,A,Bb,C,B,Tcos,D,W)
    END SELECT
    DO i = 1, mr
      Q(i,2) = B(i)
      B(i) = Q(i,1) + B(i)
    END DO
    Tcos(1) = -1._SP + 4._SP*fnum
    CALL TRIX(1,0,mr,A,Bb,C,B,Tcos,D,W)
    DO i = 1, mr
      Q(i,1) = B(i)
    END DO
    jr = 1
    i2r = 0
  END IF
  !
  !     START BACK SUBSTITUTION.
  !
  300  j = nlast - jr
  DO i = 1, mr
    B(i) = Q(i,nlast) + Q(i,j)
  END DO
  jm2 = nlast - i2r
  IF( jr==1 ) THEN
    DO i = 1, mr
      Q(i,nlast) = 0._SP
    END DO
  ELSEIF( nrod/=0 ) THEN
    DO i = 1, mr
      Q(i,nlast) = Q(i,nlast) - Q(i,jm2)
    END DO
  ELSE
    DO i = 1, mr
      ii = ip + i
      Q(i,nlast) = P(ii)
    END DO
    ip = ip - mr
  END IF
  CALL COSGEN(kr,1,fnum2,0.5_SP,Tcos)
  CALL COSGEN(lr,1,fnum2,0.5_SP,Tcos(kr+1))
  CALL TRIX(kr,lr,mr,A,Bb,C,B,Tcos,D,W)
  DO i = 1, mr
    Q(i,nlast) = Q(i,nlast) + B(i)
  END DO
  nlastp = nlast
  DO
    jstep = jr
    jr = i2r
    i2r = i2r/2
    IF( jr==0 ) THEN
      !
      !     RETURN STORAGE REQUIREMENTS FOR P VECTORS.
      !
      W(1) = ipstor
      EXIT
    ELSE
      jstart = 1 + jr
      kr = kr - jr
      IF( nlast+jr>N ) THEN
        jstop = nlast - jr
      ELSE
        kr = kr - jr
        nlast = nlast + jr
        jstop = nlast - jstep
      END IF
      lr = kr - jr
      CALL COSGEN(jr,1,0.5_SP,0._SP,Tcos)
      DO j = jstart, jstop, jstep
        jm2 = j - jr
        jp2 = j + jr
        IF( j/=jr ) THEN
          DO i = 1, mr
            B(i) = Q(i,j) + Q(i,jm2) + Q(i,jp2)
          END DO
        ELSE
          DO i = 1, mr
            B(i) = Q(i,j) + Q(i,jp2)
          END DO
        END IF
        IF( jr/=1 ) THEN
          jm1 = j - i2r
          jp1 = j + i2r
          DO i = 1, mr
            Q(i,j) = 0.5_SP*(Q(i,j)-Q(i,jm1)-Q(i,jp1))
          END DO
        ELSE
          DO i = 1, mr
            Q(i,j) = 0._SP
          END DO
        END IF
        CALL TRIX(jr,0,mr,A,Bb,C,B,Tcos,D,W)
        DO i = 1, mr
          Q(i,j) = Q(i,j) + B(i)
        END DO
      END DO
      nrod = 1
      IF( nlast+i2r<=N ) nrod = 0
      IF( nlastp/=nlast ) GOTO 300
    END IF
  END DO
  !
END SUBROUTINE POSTG2