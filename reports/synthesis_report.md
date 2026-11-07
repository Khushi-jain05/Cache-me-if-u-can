# Cache Synthesis Report

## 1. Objective

The objective of synthesis is to evaluate the hardware structure
and resource requirements of the integrated cache design.

## 2. Synthesis Tool

- Tool: Yosys
- Version: 0.70+post
- Top module: cache_top
- Synthesis command: synth -top cache_top
- Result: Successful
- Exit status: 0
- Reported synthesis runtime: 28.11 seconds

## 3. Design Modules

The synthesized design contains:

- cache_top
- cache_controller
- cache_storage
- memory_interface
- main_memory
- address_decoder

## 4. Resource Utilization

Total generic synthesized cells: 116340

| Cell Type | Count |
|---|---:|
| ANDNOT | 2398 |
| AND | 12583 |
| DFFE | 42368 |
| DFF | 70 |
| MUX | 27463 |
| NAND | 14417 |
| NOR | 3766 |
| NOT | 18 |
| ORNOT | 7874 |
| OR | 5051 |
| SDFFE | 319 |
| XNOR | 12 |
| XOR | 1 |

## 5. Module-wise Cell Distribution

| Module | Cell Count |
|---|---:|
| cache_controller | 93 |
| cache_storage | 25487 |
| memory_interface | 273 |
| main_memory | 90487 |
| Total | 116340 |

The address decoder is primarily composed of wiring and
does not contribute additional logic cells in this report.

## 6. Resource Analysis

The main memory accounts for a significant portion of the
synthesized hardware because it contains 1024 words,
each 32 bits wide.

The cache storage also requires substantial resources because
it contains 64 cache lines, each holding a 128-bit block,
along with tags and valid bits.

Yosys mapped the memory structures into generic logic cells
and flip-flops. The reported counts are generic technology-mapped
cells and should not be interpreted as FPGA LUT counts,
physical chip area, or a specific FPGA resource utilization.

## 7. Maximum Frequency Analysis

Maximum operating frequency was not determined by this
generic synthesis run.

Yosys generic synthesis statistics do not provide a
technology-specific maximum frequency.

A meaningful maximum-frequency result requires:
- A target FPGA or ASIC technology.
- A corresponding device or standard-cell timing library.
- Clock constraints.
- Static timing analysis.

Therefore, maximum frequency is reported as:
Not measured in this experiment.

## 8. Conclusion

The complete cache hierarchy was successfully synthesized
using Yosys.

The synthesis produced 116340 generic mapped cells.
The main memory and cache storage account for most of
the reported hardware resources.

Further target-specific implementation and timing analysis
are required to determine physical resource utilization
and maximum operating frequency.
