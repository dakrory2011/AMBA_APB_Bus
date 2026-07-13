interface apb_if(PCLK);

input PCLK;

logic PRESETn;
logic start;
logic rw; // 1 for write, 0 for read
logic [15:0] addr;
logic [31:0] wdata;
logic [3:0] byte_en;
logic [2:0] prot;

logic [31:0] rdata;
logic done;
logic error;

// Golden-reference outputs, driven by apb_golden_ref off the same
// PCLK/PRESETn/stimulus above, so it runs in lockstep with the DUT.
logic [31:0] rdata_ref;
logic done_ref;
logic error_ref;

// input wire PCLK,
// input wire PRESETn,

// input wire start,
// input wire rw, // 1 for write, 0 for read
// input wire [15:0] addr,
// input wire [31:0] wdata,
// input wire [3:0] byte_en,
// input wire [2:0] prot,

// output wire [31:0] rdata,
// output wire done,
// output wire error

modport DUT(input PCLK , PRESETn , start ,rw , addr , wdata , byte_en , prot ,
            output rdata , done , error);

modport GOLD(input PCLK , PRESETn , start ,rw , addr , wdata , byte_en , prot ,
             output rdata_ref , done_ref , error_ref);


endinterface