module apb_top(
input wire PCLK,
input wire PRESETn,

input wire start,
input wire rw, // 1 for write, 0 for read
input wire [15:0] addr,
input wire [31:0] wdata,
input wire [3:0] byte_en,
input wire [2:0] prot,

output wire [31:0] rdata,
output wire done,
output wire error
);

wire [15:0] PADDR;
wire PSEL;
wire PSEL0;
wire PSEL1;
wire PSEL2;
wire PSEL3;
wire PSEL_ERR;
wire PENABLE;
wire PSLVERR;
wire PSLVERR0;
wire PSLVERR1;
wire PSLVERR2;
wire PSLVERR3;
wire PREADY;
wire PREADY0;
wire PREADY1;
wire PREADY2;
wire PREADY3;
wire [31:0] PWDATA;
wire [31:0] PRDATA;
wire [31:0] PRDATA0;
wire [31:0] PRDATA1;
wire [31:0] PRDATA2;
wire [31:0] PRDATA3;
wire PWRITE;
wire [2:0] PPROT;
wire [3:0] PSTRB;

apb_master master(
.PCLK(PCLK),
.PRESETn(PRESETn),
.start(start),
.rw(rw),
.addr(addr),
.wdata(wdata),
.byte_en(byte_en),
.prot(prot),
.rdata(rdata),
.done(done),
.error(error),
.PRDATA(PRDATA),
.PREADY(PREADY),
.PSLVERR(PSLVERR),
.PADDR(PADDR),
.PWDATA(PWDATA),
.PSEL(PSEL),
.PENABLE(PENABLE),
.PWRITE(PWRITE),
.PPROT(PPROT),
.PSTRB(PSTRB)

);

apb_decoder Decoder(
.PADDR(PADDR),
.PSEL(PSEL),
.PSEL0(PSEL0),
.PSEL1(PSEL1),
.PSEL2(PSEL2),
.PSEL3(PSEL3),
.PSEL_ERR(PSEL_ERR)
);

apb_slave slave0(

.PCLK(PCLK),
.PRESETn(PRESETn),
.PSEL(PSEL0),
.PENABLE(PENABLE),
.PWRITE(PWRITE),
.PADDR(PADDR),
.PWDATA(PWDATA),
.PSTRB(PSTRB),
.PRDATA(PRDATA0),
.PREADY(PREADY0),
.PSLVERR(PSLVERR0)

);

apb_slave slave1(
.PCLK(PCLK),
.PRESETn(PRESETn),
.PSEL(PSEL1),
.PENABLE(PENABLE),
.PWRITE(PWRITE),
.PADDR(PADDR),
.PWDATA(PWDATA),
.PSTRB(PSTRB),
.PRDATA(PRDATA1),
.PREADY(PREADY1),
.PSLVERR(PSLVERR1)

);

apb_slave slave2(

.PCLK(PCLK),
.PRESETn(PRESETn),
.PSEL(PSEL2),
.PENABLE(PENABLE),
.PWRITE(PWRITE),
.PADDR(PADDR),
.PWDATA(PWDATA),
.PSTRB(PSTRB),
.PRDATA(PRDATA2),
.PREADY(PREADY2),
.PSLVERR(PSLVERR2)

);

apb_slave slave3(
.PCLK(PCLK),
.PRESETn(PRESETn),
.PSEL(PSEL3),
.PENABLE(PENABLE),
.PWRITE(PWRITE),
.PADDR(PADDR),
.PWDATA(PWDATA),
.PSTRB(PSTRB),
.PRDATA(PRDATA3),
.PREADY(PREADY3),
.PSLVERR(PSLVERR3)

);

apb_mux MUX
(
.PSEL0(PSEL0),
.PSEL1(PSEL1),
.PSEL2(PSEL2),
.PSEL3(PSEL3),
.PSEL_ERR(PSEL_ERR),
.PRDATA0(PRDATA0),
.PSLVERR0(PSLVERR0),
.PREADY0(PREADY0),
.PRDATA1(PRDATA1),
.PSLVERR1(PSLVERR1),
.PREADY1(PREADY1),
.PRDATA2(PRDATA2),
.PSLVERR2(PSLVERR2),
.PREADY2(PREADY2),
.PRDATA3(PRDATA3),
.PSLVERR3(PSLVERR3),
.PREADY3(PREADY3),
.PRDATA(PRDATA),
.PSLVERR(PSLVERR),
.PREADY(PREADY)
);


`ifdef SIM
//APB_22
property PRESETn_clear;
@(posedge PCLK)
( !PRESETn |-> (done==0 && error==0)      );
endproperty

assert property(PRESETn_clear);
cover property(PRESETn_clear);
 
//APB_23
property setup_signals;
@(posedge PCLK)
(start |=> (PSEL==1 && ~PENABLE));
endproperty

assert property (setup_signals);
cover property (setup_signals);

//APB_24
property access_signals;
@(posedge PCLK)
((PSEL & ~PENABLE) |=>(PSEL & PENABLE));
endproperty 

assert property (access_signals);
cover property (access_signals);

//APB_25
property wait_slave;
@(posedge PCLK)
((PSEL&PENABLE) |-> ##[1:$] (PREADY));
endproperty 

assert property(wait_slave);
cover property(wait_slave);

//APB_26
property finish_transaction;
@(posedge PCLK)
((start) |-> ##[1:$] (done || error));
endproperty

assert property(finish_transaction);
cover property(finish_transaction);

//APB_27
property write_data_stable;
@(posedge PCLK)
(PSEL && PENABLE && PWRITE && !PREADY)
|=> $stable(PWDATA);
endproperty

assert property(write_data_stable);
cover property(write_data_stable);

//APB_28
property address_stable;
@(posedge PCLK)
(PSEL && PENABLE && !PREADY)
|=> $stable(PADDR);
endproperty

assert property(address_stable);
cover property(address_stable);

//APB_29
property pstrb_stable;
@(posedge PCLK) disable iff(!PRESETn)
(PSEL && PENABLE && !PREADY)
|=> $stable(PSTRB);
endproperty

assert property(pstrb_stable);
cover property(pstrb_stable);

//APB_30
property invalid_address;
  @(posedge PCLK)
  (PADDR >= 16'h4000) |-> PSLVERR;
endproperty

assert property(invalid_address);
cover property(invalid_address);

//APB_31
property one_slave_only;
@(posedge PCLK)
$onehot0({PSEL0,PSEL1,PSEL2,PSEL3});
endproperty

assert property(one_slave_only);
cover property(one_slave_only);

//APB_32
property invalid_decode;
@(posedge PCLK)
PSEL_ERR |-> !(PSEL0||PSEL1||PSEL2||PSEL3);
endproperty

assert property(invalid_decode);
cover property(invalid_decode);

`endif

endmodule