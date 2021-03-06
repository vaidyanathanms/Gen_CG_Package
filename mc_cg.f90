!--------- To coarse grain PS-PEO -----------------------------------
!--------- To calculate bond and angles -----------------------------


PROGRAM ANALYSE_PSPEO
  
  USE CG_PARAMFILE
  USE OMP_LIB

  IMPLICIT NONE

  INTEGER :: i,j
  INTEGER :: ierror,narg,nargs
  CHARACTER(LEN = 64) :: filenum,proc_file,log_file
  REAL*8  :: inum

  nargs = IARGC()

  IF(nargs .NE. 1) THEN
     PRINT *, "Num of Arguments = ", nargs
     PRINT *, "Insufficient/Incorrect Arguments"
     STOP
  END IF

  narg = 1
  CALL GETARG(narg,filenum)
  READ(filenum,'(F10.1)') inum
  
  inum = inum*100000
  WRITE(filenum,'(I10)') int(inum)


  proc_file = 'cgnvt.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = ipfn, file = proc_file, status="old",action=&
       &"read",iostat = ierror)
  IF(ierror /= 0) THEN

     PRINT *, proc_file, "does not exist"
     STOP

  END IF

!Open all files for writing output
  proc_file = 'cgPSRR.'//trim(adjustl(filenum))//".xyz"
  OPEN (unit = cgfn, file = proc_file, status="replace",action=&
       &"write",iostat = ierror)

  proc_file = 'cgPSRR.'//trim(adjustl(filenum))//".lammpstrj"
  OPEN (unit = reffn, file = proc_file, status="replace",action=&
       &"write",iostat = ierror)

  proc_file = "mapPSRR.txt"
  OPEN (unit = mapfn, file = proc_file, status="replace",action=&
       &"write",iostat = ierror)

  proc_file = 'bondPSRR.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opbfn,file = proc_file,status="replace",action=&
       &"write",iostat = ierror)

  proc_file = 'anglPSRR.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opafn, file = proc_file, status="replace",action=&
       &"write",iostat = ierror)

  proc_file = 'e2ePSRR.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opefn, file = proc_file,status = "replace"&
       &, action= "write", iostat = ierror)

  proc_file = 'ABbonddist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opbdABfn,file = proc_file,status = "replace"&
       &, action= "write", iostat = ierror)

  proc_file = 'AAbonddist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opbdAAfn,file = proc_file,status="replace",action=&
       &"write",iostat = ierror)

  proc_file = 'ACbonddist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opbdACfn,file = proc_file,status="replace",action=&
       &"write",iostat = ierror)

  proc_file = 'CCbonddist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opbdCCfn,file = proc_file,status="replace",action=&
       &"write",iostat = ierror)

  proc_file = 'BABangldist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opadBABfn, file = proc_file,status = "replace"&
       &, action= "write", iostat = ierror)

  proc_file = 'BACangldist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opadBACfn, file = proc_file,status = "replace"&
       &, action= "write", iostat = ierror)

  proc_file = 'ACCangldist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opadACCfn, file = proc_file,status = "replace"&
       &, action= "write", iostat = ierror)

  proc_file = 'CCCangldist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = opadCCCfn, file = proc_file,status = "replace"&
       &, action= "write", iostat = ierror)

  proc_file = 'allrdfdist.'//trim(adjustl(filenum))//".txt"
  OPEN (unit = oprdffn, file = proc_file,status = "replace"&
       &, action= "write", iostat = ierror)

 !!$ Open log file and call subroutines

  log_file = "lognvt."//trim(adjustl(filenum))//".txt"
  OPEN(unit = opfn, file = log_file , status="replace",&
       &action="write")
  WRITE(opfn,*) "NVT calculation for : ",&
       & trim(adjustl(proc_file))
  WRITE(opfn,*) "Number of files under process: ", nframes
  WRITE(opfn,*) "Number of files skipped: ", skip_fr
  WRITE(opfn,*) "Number of particles: ", totpart

  CALL DATAFILEREAD()

  PRINT *, "Reading trajectory files .."
  CALL READFILES()

  CALL BONDOUTDIST()

  IF(flagrdf == 1) CALL RDFOUTDIST()

  PRINT *, "Deallocating and Exiting Program"
  CALL DEALOC_CLOSEFILES()
  
  PRINT *, "Program Success .."

END PROGRAM ANALYSE_PSPEO

!--------------------------------------------------------------------

