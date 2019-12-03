program day3
! Disable some legacy feature about treating certain variables as integers.
implicit none
  ! Define type for steps and points (I want to try various features).
  type Step
    character(1) :: direction = 'R'
    integer :: length = 0
  end type

  ! We have to manually define the ID of the file handle. The parameter keywords
  ! means that this is a constant (modifying will throw a compilation error).
  integer, parameter :: file_unit = 1
  integer, parameter :: X = 1, Y = 2
  character(2048) :: io_buffer
  character(5), dimension(:), allocatable :: parts_buffer
  type(Step), dimension(:), allocatable :: wire1, wire2
  integer, dimension(:, :), allocatable :: c1, c2
  integer :: n, i, j, min_distance, min_time
  integer, dimension(2, 3) :: a, b
  integer, dimension(3) :: p
  logical :: ha, hb

  ! Read input data. Fortran 95 has no high level strings. After some attempts
  ! to make this code more flexible I decided to hardcode the input dimensions.
  open(unit=file_unit, file='input.txt', status='old', action='read')

  ! Read first wire
  read(file_unit, '(A)') io_buffer
  n = count(transfer(io_buffer, 'a', len(io_buffer)) == ',') + 1
  allocate(parts_buffer(n))
  read(io_buffer, *) parts_buffer
  call read_steps(parts_buffer, wire1)
  deallocate(parts_buffer)

  ! Read second wire
  read(file_unit, '(A)') io_buffer
  n = count(transfer(io_buffer, 'a', len(io_buffer)) == ',') + 1
  allocate(parts_buffer(n))
  read(io_buffer, *) parts_buffer
  call read_steps(parts_buffer, wire2)
  deallocate(parts_buffer)

  ! Close file handle
  close(file_unit)

  ! Compute all wire positions.
  call compute_wire(wire1, c1)
  call compute_wire(wire2, c2)

  ! Compute all intersections and remember the closest one (Manhattan).
  min_distance = 1000000
  min_time = 1000000
  do i = 1, size(c1, 1) - 1
    do j = 1, size(c2, 1) - 1
      ! Skip intersection at origin.
      if (i /= 1 .or. j /= 1) then
        ! Determine line segment orientation.
        a(:, :) = c1(i:i+1, :)
        b(:, :) = c2(j:j+1, :)
        ha = (a(1,Y) == a(2,Y))
        hb = (b(1,Y) == b(2,Y))

        ! Compute intersection if one is perpendicular with the other.
        if (ha .and. (.not. hb)) then
          p = intersection(a(1,X), a(2,X), a(1,Y), b(1,X), b(1,Y), b(2,Y))
        else if ((.not. ha) .and. hb) then
          p = intersection(b(1,X), b(2,X), b(1,Y), a(1,X), a(1,Y), a(2,Y))
        end if

        ! Update min_distance and min_time
        if (p(1) == 1) then
          ! Compute Manhattan distance.
          min_distance = min(min_distance, abs(p(2)) + abs(p(3)))
          ! Compute total number of steps to intersection.
          min_time = min(min_time,&
            a(1,3) + abs(p(2) - a(1,X)) + abs(p(3) - a(1,Y)) +&
            b(1,3) + abs(p(2) - b(1,X)) + abs(p(3) - b(1,Y)))
        end if
      end if
    end do
  end do

  print *, "Closest intersection:", min_distance
  print *, "Fastest intersection:", min_time

! Define subroutines in this program.
contains
  ! Read file input into a nice steps array.
  subroutine read_steps(input, output)
    character(5), dimension(:), intent(in) :: input
    type(Step), dimension(:), intent(out), allocatable :: output
    integer :: i
    allocate(output(size(input)))
    ! Iterate over all input parts.
    ! + `len` returns the length of the character entity.
    ! + `size` returns the array length along a dimension (or total count).
    do i = 1, size(input)
      output(i)%direction = input(i)(1:1)
      read(input(i)(2:), *) output(i)%length
    end do
  end subroutine

  ! Compute wire coordinates
  subroutine compute_wire(wire, coords)
    type(Step), dimension(:), intent(in) :: wire
    integer, dimension(:, :), allocatable, intent(out) :: coords
    integer :: i, x, y, t

    ! Restart x, y, t (constant value in declaration is not reset!)
    x = 0; y = 0; t = 0
    allocate(coords(size(wire) + 1, 3))
    coords(1, :) = [x, y, t]

    ! Iterate over all steps.
    do i = 1, size(wire)
      select case (wire(i)%direction)
        case ('U')
          y = y + wire(i)%length
        case ('D')
          y = y - wire(i)%length
        case ('L')
          x = x - wire(i)%length
        case ('R')
          x = x + wire(i)%length
      end select
      t = t + wire(i)%length
      coords(i + 1, :) = [x, y, t]
    end do
  end subroutine

  ! Compute intersection between two lines. The first line is horizontal and the
  ! second one vertical.
  function intersection(x1a, x1b, y1, x2, y2a, y2b)
    integer, dimension(3) :: intersection
    integer x1a, x1b, y1, x2, y2a, y2b

    if (min(x1a, x1b) <= x2 .and. x2 <= max(x1a, x1b) .and.&
        min(y2a, y2b) <= y1 .and. y1 <= max(y2a, y2b)) then
      intersection(1) = 1
      intersection(2:3) = [x2, y1]
    else
      intersection(1) = 0
    end if
  end function
end program day3