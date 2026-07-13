package apb_sequencer_pack;
import uvm_pkg::*;
import apb_seq_item_pack:: * ;
`include "uvm_macros.svh"

class apb_sequencer extends uvm_sequencer #(apb_seq_item);
`uvm_component_utils(apb_sequencer)

function new(string name="apb_sequencer" , uvm_component parent = null);
super.new(name,parent);
endfunction

endclass


endpackage