program sample

  implicit none

  real             :: volume, density
  integer          :: parts
  logical          :: furry
  character(len=5) :: color
  character(len=8) :: name

  namelist /object/ volume, density, parts, &
                    furry, color, name

! namelist /object/ description

  volume = 1.0

!     type: real
!    units: m^3
!   min-ex: 0.0
!  details: >
!    Volume of the object as Archimedes would have measured it,
!    i.e., by displacement.

  density = 0.1

!    type: real
!   units: kg/m^3
!  min-ex: 0.0
!     max: 1.0e+3

  parts = 1

!  label: number of parts
!   type: integer
!    min: 1

  furry = .false.

!  type: logical

  color = 'black'

!         type: enum
!  enumerators: [ black, red, blue ]

  name = ''

!  type: character
!   max: 8

! end namelist /object/ description

  open(8,file='sample.nml',status='old')
    read(8,nml=object)
  close(8)

end program sample
