# Interface Selection and Bandwidth Analysis

**Target Interface:** SPI (Serial Peripheral Interface)
**Target Host:** Microcontroller (e.g., ESP32)

### 1. Interface Rationale
I have selected SPI as the communication interface between the host MCU and the custom AI accelerator. SPI is a standard, low-complexity 4-wire bus (SCLK, MOSI, MISO, CS) that is universally supported by edge microcontrollers. This aligns perfectly with the project's goal of targeting low-power TinyML applications rather than high-performance computing clusters. 

### 2. Bandwidth Analysis vs. Arithmetic Intensity
As calculated in the Codefest 2 analysis, the raw `Conv2D` forward pass has an arithmetic intensity of just **1.058 FLOPs/byte**. 
If the target accelerator compute ceiling is **20 GFLOP/s**, executing this kernel purely by streaming data continuously from the host would demand an external interface bandwidth of:
`20 GFLOP/s / 1.058 FLOP/byte = 18.9 GB/s`

A standard ESP32 SPI bus operates at a maximum of ~80 MHz, yielding a peak theoretical bandwidth of roughly **10 MB/s**. 
*Conclusion:* It is physically impossible to stream raw, unbuffered data over SPI fast enough to keep the compute array busy. If designed this way, the system would be hopelessly interface-bound.

### 3. The Local Memory Solution
To resolve this massive bandwidth deficit, the accelerator design incorporates local on-chip SRAM buffers for both the image inputs and the weights. 
By buffering data locally on the chiplet, the external SPI bus is only responsible for transferring the unique, non-overlapping data once per inference:
* **Input Image:** 1 channel × 16 × 16 (INT8) = 256 bytes
* **Weights:** 8 filters × 3 × 3 (INT8) = 72 bytes
* **Output Activations:** 8 channels × 16 × 16 (INT8) = 2,048 bytes
* **Total External Traffic per Inference:** 2,376 bytes

At a standard SPI speed of 10 MB/s, transferring 2,376 bytes takes approximately **0.237 milliseconds**. 
By utilizing local memory buffers to decouple the external interface bandwidth from the internal compute bandwidth, SPI is more than capable of feeding the accelerator with minimal latency overhead, justifying its selection for this architecture.
