program main
    use sleep
    use omp_lib

    implicit none

    integer(8) :: cycles
    integer    ::  max_kernels, num_kernels, stream_id
    real(8)    :: start, stop, seconds

    ! Get number of cycles to sleep for 1 second
    seconds = 1.0
    cycles = get_cycles(seconds)

    ! Maximum number of kernels to launch
    max_kernels = 33;

    ! Create streams
    call create_streams(max_kernels)

    ! Loop through number of kernels to launch, from 1 to num_kernels
    do num_kernels = 1, max_kernels

        ! Set number of OMP threads
        call omp_set_num_threads(num_kernels)

        ! Start timer
        start = omp_get_wtime()

        ! Launch num_kernel kernels asynchrnously

        !$omp parallel private(stream_id) firstprivate(cycles)
        stream_id = omp_get_thread_num()+2
        call sleep_kernel(cycles, stream_id)
        !$omp end parallel

        ! Wait for kernels to complete
        call wait_for_streams(num_kernels)

        ! Stop timer
        stop = omp_get_wtime()

        print *, 'Total time for ', num_kernels,' kernels: ', stop-start, 'seconds'

    enddo

    ! Clean up streams
    call destroy_streams(max_kernels)

end program main
