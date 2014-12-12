program main
    use sleep
 
    integer(8) :: cycles
    integer    ::  max_kernels, num_kernels, i
    real(8)    :: start, stop, seconds
 
    ! Get number of cycles to sleep for 1 second
    seconds = 1.0
    cycles = get_cycles(seconds)
 
    ! Maximum number of kernels to launch
    max_kernels = 33
 
    ! Loop through number of kernels to launch, from 1 to num_kernels
    do num_kernels = 1, max_kernels
 
        ! Start timer
        call cpu_time(start)
 
        ! Create streams
        call create_streams(num_kernels)
 
        ! Launch num_kernel kernels asynchrnously
        do i = 2, num_kernels+1
            call sleep_kernel(cycles, i)
        enddo

        ! Wait for kernels to complete
        call wait_for_streams(num_kernels) 

        ! Clean up streams
        call destroy_streams(num_kernels)
 
        ! Stop timer
        call cpu_time(stop)
 
        print *, 'Total time for ', num_kernels,' kernels: ', stop-start, 'seconds'
 
    enddo
 
end program main
