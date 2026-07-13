//==============================================================================
// apb_golden_ref.sv
//
// Cycle-accurate golden reference model for apb_top. Instantiated ALONGSIDE
// the real DUT in the testbench, sharing the same apb_if instance, so both
// run off the identical PCLK/PRESETn/stimulus every cycle:
//
//   apb_top        dut        (.PCLK(a_if.PCLK), .PRESETn(a_if.PRESETn),
//                               .start(a_if.start), ..., .rdata(a_if.rdata),
//                               .done(a_if.done), .error(a_if.error));
//
//   apb_golden_ref golden_ref (a_if.GOLD);
//
// This reproduces apb_master + apb_decoder + apb_mux + apb_slave(x4) +
// apb_registerfile(x4) register-for-register, INCLUDING the RTL's actual
// timing quirks (these are deliberate, not bugs in this model):
//
//  1. PPROT is captured from the *current* `prot` input during the SETUP
//     cycle (not the value present when `start` first fired).
//  2. `rdata_ref` only updates on READ transactions -- on a WRITE it holds
//     whatever it held from the previous read, exactly like apb_master.
//  3. Back-to-back transactions: if the next `start` is already pending
//     when the current one completes (next state == SETUP while finishing
//     ACCESS), the `done_ref`/`error_ref` pulse for the completing
//     transaction is suppressed -- this falls out of the nonblocking
//     overwrite order in apb_master's ACCESS state.
//  4. A slave's PRDATA only updates on a valid-offset read; writes and
//     invalid offsets leave it holding its last valid read value.
//  5. An out-of-range address (>= 0x4000) gets the mux's synthesized
//     immediate PREADY=1/PSLVERR=1/PRDATA=0 -- no slave is selected.
//  6. PSEL/PENABLE/rdata_ref are never touched by the reset branch; they
//     only become defined the first cycle after PRESETn deasserts, once
//     cs has settled back into IDLE (matches apb_master's reset branch
//     exactly).
//
// Backdoor register-file access for end-of-test comparison:
//     golden_ref_inst.mem[slave_idx][reg_idx]      // slave_idx 0..3, reg_idx 0..15
//==============================================================================

