program main
    use sleep
    implicit none
    include 'mpif.h'

    integer    ::  max_kernels, num_kernels, i, ierr, rank, size
    integer(8) :: cycles
    real(8)    :: start, stop, seconds

    call MPI_Init(ierr)

    ! Get number of cycles to sleep for 1 second
    seconds = 1.0
    cycles = get_cycles(seconds)

    call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

    ! Number of kernels to launch
    max_kernels = size

    ! Setup default stream in sleep.cu wrapper
    call create_streams(0);

    ! Loop through number of kernels to launch, from 1 to max_kernels
    do num_kernels = 1, max_kernels

        ! Start timer
        call MPI_Barrier(MPI_COMM_WORLD, ierr)
        if (rank == 0) then
            start = MPI_Wtime()
        endif

        ! Launch num_kernel kernels asynchrnously
        if (rank < num_kernels) then
            call sleep_kernel(cycles, 1)
        endif

        ! Wait for all ranks to submit kernel
        call MPI_Barrier(MPI_COMM_WORLD, ierr)

        ! Wait for kernel to complete
        if(rank < num_kernels) then
            call wait_for_stream(0)
        endif

        ! Wait for all ranks to complete
        call MPI_Barrier(MPI_COMM_WORLD, ierr)

        ! Print seconds ellapsed
        if (rank == 0) then
            stop = MPI_Wtime()
            print *, 'Total time for ', num_kernels,' kernels: ', stop-start, 'seconds'
        endif

    enddo

    ! clean up array in wrapper, no stream actually destroyed
    call destroy_streams(0)

    call MPI_Finalize(ierr)


end program main
