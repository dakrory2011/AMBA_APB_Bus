module apb_slave(
input PCLK,
input PRESETn,


input PSEL,
input PENABLE,
input PWRITE,
input [15:0] PADDR,
input [31:0] PWDATA,
input [3:0] PSTRB,

output reg [31:0] PRDATA,
output reg PREADY,
output reg PSLVERR
);

wire write_enable;
wire read_enable;
wire [3:0] reg_addr;
wire [31:0] write_data;
wire [31:0] read_data;
wire [3:0] wstrb;
wire addr_valid;


apb_registerfile rf(
.PCLK(PCLK),
.PRESETn(PRESETn),
.write_enable(write_enable),
.read_enable(read_enable),
.addr(reg_addr),
.wdata(write_data),
.wstrb(wstrb),
.rdata(read_data)
);


always@(posedge PCLK , negedge PRESETn)
    begin
        if(~PRESETn) begin
            
            PREADY <= 0;
            PRDATA <= 0;
            PSLVERR <= 0;
            end
        else
            begin
                 PREADY  <= 1'b0;
                 PSLVERR <= 1'b0;
            if(PSEL && PENABLE) begin
                PREADY <=1 ;
                if(!addr_valid)
                    PSLVERR <=1;
               else begin
                if(read_enable)
                    PRDATA <= read_data;
               end
            end
            end

    end

assign addr_valid = (PADDR[11:0] <= 12'h3C);
assign write_enable = PSEL && PENABLE && PWRITE && addr_valid;
assign read_enable = PSEL && PENABLE && !PWRITE && addr_valid;
assign reg_addr = PADDR[5:2];
assign write_data = PWDATA;
assign wstrb = PSTRB;
endmodule
