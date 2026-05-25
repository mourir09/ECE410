# Milestone 3 Synthesis and Integration Notes

## 1. Integration and End-to-End Co-Simulation
The first phase of Milestone 3 involved successfully integrating the compute core with the AXI4-Stream interface module developed during Milestone 2. The top-level module (`top.sv`) was constructed to instantiate both the host-facing interface and the internal compute engine, ensuring that all inter-module signals were correctly wired without any floating ports or stub modules. To facilitate this connection, a handshake adapter and width converter were implemented as glue logic. 

For the co-simulation, the testbench (`tb_top.sv`) was designed to mimic a real host, driving data exclusively through the AXI-Stream interface. The testbench exercised the dominant kernel identified in the M1 profiling phase. The simulation completed successfully, unambiguously printing "PASS" to the transcript, validating that the data successfully flows from the host, through the interface, into the compute engine, and back out.

## 2. Iterative Synthesis Failures and Resolutions
Pushing the integrated design through the OpenLane 2 RTL-to-GDSII flow was a highly iterative process that required multiple interventions. Initially, the unmodified RTL from Milestone 2 failed completely during the Global Routing step (Step 8). OpenROAD threw a fatal congestion error (`[ERROR GRT-0071] Routing congestion too high`), and the flow aborted. This was caused by the synthesis tool flattening the heavy combinational logic of the 2D convolution multiplier array into a massive, dense cluster of logic gates that the router could not physically wire together within the default floorplan parameters.

To get further, I had to intervene and change the OpenLane configuration. I adjusted `config.json` by relaxing the target density (`PL_TARGET_DENSITY`) from 0.40 to 0.45 and changing the synthesis strategy to prioritize area over aggressive timing unrolling (`SYNTH_STRATEGY: "AREA 0"`). After these modifications, the design successfully passed Detailed Routing and the LVS/DRC checks. 

## 3. Final Synthesis State and Timing Analysis
With the routing successfully completed, the final design consumes a total standard cell area of 11,902.7 µm², comprising 4,165 total physical instances. 

However, the flow surfaced severe timing constraints. The design was configured with a target clock period of 10.0 ns. Upon reviewing the `timing_report.txt`, the worst-case setup slack (WNS) fell to -3.49 ns in the `max_ss_100C_1v60` corner. There are 63 total setup violations. The primary cause of this timing failure is the deep combinational logic depth between the interface input and the first set of pipeline registers, primarily involving heavy complex AND-OR-INVERT standard cells attempting to resolve the multiplication and accumulation in a single cycle.

## 4. Power Estimation Constraints
Power estimation was attempted to fulfill the initial checks for Milestone 4. However, the OpenROAD power analysis step failed to generate a complete switching activity profile because a valid SAIF (Switching Activity Interchange Format) file was not successfully captured from the Icarus Verilog co-simulation environment. 

## 5. Scope Adjustment and M1 Baseline Alignment
Because the design technically synthesized and routed, the project scope remains largely the same, but specific architectural adjustments are required to achieve timing and power closure for Milestone 4.

**Scope Adjustment & Rationale:** The primary adjustment will be heavily pipelining the compute core datapath. Originally, the scope assumed a nearly single-cycle evaluation of the MAC (Multiply-Accumulate) operations. I am removing this aggressive combinational requirement. Instead, I will insert at least two stages of intermediate pipeline registers (`dfxtp_2` flip-flops) to break up the logic clouds. This scope change is highly achievable because the current physical area is very small (11,902 µm²) and there are exactly 0 hold violations, meaning the physical floorplan can easily absorb the area penalty of the added registers.

**M1 Benchmark Meaningfulness:**
This pipeline adjustment strictly preserves the meaningfulness of the M4 benchmarks relative to the M1 software baseline. Our M1 baseline established the latency and throughput of a CPU calculating a 2D convolution. While pipelining our hardware will slightly increase the initial latency (in clock cycles) for the first result to appear, the steady-state throughput of the AXI4-Stream will remain exceptionally higher than the software baseline. The core math, dataflow, and hardware-acceleration narrative remain fully intact and directly comparable to the M1 metrics.
