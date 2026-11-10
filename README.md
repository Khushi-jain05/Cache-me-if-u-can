Cache Me If U Can — Direct-Mapped Cache Controller
A Verilog implementation of a 32-bit, direct-mapped cache controller developed as a Modern Computer Architecture semester project. The design demonstrates address decoding, cache hit/miss detection, four-word block refill, finite-state-machine (FSM) control, and simulation-based performance analysis.
Project overview
The cache stores recently accessed memory blocks so that repeated accesses can be served without fetching the data again from main memory. Each memory block maps to exactly one cache line.
Implemented configuration
Parameter	Value
CPU address width	32 bits
Cache data capacity	1 KB (1,024 bytes)
Mapping	Direct mapped
Number of cache lines	64
Block size	16 bytes
Word size	32 bits
Words per block	4
Data stored per cache line	128 bits
Tag	22 bits
Index	6 bits
Block offset	4 bits


The 32-bit address is divided as follows:
31                         10 9        4 3       0
+----------------------------+----------+---------+
|          Tag (22)          | Index (6)| Offset  |
+----------------------------+----------+---------+
                                      [3:2] = word index
                                      [1:0] = byte in word
Architecture
The integrated top-level module is cache_top. It connects the following blocks:
1. Address decoder (address_decoder.v) — extracts tag, index, byte offset, and word index from the CPU address.
2. Cache storage (cache_storage.v) — stores 64 data blocks, tags, and valid bits; performs tag comparison, hit/miss detection, and word selection.
3. Main memory (main_memory.v) — models 1,024 words of 32-bit memory for simulation.
4. Memory interface (memory_interface.v) — aligns a missed address to a 16-byte boundary, reads four consecutive words, and assembles a 128-bit refill block.
5. Cache controller (cache_controller.v) — coordinates request acceptance, lookup, miss handling, refill, and response using a five-state FSM.
6. Top-level integration (cache_top.v) — connects the decoder, cache, controller, and memory interface.
Controller states
State	Code	Function
IDLE	000	Wait for and accept a CPU request
LOOKUP	001	Check the selected cache line
MISS	010	Issue a memory refill request
REFILL	011	Wait for the memory interface to fill the cache line
RESPONSE	100	Hold response data until the CPU accepts it


Miss and refill sequence
When the requested line is not valid or its tag does not match, the controller enters the miss path. The memory interface aligns the address to a 16-byte block boundary and reads the four 32-bit words at offsets 0, 4, 8, and 12 bytes. These words are packed into a 128-bit block, written into the selected cache line, and then the controller retries the lookup before returning the requested word.
Repository structure
Cache-me-if-u-can/
├── docs/
│   ├── architecture.md
│   ├── architecture_mapping.md
│   ├── cache_storage.md
│   ├── fsm_diagram.md
│   └── mermaid-diagram.png
├── reports/
│   ├── architecture.md
│   ├── performance_analysis.md
│   ├── simulation_results.txt
│   ├── synthesis_report.md
│   ├── yosys_synthesis.log
│   └── *.png                  # saved simulation/waveform figures
├── rtl/
│   ├── address_decoder.v
│   ├── cache_controller.v
│   ├── cache_storage.v
│   ├── cache_top.v
│   ├── main_memory.v
│   └── memory_interface.v
├── tb/
│   ├── address_decoder_tb.v
│   ├── cache_controller_tb.v
│   ├── cache_storage_tb.v
│   ├── cache_tb.v
│   └── memory_tb.v
└── traces/
    ├── conflict.txt
    ├── random.txt
    ├── repeated.txt
    └── sequential.txt
Requirements
- Icarus Verilog — compile and simulate the Verilog testbenches.
- vvp — runs the compiled simulation output; it is installed with Icarus Verilog.
- Yosys — optional, for synthesis.
- Surfer or another VCD viewer — optional, for inspecting waveform files.
On macOS with Homebrew:
brew install icarus-verilog
Check the tools:
iverilog -V
vvp -V
Run the simulations
Run the commands from the repository root directory. Create a build directory first:
mkdir -p build
1. Address decoder test
iverilog -g2012 -Wall -s address_decoder_tb \
  -o build/address_decoder_sim \
  rtl/address_decoder.v tb/address_decoder_tb.v

