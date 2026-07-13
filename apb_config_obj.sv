package apb_config_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class apb_config_obj extends uvm_object;
`uvm_object_utils(apb_config_obj)

virtual apb_if apb_config_vif ;

function new(string name = "apb_config_obj");
super.new(name);
endfunction
endclass

endpackage