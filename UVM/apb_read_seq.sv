package apb_rd_only_seq_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import apb_seq_item_pack::*;

  class apb_rd_only_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(apb_rd_only_seq)
      apb_seq_item seq_item;
    function new(string name = "apb_rd_only_seq");
      super.new(name);
    endfunction

    task body;
      repeat (1000) begin
         seq_item = apb_seq_item::type_id::create("seq_item");
        start_item(seq_item);
        seq_item.constraint_mode(1);

        seq_item.c_write_cmd.constraint_mode(0);
        // seq_item.c_PRESETn.constraint_mode(0);
        seq_item.c_force_valid_addr.constraint_mode(0);
        assert(seq_item.randomize()) else `uvm_fatal("RANDOMIZE_FAIL","randomization failed");
        finish_item(seq_item);

      end
    endtask
  endclass

endpackage