!-----Param file for coarse-graining methylcellulose systems-------
!-----Version: Jan-10-2019-----------------------------------------
!-----Main file: coarsegrain.f90-----------------------------------

MODULE PARAMS_COARSEGRAIN

  USE PARAMETERS_BASIC
  IMPLICIT NONE

  ! Required Input Variables

  INTEGER :: nwater, nchains, atperchain

  ! Coarsegrain Data
  
  INTEGER :: nreq_types

  !Coarse-grain ID details

  INTEGER, PARAMETER :: maxneigh = 4
  INTEGER :: init_ID, init_type, term_ID, term_type
  INTEGER :: conn_type
  INTEGER :: nmonsperchain

  !MC Details

  INTEGER :: deg_sub,natpermon
  
  !Generic mass details

  REAL*8,PARAMETER :: mass_hyd = 1.00794
  REAL*8,PARAMETER :: mass_oxy = 15.999
  REAL*8,PARAMETER :: mass_car = 12.0107
  REAL*8,PARAMETER :: mass_tol = 0.1

  !Neighbor details
  INTEGER, ALLOCATABLE, DIMENSION(:) :: nneighbors
  INTEGER, ALLOCATABLE, DIMENSION(:,:,:) :: cg_mapped_array
  REAL, ALLOCATABLE, DIMENSION(:,:) :: mass_cg

END MODULE PARAMS_COARSEGRAIN

!--------------------------------------------------------------------

!!$ CGMAPPING() - Main subroutine to coarsegrain

!!$ CONFIRM_INIT_TERM_ATOMS() - To check whether the input ID/type of
!!initial and final atoms are consistent

!!$ FIND_NEARBY_BONDED_ATOMS() - To retrieve the neighbor atoms (1-2)
!!of the reference atom (except hydrogen - probably revise later??)

!!$SIEVE_HYDROGENS() - To sieve all hydrogen atoms (probably try to
!!$incorporate in future)

!!$IS_DUPLICATE() - To check for duplicates in a cg_map
