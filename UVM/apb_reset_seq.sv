package apb_reset_seq_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import apb_seq_item_pack::*;

  class apb_reset_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(apb_reset_seq)
    apb_seq_item seq_item;

    rand int unsigned reset_cycles;
    constraint c_reset_len { reset_cycles inside {[2:8]}; }

    function new(string name = "apb_reset_seq");
      super.new(name);
    endfunction

    task body;
      void'(this.randomize());
      repeat (reset_cycles) begin
        seq_item = apb_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.PRESETn = 0;
        finish_item(seq_item);
      end
    endtask

  endclass

endpackage
