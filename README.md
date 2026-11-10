# Cache Me If U Can — Direct-Mapped Cache Controller

<div align="center">

### A Verilog HDL implementation of a 32-bit Direct-Mapped Cache Controller

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![Icarus Verilog](https://img.shields.io/badge/Simulation-Icarus%20Verilog-green)
![Yosys](https://img.shields.io/badge/Synthesis-Yosys-orange)
![Architecture](https://img.shields.io/badge/Cache-Direct--Mapped-purple)

**Modern Computer Architecture — Semester Project**

</div>

---

## 📌 Project Overview

**Cache Me If U Can** is a Verilog-based implementation of a **32-bit Direct-Mapped Cache Controller**, developed as a semester project for the Modern Computer Architecture course.

The project demonstrates how cache memory improves memory access efficiency by storing recently accessed data blocks. It implements address decoding, cache hit/miss detection, block refill from main memory, and controller operation using a Finite State Machine (FSM).

The design uses a modular architecture consisting of an address decoder, cache storage, main memory, memory interface, cache controller, and an integrated top module.

## 🎯 Project Objectives

- To understand the working of cache memory and memory hierarchy.
- To implement a direct-mapped cache using Verilog HDL.
- To design an address decoder for tag, index, and offset extraction.
- To implement cache hit and miss detection using tag comparison.
- To perform four-word block refill on a cache miss.
- To design an FSM-based cache controller.
- To verify the complete design using simulation and testbenches.
- To analyze cache performance using hit rate, miss rate, and AMAT.

## ⚙️ Cache Configuration

| Parameter | Value |
|---|---:|
| Address Width | 32 bits |
| Cache Capacity | 1 KB (1024 bytes) |
| Cache Mapping | Direct Mapped |
| Number of Cache Lines | 64 |
| Block Size | 16 bytes |
| Word Size | 32 bits |
| Words per Block | 4 |
| Data per Cache Line | 128 bits |
| Tag | 22 bits |
| Index | 6 bits |
| Block Offset | 4 bits |

### Address Format

The 32-bit memory address is divided into three main fields:

```text
31                         10  9        4  3       0
+----------------------------+----------+---------+
|          TAG (22)          | INDEX(6) | OFFSET  |
+----------------------------+----------+---------+

OFFSET:
[3:2] → Word Index
[1:0] → Byte Offset
```

- **Tag:** Identifies which memory block is stored in a cache line.
- **Index:** Selects one of the 64 cache lines.
- **Offset:** Selects the required word and byte within a block.

## 🏗️ System Architecture

The complete system is integrated through the `cache_top` module.

### Main Components

| Module | Description |
|---|---|
| `address_decoder.v` | Extracts tag, index, offset, and word index from the 32-bit address. |
| `cache_storage.v` | Stores cache data, tags, and valid bits; performs hit/miss detection and word selection. |
| `main_memory.v` | Simulates main memory containing 1024 words of 32-bit data. |
| `memory_interface.v` | Handles memory requests and fetches four consecutive words during block refill. |
| `cache_controller.v` | Controls cache operations using a five-state FSM. |
| `cache_top.v` | Integrates all modules into the complete cache system. |

### Cache Controller FSM

The controller consists of five states:

| State | Function |
|---|---|
| IDLE | Waits for and accepts a CPU request. |
| LOOKUP | Checks whether the requested data is present in the cache. |
| MISS | Initiates a memory request when a cache miss occurs. |
| REFILL | Waits for the requested block to be fetched and stored in cache. |
| RESPONSE | Returns the requested data to the CPU. |

### Cache Operation

1. The CPU sends a memory read request.
2. The address decoder extracts the tag, index, and offset.
3. The cache controller checks the selected cache line.
4. If the tag matches and the valid bit is set, a **cache hit** occurs.
5. If the data is not present, a **cache miss** occurs.
6. The memory interface fetches four consecutive 32-bit words from main memory.
7. The four words are combined into a 128-bit cache block.
8. The fetched block is stored in the selected cache line.
9. The controller performs the lookup again and returns the requested word.

## 📂 Repository Structure

```text
Cache-me-if-u-can/
│
├── docs/
│   ├── architecture.md
│   ├── architecture_mapping.md
│   ├── cache_storage.md
│   ├── fsm_diagram.md
│   └── mermaid-diagram.png
│
├── rtl/
│   ├── address_decoder.v
│   ├── cache_storage.v
│   ├── main_memory.v
│   ├── memory_interface.v
│   ├── cache_controller.v
│   └── cache_top.v
│
├── tb/
│   ├── address_decoder_tb.v
│   ├── cache_storage_tb.v
│   ├── memory_tb.v
│   ├── cache_controller_tb.v
│   └── cache_tb.v
│
├── traces/
│   ├── sequential.txt
│   ├── repeated.txt
│   ├── random.txt
│   └── conflict.txt
│
├── reports/
│   ├── architecture.md
│   ├── performance_analysis.md
│   ├── simulation_results.txt
│   ├── synthesis_report.md
│   └── yosys_synthesis.log
│
└── README.md
```

## 💻 Technologies and Tools Used

- **Verilog HDL** — Hardware description and RTL implementation.
- **Icarus Verilog** — Compilation and simulation.
- **VVP** — Running compiled simulations.
- **Yosys** — Logic synthesis and cell statistics.
- **GTKWave / Surfer** — Viewing simulation waveforms.
- **Visual Studio Code** — Verilog development environment.
- **Git and GitHub** — Version control and project collaboration.

## 🚀 Installation and Setup

### 1. Install Icarus Verilog

On macOS, use Homebrew:

```bash
brew install icarus-verilog
```

Verify the installation:

```bash
iverilog -V
vvp -V
```

### 2. Clone the Repository

```bash
git clone https://github.com/Khushi-jain05/Cache-me-if-u-can.git
```

Navigate into the project directory:

```bash
cd Cache-me-if-u-can
```

Create a build directory:

```bash
mkdir -p build
```

## 🧪 Running the Testbenches

Run the following commands from the repository root directory.

### 1. Address Decoder Testbench

```bash
iverilog -g2012 -Wall -s address_decoder_tb \
-o build/address_decoder_sim \
rtl/address_decoder.v tb/address_decoder_tb.v

vvp build/address_decoder_sim
```

### 2. Cache Storage Testbench

```bash
iverilog -g2012 -Wall -s cache_storage_tb \
-o build/cache_storage_sim \
rtl/cache_storage.v tb/cache_storage_tb.v

vvp build/cache_storage_sim
```

### 3. Main Memory and Refill Testbench

```bash
iverilog -g2012 -Wall -s memory_tb \
-o build/memory_sim \
rtl/address_decoder.v rtl/cache_storage.v \
rtl/main_memory.v rtl/memory_interface.v \
tb/memory_tb.v

vvp build/memory_sim
```

### 4. Cache Controller Testbench

```bash
iverilog -g2012 -Wall -s cache_controller_tb \
-o build/cache_controller_sim \
rtl/*.v tb/cache_controller_tb.v

vvp build/cache_controller_sim
```

### 5. Integrated Cache Testbench

```bash
iverilog -g2012 -Wall -s cache_tb \
-o build/cache_sim \
rtl/*.v tb/cache_tb.v

vvp build/cache_sim
```

**Note:** Run the integrated testbench from the project root because it reads input traces from the `traces/` directory.

The integrated testbench also generates a VCD waveform file that can be opened using a waveform viewer.

## 📊 Simulation Results

The integrated simulation report records the following results:

| Access Pattern | Total Accesses | Hits | Misses | Errors |
|---|---:|---:|---:|---:|
| Sequential | 12 | 9 | 3 | 0 |
| Repeated | 9 | 8 | 1 | 0 |
| Random | 12 | 2 | 10 | 0 |
| Conflict | 9 | 0 | 9 | 0 |
| **Total** | **42** | **19** | **23** | **0** |

### Performance Analysis

| Metric | Result |
|---|---:|
| Total Memory Accesses | 42 |
| Cache Hits | 19 |
| Cache Misses | 23 |
| Hit Rate | 45.24% |
| Miss Rate | 54.76% |
| Average Hit Latency | 1 cycle |
| Average Miss Latency | 8 cycles |
| Average Memory Access Time (AMAT) | 4.83 cycles |
| Data Verification Errors | 0 |

### AMAT Calculation

Average Memory Access Time is calculated using:

```text
AMAT = Hit Time + (Miss Rate × Miss Penalty)

     = 1 + (23/42 × (8 - 1))

     = 4.83 cycles
```

The conflict trace demonstrates conflict misses using addresses that map to the same cache index but have different tags.

**Note:** These values are taken from the simulation and performance reports included in this repository.

## 🔬 Synthesis Results

The design was synthesized using Yosys.

| Parameter | Result |
|---|---|
| Synthesis Tool | Yosys 0.70+post |
| Top Module | `cache_top` |
| Generic Mapped Cells | 116,340 |
| Synthesis Status | Successful |
| Maximum Operating Frequency | Not measured |

The reported generic cell count is not an FPGA LUT count or a physical area measurement. Target-specific resource utilization and timing analysis have not been performed.

To run synthesis, if Yosys is installed:

```bash
yosys -p "read_verilog rtl/*.v; hierarchy -top cache_top; synth -top cache_top; stat"
```

## ⚠️ Current Scope and Limitations

- The CPU-facing cache interface supports read requests.
- The main-memory write port is used for initialization and testbench purposes.
- CPU store operations are not implemented.
- Write-through and write-back policies are not implemented.
- Dirty-bit handling is not implemented.
- Main memory is a functional simulation model rather than a timing-accurate external memory device.
- Maximum operating frequency has not been measured.

## 🔮 Future Improvements

- Implement CPU write operations.
- Add write-through and write-back cache policies.
- Introduce dirty-bit management.
- Extend the design to support configurable cache sizes and block sizes.
- Improve memory timing and latency modeling.
- Perform FPGA implementation and timing analysis.
- Expand randomized testing and verification coverage.

## 👩‍💻 Project Team

| Team Member | Student ID |
|---|---|
| Agrima Ojha | 2401010047 |
| Khyati Batra | 2401010229 |
| Khushi Jain | 2401010227 |
| Suhani Gupta | 2401010463 |
| Akshat Agrawal | 2401010054 |

**Course:** Modern Computer Architecture  
**Project Title:** Cache Me If U Can — Direct-Mapped Cache Controller

## 📚 Project Documentation

For more details, refer to the following files:

- [Architecture Documentation](docs/architecture.md)
- [Address Mapping](docs/architecture_mapping.md)
- [Cache Storage](docs/cache_storage.md)
- [FSM Diagram](docs/fsm_diagram.md)
- [Performance Analysis](reports/performance_analysis.md)
- [Simulation Results](reports/simulation_results.txt)
- [Synthesis Report](reports/synthesis_report.md)

---

<div align="center">

### CACHE ME IF U CAN

**Designed and implemented using Verilog HDL**

*Modern Computer Architecture — Semester Project*

</div>
