module apb_registerfile(
input wire PCLK,
input wire PRESETn,

input wire write_enable,
input wire read_enable,
input wire [3:0] addr,
input wire [31:0] wdata,
input wire [3:0] wstrb,

output wire [31:0] rdata
);

reg[31:0] mem [0:15]; 
integer i;

always@(posedge PCLK , negedge PRESETn) begin
    if(~PRESETn) begin
        for(i=0;i<16;i=i+1)
            mem[i] <= 32'd0;
    end
    else
        begin
            if(write_enable)
                begin
                    if(wstrb[0])
                        mem[addr][7:0] <= wdata[7:0];
                    if(wstrb[1])
                        mem[addr][15:8] <= wdata[15:8];
                    if(wstrb[2])
                        mem[addr][23:16] <= wdata[23:16];
                    if(wstrb[3])
                        mem[addr][31:24] <= wdata[31:24];   
                end
        end
end

assign rdata = read_enable ? mem[addr] : 32'd0;

endmodule