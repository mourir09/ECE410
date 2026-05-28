# Codefest 9: CMAN Arithmetic Intensity Analysis

**1. Kernel Identification and Dimensions**
* **Dominant Kernel:** 2D Convolution
* **Data Types:** INT8 Inputs (1 byte), INT8 Weights (1 byte), INT32 Accumulation/Output (4 bytes).
* **Dimensions:** * Input Image: 28 x 28 ($N = 28$)
  * Weight Filter: 3 x 3 ($K = 3$)
  * Output Image: 26 x 26 ($M = 26$, assuming Stride 1, no padding)

**2. Total Operations (FLOPs / MACs)**
A single MAC operation consists of 2 operations (one multiply, one add). For a 2D convolution, every pixel in the output requires $K^2$ MACs.
* **Formula:** Total Ops = $2 \times M^2 \times K^2$
* **Calculation:** $2 \times (26^2) \times (3^2) = 2 \times 676 \times 9$
* **Total Operations:** 12,168 Ops

**3. Data Transfers and Arithmetic Intensity (AI)**

**Lower Bound (No Data Reuse):**
Assuming no on-chip reuse, every single MAC requires fetching 1 byte of image data and 1 byte of weight data from off-chip memory. The 4-byte accumulated result is written out once per output pixel.
* **Read Bytes:** $(1 + 1) \times M^2 \times K^2 = 2 \times 676 \times 9 = 12,168$ bytes
* **Write Bytes:** $4 \times M^2 = 4 \times 676 = 2,704$ bytes
* **Total Bytes Transferred:** 14,872 bytes
* **Lower Bound AI:** $12,168 \text{ Ops} / 14,872 \text{ bytes} =$ **0.818 Ops/byte**

**Upper Bound (Perfect Weight & Image Reuse):**
Assuming perfect on-chip data reuse, the entire filter ($K^2$) and the entire image ($N^2$) are read from off-chip memory exactly once. The 4-byte output is written exactly once. 
* **Read Bytes:** $K^2 + N^2 = 9 + 784 = 793$ bytes
* **Write Bytes:** $4 \times M^2 = 4 \times 676 = 2,704$ bytes
* **Total Bytes Transferred:** 3,497 bytes
* **Upper Bound AI:** $12,168 \text{ Ops} / 3,497 \text{ bytes} =$ **3.479 Ops/byte**

**4. Bottleneck Identification**
* **Current Bottleneck:** Because the design currently fetches individual operands via the AXI4-Stream interface for every MAC without a local weight buffer, it operates near the No-Reuse lower bound (0.818 Ops/byte). This places the design firmly in the **Memory-Bound** region of the roofline.
* **Highest-Leverage Improvement:** The single highest-leverage change to improve performance is implementing a local SRAM weight buffer inside the compute core. Loading the $3 \times 3$ weights once and retaining them on-chip will drastically reduce AXI stream traffic and push the design toward the compute-bound ceiling.
