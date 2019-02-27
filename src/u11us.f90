!DECK U11US
SUBROUTINE U11US(A,Mda,M,N,Ub,Db,Mode,Np,Krank,Ksure,H,W,Eb,Ir,Ic)
  IMPLICIT NONE
  REAL A, bb, Db, Eb, H, r2, rmin, SDOT, SNRM2, sum, t, temp, &
    tn, tt, Ub, W
  INTEGER i, ii, im1, imin, is, ISAMAX, j, jm1, jmax, jp1, kk, &
    km1, kmi, kp1, Krank, Ksure, kz, l, lm1, M
  INTEGER Mda, mmk, Mode, N, nn, Np
  !***BEGIN PROLOGUE  U11US
  !***SUBSIDIARY
  !***PURPOSE  Subsidiary to ULSIA
  !***LIBRARY   SLATEC
  !***TYPE      SINGLE PRECISION (U11US-S, DU11US-D)
  !***AUTHOR  (UNKNOWN)
  !***DESCRIPTION
  !
  !       This routine performs an LQ factorization of the
  !       matrix A using Householder transformations. Row
  !       and column pivots are chosen to reduce the growth
  !       of round-off and to help detect possible rank
  !       deficiency.
  !
  !***SEE ALSO  ULSIA
  !***ROUTINES CALLED  ISAMAX, ISWAP, SAXPY, SDOT, SNRM2, SSCAL, SSWAP,
  !                    XERMSG
  !***REVISION HISTORY  (YYMMDD)
  !   810801  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900328  Added TYPE section.  (WRB)
  !***END PROLOGUE  U11US
  DIMENSION A(Mda,*), Ub(*), Db(*), H(*), W(*), Eb(*)
  INTEGER Ic(*), Ir(*)
  !
  !        INITIALIZATION
  !
  !***FIRST EXECUTABLE STATEMENT  U11US
  j = 0
  Krank = M
  DO i = 1, N
    Ic(i) = i
  ENDDO
  DO i = 1, M
    Ir(i) = i
  ENDDO
  !
  !        DETERMINE REL AND ABS ERROR VECTORS
  !
  !
  !
  !        CALCULATE ROW LENGTH
  !
  DO i = 1, M
    H(i) = SNRM2(N,A(i,1),Mda)
    W(i) = H(i)
  ENDDO
  !
  !         INITIALIZE ERROR BOUNDS
  !
  DO i = 1, M
    Eb(i) = MAX(Db(i),Ub(i)*H(i))
    Ub(i) = Eb(i)
    Db(i) = 0.0
  ENDDO
  !
  !          DISCARD SELF DEPENDENT ROWS
  !
  i = 1
  DO
    IF ( Eb(i)>=H(i) ) THEN
      !
      !          MATRIX REDUCTION
      !
      kk = Krank
      Krank = Krank - 1
      IF ( Mode==0 ) RETURN
      IF ( i>Np ) THEN
        IF ( i>Krank ) EXIT
        CALL SSWAP(1,Eb(i),1,Eb(kk),1)
        CALL SSWAP(1,Ub(i),1,Ub(kk),1)
        CALL SSWAP(1,W(i),1,W(kk),1)
        CALL SSWAP(1,H(i),1,H(kk),1)
        CALL ISWAP(1,Ir(i),1,Ir(kk),1)
        CALL SSWAP(N,A(i,1),Mda,A(kk,1),Mda)
      ELSE
        CALL XERMSG('SLATEC','U11US','FIRST NP ROWS ARE LINEARLY DEPENDENT',&
          8,0)
        Krank = i - 1
        RETURN
      ENDIF
    ELSE
      IF ( i==Krank ) EXIT
      i = i + 1
    ENDIF
  ENDDO
  !
  !           TEST FOR ZERO RANK
  !
  IF ( Krank<=0 ) THEN
    Krank = 0
    Ksure = 0
    RETURN
  ENDIF
  !
  !        M A I N    L O O P
  !
  100  j = j + 1
  jp1 = j + 1
  jm1 = j - 1
  kz = Krank
  IF ( j<=Np ) kz = j
  !
  !        EACH ROW HAS NN=N-J+1 COMPONENTS
  !
  nn = N - j + 1
  !
  !         UB DETERMINES ROW PIVOT
  !
  200  imin = j
  IF ( H(j)/=0. ) THEN
    rmin = Ub(j)/H(j)
    DO i = j, kz
      IF ( Ub(i)<H(i)*rmin ) THEN
        rmin = Ub(i)/H(i)
        imin = i
      ENDIF
    ENDDO
    !
    !     TEST FOR RANK DEFICIENCY
    !
    IF ( rmin<1.0 ) GOTO 400
    tt = (Eb(imin)+ABS(Db(imin)))/H(imin)
    IF ( tt<1.0 ) THEN
      !     COMPUTE EXACT UB
      DO i = 1, jm1
        W(i) = A(imin,i)
      ENDDO
      l = jm1
      DO
        W(l) = W(l)/A(l,l)
        IF ( l==1 ) THEN
          tt = Eb(imin)
          DO i = 1, jm1
            tt = tt + ABS(W(i))*Eb(i)
          ENDDO
          Ub(imin) = tt
          IF ( Ub(imin)/H(imin)<1.0 ) GOTO 400
          EXIT
        ELSE
          lm1 = l - 1
          DO i = l, jm1
            W(lm1) = W(lm1) - A(i,lm1)*W(i)
          ENDDO
          l = lm1
        ENDIF
      ENDDO
    ENDIF
  ENDIF
  !
  !        MATRIX REDUCTION
  !
  300  kk = Krank
  Krank = Krank - 1
  kz = Krank
  IF ( Mode==0 ) RETURN
  IF ( j>Np ) THEN
    IF ( imin<=Krank ) THEN
      CALL ISWAP(1,Ir(imin),1,Ir(kk),1)
      CALL SSWAP(N,A(imin,1),Mda,A(kk,1),Mda)
      CALL SSWAP(1,Eb(imin),1,Eb(kk),1)
      CALL SSWAP(1,Ub(imin),1,Ub(kk),1)
      CALL SSWAP(1,Db(imin),1,Db(kk),1)
      CALL SSWAP(1,W(imin),1,W(kk),1)
      CALL SSWAP(1,H(imin),1,H(kk),1)
    ENDIF
    IF ( j<=Krank ) GOTO 200
    GOTO 500
  ELSE
    CALL XERMSG('SLATEC','U11US','FIRST NP ROWS ARE LINEARLY DEPENDENT',8,0)
    Krank = j - 1
    RETURN
  ENDIF
  !
  !        ROW PIVOT
  !
  400 CONTINUE
  IF ( imin/=j ) THEN
    CALL SSWAP(1,H(j),1,H(imin),1)
    CALL SSWAP(N,A(j,1),Mda,A(imin,1),Mda)
    CALL SSWAP(1,Eb(j),1,Eb(imin),1)
    CALL SSWAP(1,Ub(j),1,Ub(imin),1)
    CALL SSWAP(1,Db(j),1,Db(imin),1)
    CALL SSWAP(1,W(j),1,W(imin),1)
    CALL ISWAP(1,Ir(j),1,Ir(imin),1)
  ENDIF
  !
  !        COLUMN PIVOT
  !
  jmax = ISAMAX(nn,A(j,j),Mda)
  jmax = jmax + j - 1
  IF ( jmax/=j ) THEN
    CALL SSWAP(M,A(1,j),1,A(1,jmax),1)
    CALL ISWAP(1,Ic(j),1,Ic(jmax),1)
  ENDIF
  !
  !     APPLY HOUSEHOLDER TRANSFORMATION
  !
  tn = SNRM2(nn,A(j,j),Mda)
  IF ( tn==0.0 ) GOTO 300
  IF ( A(j,j)/=0.0 ) tn = SIGN(tn,A(j,j))
  CALL SSCAL(nn,1.0/tn,A(j,j),Mda)
  A(j,j) = A(j,j) + 1.0
  IF ( j/=M ) THEN
    DO i = jp1, M
      bb = -SDOT(nn,A(j,j),Mda,A(i,j),Mda)/A(j,j)
      CALL SAXPY(nn,bb,A(j,j),Mda,A(i,j),Mda)
      IF ( i>Np ) THEN
        IF ( H(i)/=0.0 ) THEN
          tt = 1.0 - (ABS(A(i,j))/H(i))**2
          tt = MAX(tt,0.0)
          t = tt
          tt = 1.0 + .05*tt*(H(i)/W(i))**2
          IF ( tt==1.0 ) THEN
            H(i) = SNRM2(N-j,A(i,j+1),Mda)
            W(i) = H(i)
          ELSE
            H(i) = H(i)*SQRT(t)
          ENDIF
        ENDIF
      ENDIF
    ENDDO
  ENDIF
  H(j) = A(j,j)
  A(j,j) = -tn
  !
  !
  !          UPDATE UB, DB
  !
  Ub(j) = Ub(j)/ABS(A(j,j))
  Db(j) = (SIGN(Eb(j),Db(j))+Db(j))/A(j,j)
  IF ( j/=Krank ) THEN
    DO i = jp1, Krank
      Ub(i) = Ub(i) + ABS(A(i,j))*Ub(j)
      Db(i) = Db(i) - A(i,j)*Db(j)
    ENDDO
    GOTO 100
  ENDIF
  !
  !        E N D    M A I N    L O O P
  !
  !
  !        COMPUTE KSURE
  !
  500  km1 = Krank - 1
  DO i = 1, km1
    is = 0
    kmi = Krank - i
    DO ii = 1, kmi
      IF ( Ub(ii)>Ub(ii+1) ) THEN
        is = 1
        temp = Ub(ii)
        Ub(ii) = Ub(ii+1)
        Ub(ii+1) = temp
      ENDIF
    ENDDO
    IF ( is==0 ) EXIT
  ENDDO
  Ksure = 0
  sum = 0.0
  DO i = 1, Krank
    r2 = Ub(i)*Ub(i)
    IF ( r2+sum>=1.0 ) EXIT
    sum = sum + r2
    Ksure = Ksure + 1
  ENDDO
  !
  !     IF SYSTEM IS OF REDUCED RANK AND MODE = 2
  !     COMPLETE THE DECOMPOSITION FOR SHORTEST LEAST SQUARES SOLUTION
  !
  IF ( Krank/=M.AND.Mode>=2 ) THEN
    mmk = M - Krank
    kp1 = Krank + 1
    i = Krank
    DO
      tn = SNRM2(mmk,A(kp1,i),1)/A(i,i)
      tn = A(i,i)*SQRT(1.0+tn*tn)
      CALL SSCAL(mmk,1.0/tn,A(kp1,i),1)
      W(i) = A(i,i)/tn + 1.0
      A(i,i) = -tn
      IF ( i==1 ) EXIT
      im1 = i - 1
      DO ii = 1, im1
        tt = -SDOT(mmk,A(kp1,ii),1,A(kp1,i),1)/W(i)
        tt = tt - A(i,ii)
        CALL SAXPY(mmk,tt,A(kp1,i),1,A(kp1,ii),1)
        A(i,ii) = A(i,ii) + tt*W(i)
      ENDDO
      i = i - 1
    ENDDO
  ENDIF
END SUBROUTINE U11US