vvp build/address_decoder_sim
The testbench checks four addresses and their expected tag, index, offset, and word-index fields.
2. Cache storage test
iverilog -g2012 -Wall -s cache_storage_tb \
  -o build/cache_storage_sim \
  rtl/cache_storage.v tb/cache_storage_tb.v

vvp build/cache_storage_sim
The testbench checks empty-line misses, refill, tag matching, all four word selections, tag mismatch, and disabled lookup.
3. Main memory and refill test
iverilog -g2012 -Wall -s memory_tb \
  -o build/memory_sim \
  rtl/address_decoder.v rtl/cache_storage.v \
  rtl/main_memory.v rtl/memory_interface.v \
  tb/memory_tb.v

vvp build/memory_sim
This test initializes four consecutive memory words, requests a block, and checks the four words after refill.
4. Cache controller test
iverilog -g2012 -Wall -s cache_controller_tb \
  -o build/cache_controller_sim \
  rtl/*.v tb/cache_controller_tb.v

vvp build/cache_controller_sim
This test exercises a first access that misses and refills, followed by repeated accesses that should hit.
5. Integrated cache and performance test
iverilog -g2012 -Wall -s cache_tb \
  -o build/cache_sim \
  rtl/*.v tb/cache_tb.v

vvp build/cache_sim
Run this command from the repository root, because the integrated testbench reads trace files using paths such as traces/sequential.txt. The testbench writes a waveform file named cache_tb.vcd in the current working directory.
Recorded simulation results
The committed project report records the following integrated results:
Access pattern	Accesses	Hits	Misses	Errors
Sequential	12	9	3	0
Repeated	9	8	1	0
Random	12	2	10	0
Conflict	9	0	9	0
Total	42	19	23	0


Metric	Recorded result
Hit rate	45.24%
Miss rate	54.76%
Average hit latency	1 cycle
Average miss latency	8 cycles
Reported AMAT	4.83 cycles
Data verification errors	0


The AMAT calculation in the project report is:
AMAT = Hit time + (Miss rate × Miss penalty)
     = 1 + (23 / 42 × (8 − 1))
     = 4.83 cycles
The conflict trace uses addresses 0x00000020, 0x00000420, and 0x00000820. They map to the same cache index but have different tags, illustrating conflict misses.

These are the results documented in reports/simulation_results.txt and reports/performance_analysis.md.
Synthesis
The repository includes a Yosys synthesis report for cache_top.
- Tool: Yosys 0.70+post
- Synthesis top: cache_top
- Recorded generic mapped cells: 116,340
- Synthesis status: successful
- Maximum operating frequency: not measured
The generic cell count is not an FPGA LUT count or a physical area estimate. A target-specific implementation and static timing analysis are required to report device utilization and maximum frequency.

If Yosys is installed, a synthesis run can be started with:
yosys -p "read_verilog rtl/*.v; hierarchy -top cache_top; synth -top cache_top; stat"
Limitations
- The CPU-facing cache interface implements read requests.
- The main-memory write port is provided for memory initialization and testbench use; a CPU store policy is not implemented.
- Write-through, write-back, and dirty-bit handling are not implemented.
- Main memory is a functional simulation model, not a timing-accurate external memory device.
- The recorded synthesis statistics are generic and do not include target-specific timing or maximum-frequency analysis.
Team
Name	Student ID
Agrima Ojha	2401010047
Khyati Batra	2401010229
Khushi Jain	2401010227
Suhani Gupta	2401010463
Akshat Agrawal	2401010054


Course: Modern Computer Architecture — Semester Project
Project documentation
- [Architecture](docs/architecture.md)
- [Address mapping](docs/architecture_mapping.md)
- [Cache storage and hit/miss detection](docs/cache_storage.md)
- [Controller FSM](docs/fsm_diagram.md)
- [Performance analysis](reports/performance_analysis.md)
- [Simulation results](reports/simulation_results.txt)
- [Synthesis report](reports/synthesis_report.md)
License
No license is specified in this repository. If you intend others to reuse, modify, or distribute this project, add an appropriate open-source license file.
