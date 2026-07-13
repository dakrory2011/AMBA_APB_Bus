package apb_wr_rd_seq_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import apb_seq_item_pack::*;

  class apb_wr_rd_seq extends uvm_sequence #(apb_seq_item);
    `uvm_object_utils(apb_wr_rd_seq)
      apb_seq_item wr_item;
      apb_seq_item rd_item;
    function new(string name = "apb_wr_rd_seq");
      super.new(name);
    endfunction

    task body;
      repeat (1000) begin

        // --- write a random valid register ---
        wr_item = apb_seq_item::type_id::create("wr_item");
        start_item(wr_item);
        wr_item.constraint_mode(1);

        wr_item.c_read_cmd.constraint_mode(0);
        // wr_item.c_PRESETn.constraint_mode(0);
        wr_item.c_invalid_addr_dist.constraint_mode(0);
        // NOTE: c_force_valid_addr stays ON here on purpose. This sequence
        // checks write/read-back data integrity, and the rd_item below
        // targets wr_item's exact slave_sel/reg_sel - that only means
        // anything if wr_item's address is guaranteed valid. Invalid-
        // address coverage is handled by apb_wr_only_seq/apb_rd_only_seq
        // instead, where there's no read-back dependency to preserve.

        assert(wr_item.randomize()) else `uvm_fatal("RANDOMIZE_FAIL","randomization failed");
        finish_item(wr_item);

        // --- read back the exact same register just written ---
        rd_item = apb_seq_item::type_id::create("rd_item");
        start_item(rd_item);
        rd_item.constraint_mode(1);

        rd_item.c_write_cmd.constraint_mode(0);
        // rd_item.c_PRESETn.constraint_mode(0);
        rd_item.c_invalid_addr_dist.constraint_mode(0);

        // slave_sel/reg_sel must match the write just issued - this is a
        // runtime dependency on a sibling object, which constraint_mode()
        // toggling alone can't express, so it's the one inline override.
        assert(rd_item.randomize() with {
          slave_sel == wr_item.slave_sel;
          reg_sel   == wr_item.reg_sel;
        }) else `uvm_fatal("RANDOMIZE_FAIL","randomization failed");
        finish_item(rd_item);

      end
    endtask
  endclass

endpackage
