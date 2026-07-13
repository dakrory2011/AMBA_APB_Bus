package apb_seq_item_pack;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class apb_seq_item extends uvm_sequence_item;
    `uvm_object_utils(apb_seq_item)

    typedef enum bit {
      APB_READ  = 1'b0,   // rw=0 => read
      APB_WRITE = 1'b1    // rw=1 => write
    } apb_trans_type_e;

  
    localparam int        NUM_SLAVES     = 4;
    localparam bit [15:0] SLAVE_SIZE     = 16'h1000;
    localparam int        REGS_PER_SLAVE = 16;
    localparam bit [15:0] REG_OFFSET_MAX = 16'h3C;

    rand apb_trans_type_e trans_type;
    rand bit  [15:0]      addr;      
    rand bit  [31:0]      wdata;     
    rand logic [3:0]      byte_en;   
    rand bit  [2:0]       pprot;    

    rand bit              invalid_addr;  
    rand bit              invalid_kind;  
                                         
    rand int unsigned     slave_sel;     
    rand int unsigned     reg_sel;       

    rand bit               PRESETn;      

    bit [31:0]   rdata;   
    bit          pslverr;      
    int unsigned wait_cycles;   

    logic [31:0] rdata_ref;
    bit          done_ref;
    bit          pslverr_ref;

  
    bit          PCLK;
    logic        start;
    bit          done;

    int unsigned          trans_id;
    static int unsigned   trans_id_ctr   = 0;
    static bit            prev_invalid   = 1'b0;
    bit                   allow_invalid   = 1'b1;  
    bit                   allow_zero_strb = 1'b0;  

// APB_1
  constraint c_PRESETn {
      PRESETn dist {1 := 95, 0 := 5};
    }
// APB_2
    constraint c_invalid_addr_dist {
      allow_invalid == 1 -> invalid_addr dist {1'b0 := 95, 1'b1 := 5};
      allow_invalid == 0 -> invalid_addr == 1'b0;
    }
// APB_3
    constraint c_slave_reg_range {
      slave_sel inside {[0:NUM_SLAVES-1]};
      reg_sel   inside {[0:REGS_PER_SLAVE-1]};
    }
// APB_4
    constraint c_addr_valid {
      (invalid_addr == 0) ->
        addr == (slave_sel * SLAVE_SIZE) + (reg_sel * 4);
    }
// APB_5
    constraint c_addr_invalid_in_window {
      (invalid_addr == 1 && invalid_kind == 0) ->
        addr inside {[(slave_sel * SLAVE_SIZE) + REG_OFFSET_MAX + 4 :
                      (slave_sel * SLAVE_SIZE) + SLAVE_SIZE - 1]};
    }
// APB_6
    constraint c_addr_invalid_unmapped {
      (invalid_addr == 1 && invalid_kind == 1) ->
        addr inside {[16'h4000 : 16'hFFFF]};
    }
// APB_7
    constraint c_byte_en_valid {
      (trans_type == APB_WRITE && !allow_zero_strb) -> byte_en != 4'b0000;
    }
// APB_8
    constraint c_write_cmd {
      trans_type == APB_WRITE;
    }
// APB_9
    constraint c_read_cmd {
      trans_type == APB_READ;
    }
// APB_10
    constraint c_force_valid_addr {
      invalid_addr == 1'b0;
    }
// APB_11
    constraint c_no_reset {
      PRESETn == 1'b1;
    }

    function void pre_randomize();
      allow_invalid = !prev_invalid;
    endfunction

    function void post_randomize();
      trans_id     = trans_id_ctr++;
      prev_invalid = invalid_addr;
    endfunction

    function bit is_write();
      return (trans_type == APB_WRITE);
    endfunction

    function bit is_read();
      return (trans_type == APB_READ);
    endfunction

    function void clear_response();
      rdata       = '0;
      pslverr     = 1'b0;
      wait_cycles = 0;
    endfunction

    function string convert2string();
      string s;
      s = $sformatf("id:%0d type:%s addr:0x%0h wdata:0x%0h byte_en:%b pprot:%b",
                     trans_id, trans_type.name(), addr, wdata, byte_en, pprot);
      s = {s, $sformatf(" | rdata:0x%0h pslverr:%b wait_cycles:%0d",
                         rdata, pslverr, wait_cycles)};
      return s;
    endfunction

  endclass
endpackage