//==============================================================================
// apb_test.sv
//
// Same architecture as slave_test.sv: config_obj retrieved/set via
// config_db, env built in build_phase, sequences created in build_phase and
// started on env.agent.sqr in run_phase under a single raise/drop objection.
//
// NOTE: this assumes your apb_config_obj exposes a virtual apb_if field
// named `apb_config_vif` and is registered in config_db under the key
// "APB" (mirroring slave_config_obj's `slave_config_vif` under "SLAVE").
// If your actual field/key names differ, adjust the two lines in
// build_phase that reference them.
//==============================================================================

package apb_test_pkg;
import uvm_pkg::*;
import apb_env_pkg::*;
import apb_reset_seq_pack::*;
import apb_rd_only_seq_pack::*;
import apb_wr_only_seq_pack::*;
import apb_wr_rd_seq_pack::*;
import apb_config_pkg::*;
`include "uvm_macros.svh"

class apb_test extends uvm_test;

`uvm_component_utils(apb_test)

apb_config_obj cfg ;
apb_env env;
virtual apb_if  vif;

apb_reset_seq   reset_seq;
apb_rd_only_seq rd_only_seq;
apb_wr_only_seq wr_only_seq;
apb_wr_rd_seq   wr_rd_seq;

function new(string name = "apb_test" ,uvm_component parent = null);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
env = apb_env::type_id::create("env" , this);
cfg = apb_config_obj::type_id::create("apb_config_obj_test" , this);

reset_seq   = apb_reset_seq::type_id::create("reset_seq" , this);
rd_only_seq = apb_rd_only_seq::type_id::create("rd_only_seq" , this);
wr_only_seq = apb_wr_only_seq::type_id::create("wr_only_seq" , this);
wr_rd_seq   = apb_wr_rd_seq::type_id::create("wr_rd_seq" , this);

if(!uvm_config_db #(virtual apb_if)::get(this, "" ,"APB" , cfg.apb_config_vif ) ) begin
`uvm_fatal("build_phase" , "failed to get virtual interface") end

uvm_config_db #(apb_config_obj)::set(this,"*" ,"CFG" , cfg);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);
phase.raise_objection(this);

reset_seq.start(env.agent.sqr);
`uvm_info("run-phase" , "Reset Sequence Started" , UVM_LOW)

wr_only_seq.start(env.agent.sqr);
`uvm_info("run-phase" , "Write-Only Sequence Started" , UVM_LOW)

rd_only_seq.start(env.agent.sqr);
`uvm_info("run-phase" , "Read-Only Sequence Started" , UVM_LOW)

wr_rd_seq.start(env.agent.sqr);
`uvm_info("run-phase" , "Write-Read Sequence Started" , UVM_LOW)

phase.drop_objection(this);
endtask
endclass
endpackage
