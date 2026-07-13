module apb_master(

input wire PCLK,
input wire PRESETn,

//=====================
// CPU Interface
//=====================

input wire start,
input wire rw, // 1 for write, 0 for read
input wire [15:0] addr,
input wire [31:0] wdata,
input wire [3:0] byte_en,
input wire [2:0] prot,

output reg [31:0] rdata,
output reg done,
output reg error,

//=====================
// APB Interface
//=====================

input wire [31:0] PRDATA,
input wire PREADY,
input wire PSLVERR,

output wire [15:0] PADDR,
output wire [31:0] PWDATA,
output reg PSEL,
output reg PENABLE,
output wire PWRITE,
output reg [2:0] PPROT,
output reg [3:0] PSTRB

);

localparam IDLE = 2'b00;
localparam SETUP = 2'b01;
localparam ACCESS = 2'b10;

reg [1:0] cs, ns;
reg [31:0] wdata_reg;
reg [15:0] addr_reg ;
reg rw_reg;

reg [31:0] read_reg;

always@(posedge PCLK , negedge PRESETn) begin
    if (~PRESETn) begin
        cs <= IDLE;
    end
    else begin
        cs <= ns;
    end
end

always@(*) begin
case(cs)

IDLE: begin
if(start) 
    ns = SETUP;
else
    ns = IDLE;
end

SETUP: begin
    ns = ACCESS;

end

ACCESS: begin
    if(PREADY && !start)
        ns = IDLE;
    else if (!PREADY)
        ns = ACCESS;
    else if (PREADY && start)
        ns = SETUP;
end

default: ns = IDLE;
endcase
end

always@(posedge PCLK , negedge PRESETn) begin
    if(~PRESETn) begin

        PPROT <= 0;
        PSTRB <= 0;
        error <= 0;
        done <= 0;
        addr_reg <= 0;
        wdata_reg <= 0;
        rw_reg <= 0;
    end
    else begin
        case(cs)
                IDLE: begin
                    PSEL<=0;
                    PENABLE<=0;
                    done<=0;
                    error<=0;
                    if(ns==SETUP) begin
                           addr_reg <= addr;
                           wdata_reg <= wdata;
                           rw_reg <= rw;
                           PSEL <= 1;
                     end
                     end

                SETUP: begin
                        PENABLE<=0;
                        PSEL <= 1;
                        done<=0;
                        PSTRB <= rw_reg ? byte_en : 4'b0000;
                        PPROT <= prot;
                        if(ns==ACCESS) begin
                            PENABLE <= 1;
                                end
                end

                ACCESS : begin
                    if(~PREADY) begin
                        done<=0;
                    end
                    else if(PREADY) begin
                            if(~rw_reg) begin
                                read_reg <= PRDATA;
                                rdata <= PRDATA;
                            end

                            if(PSLVERR)
                                error <= 1 ;
                            else
                                error <= 0 ;

                            done <=1;
                            if(ns==SETUP) begin
                                addr_reg <= addr;
                                wdata_reg <= wdata;
                                rw_reg <= rw;
                                PSEL <= 1;
                                PENABLE <= 0; // must be low during SETUP (APB protocol);
                                              // previously left at 1 from the prior
                                              // ACCESS cycle on back-to-back transfers
                                done<=0;
                                error<=0;
                            end
                

                         end 

                end



        endcase
     
        end
    end
assign PADDR =  addr_reg ;
assign PWDATA = wdata_reg ;
assign PWRITE = rw_reg ;
endmodule