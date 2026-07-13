module APB(apb_if.DUT a_if);

apb_top des(
.PCLK(a_if.PCLK),
.PRESETn(a_if.PRESETn),

.start(a_if.start),
.rw(a_if.rw),
.addr(a_if.addr),
.wdata(a_if.wdata),
.byte_en(a_if.byte_en),
.prot(a_if.prot),
.rdata(a_if.rdata),
.done(a_if.done),
.error(a_if.error)
);


endmodule
