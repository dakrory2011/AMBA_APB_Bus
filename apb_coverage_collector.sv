package apb_coverage_collector_pack;
import uvm_pkg::* ;
import apb_seq_item_pack::* ;
`include "uvm_macros.svh"

class apb_coverage_collector extends uvm_component;
`uvm_component_utils(apb_coverage_collector)

apb_seq_item seq_item ;
uvm_analysis_export#(apb_seq_item) cov_export;
uvm_tlm_analysis_fifo#(apb_seq_item) cov_fifo;

covergroup CovGroupSys;
//APB_12
  cp_reset: coverpoint seq_item.PRESETn {
      bins in_reset     = {1'b0};
      bins out_of_reset = {1'b1};
  }

endgroup

covergroup CovGroupTxn;

  //APB_13
  cp_trans_type: coverpoint seq_item.trans_type {
      bins write = {apb_seq_item::APB_WRITE};
      bins read  = {apb_seq_item::APB_READ};
  }

  //APB_14
  cp_slave: coverpoint seq_item.addr[15:12] {
      bins slave0   = {4'h0};
      bins slave1   = {4'h1};
      bins slave2   = {4'h2};
      bins slave3   = {4'h3};
      bins unmapped = {[4'h4:4'hF]};
  }

  //APB_15
  cp_offset_valid: coverpoint (seq_item.addr[11:0] <= 12'h3C) {
      bins valid_offset   = {1'b1};
      bins invalid_offset = {1'b0};
  }

  //APB_16
  cp_reg_sel: coverpoint seq_item.addr[5:2] {
      bins reg_idx[16] = {[0:15]};
  }

  //APB_17
  cp_byte_en: coverpoint seq_item.byte_en {
      bins byte0       = {4'b0001};
      bins byte1       = {4'b0010};
      bins byte2       = {4'b0100};
      bins byte3       = {4'b1000};
      bins halfword_lo = {4'b0011};
      bins halfword_hi = {4'b1100};
      bins fullword    = {4'b1111};
      bins other_mix   = default;
  }

  //APB_18
  cp_pslverr: coverpoint seq_item.pslverr {
      bins error = {1'b1};
      bins ok    = {1'b0};
  }

  //APB_19
  cross_type_slave: cross cp_trans_type, cp_slave;

  //APB_20
  cross_type_offset: cross cp_trans_type, cp_offset_valid;

  //APB_21
  cross_slave_offset: cross cp_slave, cp_offset_valid {
      ignore_bins unmapped_ignore = binsof(cp_slave.unmapped);
  }

endgroup

function new(string name="apb_coverage_collector" , uvm_component parent = null);
super.new(name, parent);
CovGroupSys = new();
CovGroupTxn = new();
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
cov_export = new("cov_export" , this);
cov_fifo = new("cov_fifo" , this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
cov_export.connect(cov_fifo.analysis_export);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
forever begin
cov_fifo.get(seq_item);
Sample();
end
endtask
task Sample();
    CovGroupSys.sample();

    if(seq_item.PRESETn == 1 && seq_item.done)
      CovGroupTxn.sample();
  endtask

endclass
endpackage