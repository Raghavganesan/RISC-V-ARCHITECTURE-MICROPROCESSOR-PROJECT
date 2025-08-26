 <header>
      <h1>RISC-V RV321 (RV32I Base) — Modular CPU Design</h1>
       <p class="subtitle">
        A from-scratch RISC-V RV321 architecture implementing the RV32I base instruction set with a clean, modular RTL split:
        Top Module, PC MUX, Register Files, Immediate Gen/Adder, ALU, CSR, Load/Store, Branch/Decode, Machine Control, and Write-Back MUX.
      </p>
      <div class="badges">
        <span class="pill">ISA: RISC-V RV32I</span>
        <span class="pill">Design: Modular RTL</span>
        <span class="pill">Sim: ModelSim Altera</span>
        <span class="pill">FPGA: Quartus Prime</span>
        <span class="pill">Tools: Sophus Connect, MobaXTerm</span>
      </div>
    </header>

  <section id="overview">
        <h2>1) Overview</h2>
        <p>
          This repository hosts a modular implementation of a RISC-V RV321 processor targeting the RV32I base ISA.
          The design emphasizes clarity and testability: each unit is isolated, verified with waveforms,
          and orchestrated through a top-level that covers fetch, decode, execute, memory and write-back control.
        </p>

<section id="architecture">
        <h2>2) Architecture & Pipeline</h2>
  <img width="967" height="532" alt="image" src="https://github.com/user-attachments/assets/d58f4a81-432e-4b24-afe9-72fe78034c4f" />
        <p>
          The top module wires instruction fetch and PC control (PC MUX, Register Blocks),
          immediate generation/offset addition, an integer register file, branch unit, decoder and machine-control,
          memory access via Load/Store units, ALU execution, CSR handling, and final selection through a Write-Back MUX.
        </p>
        <ul>
          <li><strong>Fetch:</strong> PC MUX &amp; Program Counter registers.</li>
          <li><strong>Decode:</strong> Decoder + Immediate Generator + Machine Control.</li>
          <li><strong>Execute:</strong> ALU / Branch Unit / Immediate Adder.</li>
          <li><strong>Memory:</strong> Load Unit &amp; Store Unit.</li>
          <li><strong>Write-Back:</strong> WB-MUX selects ALU or memory result.</li>
          <li><strong>System:</strong> CSR file supporting privileged access & CSR ops.</li>
        </ul>
        <p class="foot">Design intent: clean interfaces, predictable control, and module-level verification.</p>
      </section>

  <section id="modules">
      <h2>3) Module Reference (RV321 / RV32I)</h2>

  <details open>
        <summary>Top Module</summary>
        <p>Instantiates and connects all submodules to implement the full RV32I flow, coordinating fetch → decode → execute → memory → write-back.</p>
      </details>

  <details>
        <summary>1) PC MUX</summary>
        <ul>
          <li>Selects the next PC based on branch/jump outcomes and control.</li>
          <li>Ensures correct sequential flow (PC+4) or redirection on taken branches.</li>
        </ul>
      </details>

  <details>
        <summary>2) Register Block 1 (Program Counter Register)</summary>
        <ul>
          <li>Holds current PC; reset drives PC to 0; updates on clock edge.</li>
        </ul>
      </details>

  <details>
        <summary>3) Immediate Generator</summary>
        <ul>
          <li>Derives sign-extended immediates from instruction encoding (I/S/B/U/J types).</li>
        </ul>
      </details>

  <details>
        <summary>4) Immediate Adder</summary>
        <ul>
          <li>Adds immediate to <code>rs1</code> or <code>pc</code> (e.g., loads, stores, JALR).</li>
        </ul>
      </details>

  <details>
        <summary>5) Integer Register File</summary>
        <ul>
          <li>32 × 32-bit GPRs with read/write ports and zero-register semantics.</li>
          <li>Supports operand fetch, write-back, bypassing/reset policies.</li>
        </ul>
      </details>

  <details>
        <summary>6) Write-Enable Generator</summary>
        <ul>
          <li>Generates guarded register write-enable signals (flush-aware).</li>
        </ul>
      </details>

  <details>
        <summary>7) Instruction MUX</summary>
        <ul>
          <li>Routes the selected instruction to the decoding/execution path.</li>
        </ul>
      </details>

  <details>
        <summary>8) Branch Unit</summary>
        <ul>
          <li>Evaluates branch conditions using opcode/funct3 and register values.</li>
          <li>Drives PC redirection control when branch is taken.</li>
        </ul>
      </details>

  <details>
        <summary>9) Decoder</summary>
        <ul>
          <li>Extracts opcode/fields; generates control signals for all functional units.</li>
        </ul>
      </details>

  <details>
        <summary>10) Machine Control</summary>
        <ul>
          <li>Central control: sequences reads/writes and orchestrates unit enables.</li>
        </ul>
      </details>

  <details>
        <summary>11) CSR File</summary>
        <ul>
          <li>Holds control/status registers; supports privileged access and CSR ops.</li>
        </ul>
      </details>

  <details>
        <summary>12) Register Block 2 (Aux Registers)</summary>
        <ul>
          <li>Temporary/intermediate value storage during instruction execution.</li>
        </ul>
      </details>

  <details>
        <summary>13) Store Unit</summary>
        <ul>
          <li>Calculates addresses and writes data from <code>rs</code> to data memory.</li>
        </ul>
      </details>

  <details>
        <summary>14) Load Unit</summary>
        <ul>
          <li>Computes addresses, reads from data memory, forwards to write-back.</li>
        </ul>
      </details>

  <details>
        <summary>15) ALU</summary>
        <ul>
          <li>Implements arithmetic, logical, shifts and comparisons per RV32I.</li>
        </ul>
      </details>

  <details>
        <summary>16) Write-Back MUX Selection Unit</summary>
        <ul>
          <li>Selects between ALU and Load data for register write-back.</li>
        </ul>
      </details>
    </section>
    </div>

  <section id="toolchain">
      <h2>4) Toolchain</h2>
      <ul>
        <li><strong>Simulation:</strong> ModelSim Altera (waveform-based module validation)</li>
        <li><strong>FPGA Flow:</strong> Intel Quartus Prime (synthesis/fit)</li>
        <li><strong>Utilities:</strong> Sophus Connect, MobaXTerm</li>
      </ul>
    </section>

<section id="build">
      <h2>5) Build & Simulation</h2>
      <h3>Simulation (ModelSim Altera)</h3>
      <pre><code># 1) Create a new ModelSim project and add RTL sources for all modules
# 2) Compile all files (work library)
# 3) Launch the testbench for the Top module
# 4) Add key signals to the waveform: PC, control, ALU result, load/store buses, WB MUX
# 5) Run and inspect waveforms per module</code></pre>

  <h3>FPGA (Quartus Prime)</h3>
  <pre><code># 1) Create a Quartus project; set device to your target FPGA
# 2) Add RTL sources (Top + submodules)
# 3) Assign pins (if integrating with on-board memories/peripherals)
# 4) Compile (Analysis &amp; Synthesis → Fitter)
# 5) Program device (if hardware validation is desired)</code></pre>


<h2>Output Waveform</h2>
<img width="918" height="482" alt="image" src="https://github.com/user-attachments/assets/f704761c-5a63-4268-964f-d0a4d12e8326" />
