#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/time.h>
 
int64_t get_cycles(float seconds);
void sleep_kernel(int64_t num_cycles, int stream_id);
void create_streams(int num_streams);
void wait_for_streams(int num_streams);
void destroy_streams(int num_streams);
 
int main(int argc, char *argv[])
{
    uint64_t cycles;
    struct timeval start, stop;
    int i, num_kernels;
 
    // Get number of cycles to sleep for 1 second
    cycles = get_cycles(1.0);
 
    // Max number of kernels to launch
    int max_kernels = 33;
 
    // Loop through number of kernels to launch, from 1 to num_kernels
    for(num_kernels=1; num_kernels<=max_kernels; num_kernels++)
    {
        // Start timer
        gettimeofday(&start, NULL);
 
        // Create streams
        create_streams(num_kernels);
 
        // Launch num_kernel kernels asynchrnously
        for(i=1; i<=num_kernels; i++){
            sleep_kernel(cycles, i);
        }
 
        // Wait for kernels to complete
        wait_for_streams(num_kernels);
 
        // Clean up streams
        destroy_streams(num_kernels);
 
        // Print seconds ellapsed
        gettimeofday(&stop, NULL);
        double seconds;
        seconds = (stop.tv_sec - start.tv_sec);
        seconds += (stop.tv_usec - start.tv_usec) / 1000000.0;
        printf("Total time for %d kernels: %f s\n", num_kernels, seconds);
    }
 
    return 0;
}
