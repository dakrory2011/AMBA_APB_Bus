module apb_mux(
input wire PSEL0,
input wire PSEL1,
input wire PSEL2,
input wire PSEL3,
input wire PSEL_ERR,

input wire [31:0] PRDATA0,
input wire PSLVERR0,
input wire PREADY0,

input wire [31:0] PRDATA1,
input wire PSLVERR1,
input wire PREADY1,

input wire [31:0] PRDATA2,
input wire PSLVERR2,
input wire PREADY2,

input wire [31:0] PRDATA3,
input wire PSLVERR3,
input wire PREADY3,

output reg [31:0] PRDATA,
output reg PSLVERR,
output reg PREADY
);

always@(*) begin
    if(PSEL0) begin
        PRDATA = PRDATA0;
        PSLVERR = PSLVERR0;
        PREADY = PREADY0;
    end
    else if(PSEL1) begin
        PRDATA = PRDATA1;
        PSLVERR = PSLVERR1;
        PREADY = PREADY1;
    end
    else if(PSEL2) begin
        PRDATA = PRDATA2;
        PSLVERR = PSLVERR2;
        PREADY = PREADY2;
    end
     else if(PSEL3) begin
        PRDATA = PRDATA3;
        PSLVERR = PSLVERR3;
        PREADY = PREADY3;
    end
    else if(PSEL_ERR) begin
        // Address didn't land in any slave's window. Return an immediate
        // one-cycle error instead of leaving PREADY low forever, which
        // would otherwise hang the master's FSM in ACCESS indefinitely.
        PRDATA  = 32'd0;
        PSLVERR = 1'b1;
        PREADY  = 1'b1;
    end
    else begin
        PRDATA = 0;
        PSLVERR = 0;
        PREADY = 0;
    end
end

endmodule
