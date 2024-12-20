PROGRAM leapfrog

  USE geometry
  USE particle
  USE ISO_FORTRAN_ENV

  IMPLICIT NONE
  INTEGER :: i,j                                    !counters
  INTEGER :: n                                      !Number of particles
  REAL(REAL64) :: dt, t_end, dt_out, t, t_out       !Control params
  TYPE(particle3d), DIMENSION(:), ALLOCATABLE :: pt   !Particles
  TYPE(vector3d), DIMENSION(:), ALLOCATABLE :: a    !Accelerations
  TYPE(vector3d) :: r                               
  
  character(len=25) :: input, output, orbit
  
  input = "initial_conditions.dat"
  output = "output.dat"
  orbit = "orbit.dat"
  
  OPEN (1,file = input, status = 'old', action = 'read')

  READ(1,*) dt
  READ(1,*) dt_out
  READ(1,*) t_end
  READ(1,*) n
  
  ! Show the reading values in screen
  WRITE(*,'(A,3F12.4)') "Value of dt =" ,dt
  WRITE(*,'(A,3F12.4)') "Value of dt_out =", dt_out
  WRITE(*,'(A,3F12.4)') "Value of t_end =", t_end
  WRITE(*,'(A,I3)') "Value of n =", n
  
  ! Create the particles and acceleration
  ALLOCATE(pt(n))
  ALLOCATE(a(n))
  
  ! Read the particles
  DO i = 1, n
    READ(1,*) pt(i)
    WRITE(*,'(A,I3,A)') "Particle number ", i,": format x,y,z, vx, vy,vz, m"
    WRITE(*,'(3F12.6)') pt(i)
  END DO
  CLOSE(1)
  
  ! Initial calculation of acceleration
  CALL calc_acc
  
  
  
  OPEN(2, file = output, status = 'replace', action = 'write')
  OPEN(3, file = orbit, status = 'replace', action = 'write')
  ! Init output parameters
  t = 0.0
  t_out = 0.0
  DO 
    ! In each cyclo, increase the output parameters
    t = t + dt
    t_out = t_out + dt
    ! Calculate the new position and velocities
    pt%v = pt%v + a * (dt/2)
    pt%p = pt%p + pt%v * dt
    ! Calculate the new aceleration
    CALL calc_acc
    ! Update the velocity with the new acceleration
    pt%v = pt%v + a * (dt/2)
    ! Condicion for save the position
    IF (t_out >= dt_out) THEN
      write (3, '(3F12.4)', advance='no') t
      DO i = 1,n
        IF(i<n) THEN
          write (2, '(3F12.4)', advance='no') t
          write (2, '(I3)', advance='no') i
          write (2, '(3F12.6)', advance='no') pt(i)%p
          write (2, '(3F12.6)', advance='no') pt(i)%v
          write (2, '(3F12.6)') pt(i)%m
          write (3, '(3F12.6)', advance='no') pt(i)%p
        ELSE
          write (2, '(3F12.4)', advance='no') t
          write (2, '(I3)', advance='no') i
          write (2, '(3F12.6)', advance='no') pt(i)%p
          write (2, '(3F12.6)', advance='no') pt(i)%v
          write (2, '(3F12.6)') pt(i)%m
          write (3, '(3F12.6)') pt(i)%p
        END IF
      END DO
      t_out = 0.0 ! reset of output parameter 
    END IF
    ! Exit conditions
    IF (t>= t_end) THEN
      EXIT
    END IF
  END DO
 
CONTAINS
! Subroutine to calculate acelerations 
 SUBROUTINE calc_acc
 ! Init acceleration
  a = vector3d(0,0,0)
  DO i = 1,n
    DO j = i+1,n ! j > i to avoid duplications
      r = pt(i)%p - pt(j)%p  ! We need the vector thar separate the particla i and j
      a(i) = a(i) + (pt(j)%m *r)/ distance(pt(i)%p,pt(j)%p)**3 !accel of particle i due to j
      a(j) = a(j) - (pt(i)%m *r)/ distance(pt(i)%p,pt(j)%p)**3 !accel of particle j due to i
    END DO
  END DO
 END SUBROUTINE calc_acc

END PROGRAM leapfrog