package apb_scoreboard_pack;
import uvm_pkg::*;
import apb_seq_item_pack::*;
`include "uvm_macros.svh"

class apb_scoreboard extends uvm_scoreboard;
`uvm_component_utils(apb_scoreboard)

virtual apb_if vif;
uvm_analysis_export#(apb_seq_item) sb_export;
uvm_tlm_analysis_fifo#(apb_seq_item) sb_fifo;
apb_seq_item seq_item;

integer correct_count = 0;
integer error_count   = 0;

function new(string name = "apb_scoreboard", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
sb_fifo   = new("sb_fifo", this);
sb_export = new("sb_export", this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
sb_export.connect(sb_fifo.analysis_export);
endfunction


task run_phase(uvm_phase phase);
super.run_phase(phase);

forever begin

sb_fifo.get(seq_item);


// APB_10
if(seq_item.done == seq_item.done_ref)
correct_count++;
else begin
error_count++;
`uvm_info("run-phase", $sformatf(" done Mismatch! , Data from DUT:%b , while Data from Ref: %b (addr=0x%0h type=%s)", seq_item.done, seq_item.done_ref, seq_item.addr, seq_item.trans_type.name()), UVM_NONE)
end

// APB_11 - pslverr check
if(seq_item.done) begin
if(seq_item.pslverr == seq_item.pslverr_ref)
correct_count++;
else begin
error_count++;
`uvm_info("run-phase", $sformatf(" pslverr Mismatch! , Data from DUT:%b , while Data from Ref: %b (addr=0x%0h)", seq_item.pslverr, seq_item.pslverr_ref, seq_item.addr), UVM_NONE)
end

// APB_12 - rdata check
if(seq_item.rdata == seq_item.rdata_ref)
correct_count++;
else begin
error_count++;
`uvm_info("run-phase", $sformatf(" rdata Mismatch! , Data from DUT:%0h , while Data from Ref: %0h (addr=0x%0h type=%s)", seq_item.rdata, seq_item.rdata_ref, seq_item.addr, seq_item.trans_type.name()), UVM_NONE)
end
end

end
endtask


function void compare_final_registers(
    input logic [31:0] gold_mem [0:3][0:15],
    input logic [31:0] dut_s0   [0:15],
    input logic [31:0] dut_s1   [0:15],
    input logic [31:0] dut_s2   [0:15],
    input logic [31:0] dut_s3   [0:15]);

  logic [31:0] dut_mem [0:3][0:15];
  int reg_errors;
  reg_errors = 0;
  dut_mem[0] = dut_s0; dut_mem[1] = dut_s1; dut_mem[2] = dut_s2; dut_mem[3] = dut_s3;

  for (int slv = 0; slv < 4; slv++) begin
    for (int r = 0; r < 16; r++) begin
      if (gold_mem[slv][r] == dut_mem[slv][r])
        correct_count++;
      else begin
        error_count++;
        reg_errors++;
        `uvm_info("run-phase", $sformatf(
          " register Mismatch! slave%0d reg[%0d] , Data from DUT:%0h , while Data from Ref: %0h",
          slv, r, dut_mem[slv][r], gold_mem[slv][r]), UVM_NONE)
      end
    end
  end

  if (reg_errors == 0)
    `uvm_info("run-phase", "final register-file check: PASS (64/64 registers match)", UVM_LOW)
endfunction


function void report_phase (uvm_phase phase);
super.report_phase(phase);

`uvm_info("report-phase" , $sformatf("Number of Succesful Transaction: %d" , correct_count) , UVM_LOW)
`uvm_info("report-phase" , $sformatf("Number of Failed Transaction: %d" , error_count) , UVM_LOW)
endfunction

endclass
endpackage
