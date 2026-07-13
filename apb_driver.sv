package apb_driver_pack;

import uvm_pkg::*;
import apb_seq_item_pack::*;
`include "uvm_macros.svh"

class apb_driver extends uvm_driver #(apb_seq_item);
  `uvm_component_utils(apb_driver)

  virtual apb_if apb_driver_vif;

  function new(string name = "apb_driver",
               uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(virtual apb_if)::get(this,"","apb_vif",apb_driver_vif))
      `uvm_fatal("NOVIF","Failed to get APB interface")
  endfunction


  task run_phase(uvm_phase phase);

    apb_seq_item seq_item;

    super.run_phase(phase);
    forever begin
      seq_item = apb_seq_item::type_id::create("seq_item");
      seq_item_port.get_next_item(seq_item);

      if (!seq_item.PRESETn) begin

        apb_driver_vif.start   <= 1'b0;
        apb_driver_vif.PRESETn <= 1'b0;
        @(negedge apb_driver_vif.PCLK);
        apb_driver_vif.PRESETn <= 1'b1;
        seq_item_port.item_done();
      end
      else begin

        apb_driver_vif.PRESETn <= seq_item.PRESETn;
        apb_driver_vif.rw      <= (seq_item.trans_type == apb_seq_item::APB_WRITE);
        apb_driver_vif.addr    <= seq_item.addr;
        apb_driver_vif.wdata   <= seq_item.wdata;
        apb_driver_vif.byte_en <= seq_item.byte_en;
        apb_driver_vif.prot    <= seq_item.pprot;

        apb_driver_vif.start   <= 1'b1;
        @(negedge apb_driver_vif.PCLK);
        apb_driver_vif.start   <= 1'b0;

        while (!apb_driver_vif.done)
          @(negedge apb_driver_vif.PCLK);

        seq_item_port.item_done();
      end

      `uvm_info("APB_DRIVER",seq_item.convert2string(),UVM_HIGH)

    end

  endtask

endclass

endpackage