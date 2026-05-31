# Codefest 9: Roofline Analysis

The roofline plot for the M3 hardware accelerator reveals that our current architecture is fundamentally memory-bound. While the compute core is theoretically capable of achieving a peak performance of 0.2 GOPS (running at a 100 MHz clock frequency and executing 2 operations per cycle), the attainable performance is strictly capped at approximately 0.1636 GOPS. 

This hardware bottleneck occurs because our algorithm's Arithmetic Intensity is 0.818 Ops/byte, which falls to the left of the hardware's ridge point of 1.0 Ops/byte. Consequently, the AXI4-Stream interface, which provides a peak memory bandwidth of 200 MB/s, cannot supply data fast enough to keep the pipelined INT8 multiplier and 32-bit accumulator fully saturated. The compute core ends up stalling while waiting for the next operands to arrive. 

To bridge this gap and reach the 0.2 GOPS computational ceiling in future iterations, we would either need to physically increase the memory bandwidth (such as widening the AXI data bus to 32 bits) or restructure the software algorithm to reuse data more effectively, thereby increasing the overall arithmetic intensity past the ridge point.
