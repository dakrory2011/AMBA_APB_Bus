package apb_monitor_pack;
import uvm_pkg::* ;
import apb_seq_item_pack::* ;
`include "uvm_macros.svh"
class apb_monitor extends uvm_monitor;
 `uvm_component_utils(apb_monitor)

 virtual apb_if  apb_monitor_vif ;
 apb_seq_item seq_item;
 uvm_analysis_port#(apb_seq_item) mon_ap;
 function new(string name = "apb_monitor" , uvm_component parent = null);
 super.new(name, parent);
 endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
mon_ap=new("mon_ap" , this);
endfunction

task run_phase (uvm_phase phase);
super.run_phase(phase);
forever begin
seq_item=apb_seq_item::type_id::create("seq_item" , this);

@(negedge apb_monitor_vif.PCLK);

seq_item.PCLK       = apb_monitor_vif.PCLK;
seq_item.PRESETn    = apb_monitor_vif.PRESETn;
seq_item.start      = apb_monitor_vif.start;
seq_item.trans_type = apb_monitor_vif.rw ? apb_seq_item::APB_WRITE : apb_seq_item::APB_READ;
seq_item.addr       = apb_monitor_vif.addr;
seq_item.wdata      = apb_monitor_vif.wdata;
seq_item.byte_en    = apb_monitor_vif.byte_en;
seq_item.pprot      = apb_monitor_vif.prot;
seq_item.rdata      = apb_monitor_vif.rdata;
seq_item.done       = apb_monitor_vif.done;
seq_item.pslverr    = apb_monitor_vif.error;

seq_item.rdata_ref   = apb_monitor_vif.rdata_ref;
seq_item.done_ref    = apb_monitor_vif.done_ref;
seq_item.pslverr_ref = apb_monitor_vif.error_ref;

//   rand apb_trans_type_e trans_type; ......... <- driven from rw
//   rand bit [15:0]        addr;      .........
//   rand bit [31:0]        wdata;     .........
//   rand logic [3:0]      byte_en;   // PSTRB   <- driven from byte_en
//   rand bit [2:0]         pprot;     // PPROT   <- driven from prot
//   bit [31:0] rdata;   // filled by monitor
//   bit        pslverr; // filled by monitor     <- driven from error
//   bit        PCLK, PRESETn, start, done;       // observation-only

mon_ap.write(seq_item);
`uvm_info("run-phase" , seq_item.convert2string() , UVM_HIGH)
end
endtask
endclass
endpackage