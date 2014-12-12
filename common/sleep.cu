#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
 
static cudaStream_t *streams;

// CUDA kernel to pause for at least num_cycle cycles
__global__ void sleep(int64_t num_cycles)
{
    int64_t cycles = 0;
    int64_t start = clock64();
    while(cycles < num_cycles) {
        cycles = clock64() - start;
    }
}
 
// Returns number of cycles required for requested seconds
extern "C" int64_t get_cycles(float seconds)
{
    // Get device frequency in KHz
    int64_t Hz;
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    Hz = int64_t(prop.clockRate) * 1000;
 
    // Calculate number of cycles to wait
    int64_t num_cycles;
    num_cycles = (int64_t)(seconds * Hz);
   
    return num_cycles;
}
 
// Create streams
extern "C" void create_streams(int num_streams)
{
    // Allocate streams
    streams = (cudaStream_t *) malloc((num_streams+1)*sizeof(cudaStream_t));    
 
    // Default stream
    streams[0] = NULL;

    // Primer kernel launch
    sleep<<< 1, 1 >>>(1); 

    // Create streams
    for(int i = 1; i <= num_streams; i++)
        cudaStreamCreate(&streams[i]);
}
 
// Launches a kernel that sleeps for num_cycles
extern "C" void sleep_kernel(int64_t num_cycles, int stream_id)
{
    // Launch a single GPU thread to sleep
    int blockSize, gridSize;
    blockSize = 1;
    gridSize = 1;
 
    // Execute the kernel
    sleep<<< gridSize, blockSize, 0, streams[stream_id] >>>(num_cycles);
}
 
// Wait for stream to complete
extern "C" void wait_for_stream(int stream_id)
{
    cudaStreamSynchronize(streams[stream_id]);
}
 
// Wait for streams to complete
extern "C" void wait_for_streams(int num_streams)
{
    for(int i = 1; i <= num_streams; i++)
        cudaStreamSynchronize(streams[i]);
}
 
// Destroy stream objects
extern "C" void destroy_streams(int num_streams)
{
    // Clean up stream
    for(int i = 1; i <= num_streams; i++)
        cudaStreamDestroy(streams[i]);
    free(streams);
}
