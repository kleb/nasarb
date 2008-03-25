program sample

  implicit none

  real             :: volume, density
  integer          :: parts
  logical          :: furry
  character(len=5) :: color
  character(len=8) :: name

  namelist /object/ volume, density, parts, &
                    furry, color, name

! begin namelist /object/ description

  volume = 1.0

!    type: float
!   units: m^3
! minimum: 0.0
! details: Volume of the object as Archimedes would have measured it,
!          i.e., by the displacement.

  density = 0.1

!    type: float
!   units: kg/m^3
! minimum: 0.0
! maximum: 1.0e+3

  parts = 1

!  prompt: number of parts
!    type: integer
! minimum: 1

  furry = .false.

!    type: boolean

  color = 'black'

!    type: enumerable
! options: [ 'black', 'red', 'blue' ]

  name = ''

! maximum: 8

! end namelist /object/ description

  open(8,file='sample.nml',status='old')
    read(8,nml=object)
  close(8)

end program sample
