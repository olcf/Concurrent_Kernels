#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <omp.h>

int64_t get_cycles(float seconds);
void sleep_kernel(int64_t num_cycles, int stream_id);
void create_streams(int num_streams);
void wait_for_streams(int num_streams);
void destroy_streams(int num_streams);

int main(int argc, char *argv[])
{
    uint64_t cycles;
    double start, stop;
    int i, num_kernels;

    // Get number of cycles to sleep for 1 second
    cycles = get_cycles(1.0);

    // Number of kernels to launch
    int max_kernels = 33;

    // Loop through number of kernels to launch, from 1 to num_kernels
    for(num_kernels=1; num_kernels<=max_kernels; num_kernels++)
    {

        // Set number of OMP threads
        omp_set_num_threads(num_kernels);

        // Start timer
        start = omp_get_wtime();

        // Create streams
        create_streams(num_kernels);

        // Launch num_kernel kernels asynchrnously
        #pragma omp parallel firstprivate(cycles)
        {
            int stream_id = omp_get_thread_num()+1;
            sleep_kernel(cycles, stream_id);
        }

        // Wait for kernels to complete
        wait_for_streams(num_kernels);

        // Clean up streams
        destroy_streams(num_kernels);

        // Stop timer
        stop = omp_get_wtime();
        printf("Total time for %d kernels: %f s\n", num_kernels, stop-start);
    }

    return 0;
}
