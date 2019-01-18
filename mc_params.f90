!----------------- To analyze PS-PEO trajectory ---------------------
!----------------- Module file for cgpspeo.f90 ----------------------

MODULE CG_PARAMFILE

  !Chain Parameters 
  
  INTEGER, PARAMETER :: N = 100!nchains
  INTEGER, PARAMETER :: M = 151!nmons
  INTEGER, PARAMETER :: benpercg = 10 ! benzene rings per molecule
  INTEGER, PARAMETER :: oxypercg = 23
  INTEGER, PARAMETER :: atpercg = 2*benpercg+1 + oxypercg
  INTEGER, PARAMETER :: totpart = N*M
  INTEGER, PARAMETER :: nframes = 200
  INTEGER, PARAMETER :: skip_fr = 10
  INTEGER, PARAMETER :: nuaatoms = atpercg*N
  INTEGER, PARAMETER :: termtype1 = 5, termtype2 = 8,midtype = 7

  INTEGER :: ABanglcnt,CCOCdhdcnt

  ! Math Constants

  REAL*8, PARAMETER :: pival = 3.14159265359

  ! LAMMPS Variables

  REAL    :: box_lx, box_ly, box_lz
  REAL    :: boxxinv,boxyinv,boxzinv
  REAL    :: density, volbox
  INTEGER :: aid_lmp
  REAL, PARAMETER :: denconv = 0.6023

  ! File Variables

  INTEGER, PARAMETER :: ipfn = 5,opfn = 10,seqfn=8
  INTEGER, PARAMETER :: cgfn = 15, reffn=16, mapfn = 20
  INTEGER, PARAMETER :: opbfn = 25, opafn = 30
  INTEGER, PARAMETER :: opefn = 35
  INTEGER, PARAMETER :: opbdAAfn = 90, opbdABfn=91,opbdACfn = 92
  INTEGER, PARAMETER :: opbdCCfn = 93
  INTEGER, PARAMETER :: opadBABfn = 95, opadBACfn = 96,opadACCfn= 97
  INTEGER, PARAMETER :: opadCCCfn = 98
  INTEGER, PARAMETER :: oprdffn = 80

  ! File Flags

  INTEGER, PARAMETER :: flagrdf = 0 !Compute RDF
  INTEGER, PARAMETER :: flagref = 0 !Reference LAMMPS config.

  ! Atom Data

  INTEGER :: natoms,nbonds,nangls,ndihed,nimprp
  INTEGER :: ntypeatom,ntypebond,ntypeangl,ntypedihd,ntypeimpr
 
  ! CG Variables

  INTEGER,PARAMETER :: bonbinmax = 10000
  INTEGER,PARAMETER :: angbinmax = 1000
  INTEGER,PARAMETER :: rdfbinmax = 1000
  REAL*8, PARAMETER :: angbinlen = pival/REAL(angbinmax)

  ! Misc Variables

  REAL :: blen, bbinlen, maxblen, rdfbinlen
  REAL, PARAMETER :: nx = 8, ny = 8, nz = 8

  ! Allocatable Arrays

  REAL*8, ALLOCATABLE, DIMENSION(:)   :: x_lmp, y_lmp, z_lmp
  REAL*8, DIMENSION(N,atpercg)        :: cgxpos, cgypos, cgzpos  
  REAL, ALLOCATABLE, DIMENSION(:)     :: masses
  INTEGER, ALLOCATABLE, DIMENSION(:)  :: atype,molarray
  INTEGER, ALLOCATABLE, DIMENSION(:,:):: bondarray,anglarray
  INTEGER, ALLOCATABLE, DIMENSION(:,:):: cgmap, cgtype
  INTEGER, ALLOCATABLE, DIMENSION(:,:):: ABanglarr
  INTEGER, DIMENSION(N,benpercg)      :: benmolids
  INTEGER, DIMENSION(N,2)             :: termaids
  INTEGER, DIMENSION(N)               :: molptr
 
  ! Distribution arrays

  REAL*8, DIMENSION(bonbinmax)        :: ABbondistarr,AAbondistarr
  REAL*8, DIMENSION(bonbinmax)        :: ACbondistarr,CCbondistarr
  REAL*8, DIMENSION(angbinmax)        :: BABangdistarr,BACangdistarr
  REAL*8, DIMENSION(angbinmax)        :: ACCangdistarr,CCCangdistarr
 
  ! Structure Arrays

  REAL*8, DIMENSION(rdfbinmax) :: rdfAB, rdfBC, rdfAC
  !REAL*8, DIMENSION(0:qlen-1,0:qlen-1,0:qlen-1)  :: Sfac

END MODULE CG_PARAMFILE