module apb_golden_ref (apb_if.GOLD a_if);

  //-------------------------------------------------------------------
  // FSM encoding -- must match apb_master exactly
  //-------------------------------------------------------------------
  localparam IDLE   = 2'b00;
  localparam SETUP  = 2'b01;
  localparam ACCESS = 2'b10;

  reg [1:0] cs, ns;

  //-------------------------------------------------------------------
  // apb_master state
  //-------------------------------------------------------------------
  reg [31:0] wdata_reg;
  reg [15:0] addr_reg;
  reg        rw_reg;

  reg [2:0] PPROT_r;
  reg [3:0] PSTRB_r;
  reg       PSEL_r;
  reg       PENABLE_r;

  //-------------------------------------------------------------------
  // Per-slave state (0..3): mirrors apb_slave + apb_registerfile
  //-------------------------------------------------------------------
  reg [31:0] PRDATA_s  [0:3];
  reg        PREADY_s  [0:3];
  reg        PSLVERR_s [0:3];
  reg [31:0] mem        [0:3][0:15];

  //-------------------------------------------------------------------
  // Phase A: apb_decoder + apb_mux, purely combinational off the
  // PRE-edge registered master/slave state (identical to the RTL).
  //-------------------------------------------------------------------
  wire [15:0] PADDR_c  = addr_reg;
  wire [31:0] PWDATA_c = wdata_reg;
  wire        PWRITE_c = rw_reg;

  wire PSEL0    = (PADDR_c < 16'h1000)                        && PSEL_r;
  wire PSEL1    = (PADDR_c >= 16'h1000 && PADDR_c < 16'h2000) && PSEL_r;
  wire PSEL2    = (PADDR_c >= 16'h2000 && PADDR_c < 16'h3000) && PSEL_r;
  wire PSEL3    = (PADDR_c >= 16'h3000 && PADDR_c < 16'h4000) && PSEL_r;
  wire PSEL_ERR = PSEL_r && !(PSEL0 || PSEL1 || PSEL2 || PSEL3);

  reg [31:0] PRDATA_mux;
  reg        PSLVERR_mux, PREADY_mux;

  always @(*) begin
    if (PSEL0)         begin PRDATA_mux = PRDATA_s[0]; PSLVERR_mux = PSLVERR_s[0]; PREADY_mux = PREADY_s[0]; end
    else if (PSEL1)    begin PRDATA_mux = PRDATA_s[1]; PSLVERR_mux = PSLVERR_s[1]; PREADY_mux = PREADY_s[1]; end
    else if (PSEL2)    begin PRDATA_mux = PRDATA_s[2]; PSLVERR_mux = PSLVERR_s[2]; PREADY_mux = PREADY_s[2]; end
    else if (PSEL3)    begin PRDATA_mux = PRDATA_s[3]; PSLVERR_mux = PSLVERR_s[3]; PREADY_mux = PREADY_s[3]; end
    else if (PSEL_ERR) begin PRDATA_mux = 32'd0;       PSLVERR_mux = 1'b1;        PREADY_mux = 1'b1;        end
    else               begin PRDATA_mux = 32'd0;       PSLVERR_mux = 1'b0;        PREADY_mux = 1'b0;        end
  end

  //-------------------------------------------------------------------
  // master ns -- mirrors apb_master's always@(*) case(cs) block
  //-------------------------------------------------------------------
  always @(*) begin
    case (cs)
      IDLE:    ns = a_if.start ? SETUP : IDLE;
      SETUP:   ns = ACCESS;
      ACCESS:  begin
                 if (PREADY_mux && !a_if.start)      ns = IDLE;
                 else if (!PREADY_mux)               ns = ACCESS;
                 else /* PREADY_mux && start */      ns = SETUP;
               end
      default: ns = IDLE;
    endcase
  end

  //-------------------------------------------------------------------
  // cs register
  //-------------------------------------------------------------------
  always @(posedge a_if.PCLK or negedge a_if.PRESETn) begin
    if (!a_if.PRESETn) cs <= IDLE;
    else               cs <= ns;
  end

  //-------------------------------------------------------------------
  // master's registered outputs -- mirrors apb_master's 2nd always block,
  // including its nonblocking overwrite order (last assignment to a given
  // signal in a branch wins, exactly as in the RTL).
  //-------------------------------------------------------------------
  always @(posedge a_if.PCLK or negedge a_if.PRESETn) begin
    if (!a_if.PRESETn) begin
      PPROT_r        <= 0;
      PSTRB_r        <= 0;
      a_if.error_ref <= 0;
      a_if.done_ref  <= 0;
      addr_reg       <= 0;
      wdata_reg      <= 0;
      rw_reg         <= 0;
      a_if.rdata_ref <= 0;
      // PSEL_r / PENABLE_r / a_if.rdata_ref intentionally NOT reset here --
      // matches apb_master's reset branch exactly (quirk #6 above).
    end
    else begin
      case (cs)
        IDLE: begin
          PSEL_r         <= 0;
          PENABLE_r      <= 0;
          a_if.done_ref  <= 0;
          a_if.error_ref <= 0;
          if (ns == SETUP) begin
            addr_reg  <= a_if.addr;
            wdata_reg <= a_if.wdata;
            rw_reg    <= a_if.rw;
            PSEL_r    <= 1;
          end
        end

        SETUP: begin
          PENABLE_r     <= 0;
          PSEL_r        <= 1;
          a_if.done_ref <= 0;
          PSTRB_r       <= rw_reg ? a_if.byte_en : 4'b0000;
          PPROT_r       <= a_if.prot;
          if (ns == ACCESS) PENABLE_r <= 1;
        end

        ACCESS: begin
          if (!PREADY_mux) begin
            a_if.done_ref <= 0;
          end
          else begin // PREADY_mux asserted
            if (!rw_reg) begin
              a_if.rdata_ref <= PRDATA_mux;
            end
            a_if.error_ref <= PSLVERR_mux ? 1'b1 : 1'b0;
            a_if.done_ref  <= 1'b1;
            if (ns == SETUP) begin
              addr_reg       <= a_if.addr;
              wdata_reg      <= a_if.wdata;
              rw_reg         <= a_if.rw;
              PSEL_r         <= 1;
              PENABLE_r      <= 0; // must be low during SETUP (APB protocol);
                                    // mirrors the apb_master.v fix so the two
                                    // stay cycle-accurate to each other
              a_if.done_ref  <= 0;
              a_if.error_ref <= 0;
            end
          end
        end

        default: ;
      endcase
    end
  end

  //-------------------------------------------------------------------
  // Per-slave registered state + register-file (mirrors apb_slave +
  // apb_registerfile, x4). addr_valid checks only the low 12 bits, same
  // as the RTL (PADDR still carries the decoded upper slave-select bits).
  //-------------------------------------------------------------------
  wire        addr_valid = (PADDR_c[11:0] <= 12'h3C);
  wire [3:0]  reg_addr   = PADDR_c[5:2];

  genvar gi;
  generate
    for (gi = 0; gi < 4; gi = gi + 1) begin : SLAVES
      wire sel_i   = (gi == 0) ? PSEL0 : (gi == 1) ? PSEL1 : (gi == 2) ? PSEL2 : PSEL3;
      wire sel_pen = sel_i && PENABLE_r;

      always @(posedge a_if.PCLK or negedge a_if.PRESETn) begin
        if (!a_if.PRESETn) begin
          PREADY_s[gi]  <= 0;
          PSLVERR_s[gi] <= 0;
          PRDATA_s[gi]  <= 0;
        end
        else begin
          PREADY_s[gi]  <= 0;   // defaults, mirrors slave's own always block
          PSLVERR_s[gi] <= 0;
          if (sel_pen) begin
            PREADY_s[gi] <= 1;
            if (!addr_valid)
              PSLVERR_s[gi] <= 1;
            else if (!PWRITE_c)          // read_enable = sel_pen && !PWRITE && addr_valid
              PRDATA_s[gi] <= mem[gi][reg_addr];   // read BEFORE this edge's write commits
          end
        end
      end

      // register file write (separate always block in the RTL, same edge)
      integer k;
      always @(posedge a_if.PCLK or negedge a_if.PRESETn) begin
        if (!a_if.PRESETn) begin
          for (k = 0; k < 16; k = k + 1) mem[gi][k] <= 32'd0;
        end
        else if (sel_pen && PWRITE_c && addr_valid) begin   // write_enable
          if (PSTRB_r[0]) mem[gi][reg_addr][7:0]   <= PWDATA_c[7:0];
          if (PSTRB_r[1]) mem[gi][reg_addr][15:8]  <= PWDATA_c[15:8];
          if (PSTRB_r[2]) mem[gi][reg_addr][23:16] <= PWDATA_c[23:16];
          if (PSTRB_r[3]) mem[gi][reg_addr][31:24] <= PWDATA_c[31:24];
        end
      end
    end
  endgenerate

endmodule
