# Codefest 9: Benchmark Results

| Metric | M1 Software Baseline (GitHub Codespace) | M3 Accelerator (Projected) | Speedup |
| :--- | :--- | :--- | :--- |
| Execution Time (per conv) | 13.10 ms | 0.061 ms | **~215.1x faster** |
| Throughput | 0.93 MOPS (0.0009 GOPS) | 200 MOPS (0.2 GOPS) | **~215.1x throughput** |
| Memory Usage/Bandwidth | 33.16 KB (Peak Allocation) | 200 MB/s (AXI Peak Bandwidth) | N/A |

**Projection Assumptions:**
Because a full end-to-end multi-layer simulation is not yet runnable due to the single-cycle timing failures found during M3 synthesis, the hardware throughput is projected mathematically as permitted by the Codefest instructions. 
* **Clock Frequency:** 100 MHz (Target from M3 `config.json`).
* **Operations:** 2 Ops per cycle (1 Multiply + 1 Add from the INT8 MAC).
* **Peak Projected Throughput:** 100 MHz × 2 Ops/cycle = 200 MOPS (0.2 GOPS).
* **Peak Memory Bandwidth:** 100 MHz × 2 bytes/cycle (16-bit AXI `s_axis_tdata`) = 200 MB/s.
