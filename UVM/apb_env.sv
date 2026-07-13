package apb_env_pkg;
import uvm_pkg::*;
import apb_agent_pack::* ;
import apb_coverage_collector_pack::* ;
import apb_scoreboard_pack::* ;
`include "uvm_macros.svh"

class apb_env extends uvm_env;
`uvm_component_utils(apb_env)

apb_coverage_collector cov;
apb_agent agent;
apb_scoreboard sb;

function new(string name="apb_env" , uvm_component parent = null);
super.new(name , parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
cov=apb_coverage_collector::type_id::create("cov" , this);
agent=apb_agent::type_id::create("agent" , this);
sb=apb_scoreboard::type_id::create("sb" , this);
endfunction

function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
agent.agent_ap.connect(sb.sb_export);
agent.agent_ap.connect(cov.cov_export);

endfunction
endclass
endpackage