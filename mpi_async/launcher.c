#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "mpi.h"

int64_t get_cycles(float seconds);
void sleep_kernel(int64_t num_cycles, int stream_id);
void create_streams(int num_streams);
void wait_for_stream(int stream_id);
void destroy_streams(int num_streams);

int main(int argc, char *argv[])
{
    MPI_Init(&argc, &argv);
 
    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    uint64_t cycles;
    double start, stop;
    int num_kernels;

    // Get number of cycles to sleep for 1 second
    cycles = get_cycles(1.0);

    // Number of kernels to launch
    int max_kernels = size;

    // Setup default stream in sleep.cu wrapper
    create_streams(0);

    // Loop through number of kernels to launch, from 1 to max_kernels
    for(num_kernels=1; num_kernels<=max_kernels; num_kernels++)
    {
        // Start timer
        MPI_Barrier(MPI_COMM_WORLD);
        if(rank == 0)
            start = MPI_Wtime();

        // Launch kernel into default stream
        if(rank < num_kernels)
            sleep_kernel(cycles, 0);

        // Wait for all ranks to submit kernel
        MPI_Barrier(MPI_COMM_WORLD);

        // Wait for default stream
        if(rank < num_kernels)
            wait_for_stream(0);

        // Wait for all ranks to complete
        MPI_Barrier(MPI_COMM_WORLD);

        // Print seconds ellapsed
        if(rank == 0) {
            stop = MPI_Wtime();
            printf("Total time for %d kernels: %f s\n", num_kernels, stop-start);
        }
    }

    destroy_streams(0);
    MPI_Finalize();

    return 0;
}
