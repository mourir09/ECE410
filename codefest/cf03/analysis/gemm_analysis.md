# GEMM Analysis: Naive vs. Tiled (N=32)

**(a) Why the naive kernel is memory-bound:** The naive kernel is strictly memory-bound because its arithmetic intensity is extremely low (0.25 FLOP/byte), far below our hardware's roofline ridge point of 31.25 FLOP/byte. Every matrix element is fetched from global memory repeatedly, choking the GPU on memory latency rather than math throughput.

**(b) How tiling reduces DRAM traffic:** Tiling resolves this by collaboratively loading an 8x8 block of data into ultra-fast shared memory once per block. Threads compute partial sums from this local cache, reducing total global DRAM accesses by a factor of 8. This drops theoretical DRAM traffic from 262 KB to roughly 32 KB, pushing the arithmetic intensity to 2.0 FLOP/byte.

**(c) Did it achieve the expected improvement?** Surprisingly, the tiled kernel performed worse (17.8 GFLOP/s) than the naive version (20.1 GFLOP/s). Because N=32 is incredibly small, both matrices easily fit within the GPU’s L1 cache automatically. The naive kernel never actually stalls on slow global DRAM. Consequently, the tiled kernel merely introduces heavy `__syncthreads()` synchronization overhead and shared memory instruction latency, which becomes the primary bottleneck and offsets any theoretical bandwidth gains.
