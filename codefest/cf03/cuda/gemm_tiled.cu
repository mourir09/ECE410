#include <iostream>
#include <cuda_runtime.h>

#define N 32
#define TILE_SIZE 8

// (b) Shared-memory tiled kernel with tile size 8
__global__ void tiled_gemm(float *A, float *B, float *C, int n) {
    __shared__ float tileA[TILE_SIZE][TILE_SIZE];
    __shared__ float tileB[TILE_SIZE][TILE_SIZE];

    int row = blockIdx.y * TILE_SIZE + threadIdx.y;
    int col = blockIdx.x * TILE_SIZE + threadIdx.x;

    float sum = 0.0f;

    // Loop over the tiles required to compute the output
    for (int p = 0; p < n / TILE_SIZE; ++p) {
        // Collaboratively load data into shared memory
        tileA[threadIdx.y][threadIdx.x] = A[row * n + (p * TILE_SIZE + threadIdx.x)];
        tileB[threadIdx.y][threadIdx.x] = B[(p * TILE_SIZE + threadIdx.y) * n + col];
        
        __syncthreads(); // Wait for all threads to finish loading the tile

        // Compute the partial sum for this tile
        for (int k = 0; k < TILE_SIZE; ++k) {
            sum += tileA[threadIdx.y][k] * tileB[k][threadIdx.x];
        }
        
        __syncthreads(); // Wait for all threads to finish computing before loading the next tile
    }

    C[row * n + col] = sum;
}

int main() {
    size_t bytes = N * N * sizeof(float);
    float *h_A = (float*)malloc(bytes);
    float *h_B = (float*)malloc(bytes);
    float *h_C = (float*)malloc(bytes);

    for (int i = 0; i < N * N; ++i) {
        h_A[i] = 1.0f; h_B[i] = 2.0f;
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes); cudaMalloc(&d_B, bytes); cudaMalloc(&d_C, bytes);
    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    // Grid and block configuration specifically for TILE_SIZE = 8
    dim3 threadsPerBlock(TILE_SIZE, TILE_SIZE);
    dim3 numBlocks(N / TILE_SIZE, N / TILE_SIZE);

    tiled_gemm<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    
    int iterations = 10000;
    cudaEventRecord(start);
    for(int i = 0; i < iterations; i++) {
        tiled_gemm<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C, N);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    double seconds = (milliseconds / 1000.0) / iterations;
    double flops = 2.0 * N * N * N;
    double gflops = (flops / seconds) / 1e9;

    std::cout << "Tiled Kernel GFLOP/s: " << gflops << std::endl;

    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C);
    return 0;
}
