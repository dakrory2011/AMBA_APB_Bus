package apb_agent_pack;
import uvm_pkg::* ;
import apb_config_pkg::*;
import apb_seq_item_pack::* ;
import apb_sequencer_pack::* ;
import apb_driver_pack::* ;
import apb_monitor_pack::* ;

`include "uvm_macros.svh"

class apb_agent extends uvm_agent;
`uvm_component_utils(apb_agent)
apb_sequencer sqr;
apb_driver drv;
apb_monitor mon;
apb_config_obj cfg;
 uvm_analysis_port#(apb_seq_item) agent_ap;

function new(string name="apb_agent" , uvm_component parent = null);
 super.new(name , parent);
 endfunction

 function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(apb_config_obj)::get(this,"","CFG" , cfg)) begin
`uvm_fatal("build-phase", "Failed to get Config Object") 
end
drv=apb_driver::type_id::create("drv", this);
mon=apb_monitor::type_id::create("mon" , this);
sqr=apb_sequencer::type_id::create("sqr" , this);
agent_ap= new("agent_ap", this);
 endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
drv.apb_driver_vif=cfg.apb_config_vif;
mon.apb_monitor_vif=cfg.apb_config_vif;
mon.mon_ap.connect(agent_ap);
drv.seq_item_port.connect(sqr.seq_item_export);
endfunction

endclass
endpackage