SUBROUTINE INITARRAYS()

  USE CG_PARAMFILE

  IMPLICIT NONE

  INTEGER :: AllocateStatus

  ALLOCATE (x_lmp(1:totpart), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation x_lmp not proper ***"
  ALLOCATE (y_lmp(1:totpart), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation y_lmp not proper ***"
  ALLOCATE (z_lmp(1:totpart), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation z_lmp not proper ***"
  ALLOCATE (atype(1:totpart), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation atype not proper ***"
  ALLOCATE (molarray(1:totpart), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation molarray not proper**"
  ALLOCATE (bondarray(1:nbonds,4), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation bondarray not proper*"
  ALLOCATE (anglarray(1:nangls,5), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation bondarray not proper*"
  ALLOCATE (masses(1:ntypeatom), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation masses not proper*"
  ALLOCATE (cgmap(N,atpercg), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation cgmap not proper*"
  ALLOCATE (cgtype(N,atpercg), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation cgtype not proper*"

END SUBROUTINE INITARRAYS

!--------------------------------------------------------------------

SUBROUTINE DEALOC_CLOSEFILES()
  
  USE CG_PARAMFILE

  IMPLICIT NONE
 
  DEALLOCATE(x_lmp)
  DEALLOCATE(y_lmp)
  DEALLOCATE(z_lmp)
  DEALLOCATE(atype)
  DEALLOCATE(bondarray)
  DEALLOCATE(molarray)
  DEALLOCATE(masses)

  CLOSE(unit = ipfn)
  CLOSE(unit = opfn)
  CLOSE(unit = cgfn)
  CLOSE(unit = mapfn)
  CLOSE(unit = opbfn)
  CLOSE(unit = opafn)
  CLOSE(unit = opefn)
  CLOSE(unit = opbdAAfn)
  CLOSE(unit = opbdABfn)
  CLOSE(unit = opbdACfn)
  CLOSE(unit = opbdCCfn)
  CLOSE(unit = opadBABfn)
  CLOSE(unit = opadBACfn)
  CLOSE(unit = opadACCfn)
  CLOSE(unit = opadCCCfn)

END SUBROUTINE DEALOC_CLOSEFILES

!--------------------------------------------------------------------

SUBROUTINE DATAFILEREAD()

  USE CG_PARAMFILE

  IMPLICIT NONE

  REAL    :: xlo, xhi, ylo, yhi, zlo, zhi
  INTEGER :: i,j,k,ierr,skipl,AllocateStatus,angcnt,a1,a2,a3,a4,a5
  INTEGER :: atomid,molid,bondid
  CHARACTER (LEN =256) :: dread
  INTEGER, DIMENSION(N) :: c1cnt

  PRINT *, "Reading datafile .."
  
  OPEN(unit = 3, file = 'data_randominit.txt',&
       & status = "old", action="read", iostat=ierr)

  IF(ierr /= 0) STOP "Datafile does not exist"

  READ(3,*)

  READ(3,*) natoms, dread
  READ(3,*) nbonds, dread
  READ(3,*) nangls, dread
  READ(3,*) ndihed, dread
  READ(3,*) nimprp, dread

  IF(natoms /= totpart) STOP "Inconsistency in parameter and datafile"

  READ(3,*) ntypeatom, dread
  READ(3,*) ntypebond, dread
  READ(3,*) ntypeangl, dread
  READ(3,*) ntypedihd, dread

  IF(nimprp /= 0) READ(3,*) ntypeimpr, dread

  PRINT *, "Number of atoms/type:  ", natoms, ntypeatom
  PRINT *, "Number of bonds/type:  ", nbonds, ntypebond
  PRINT *, "Number of angls/type:  ", nangls, ntypeangl
  PRINT *, "Number of dihds/type:  ", ndihed, ntypedihd
  PRINT *, "Number of dihds/type:  ", nimprp, ntypeimpr

  WRITE(opfn,*) "Number of atoms/type:  ", natoms, ntypeatom
  WRITE(opfn,*) "Number of bonds/type:  ", nbonds, ntypebond
  WRITE(opfn,*) "Number of angls/type:  ", nangls, ntypeangl
  WRITE(opfn,*) "Number of dihds/type:  ", ndihed, ntypedihd
  WRITE(opfn,*) "Number of dihds/type:  ", nimprp, ntypeimpr

  CALL INITARRAYS
  
  READ(3,*) xlo, xhi !dummyread
  READ(3,*) ylo, yhi !dummyread
  READ(3,*) zlo, zhi !dummyread

! Careful here
!  IF(nimprp /= 0) THEN 

!!$  skipl =  (3 + ntypeatom) + (3 + ntypebond) + (3 + ntypeangl) +&
!!$       & (3 + ntypedihd) + (3 + ntypeimpr) + (3 + ntypeatom)

!  ELSE

  skipl =  (3 + ntypeatom) + (3 + ntypebond) + (3 + ntypeangl) +&
       & (3 + ntypedihd) + 3

!  END IF

  PRINT *, "Number of skipped lines: ", skipl
  DO i = 1, skipl

     READ(3,*)

  END DO

  DO i = 1,ntypeatom
     
     READ(3,*) j, masses(j)

  END DO
  
  DO i = 1,3
     
     READ(3,*) 

  END DO

  c1cnt = 0
  molptr = 0
  PRINT *, "Processing atom info .."
  DO i = 1,natoms
   
     READ(3,*) atomid, molid, atype(atomid)
     molarray(atomid) = molid

     IF(atype(atomid) == 3) THEN

        c1cnt(molid) = c1cnt(molid) + 1
        benmolids(molid,c1cnt(molid)) = atomid
        
     END IF

     IF(atype(atomid) == termtype1) THEN
        
        molptr(molid) = molptr(molid) + 1
        termaids(molid,molptr(molid)) = atomid

     ELSEIF(atype(atomid) == termtype2) THEN
        
        molptr(molid) = molptr(molid) + 1
        termaids(molid,molptr(molid)) = atomid

     END IF

  END DO

  OPEN(unit = 4,file="bencheck.txt",status="replace",action="write")
  
  DO i = 1,N
     
     WRITE(4,*) i,c1cnt(i),benmolids(i,:)

  END DO

  CLOSE(4)

  OPEN(unit = 4,file="termcheck.txt",status="replace",action="write")
  
  DO i = 1,N
     
     WRITE(4,*) i,termaids(i,1),termaids(i,2),atype(termaids(i,1)),&
          & atype(termaids(i,2))

  END DO

  CLOSE(4)


  DO i = 1,3

     READ(3,*)

  END DO

  PRINT *, "Processing bond info .."
  DO i = 1, nbonds

     READ(3,*) bondarray(i,1), bondarray(i,2), bondarray(i,3),&
          & bondarray(i,4)

  END DO

  DO i = 1,3

     READ(3,*)

  END DO
  
  angcnt = 0
  OPEN(unit = 4,file="ABAangls.txt",status="replace",action="write")
  PRINT *, "Processing angle info .."
  DO i = 1, nangls

     READ(3,*) anglarray(i,1), anglarray(i,2), anglarray(i,3),&
          & anglarray(i,4), anglarray(i,5)

     IF(atype(anglarray(i,3)) == 4 .AND. atype(anglarray(i,4)) == 3&
          & .AND. atype(anglarray(i,5)) == 4) THEN
        
        WRITE(4,'(4(I5,1X))') anglarray(i,2),anglarray(i,3)&
             &,anglarray(i,4),anglarray(i,5)
        angcnt = angcnt + 1

     ELSEIF(atype(anglarray(i,3)) == 5 .AND. atype(anglarray(i,4)) ==&
          & 3.AND. atype(anglarray(i,5)) == 4) THEN

        WRITE(4,'(4(I5,1X))') anglarray(i,2),anglarray(i,3)&
             &,anglarray(i,4),anglarray(i,5)
        angcnt = angcnt + 1

     ELSEIF(atype(anglarray(i,3)) == 4 .AND. atype(anglarray(i,4)) ==&
          & 3.AND. atype(anglarray(i,5)) == 5) THEN
        
        WRITE(4,'(4(I5,1X))') anglarray(i,2),anglarray(i,3)&
             &,anglarray(i,4),anglarray(i,5)
        angcnt = angcnt + 1

     END IF
        
  END DO
  CLOSE (4)

  ABanglcnt = angcnt

  PRINT *, "Number of ABA angles in the system: ", ABanglcnt

  OPEN(unit = 4,file="ABAangls.txt",status="old",action="read")
  ALLOCATE (ABanglarr(angcnt,5), stat = AllocateStatus)
  IF(AllocateStatus /=0 ) STOP "*** Allocation masses not proper*"

  ABanglarr = 0

  DO i = 1,angcnt

     READ(4,*) a1,a2,a3,a4
     
     ABanglarr(i,1) = a1
     ABanglarr(i,2) = a2
     ABanglarr(i,3) = a3
     ABanglarr(i,4) = a4
     ABanglarr(i,5) = 0

  END DO

  DO i = 1,3

     READ(3,*) 

  END DO

!  PRINT *, "Processing Dihedral Info .."
  
  PRINT *, "Creating Mapping"
  CALL CGMAPPING()

END SUBROUTINE DATAFILEREAD

!--------------------------------------------------------------------

SUBROUTINE CGMAPPING()

  USE CG_PARAMFILE

  IMPLICIT NONE

  INTEGER :: i,j,k,b1,b2,b3,b4,molid,c13cnt,flag,refatom
  INTEGER :: a1,a2,a3,a4,a5,init,fin

  c13cnt = 0
  cgmap  = 0

! Coarse Graining PS
  
  DO i = 1,N

     IF(atype(termaids(i,1)) == termtype1) THEN

        refatom = termaids(i,1)
        cgmap(i,1)   = refatom
        cgtype(i,1)  = 1
        flag    = 0

     ELSEIF(atype(termaids(i,2)) == termtype1) THEN

        refatom = termaids(i,2)
        cgmap(i,1)   = refatom
        cgtype(i,1)  = 1
        flag    = 0

     END IF
     
     k = 1

     DO WHILE(k <= benpercg)

        DO j = 1,ABanglcnt
           
           a1 = ABanglarr(j,1)
           a2 = ABanglarr(j,2)
           a3 = ABanglarr(j,3)
           a4 = ABanglarr(j,4)
           a5 = ABanglarr(j,5)

           IF(a2 == refatom .AND. molarray(a2) == i .AND. a5 == 0)&
                & THEN


              IF(atype(a4) .NE. 4 .OR. atype(a3) .NE. 3) THEN

                 PRINT *, "Unidentified type"
                 PRINT *, i,a1,a2,a3,a4,a5
                 STOP 
                 
              END IF

              cgmap(i,2*k)   = a3
              cgtype(i,2*k)  = 2

              cgmap(i,2*k+1) = a4
              cgtype(i,2*k+1)= 1
              refatom        = a4

              k = k + 1
              ABanglarr(j,5) = 1 ! Change flag

           ELSEIF(a4 == refatom .AND. molarray(a4) == i .AND. a5 ==&
                & 0) THEN
              
              IF(atype(a2) .NE. 4 .OR. atype(a3) .NE. 3) THEN

                 PRINT *, "Unidentified type"
                 PRINT *, i,a1,a2,a3,a4,a5
                 STOP 
                 
              END IF

              cgmap(i,2*k)   = a3
              cgtype(i,2*k)  = 2

              cgmap(i,2*k+1) = a2
              cgtype(i,2*k+1)= 1
              refatom        = a2

              k = k + 1
              ABanglarr(j,5) = 1 ! Change flag
           
           END IF

        END DO
           
     END DO

  END DO

  DO i = 1,ABanglcnt

     IF(ABanglarr(i,5) .NE. 1) THEN

        PRINT *, "Not all angles are assigned"
        PRINT *, i,ABanglarr(i,2),ABanglarr(i,3),ABanglarr(i,4)
        STOP 

     END IF

  END DO

! Coarse Graining PEO **CHECK THIS AGAIN**

  DO i = 1,N

     init = 1 + M*(i-1)
     fin  = init + 3*oxypercg - 1
     
     IF(atype(fin - 2) .NE. midtype) THEN
        PRINT *, "Logic failed: Point 1"
        PRINT *, i,init,fin,atype(fin),atype(fin-2)
        STOP
     END IF

     k = 0

     DO j = init,fin,3
        
        IF(atype(j) .NE. 6) THEN

           IF(j .NE. fin -2 .OR. atype(j) .NE. midtype) THEN

              PRINT *, "Logic failed: Point 2"
              PRINT *, j,atype(j),i,init, fin
              STOP

           END IF

        END IF

        cgmap(i,atpercg-k)  = j+1
        cgtype(i,atpercg-k) = 3
        
        k = k + 1
        
     END DO

  END DO
        
  WRITE(mapfn,*) "CG ATOM", "CG TYPE"
  WRITE(mapfn,*) "CH2/CH3(vinyl)", "     ", "1"
  WRITE(mapfn,*) "BENZENE RING", "       ", "2"
  WRITE(mapfn,*) "PEO MONOMER", "        ", "3"

  DO i = 1,N

     WRITE(mapfn,*) "Chain Number ", i

     DO j = 1,atpercg

        WRITE(mapfn,'(3(I5,1X))') j, cgmap(i,j), cgtype(i,j)

     END DO

  END DO

  OPEN(unit=seqfn, file='atseq.txt',action='write',status='replace')
  
  DO i = 1,atpercg

     WRITE(seqfn,*) i, cgtype(1,i)

  END DO

  CLOSE(unit = seqfn)

END SUBROUTINE CGMAPPING

!--------------------------------------------------------------------

SUBROUTINE READFILES()

  USE CG_PARAMFILE

  IMPLICIT NONE

  INTEGER :: i,j,k,tstep,file_inc,u,v,s
  REAL    :: xlo, xhi, ylo, yhi, zlo, zhi
  INTEGER, DIMENSION(1:N*M) :: ua_attyp

  DO i = 1,skip_fr

     IF(mod(i,50) == 0) PRINT *, "Skipped ", i, "frames .."

     DO j = 1,totpart+9
  
        READ(ipfn,*)

     END DO

  END DO

  IF(skip_fr /= 0) THEN
     IF(EOF(ipfn)) THEN
        print *, "No match found for the first file number "
        WRITE(opfn,*) "No match found for the first file number "
        STOP
     END IF
  END IF

  DO file_inc = 1,nframes
     
     IF(file_inc==1 .OR. mod(file_inc,100) == 0) PRINT *, "Processing &
          &Frame: ", file_inc
     
     DO j = 1,5
        
        READ(ipfn,*) 
        
     END DO
     
     READ(ipfn,*) xlo, xhi
     READ(ipfn,*) ylo, yhi
     READ(ipfn,*) zlo, zhi
     
     box_lx = xhi - xlo
     box_ly = yhi - ylo
     box_lz = zhi - zlo

     volbox = box_lx*box_ly*box_lz
     
     boxxinv = 1.0/box_lx
     boxyinv = 1.0/box_ly
     boxzinv = 1.0/box_lz
     
     IF(file_inc == 1) THEN
        IF(box_lx .GE. box_ly .AND. box_lx .GE. box_lz) THEN
           maxblen = 0.5*box_lx
        ELSEIF(box_ly .GE. box_lz) THEN
           maxblen = 0.5*box_ly
        ELSE
           maxblen = 0.5*box_lz
        END IF
        
        bbinlen  = maxblen/bonbinmax
        rdfbinlen= maxblen/rdfbinmax
    
        DO s = 1,bonbinmax
           
           ABbondistarr(s) = 0.0
           AAbondistarr(s) = 0.0
           ACbondistarr(s) = 0.0
           CCbondistarr(s) = 0.0
           
        END DO

        PRINT *, "Bondlength binsize : ", bbinlen
        
        DO s = 1,angbinmax
           
           BABangdistarr(s) = 0.0
           BACangdistarr(s) = 0.0
           ACCangdistarr(s) = 0.0
           CCCangdistarr(s) = 0.0

        END DO

        IF(flagrdf == 1) THEN 
           DO s = 1,rdfbinmax
              
              rdfAB(s) = 0.0
              rdfBC(s) = 0.0
              rdfAC(s) = 0.0
              
           END DO

           PRINT *, "RDF binsize : ", rdfbinlen

        END IF
        
     END IF

        
     READ(ipfn,*)
     
     DO j = 1,natoms
        
        READ(ipfn,*) u, ua_attyp(u), x_lmp(u), y_lmp(u), z_lmp(u)
        
     END DO

     IF((file_inc==1 .OR. mod(file_inc,50) == 0) .AND. flagref == 1)&
          & THEN
     
        WRITE(reffn,'(A14)') "ITEM: TIMESTEP"
        WRITE(reffn,'(I0)') file_inc
        WRITE(reffn,'(A21)') "ITEM: NUMBER OF ATOMS"
        WRITE(reffn,'(I0)') N*M
        WRITE(reffn,'(A25)') "ITEM: BOX BOUNDS pp pp pp"
        WRITE(reffn,*) xlo, xhi
        WRITE(reffn,*) ylo, yhi
        WRITE(reffn,*) zlo, zhi
        WRITE(reffn,'(A28)') "ITEM: ATOMS id type xu yu zu"
        DO i = 1,N
           
           DO j = 1,M
           
              k = j + (i-1)*M
              WRITE(reffn,'(I6,1X,I2,1X,3(F14.8,1X))') k,ua_attyp(k)&
                   &,x_lmp(k),y_lmp(k),z_lmp(k)
              
           END DO
           
        END DO
        
     END IF
             
     CALL COARSEGRAIN(file_inc)
     CALL BONDANGLE(file_inc)
     IF(flagrdf == 1) CALL CGRDF(file_inc)

  END DO
  
END SUBROUTINE READFILES

!--------------------------------------------------------------------

SUBROUTINE COARSEGRAIN(fileval)

  USE CG_PARAMFILE

  IMPLICIT NONE
    
  INTEGER,INTENT(IN) :: fileval
  INTEGER :: i,j,k,ierr,cgpos,molid,ncgcnt,flag
  REAL :: benzx, benzy, benzz, mB, mP,masstot

!flag = 1 => found CG atom of type 3,4 or 5
!flag = 2 => found CG atom of type 1 or 2
!flag = 0 => could not find a match for CG atom
  mB = masses(1) + 5*masses(2) + masses(3)
  mP = 2*masses(6) + masses(9)

  masstot = N*(benpercg*(mB + masses(4)) + oxypercg*mP + 2*masses(5)) 
  density = masstot/(volbox*denconv)

  IF(fileval == 1) PRINT *, "Mass of A type", masses(4)
  IF(fileval == 1) PRINT *, "Mass of B type", mB
  IF(fileval == 1) PRINT *, "Mass of C type", mP
  IF(fileval == 1) PRINT *, "Mass of End type", masses(5)

!  IF(fileval == 1 .OR. mod(fileval,10) == 0) PRINT *, "Density:",&
!       & density

  cgxpos = 0.0; cgypos = 0.0; cgzpos = 0.0
  ncgcnt = 0

  DO i = 1,natoms

     molid = molarray(i)
     flag  = 0

     IF(atype(i) == 1 .OR. atype(i) == 2 .OR. atype(i) == 3 &
          & .OR. atype(i) == 7) THEN
       !found atype of ring atom or oxygen
        
        flag = 2

     END IF

! Find atom position
     DO j = 1,atpercg
        
        IF(cgmap(molid,j) == i) THEN
              
           ncgcnt = ncgcnt + 1
           flag   = 1
           cgpos  = j

        END IF

     END DO

!!$     IF(flag == 0) THEN !did not find any atom
!!$
!!$        PRINT *, "CG Atom not found"
!!$        PRINT *, i,molid,cgmap(molid,:)
!!$        STOP
!!$        
!!$     END IF

! CG according to type (flag == 1)
     IF(flag == 1) THEN

        IF(atype(i) == 3) THEN
           
           IF(mod(cgpos,2) /= 0) THEN
              
              PRINT *, "Something wrong in CG-MAP"
              PRINT *, molid, cgpos,i,atype(i)
              STOP
              
           END IF
           
           benzx = x_lmp(i)*masses(3) + x_lmp(i-6)*masses(1)
           benzy = y_lmp(i)*masses(3) + y_lmp(i-6)*masses(1)
           benzz = z_lmp(i)*masses(3) + z_lmp(i-6)*masses(1)
           
           DO k = i-5,i-1
              
              IF(atype(k) /= 2) STOP "Logic failed - Incorrect order!"
              
              benzx = benzx + masses(2)*x_lmp(k)
              benzy = benzy + masses(2)*y_lmp(k)
              benzz = benzz + masses(2)*z_lmp(k)
              
           END DO
           
           benzx = benzx/mB; benzy = benzy/mB; benzz = benzz/mB
           
           cgxpos(molid, cgpos) = benzx
           cgypos(molid, cgpos) = benzy
           cgzpos(molid, cgpos) = benzz
           
           
        ELSEIF(atype(i) == 4 .OR. atype(i) == 5 .OR. atype(i) == 8)&
             & THEN
           
           cgxpos(molid,cgpos) = x_lmp(i)
           cgypos(molid,cgpos) = y_lmp(i)
           cgzpos(molid,cgpos) = z_lmp(i)
           
!!$           IF(mod(cgpos,2) == 0) THEN
!!$              
!!$              PRINT *, "Something wrong in CG-MAP"
!!$              PRINT *, molid, cgpos,i,atype(i)
!!$              
!!$           END IF

        ELSEIF(atype(i) == 6) THEN

           cgxpos(molid,cgpos) = masses(6)*(x_lmp(i) + x_lmp(i-1)) +&
                & masses(9)*x_lmp(i+1)
           cgypos(molid,cgpos) = masses(6)*(y_lmp(i) + y_lmp(i-1)) +&
                & masses(9)*y_lmp(i+1)
           cgzpos(molid,cgpos) = masses(6)*(z_lmp(i) + z_lmp(i-1)) +&
                & masses(9)*z_lmp(i+1)

           cgxpos(molid,cgpos) = cgxpos(molid,cgpos)/mP
           cgypos(molid,cgpos) = cgypos(molid,cgpos)/mP
           cgzpos(molid,cgpos) = cgzpos(molid,cgpos)/mP

        END IF

     END IF

  END DO

  IF(ncgcnt /= nuaatoms) THEN

     PRINT *, "Warning: Not everything is mapped in ", fileval
     PRINT *, "Mapped/Actual", ncgcnt, nuaatoms
     STOP

  END IF
  
  IF(mod(fileval,50) == 0 .OR. fileval == 1) THEN

     PRINT *, "Writing CG information for iter: ", fileval
     
     WRITE(cgfn,*) nuaatoms
     WRITE(cgfn,*) "Coarse Grained Configuration"
     
     DO i = 1,N
        
        DO j = 1,atpercg
           
           WRITE(cgfn,'(A1,1X,3(F14.8,1X))') "C",cgxpos(i,j),&
                & cgypos(i,j),cgzpos(i,j)
           
        END DO
        
     END DO

  END IF
        

END SUBROUTINE COARSEGRAIN

!--------------------------------------------------------------------

SUBROUTINE BONDANGLE(frnum)

  USE CG_PARAMFILE

  IMPLICIT NONE
  
  INTEGER :: i,j,k,ierror
  INTEGER, INTENT(IN) :: frnum
  REAL    :: bondl,bondl2,angval
  REAL    :: rxx, ryy, rzz, r2xx, r2yy, r2zz
  REAL    :: end2end
  INTEGER :: bondbin,angbin,anglecnt,bondbin2
  INTEGER :: nABcgbonds,nAAcgbonds, nCCcgbonds, nACcgbonds
  INTEGER :: ncgBABangls, ncgBACangls, ncgACCangls, ncgCCCangls
  REAL, PARAMETER :: rad2deg = 180.0/pival

  INTEGER*8,DIMENSION(bonbinmax) :: dumABbondistarr
  INTEGER*8,DIMENSION(bonbinmax) :: dumAAbondistarr
  INTEGER*8,DIMENSION(bonbinmax) :: dumCCbondistarr
  INTEGER*8,DIMENSION(bonbinmax) :: dumACbondistarr

  INTEGER*8,DIMENSION(angbinmax) :: dumBABangdistarr
  INTEGER*8,DIMENSION(angbinmax) :: dumBACangdistarr
  INTEGER*8,DIMENSION(angbinmax) :: dumACCangdistarr
  INTEGER*8,DIMENSION(angbinmax) :: dumCCCangdistarr

  nABcgbonds = N*2*benpercg
  nAAcgbonds = N*benpercg
  nCCcgbonds = N*(oxypercg-1)
  nACcgbonds = N
  
  ncgBABangls = N*(benpercg-2) !One BAB angle per dimer
  ncgBACangls = N
  ncgACCangls = N
  ncgCCCangls = N*(oxypercg-2)
  
  anglecnt = 0
  
  DO i = 1,bonbinmax
     
     dumABbondistarr(i) = 0
     dumAAbondistarr(i) = 0
     dumCCbondistarr(i) = 0
     dumACbondistarr(i) = 0

  END DO

  DO i = 1,angbinmax

     dumBABangdistarr(i) = 0
     dumBACangdistarr(i) = 0
     dumACCangdistarr(i) = 0
     dumCCCangdistarr(i) = 0

  END DO
  
  IF(frnum == 1) PRINT *, "Finding Bond/Angle distributions ... "

! Bond Distributions  
  DO i = 1,N
     
     DO j = 1,atpercg-1
        
        rxx = cgxpos(i,j+1) - cgxpos(i,j)
        ryy = cgypos(i,j+1) - cgypos(i,j)
        rzz = cgzpos(i,j+1) - cgzpos(i,j) 
        
        bondl   = rxx**2 + ryy**2 + rzz**2
        bondl   = sqrt(bondl)
  
        IF(bondl > maxblen) THEN
           PRINT *, "Error at chain: ",i,"monomers: ",j,j+1
           PRINT *, "Bondlength/Max allowed:",bondl,maxblen
           STOP "Very Large Bonds/Unnatural box stretch"
        END IF
      
        bondbin = 1+INT(bondl/bbinlen)

        IF(cgtype(i,j) == 1 .AND. cgtype(i,j+1) == 2) THEN

           IF(bondbin < bonbinmax) THEN
           
              dumABbondistarr(bondbin) = dumABbondistarr(bondbin) + 1
              
           END IF

           IF(cgtype(i,j+2) == 1) THEN

              r2xx = cgxpos(i,j+2) - cgxpos(i,j)
              r2yy = cgypos(i,j+2) - cgypos(i,j)
              r2zz = cgzpos(i,j+2) - cgzpos(i,j) 
              
              bondl2  = r2xx**2 + r2yy**2 + r2zz**2
              bondl2  = sqrt(bondl2)
              
              bondbin2 = 1+INT(bondl2/bbinlen)

              IF(bondbin2 < bonbinmax) THEN
           
                 dumAAbondistarr(bondbin2)=dumAAbondistarr(bondbin2)+1
                 
              END IF

           ELSEIF(cgtype(i,j+2) .NE. 3) THEN

              PRINT *, "WARNING : SOMETHING WRONG WITH END OF BLOCK"
              PRINT *, i, j, cgtype(i,j), cgtype(i,j+1), cgtype(i,j+2)
              
           END IF
              
        ELSEIF(cgtype(i,j) == 2 .AND. cgtype(i,j+1) == 1) THEN

           IF(bondbin < bonbinmax) THEN
           
              dumABbondistarr(bondbin) = dumABbondistarr(bondbin) + 1
              
           END IF


        ELSEIF(cgtype(i,j) == 1 .AND. cgtype(i,j+1) == 3) THEN
  
           IF(bondbin < bonbinmax) THEN
           
              dumACbondistarr(bondbin) = dumACbondistarr(bondbin) + 1
              
           END IF

        ELSEIF(cgtype(i,j) == 3 .AND. cgtype(i,j+1) == 3) THEN

           IF(bondbin < bonbinmax) THEN
           
              dumCCbondistarr(bondbin) = dumCCbondistarr(bondbin) + 1
              
           END IF

        ELSE
           
           PRINT *, "Unknown connection "
           PRINT *, i, j, j+1, cgtype(i,j), cgtype(i,j+1)

        END IF

        IF(frnum == 1 .OR. mod(frnum,50) == 0) THEN

           IF(i == 1 .and. j == 1) WRITE(opbfn,*) "File Number :",&
                & frnum
           WRITE(opbfn,'(I4,1X,2(I3,1X),7(F14.8))') i,cgtype(i,j)&
                &,cgtype(i,j+1),cgxpos(i,j),cgypos(i,j),cgzpos(i,j),&
                & rxx,ryy,rzz,bondl

        END IF

     END DO

     rxx = cgxpos(i,atpercg) - cgxpos(i,1)
     ryy = cgypos(i,atpercg) - cgypos(i,1)
     rzz = cgzpos(i,atpercg) - cgzpos(i,1) 
     
     end2end = rxx**2 + ryy**2 + rzz**2
     
     WRITE(opefn,*) i, sqrt(end2end)
 
  END DO

! Angle distributions

  DO i = 1, N

     DO j = 1,atpercg-2

        rxx = cgxpos(i,j+1) - cgxpos(i,j)
        ryy = cgypos(i,j+1) - cgypos(i,j)
        rzz = cgzpos(i,j+1) - cgzpos(i,j) 
        
        bondl   = rxx**2 + ryy**2 + rzz**2
        bondl   = sqrt(bondl)

        r2xx = cgxpos(i,j+2) - cgxpos(i,j+1)
        r2yy = cgypos(i,j+2) - cgypos(i,j+1)
        r2zz = cgzpos(i,j+2) - cgzpos(i,j+1) 
        
        bondl2  = r2xx**2 + r2yy**2 + r2zz**2
        bondl2  = sqrt(bondl2)

        angval  = (-1.0)*(rxx*r2xx + ryy*r2yy + rzz*r2zz)
        angval  = acos(angval/(REAL(bondl*bondl2)))
        
        angbin  = 1 + INT(angval/angbinlen)
      
        IF(cgtype(i,j) == 2 .AND. cgtype(i,j+2) == 2) THEN

           IF(angbin .LE. angbinmax) THEN
              
              dumBABangdistarr(angbin) = dumBABangdistarr(angbin) + 1
              
           END IF
           
        ELSEIF(cgtype(i,j) == 2 .AND. cgtype(i,j+2) == 3) THEN

           IF(angbin .LE. angbinmax) THEN
              
              dumBACangdistarr(angbin) = dumBACangdistarr(angbin) + 1
              
           END IF

        ELSEIF(cgtype(i,j) == 1 .AND. cgtype(i,j+2) == 3) THEN

           IF(angbin .LE. angbinmax) THEN
              
              dumACCangdistarr(angbin) = dumACCangdistarr(angbin) + 1
              
           END IF
              
        ELSEIF(cgtype(i,j) == 3 .AND. cgtype(i,j+2) == 3) THEN

           IF(angbin .LE. angbinmax) THEN
              
              dumCCCangdistarr(angbin) = dumCCCangdistarr(angbin) + 1
              
           END IF

        END IF
        
        IF(frnum == 1 .OR. mod(frnum,50) == 0) THEN
           
           IF(i == 1 .and. j == 1) WRITE(opafn,*) "File Number :",&
                & frnum
           WRITE(opafn,*) i,cgtype(i,j),cgtype(i,j+1),cgtype(i,j+2)&
                &,rad2deg*angval
           
        END IF
        
     END DO
     
  END DO
  
  DO i = 1,bonbinmax
     
     ABbondistarr(i) = ABbondistarr(i) + REAL(dumABbondistarr(i))&
          &/REAL(nABcgbonds)

     AAbondistarr(i) = AAbondistarr(i) + REAL(dumAAbondistarr(i))&
          &/REAL(nAAcgbonds)

     ACbondistarr(i) = ACbondistarr(i) + REAL(dumACbondistarr(i))&
          &/REAL(nACcgbonds)

     CCbondistarr(i) = CCbondistarr(i) + REAL(dumCCbondistarr(i))&
          &/REAL(nCCcgbonds)

  END DO

  DO i = 1,angbinmax

     BABangdistarr(i) = BABangdistarr(i) + REAL(dumBABangdistarr(i))&
          &/REAL(ncgBABangls)

     BACangdistarr(i) = BACangdistarr(i) + REAL(dumBACangdistarr(i))&
          &/REAL(ncgBACangls)

     ACCangdistarr(i) = ACCangdistarr(i) + REAL(dumACCangdistarr(i))&
          &/REAL(ncgACCangls)

     CCCangdistarr(i) = CCCangdistarr(i) + REAL(dumCCCangdistarr(i))&
          &/REAL(ncgCCCangls)

  END DO

END SUBROUTINE BONDANGLE

!--------------------------------------------------------------------

SUBROUTINE CGRDF(frnum)

  USE CG_PARAMFILE

  IMPLICIT NONE
  
  INTEGER :: i,i1,j,k,rdfbin
  INTEGER, INTENT(IN) :: frnum
  REAL :: dist,rxx,ryy,rzz
  REAL*8, DIMENSION(rdfbinmax) :: dumrAB, dumrBC, dumrAC
  INTEGER :: nABpairs, nACpairs, nBCpairs
  INTEGER :: abcnt, accnt, bccnt

  nABpairs = N*N*benpercg*(benpercg+1)
  nACpairs = N*N*(benpercg+1)*oxypercg
  nBCpairs = N*N*benpercg*oxypercg

  dumrAB = 0.0; dumrBC = 0.0; dumrAC = 0.0
  abcnt = 0; accnt = 0; bccnt = 0

  IF(frnum == 1 .OR. mod(frnum,50) == 0) PRINT *, "Calculating RDF for&
       &", frnum

  DO i = 1, N

     DO j = 1, atpercg !benpercg would work

        DO i1 = 1,N
        
           DO k = 1, atpercg

              IF(i == i1 .AND. j == k) CYCLE

              IF(cgtype(i,j) == 1 .AND. cgtype(i1,k) == 2) THEN

                 rxx = cgxpos(i,j) - cgxpos(i1,k)
                 ryy = cgypos(i,j) - cgypos(i1,k)
                 rzz = cgzpos(i,j) - cgzpos(i1,k) 
                 
                 rxx = rxx - box_lx*ANINT(rxx/box_lx)
                 ryy = ryy - box_ly*ANINT(ryy/box_ly)
                 rzz = rzz - box_lz*ANINT(rzz/box_lz)

                 dist = rxx**2 + ryy**2 + rzz**2
                 dist = sqrt(dist)

                 rdfbin = 1+INT(dist/rdfbinlen)

                 IF(rdfbin < rdfbinmax) THEN
                 
                    dumrAB(rdfbin) = dumrAB(rdfbin) + 1

                 END IF

                 abcnt = abcnt + 1
                 
                     
              ELSEIF(cgtype(i,j) == 1 .AND. cgtype(i1,k) == 3) THEN

                 rxx = cgxpos(i,j) - cgxpos(i1,k)
                 ryy = cgypos(i,j) - cgypos(i1,k)
                 rzz = cgzpos(i,j) - cgzpos(i1,k) 
                 
                 rxx = rxx - box_lx*ANINT(rxx/box_lx)
                 ryy = ryy - box_ly*ANINT(ryy/box_ly)
                 rzz = rzz - box_lz*ANINT(rzz/box_lz)

                 dist = rxx**2 + ryy**2 + rzz**2
                 dist = sqrt(dist)
                 
                 rdfbin = 1+INT(dist/rdfbinlen)
                 
                 IF(rdfbin < rdfbinmax) THEN
                    
                    dumrAC(rdfbin) = dumrAC(rdfbin) + 1
                    
                 END IF
                 accnt = accnt + 1
                 
              ELSEIF(cgtype(i,j) == 2 .AND. cgtype(i1,k) == 3) THEN
              
                 rxx = cgxpos(i,j) - cgxpos(i1,k)
                 ryy = cgypos(i,j) - cgypos(i1,k)
                 rzz = cgzpos(i,j) - cgzpos(i1,k) 

                 rxx = rxx - box_lx*ANINT(rxx/box_lx)
                 ryy = ryy - box_ly*ANINT(ryy/box_ly)
                 rzz = rzz - box_lz*ANINT(rzz/box_lz)
                 
                 dist = rxx**2 + ryy**2 + rzz**2
                 dist = sqrt(dist)
                 
                 rdfbin = 1+INT(dist/rdfbinlen)
                 
                 IF(rdfbin < rdfbinmax) THEN
                    
                    dumrBC(rdfbin) = dumrBC(rdfbin) + 1
                    
                 END IF
                 bccnt = bccnt + 1
              
              END IF

           END DO
           
        END DO

     END DO

  END DO

  IF(abcnt .NE. nABpairs) STOP "ABCNT NOT EQUAL"
  IF(accnt .NE. nACpairs) STOP "ACCNT NOT EQUAL"
  IF(bccnt .NE. nBCpairs) STOP "BCCNT NOT EQUAL"


  DO i = 1,rdfbinmax

     rdfAB(i) = rdfAB(i) + REAL(dumrAB(i)*volbox)/REAL(nABpairs)
     rdfAC(i) = rdfAC(i) + REAL(dumrAC(i)*volbox)/REAL(nACpairs)
     rdfBC(i) = rdfBC(i) + REAL(dumrBC(i)*volbox)/REAL(nBCpairs)

  END DO

  IF(frnum == 50) THEN
     OPEN(unit = 4,file = "rdfcheck.txt",action="write",status="replac&
          &e")
  
     DO i = 1,rdfbinmax

        dist = 0.5*(2.0*REAL(i)-1.0)*rdfbinlen
        WRITE(4,'(4(F14.8,1X))') dist, dumrAB(i), dumrAC(i), dumrBC(i)

     END DO
     CLOSE(4)

  END IF


END SUBROUTINE CGRDF

!--------------------------------------------------------------------

SUBROUTINE BONDOUTDIST()

  USE CG_PARAMFILE

  IMPLICIT NONE

  INTEGER :: i,ierror
  REAL    :: xval,finbonddist,finangldist
  INTEGER :: ncgbonds,ncgangls
  REAL :: norm,ri,rip1,area
  REAL, PARAMETER :: const = 4.0*pival/3
  REAL, PARAMETER :: rad2deg = 180.0/pival

  PRINT *, "Writing Bonds into final file format .."

  DO i = 1, bonbinmax
     
     ri = REAL(i-1)*bbinlen
     rip1 = ri+bbinlen
     norm = const*(rip1**3 - ri**3)

     finbonddist = abbondistarr(i)/(REAL(nframes)*norm)
     WRITE(opbdABfn,*) 0.5*(2.0*REAL(i)-1.0)*bbinlen,finbonddist

     finbonddist = aabondistarr(i)/(REAL(nframes)*norm)
     WRITE(opbdAAfn,*) 0.5*(2.0*REAL(i)-1.0)*bbinlen,finbonddist     

     finbonddist = acbondistarr(i)/(REAL(nframes)*norm)
     WRITE(opbdACfn,*) 0.5*(2.0*REAL(i)-1.0)*bbinlen,finbonddist

     finbonddist = ccbondistarr(i)/(REAL(nframes)*norm)
     WRITE(opbdCCfn,*) 0.5*(2.0*REAL(i)-1.0)*bbinlen,finbonddist     

  END DO
 
  PRINT *, "Writing Angles into final file format .."
  
  DO i = 1, angbinmax

     finangldist = BABangdistarr(i)/(REAL(nframes)*angbinlen)
     WRITE(opadBABfn,*) 0.5*(2.0*REAL(i)-1.0)*angbinlen*rad2deg&
          &,finangldist

     finangldist = BACangdistarr(i)/(REAL(nframes)*angbinlen)
     WRITE(opadBACfn,*) 0.5*(2.0*REAL(i)-1.0)*angbinlen*rad2deg&
          &,finangldist

     finangldist = ACCangdistarr(i)/(REAL(nframes)*angbinlen)
     WRITE(opadACCfn,*) 0.5*(2.0*REAL(i)-1.0)*angbinlen*rad2deg&
          &,finangldist

     finangldist = CCCangdistarr(i)/(REAL(nframes)*angbinlen)
     WRITE(opadCCCfn,*) 0.5*(2.0*REAL(i)-1.0)*angbinlen*rad2deg&
          &,finangldist
     
  END DO

END SUBROUTINE BONDOUTDIST

!--------------------------------------------------------------------

SUBROUTINE RDFOUTDIST()

  USE CG_PARAMFILE

  IMPLICIT NONE
  

  INTEGER :: i,ierror
  REAL    :: xval,rdfABval, rdfACval, rdfBCval
  REAL    :: norm,ri,rip1
  REAL, PARAMETER :: const = 4.0*pival/3

  PRINT *, "Writing RDF into final file format .."

  DO i = 1, rdfbinmax
     
     ri = REAL(i-1)*rdfbinlen
     rip1 = ri+rdfbinlen
     norm = const*(rip1**3 - ri**3)

     rdfABval = rdfAB(i)/(REAL(nframes)*norm)
     rdfACval = rdfAC(i)/(REAL(nframes)*norm)
     rdfBCval = rdfBC(i)/(REAL(nframes)*norm)

     WRITE(oprdffn,'(4(F16.9,1X))') 0.5*(2.0*REAL(i)-1.0)*rdfbinlen,&
          & rdfABval, rdfACval, rdfBCval

  END DO


END SUBROUTINE RDFOUTDIST

!--------------------------------------------------------------------

!!$SUBROUTINE STRUCTFAC()
!!$
!!$  USE PARAMS
!!$  USE RAN_NUMBERS
!!$  
!!$  IMPLICIT NONE
!!$
!!$  REAL, PARAMETER :: pi_const = 3.14159265
!!$  REAL :: modq
!!$  COMPLEX, PARAMETER :: z = (0.0,1.0)
!!$  COMPLEX :: sum_sf
!!$  REAL, PARAMETER :: wave_pref = real(2.0)*pi_const/real(boxl)
!!$  REAL :: totinv = real(1.0)/(totpart)
!!$  INTEGER :: i,j,k,nx,ny,nz
!!$
!!$!$OMP PARALLEL DO PRIVATE(sum_sf,i,j,k,nx,ny,nz)
!!$  DO nz = 0,qlen-1
!!$     
!!$     DO ny = 0,qlen-1
!!$        
!!$        DO nx = 0,qlen-1
!!$
!!$           sum_sf = (0.0,0.0)
!!$
!!$           DO i = 1,N
!!$              
!!$              DO j = 1,atpercg
!!$
!!$                 IF(cgtype(i,j) == 1 .AND. cgtype(i1,k) == 2) THEN
!!$                    sum_sf = sum_sf + (1-2*seq(j))*(exp(-z*wave_pref&
!!$                         &*(nx*rxyz(i,k+1) + ny*rxyz(i,k+2) + nz&
!!$                         &*rxyz(i,k+3))))
!!$
!!$              END DO
!!$
!!$           END DO
!!$
!!$           Sfac(nx,ny,nz) = real(totinv)*abs(sum_sf)*abs(sum_sf)
!!$      
!!$        END DO
!!$
!!$     END DO
!!$
!!$  END DO
!!$!$OMP END PARALLEL DO
!!$!$OMP FLUSH(Sfac)
!!$
!!$END SUBROUTINE STRUCTFAC
!!$
!!$!---------------------------------------------------------------------------------------------
!!$
!!$SUBROUTINE STRUCTOUT()
!!$ 
!!$  USE PARAMS
!!$  USE RAN_NUMBERS
!!$
!!$  IMPLICIT NONE
!!$
!!$  INTEGER i,j,k,ierror
!!$  REAL, PARAMETER :: pi_const = 3.14159265
!!$  REAL, PARAMETER :: wave_pref = real(2.0)*pi_const/real(boxl)
!!$  REAL :: modq_sq
!!$  CHARACTER*15 :: strfile
!!$  CHARACTER*1  :: fnum
!!$
!!$
!!$  WRITE(fnum,"(I1)") corddum
!!$  
!!$  strfile = "struct_"//fnum//".txt"
!!$  strfile = trim(strfile)
!!$
!!$  OPEN (unit=22, file=strfile, status="replace", action =&
!!$       &"write",iostat=ierror)
!!$
!!$
!!$  IF (ierror /= 0) THEN
!!$
!!$     PRINT*, "Failed to open struct.txt"
!!$     
!!$  ELSE
!!$     
!!$     DO i = 0,qlen-1
!!$
!!$        DO j = 0,qlen-1
!!$           
!!$           DO k = 0,qlen-1
!!$              
!!$              modq_sq = (wave_pref**2)*(i**2 + j**2 + k**2)
!!$              
!!$              WRITE (22,*) (i**2+j**2+k**2), modq_sq, Sfac_avg(i,j,k)/nmax
!!$              
!!$           END DO
!!$           
!!$        END DO
!!$        
!!$     END DO
!!$
!!$  END IF
!!$
!!$  CLOSE (unit = 22)
!!$
!!$END SUBROUTINE STRUCTOUT
!!$
!!$!-----------------------------------------------------------------------------------------------
