!** LA05AS
SUBROUTINE LA05AS(A,Ind,Nz,Ia,N,Ip,Iw,W,G,U)
  !> Subsidiary to SPLP
  !***
  ! **Library:**   SLATEC
  !***
  ! **Type:**      SINGLE PRECISION (LA05AS-S, LA05AD-D)
  !***
  ! **Author:**  (UNKNOWN)
  !***
  ! **Description:**
  !
  !     THIS SUBPROGRAM IS A SLIGHT MODIFICATION OF A SUBPROGRAM
  !     FROM THE C. 1979 AERE HARWELL LIBRARY.  THE NAME OF THE
  !     CORRESPONDING HARWELL CODE CAN BE OBTAINED BY DELETING
  !     THE FINAL LETTER =S= IN THE NAMES USED HERE.
  !     REVISIONS MADE BY R J HANSON, SNLA, AUGUST, 1979.
  !     REVISED SEP. 13, 1979.
  !
  !     ROYALTIES HAVE BEEN PAID TO AERE-UK FOR USE OF THEIR CODES
  !     IN THE PACKAGE GIVEN HERE.  ANY PRIMARY USAGE OF THE HARWELL
  !     SUBROUTINES REQUIRES A ROYALTY AGREEMENT AND PAYMENT BETWEEN
  !     THE USER AND AERE-UK.  ANY USAGE OF THE SANDIA WRITTEN CODES
  !     SPLP( ) (WHICH USES THE HARWELL SUBROUTINES) IS PERMITTED.
  !
  ! IP(I,1),IP(I,2) POINT TO THE START OF ROW/COL I.
  ! IW(I,1),IW(I,2) HOLD THE NUMBER OF NON-ZEROS IN ROW/COL I.
  ! DURING THE MAIN BODY OF THIS SUBROUTINE THE VECTORS IW(.,3),IW(.,5),
  !     IW(.,7) ARE USED TO HOLD DOUBLY LINKED LISTS OF ROWS THAT HAVE
  !     NOT BEEN PIVOTAL AND HAVE EQUAL NUMBERS OF NON-ZEROS.
  ! IW(.,4),IW(.,6),IW(.,8) HOLD SIMILAR LISTS FOR THE COLUMNS.
  ! IW(I,3),IW(I,4) HOLD FIRST ROW/COLUMN TO HAVE I NON-ZEROS
  !     OR ZERO IF THERE ARE NONE.
  ! IW(I,5), IW(I,6) HOLD ROW/COL NUMBER OF ROW/COL PRIOR TO ROW/COL I
  !     IN ITS LIST, OR ZERO IF NONE.
  ! IW(I,7), IW(I,8) HOLD ROW/COL NUMBER OF ROW/COL AFTER ROW/COL I
  !     IN ITS LIST, OR ZERO IF NONE.
  ! FOR ROWS/COLS THAT HAVE BEEN PIVOTAL IW(I,5),IW(I,6) HOLD NEGATION OF
  !     POSITION OF ROW/COL I IN THE PIVOTAL ORDERING.
  !
  !***
  ! **See also:**  SPLP
  !***
  ! **Routines called:**  LA05ES, MC20AS, R1MACH, XERMSG, XSETUN
  !***
  ! COMMON BLOCKS    LA05DS

  !* REVISION HISTORY  (YYMMDD)
  !   811215  DATE WRITTEN
  !   890531  Changed all specific intrinsics to generic.  (WRB)
  !   890605  Corrected references to XERRWV.  (WRB)
  !   890831  Modified array declarations.  (WRB)
  !   891214  Prologue converted to Version 4.0 format.  (BAB)
  !   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
  !   900402  Added TYPE section.  (WRB)
  !   900510  Convert XERRWV calls to XERMSG calls.  (RWC)
  USE LA05DS, ONLY : lp_com, lcol_com, lenl_com, lenu_com, ncp_com, lrow_com, small_com
  USE service, ONLY : eps_sp

  INTEGER, INTENT(IN) :: Ia, N
  INTEGER , INTENT(INOUT):: Ind(Ia,2), Nz
  INTEGER , INTENT(OUT):: Ip(N,2), Iw(N,8)
  REAL(SP), INTENT(INOUT) :: A(:), U
  REAL(SP), INTENT(OUT) :: G, W(:)
  INTEGER :: i, idummy, ii, il, in, ipp, ipv, ir, j, jcost, jp, k, k1, k2, kc, &
    kcost, kj, kk, kl, klc, kn, knp, kp, kpc, kpl, kq, kr, krl, ks, l, mcp, nc, nzc
  REAL(SP) :: amax, au, am
  CHARACTER(8) :: xern0, xern1, xern2
  ! EPS IS THE RELATIVE ACCURACY OF FLOATING-POINT COMPUTATION
  REAL(SP), PARAMETER :: eps = 2.0E0*eps_sp
  !* FIRST EXECUTABLE STATEMENT  LA05AS
  !
  !     SET THE OUTPUT UNIT NUMBER FOR THE ERROR PROCESSOR.
  !     THE USAGE OF THIS ERROR PROCESSOR IS DOCUMENTED IN THE
  !     SANDIA LABS. TECH. REPT. SAND78-1189, BY R E JONES.
  IF( U>1.0E0 ) U = 1._SP
  IF( U<eps ) U = eps
  IF( N<1 ) THEN
    !
    IF( lp_com>0 ) ERROR STOP 'LA05AS : THE ORDER OF THE SYSTEM, N, IS NOT POSITIVE.'
    G = -1._SP
    RETURN
  ELSE
    G = 0._SP
    DO i = 1, N
      W(i) = 0._SP
      DO j = 1, 5
        Iw(i,j) = 0
      END DO
    END DO
    !
    ! FLUSH OUT SMALL ENTRIES, COUNT ELEMENTS IN ROWS AND COLUMNS
    l = 1
    lenu_com = Nz
    DO idummy = 1, Nz
      IF( l<=lenu_com ) THEN
        DO k = l, lenu_com
          IF( ABS(A(k))<=small_com ) GOTO 20
          i = Ind(k,1)
          j = Ind(k,2)
          G = MAX(ABS(A(k)),G)
          IF( i<1 .OR. i>N ) GOTO 200
          IF( j<1 .OR. j>N ) GOTO 200
          Iw(i,1) = Iw(i,1) + 1
          Iw(j,2) = Iw(j,2) + 1
        END DO
      END IF
      EXIT
      20  l = k
      A(l) = A(lenu_com)
      Ind(l,1) = Ind(lenu_com,1)
      Ind(l,2) = Ind(lenu_com,2)
      lenu_com = lenu_com - 1
    END DO
    !
    lenl_com = 0
    lrow_com = lenu_com
    lcol_com = lrow_com
    ! MCP IS THE MAXIMUM NUMBER OF COMPRESSES PERMITTED BEFORE AN
    !     ERROR RETURN RESULTS.
    mcp = MAX(N/10,20)
    ncp_com = 0
    ! CHECK FOR NULL ROW OR COLUMN AND INITIALIZE IP(I,2) TO POINT
    !     JUST BEYOND WHERE THE LAST COMPONENT OF COLUMN I OF A WILL
    !     BE STORED.
    k = 1
    DO ir = 1, N
      k = k + Iw(ir,2)
      Ip(ir,2) = k
      DO l = 1, 2
        IF( Iw(ir,l)<=0 ) GOTO 300
      END DO
    END DO
    ! REORDER BY ROWS
    ! CHECK FOR DOUBLE ENTRIES WHILE USING THE NEWLY CONSTRUCTED
    !     ROW FILE TO CONSTRUCT THE COLUMN FILE. NOTE THAT BY PUTTING
    !    THE ENTRIES IN BACKWARDS AND DECREASING IP(J,2) EACH TIME IT
    !     IS USED WE AUTOMATICALLY LEAVE IT POINTING TO THE FIRST ELEMENT.
    CALL MC20AS(N,lenu_com,A,Ind(1,2),Ip,Ind(1,1),0)
    kl = lenu_com
    DO ii = 1, N
      ir = N + 1 - ii
      kp = Ip(ir,1)
      DO k = kp, kl
        j = Ind(k,2)
        IF( Iw(j,5)==ir ) GOTO 100
        Iw(j,5) = ir
        kr = Ip(j,2) - 1
        Ip(j,2) = kr
        Ind(kr,1) = ir
      END DO
      kl = kp - 1
    END DO
    !
    ! SET UP LINKED LISTS OF ROWS AND COLS WITH EQUAL NUMBERS OF NON-ZEROS.
    DO l = 1, 2
      DO i = 1, N
        Nz = Iw(i,l)
        in = Iw(Nz,l+2)
        Iw(Nz,l+2) = i
        Iw(i,l+6) = in
        Iw(i,l+4) = 0
        IF( in/=0 ) Iw(in,l+4) = i
      END DO
    END DO
    !
    !
    ! START OF MAIN ELIMINATION LOOP.
    DO ipv = 1, N
      ! FIND PIVOT. JCOST IS MARKOWITZ COST OF CHEAPEST PIVOT FOUND SO FAR,
      !     WHICH IS IN ROW IPP AND COLUMN JP.
      jcost = N*N
      ! LOOP ON LENGTH OF COLUMN TO BE SEARCHED
      DO Nz = 1, N
        IF( jcost<=(Nz-1)**2 ) EXIT
        j = Iw(Nz,4)
        ! SEARCH COLUMNS WITH NZ NON-ZEROS.
        DO idummy = 1, N
          IF( j<=0 ) EXIT
          kp = Ip(j,2)
          kl = kp + Iw(j,2) - 1
          DO k = kp, kl
            i = Ind(k,1)
            kcost = (Nz-1)*(Iw(i,1)-1)
            IF( kcost<jcost ) THEN
              IF( Nz/=1 ) THEN
                ! FIND LARGEST ELEMENT IN ROW OF POTENTIAL PIVOT.
                amax = 0._SP
                k1 = Ip(i,1)
                k2 = Iw(i,1) + k1 - 1
                DO kk = k1, k2
                  amax = MAX(amax,ABS(A(kk)))
                  IF( Ind(kk,2)==j ) kj = kk
                END DO
                ! PERFORM STABILITY TEST.
                IF( ABS(A(kj))<amax*U ) CYCLE
              END IF
              jcost = kcost
              ipp = i
              jp = j
              IF( jcost<=(Nz-1)**2 ) GOTO 40
            END IF
          END DO
          j = Iw(j,8)
        END DO
        ! SEARCH ROWS WITH NZ NON-ZEROS.
        i = Iw(Nz,3)
        DO idummy = 1, N
          IF( i<=0 ) EXIT
          amax = 0._SP
          kp = Ip(i,1)
          kl = kp + Iw(i,1) - 1
          ! FIND LARGEST ELEMENT IN THE ROW
          DO k = kp, kl
            amax = MAX(ABS(A(k)),amax)
          END DO
          au = amax*U
          DO k = kp, kl
            ! PERFORM STABILITY TEST.
            IF( ABS(A(k))>=au ) THEN
              j = Ind(k,2)
              kcost = (Nz-1)*(Iw(j,2)-1)
              IF( kcost<jcost ) THEN
                jcost = kcost
                ipp = i
                jp = j
                IF( jcost<=(Nz-1)**2 ) GOTO 40
              END IF
            END IF
          END DO
          i = Iw(i,7)
        END DO
      END DO
      !
      ! PIVOT FOUND.
      ! REMOVE ROWS AND COLUMNS INVOLVED IN ELIMINATION FROM ORDERING VECTORS.
      40  kp = Ip(jp,2)
      kl = Iw(jp,2) + kp - 1
      DO l = 1, 2
        DO k = kp, kl
          i = Ind(k,l)
          il = Iw(i,l+4)
          in = Iw(i,l+6)
          IF( il==0 ) THEN
            Nz = Iw(i,l)
            Iw(Nz,l+2) = in
          ELSE
            Iw(il,l+6) = in
          END IF
          IF( in>0 ) Iw(in,l+4) = il
        END DO
        kp = Ip(ipp,1)
        kl = kp + Iw(ipp,1) - 1
      END DO
      ! STORE PIVOT
      Iw(ipp,5) = -ipv
      Iw(jp,6) = -ipv
      ! ELIMINATE PIVOTAL ROW FROM COLUMN FILE AND FIND PIVOT IN ROW FILE.
      DO k = kp, kl
        j = Ind(k,2)
        kpc = Ip(j,2)
        Iw(j,2) = Iw(j,2) - 1
        klc = kpc + Iw(j,2)
        DO kc = kpc, klc
          IF( ipp==Ind(kc,1) ) EXIT
        END DO
        Ind(kc,1) = Ind(klc,1)
        Ind(klc,1) = 0
        IF( j==jp ) kr = k
      END DO
      ! BRING PIVOT TO FRONT OF PIVOTAL ROW.
      au = A(kr)
      A(kr) = A(kp)
      A(kp) = au
      Ind(kr,2) = Ind(kp,2)
      Ind(kp,2) = jp
      !
      ! PERFORM ELIMINATION ITSELF, LOOPING ON NON-ZEROS IN PIVOT COLUMN.
      nzc = Iw(jp,2)
      IF( nzc/=0 ) THEN
        DO nc = 1, nzc
          kc = Ip(jp,2) + nc - 1
          ir = Ind(kc,1)
          ! SEARCH NON-PIVOT ROW FOR ELEMENT TO BE ELIMINATED.
          kr = Ip(ir,1)
          krl = kr + Iw(ir,1) - 1
          DO knp = kr, krl
            IF( jp==Ind(knp,2) ) EXIT
          END DO
          ! BRING ELEMENT TO BE ELIMINATED TO FRONT OF ITS ROW.
          am = A(knp)
          A(knp) = A(kr)
          A(kr) = am
          Ind(knp,2) = Ind(kr,2)
          Ind(kr,2) = jp
          am = -A(kr)/A(kp)
          ! COMPRESS ROW FILE UNLESS IT IS CERTAIN THAT THERE IS ROOM FOR NEW ROW.
          IF( lrow_com+Iw(ir,1)+Iw(ipp,1)+lenl_com>Ia ) THEN
            IF( ncp_com>=mcp .OR. lenu_com+Iw(ir,1)+Iw(ipp,1)+lenl_com>Ia ) GOTO 400
            CALL LA05ES(A,Ind(:,2),Ip(:,1),N,Iw,.TRUE.)
            kp = Ip(ipp,1)
            kr = Ip(ir,1)
          END IF
          krl = kr + Iw(ir,1) - 1
          kq = kp + 1
          kpl = kp + Iw(ipp,1) - 1
          ! PLACE PIVOT ROW (EXCLUDING PIVOT ITSELF) IN W.
          IF( kq<=kpl ) THEN
            DO k = kq, kpl
              j = Ind(k,2)
              W(j) = A(k)
            END DO
          END IF
          Ip(ir,1) = lrow_com + 1
          !
          ! TRANSFER MODIFIED ELEMENTS.
          Ind(kr,2) = 0
          kr = kr + 1
          IF( kr<=krl ) THEN
            DO ks = kr, krl
              j = Ind(ks,2)
              au = A(ks) + am*W(j)
              Ind(ks,2) = 0
              ! IF ELEMENT IS VERY SMALL REMOVE IT FROM U.
              IF( ABS(au)<=small_com ) THEN
                lenu_com = lenu_com - 1
                ! REMOVE ELEMENT FROM COL FILE.
                k = Ip(j,2)
                kl = k + Iw(j,2) - 1
                Iw(j,2) = kl - k
                DO kk = k, kl
                  IF( Ind(kk,1)==ir ) EXIT
                END DO
                Ind(kk,1) = Ind(kl,1)
                Ind(kl,1) = 0
              ELSE
                G = MAX(G,ABS(au))
                lrow_com = lrow_com + 1
                A(lrow_com) = au
                Ind(lrow_com,2) = j
              END IF
              W(j) = 0._SP
            END DO
          END IF
          !
          ! SCAN PIVOT ROW FOR FILLS.
          IF( kq<=kpl ) THEN
            DO ks = kq, kpl
              j = Ind(ks,2)
              au = am*W(j)
              IF( ABS(au)<=small_com ) GOTO 44
              lrow_com = lrow_com + 1
              A(lrow_com) = au
              Ind(lrow_com,2) = j
              lenu_com = lenu_com + 1
              !
              ! CREATE FILL IN COLUMN FILE.
              Nz = Iw(j,2)
              k = Ip(j,2)
              kl = k + Nz - 1
              IF( Nz/=0 ) THEN
                ! IF POSSIBLE PLACE NEW ELEMENT AT END OF PRESENT ENTRY.
                IF( kl/=lcol_com ) THEN
                  IF( Ind(kl+1,1)==0 ) THEN
                    Ind(kl+1,1) = ir
                    GOTO 42
                  END IF
                ELSEIF( lcol_com+lenl_com<Ia ) THEN
                  lcol_com = lcol_com + 1
                  Ind(kl+1,1) = ir
                  GOTO 42
                END IF
              END IF
              ! NEW ENTRY HAS TO BE CREATED.
              IF( lcol_com+lenl_com+Nz+1>=Ia ) THEN
                ! COMPRESS COLUMN FILE IF THERE IS NOT ROOM FOR NEW ENTRY.
                IF( ncp_com>=mcp .OR. lenu_com+lenl_com+Nz+1>=Ia ) GOTO 400
                CALL LA05ES(A,Ind,Ip(:,2),N,Iw(1,2),.FALSE.)
                k = Ip(j,2)
                kl = k + Nz - 1
              END IF
              ! TRANSFER OLD ENTRY INTO NEW.
              Ip(j,2) = lcol_com + 1
              IF( kl>=k ) THEN
                DO kk = k, kl
                  lcol_com = lcol_com + 1
                  Ind(lcol_com,1) = Ind(kk,1)
                  Ind(kk,1) = 0
                END DO
              END IF
              ! ADD NEW ELEMENT.
              lcol_com = lcol_com + 1
              Ind(lcol_com,1) = ir
              42  G = MAX(G,ABS(au))
              Iw(j,2) = Nz + 1
              44  W(j) = 0._SP
            END DO
          END IF
          Iw(ir,1) = lrow_com + 1 - Ip(ir,1)
          !
          ! STORE MULTIPLIER
          IF( lenl_com+lcol_com+1>Ia ) THEN
            ! COMPRESS COL FILE IF NECESSARY.
            IF( ncp_com>=mcp ) GOTO 400
            CALL LA05ES(A,Ind,Ip(:,2),N,Iw(1,2),.FALSE.)
          END IF
          k = Ia - lenl_com
          lenl_com = lenl_com + 1
          A(k) = am
          Ind(k,1) = ipp
          Ind(k,2) = ir
          lenu_com = lenu_com - 1
        END DO
      END IF
      !
      ! INSERT ROWS AND COLUMNS INVOLVED IN ELIMINATION IN LINKED LISTS
      !     OF EQUAL NUMBERS OF NON-ZEROS.
      k1 = Ip(jp,2)
      k2 = Iw(jp,2) + k1 - 1
      Iw(jp,2) = 0
      DO l = 1, 2
        IF( k2>=k1 ) THEN
          DO k = k1, k2
            ir = Ind(k,l)
            IF( l==1 ) Ind(k,l) = 0
            Nz = Iw(ir,l)
            IF( Nz<=0 ) GOTO 500
            in = Iw(Nz,l+2)
            Iw(ir,l+6) = in
            Iw(ir,l+4) = 0
            Iw(Nz,l+2) = ir
            IF( in/=0 ) Iw(in,l+4) = ir
          END DO
        END IF
        k1 = Ip(ipp,1) + 1
        k2 = Iw(ipp,1) + k1 - 2
      END DO
    END DO
    !
    ! RESET COLUMN FILE TO REFER TO U AND STORE ROW/COL NUMBERS IN
    !     PIVOTAL ORDER IN IW(.,3),IW(.,4)
    DO i = 1, N
      j = -Iw(i,5)
      Iw(j,3) = i
      j = -Iw(i,6)
      Iw(j,4) = i
      Iw(i,2) = 0
    END DO
    DO i = 1, N
      kp = Ip(i,1)
      kl = Iw(i,1) + kp - 1
      DO k = kp, kl
        j = Ind(k,2)
        Iw(j,2) = Iw(j,2) + 1
      END DO
    END DO
    k = 1
    DO i = 1, N
      k = k + Iw(i,2)
      Ip(i,2) = k
    END DO
    lcol_com = k - 1
    DO ii = 1, N
      i = Iw(ii,3)
      kp = Ip(i,1)
      kl = Iw(i,1) + kp - 1
      DO k = kp, kl
        j = Ind(k,2)
        kn = Ip(j,2) - 1
        Ip(j,2) = kn
        Ind(kn,1) = i
      END DO
    END DO
    RETURN
  END IF
  !
  !     THE FOLLOWING INSTRUCTIONS IMPLEMENT THE FAILURE EXITS.
  !
  100 CONTINUE
  IF( lp_com>0 ) THEN
    WRITE (xern1,'(I8)') ir
    WRITE (xern2,'(I8)') j
    ERROR STOP 'LA05AS : MORE THAN ONE MATRIX ENTRY'
      !.  HERE ROW = '//xern1//' AND COL = '//xern2,-4,1)
  END IF
  G = -4._SP
  RETURN
  !
  200 CONTINUE
  IF( lp_com>0 ) THEN
    WRITE (xern0,'(I8)') k
    WRITE (xern1,'(I8)') i
    WRITE (xern2,'(I8)') j
    ERROR STOP 'LA05AS : ELEMENT K IS OUT OF BOUNDS.'
      ! 'HERE ROW = '//xern1//' AND COL = '//xern2
  END IF
  G = -3._SP
  RETURN
  !
  300 CONTINUE
  IF( lp_com>0 ) THEN
    WRITE (xern1,'(I8)') l
    ERROR STOP 'LA05AS : ROW OR COLUMN HAS NO ELEMENTS' !.  HERE INDEX = '//xern1
  END IF
  G = -2._SP
  RETURN
  !
  400 CONTINUE
  IF( lp_com>0 ) ERROR STOP 'LA05AS : LENGTHS OF ARRAYS A(*) AND IND(*,2) ARE TOO SMALL.'
  G = -7._SP
  RETURN
  !
  500  ipv = ipv + 1
  Iw(ipv,1) = ir
  DO i = 1, N
    ii = -Iw(i,l+4)
    IF( ii>0 ) Iw(ii,1) = i
  END DO
  !
  IF( lp_com>0 ) THEN
    IF( l==2 ) THEN
       ERROR STOP 'LA05AS : DEPENDANT COLUMNS'
    ELSE
       ERROR STOP 'LA05AS : DEPENDANT ROWS'
    END IF
    DO
      !
      WRITE (xern1,'(I8)') Iw(i,1)
      xern2 = ' '
      IF( i+1<=ipv ) WRITE (xern2,'(I8)') Iw(i+1,1)
      ERROR STOP 'LA05AS : DEPENDENT VECTOR INDICES' ! ARE '//xern1//' AND '//xern2
      i = i + 2
      IF( i>ipv ) EXIT
    END DO
  END IF
  G = -5._SP

END SUBROUTINE LA05AS