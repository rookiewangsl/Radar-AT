MODULE bellhopMod

  USE MathConstantsMod
  INTEGER, PARAMETER :: PRTFile = 6, MaxN = 100000

  ! Reduce MaxN (= max # of steps along a ray) to reduce storage
  ! Note space is wasted in NumTopBnc, NumBotBnc ...

  INTEGER            :: Nrz_per_range, iStep
  REAL    ( KIND= 8) :: freq, omega
  CHARACTER (LEN=80) :: Title

  ! *** Halfspace properties structure ***

  TYPE HSInfo
     REAL     (KIND=8) :: alphaR, alphaI, betaR, betaI  ! compressional and shear wave speeds/attenuations in user units
     COMPLEX  (KIND=8) :: cP, cS                 ! P-wave, S-wave speeds
     REAL     (KIND=8) :: rho, Depth             ! density, depth
     REAL     (KIND=8) :: BumpDensity, eta, xi   ! Twersky boss parameters
     CHARACTER (LEN=1) :: BC                     ! Boundary condition type
     CHARACTER (LEN=6) :: Opt
  END TYPE HSInfo

  TYPE BdryPt
     TYPE( HSInfo )   :: HS
  END TYPE

  TYPE BdryType
     TYPE( BdryPt )   :: Top, Bot
  END TYPE BdryType

  TYPE(BdryType) :: Bdry

  ! *** Beam structure ***

  TYPE rxyz
     REAL (KIND=8) :: r, x, y, z
  END TYPE rxyz

  TYPE BeamStructure
     INTEGER           :: NBeams, Nimage, Nsteps, iBeamWindow
     REAL     (KIND=8) :: deltas, epsMultiplier = 1, rLoop
     CHARACTER (LEN=1) :: Component              ! Pressure or displacement
     CHARACTER (LEN=4) :: Type = 'G S '
     CHARACTER (LEN=7) :: RunType
     TYPE( rxyz )      :: Box
  END TYPE BeamStructure

  TYPE( BeamStructure ) :: Beam

  ! *** ray structure ***

  TYPE ray2DPt
     INTEGER          :: NumTopBnc, NumBotBnc
     REAL   (KIND=8 ) :: x( 2 ), t( 2 ), p( 2 ), q( 2 ), c, Amp, Phase
     COMPLEX (KIND=8) :: tau
  END TYPE ray2DPt
  TYPE( ray2DPt )     :: ray2D( MaxN )

  ! uncomment COMPLEX below if using Cerveny beams !!!
  TYPE ray3DPt
     REAL    (KIND=8) :: p_tilde( 2 ), q_tilde( 2 ), p_hat( 2 ), q_hat( 2 ), DetQ
     REAL    (KIND=8) :: x( 3 ), t( 3 ), phi, c, Amp, Phase
     INTEGER          :: NumTopBnc, NumBotBnc
     ! COMPLEX (KIND=8) :: p_tilde( 2 ), q_tilde( 2 ), p_hat( 2 ), q_hat( 2 ), f, g, h, DetP, DetQ
     COMPLEX (KIND=8) :: tau

  END TYPE ray3DPt
  TYPE( ray3DPt )      :: ray3D( MaxN )

END MODULE bellhopMod
