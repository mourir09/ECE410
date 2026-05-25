# Milestone 3 Repository Index

**Simulator Used:** Icarus Verilog (executed via standard `make sim`).
**OpenLane 2 Version:** `2.0.0-b3` (Run locally via Docker container, using the configuration in `project/m3/synth/config.json`).

## Directory Contents

* `project/m3/README.md` - This index file cataloging the M3 deliverables.
* `project/m3/synthesis_notes.md` - Narrative detailing the synthesis results, timing failures, and M4 plans.

**RTL and Testbench**
* `project/m3/rtl/top.sv` - The integrated top module instantiating the interface and compute core.
* `project/m3/rtl/compute_core.sv` - The MAC compute core.
* `project/m3/rtl/interface.sv` - The AXI4-Stream interface.
* `project/m3/tb/tb_top.sv` - The end-to-end co-simulation testbench using the host protocol.

**Simulation Logs**
* `project/m3/sim/cosim_run.log` - The simulation transcript showing the final "PASS" assertion.
* `project/m3/sim/cosim_waveform.png` - Annotated waveform showing write, compute, and read transactions.

**Synthesis Data**
* `project/m3/synth/config.json` - The OpenLane configuration file dictating the 10.0ns clock target.
* `project/m3/synth/openlane_run.log` - Full captured stdout/stderr log of the successful OpenLane run.
* `project/m3/synth/timing_report.txt` - STA report detailing the -3.49 ns WNS and setup violations.
* `project/m3/synth/area_report.txt` - Total cell area breakdown (11,902.7 µm², 4165 cells).
* `project/m3/synth/critical_path.md` - Start point, end point, and logic description of the worst timing path.
* `project/m3/synth/power_report.txt` - Brief note on the failure of the SAIF power profile generation.
