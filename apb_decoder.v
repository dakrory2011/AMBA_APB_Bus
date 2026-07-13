module apb_decoder(

input wire [15:0] PADDR,
input PSEL,
output wire PSEL0,
output wire PSEL1,
output wire PSEL2,
output wire PSEL3,
output wire PSEL_ERR
);


assign PSEL0 = (PADDR < 16'h1000 && PSEL);
assign PSEL1 = (PADDR >= 16'h1000 && PADDR < 16'h2000 && PSEL);
assign PSEL2 = (PADDR >= 16'h2000 && PADDR < 16'h3000 && PSEL);
assign PSEL3 = (PADDR >= 16'h3000 && PADDR < 16'h4000 && PSEL);
assign PSEL_ERR = PSEL && !(PSEL0 || PSEL1 || PSEL2 || PSEL3);

endmodule


// | Slave  | Address Range   |
// | ------ | --------------- |
// | Slave0 | 0x0000 - 0x0FFF |
// | Slave1 | 0x1000 - 0x1FFF |
// | Slave2 | 0x2000 - 0x2FFF |
// | Slave3 | 0x3000 - 0x3FFF |
// | (none) | 0x4000 - 0xFFFF -> PSEL_ERR |
