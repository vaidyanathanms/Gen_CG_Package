!-------Basic set of parameters. Can be used with any program --------
!-------Version: Jan-18-2019 -----------------------------------------
!---------------------------------------------------------------------

MODULE PARAMETERS_BASIC

  USE OMP_LIB
  IMPLICIT NONE

  ! Required Input Variables

  INTEGER :: nframes, skipfr, freqfr, nfrcntr
  INTEGER :: nproc

  !Math Constants

  REAL*8, PARAMETER :: pival  = 3.14159265359
  REAL*8, PARAMETER :: pi2val = 2.0*pival

  ! File names and unit Numbers
  
  CHARACTER(LEN = 256) :: ana_fname,data_fname,traj_fname,log_fname
  CHARACTER(LEN = 256) :: dum_fname,out_fname
  INTEGER, PARAMETER :: anaread = 2,   logout = 3, trajread = 15
  INTEGER, PARAMETER :: inpread = 100, dumwrite = 200,outwrite=150


  !Global analysis variables and flags

  INTEGER :: atomflag, velflag, bondflag, anglflag, dihdflag,imprflag
  INTEGER :: ntotatoms, ntotbonds, ntotangls,ntotdihds,ntotimprs
  INTEGER :: ntotatomtypes,ntotbondtypes,ntotangltypes,ntotdihdtypes&
       &,ntotimprtypes

  !LAMMPS trajectory file read details

  REAL :: box_xl,box_yl,box_zl, boxval
  INTEGER*8 :: timestep

  !LAMMPS Global Arrays

  REAL*8, ALLOCATABLE, DIMENSION(:,:) :: rxyz_lmp, vel_xyz, charge_lmp&
       &,masses
  INTEGER, ALLOCATABLE, DIMENSION(:,:) :: bond_lmp, angl_lmp,&
       & dihd_lmp, impr_lmp,aidvals
  CHARACTER,ALLOCATABLE,DIMENSION(:,:) :: keywords
  REAL,ALLOCATABLE,DIMENSION(:):: boxx_arr, boxy_arr,boxz_arr


END MODULE PARAMETERS_BASIC
