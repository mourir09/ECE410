# Codefest 9: Benchmark Results

| Metric | M1 Software Baseline (GitHub Codespace) | M3 Accelerator (Projected) | Speedup |
| :--- | :--- | :--- | :--- |
| Execution Time (per conv) | 13.10 ms | 0.075 ms | **~175.9x faster** |
| Throughput | 0.93 MOPS (0.0009 GOPS) | 163.6 MOPS (0.1636 GOPS) | **~175.9x throughput** |
| Memory Usage/Bandwidth | 33.16 KB (Peak Allocation) | 200 MB/s (AXI Peak Bandwidth) | N/A |

**Projection Assumptions:**
* **Clock Frequency:** 100 MHz (Target from M3 `config.json`).
* **Peak Computed Operations:** 2 Ops per cycle = 200 MOPS.
* **Peak Memory Bandwidth:** 2 bytes/cycle = 200 MB/s.
* **Algorithm Arithmetic Intensity:** 0.818 Ops/byte.
* **Attainable Performance:** Because the AI (0.818) is lower than the ridge point (1.0), the system is memory-bound. Attainable throughput is 0.818 Ops/byte × 200 MB/s = 163.6 MOPS.
