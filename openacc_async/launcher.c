#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "math.h"
#include <sys/time.h>

int main(int argc, char *argv[])
{

    uint64_t num_cycles;
    struct timeval start, stop;
    int i,num_kernels;

    // Set number of cycles to sleep for 1 second
    // We'll use frequency/instruction latency to estimate this
    num_cycles = 730000000/15;

    // Number of kernels to launch
    int max_kernels = 33;

    // Loop through number of kernels to launch, from 1 to num_kernels
    for(num_kernels=1; num_kernels<max_kernels; num_kernels++)
    {
        // Start timer
        gettimeofday(&start, NULL);

        for(i=0; i<=num_kernels; i++) 
        {
            #pragma acc parallel async(i) vector_length(1) num_gangs(1)
            {
                uint64_t cycles;
                #pragma acc loop seq
                for(cycles=0; cycles<num_cycles; cycles++) {
                    cycles = cycles;
                }
            }
        }

        // Wait for all async streams to complete
        #pragma acc wait

        // Print seconds ellapsed
        gettimeofday(&stop, NULL);
        double seconds;
        seconds = (stop.tv_sec - start.tv_sec);
        seconds += (stop.tv_usec - start.tv_usec) / 1000000.0;
        printf("Total time for %d kernels: %f s\n", num_kernels, seconds);
    }

    return 0;
}
