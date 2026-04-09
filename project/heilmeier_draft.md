# Project Proposal: Heilmeier Questions Draft
**Target Algorithm:** INT8 Quantized Depthwise Separable Convolutions (MobileNet)
**Target Interface:** SPI

### 1. What are you trying to do? Articulate your objectives using absolutely no jargon.
I am designing a custom hardware chiplet that acts as a specialized co-processor to speed up image recognition tasks on small, low-power devices. It will communicate with a standard microcontroller using a simple, 4-wire SPI connection, taking over the heavy math required to process images.

### 2. How is it done today, and what are the limits of current practice?
Currently, image processing algorithms run entirely in software on general-purpose CPUs. Profiling tools reveal that structuring this math in software requires deeply nested loops that constantly fetch overlapping image patches from main memory. This creates a severe memory bottleneck. The limit of current practice is that the CPU spends the vast majority of its time and battery power moving data back and forth rather than actually computing the results, leading to slow reaction times on edge devices.

### 3. What is new in your approach and why do you think it will be successful?
Instead of relying on a general-purpose CPU that constantly accesses external memory, I am offloading the heavy convolution math to a dedicated hardware accelerator. The key innovation is equipping the accelerator with local, on-chip SRAM to hold the image data. By buffering the data locally and compressing the math into 8-bit integers (INT8), the chip drastically reduces the need to transfer data. I believe this will be successful because resolving the memory bottleneck allows the chip to calculate results at high speed, even when connected to the host via a simple, low-bandwidth SPI interface.
