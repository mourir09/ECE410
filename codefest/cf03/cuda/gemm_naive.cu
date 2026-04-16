#include <iostream>
#include <cuda_runtime.h>

#define N 32

// (a) Naive kernel with one thread per output element
__global__ void naive_gemm(float *A, float *B, float *C, int n) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < n && col < n) {
        float sum = 0.0f;
        for (int i = 0; i < n; ++i) {
            sum += A[row * n + i] * B[i * n + col];
        }
        C[row * n + col] = sum;
    }
}

int main() {
    size_t bytes = N * N * sizeof(float);
    float *h_A = (float*)malloc(bytes);
    float *h_B = (float*)malloc(bytes);
    float *h_C = (float*)malloc(bytes);

    // Initialize matrices with dummy data
    for (int i = 0; i < N * N; ++i) {
        h_A[i] = 1.0f; h_B[i] = 2.0f;
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, bytes); cudaMalloc(&d_B, bytes); cudaMalloc(&d_C, bytes);
    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, bytes, cudaMemcpyHostToDevice);

    // 1 thread per element: Block size 8x8, Grid size 4x4 (for 32x32 matrix)
    dim3 threadsPerBlock(8, 8);
    dim3 numBlocks((N + threadsPerBlock.x - 1) / threadsPerBlock.x, 
                   (N + threadsPerBlock.y - 1) / threadsPerBlock.y);

    // Warmup
    naive_gemm<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C, N);
    cudaDeviceSynchronize();

    // Timing
    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    
    int iterations = 10000;
    cudaEventRecord(start);
    for(int i = 0; i < iterations; i++) {
        naive_gemm<<<numBlocks, threadsPerBlock>>>(d_A, d_B, d_C, N);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);

    // Calculate GFLOP/s
    double seconds = (milliseconds / 1000.0) / iterations;
    double flops = 2.0 * N * N * N; 
    double gflops = (flops / seconds) / 1e9;

    std::cout << "Naive Kernel GFLOP/s: " << gflops << std::endl;

    // Cleanup
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C);
    return 0;
}
