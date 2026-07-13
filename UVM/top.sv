import uvm_pkg::*;
import apb_test_pkg::*;
`include "uvm_macros.svh"
module top();

bit PCLK;

initial begin
PCLK=0;
forever
#5 PCLK=~PCLK;
end

apb_if a_if (PCLK);
APB  DUT (a_if);
apb_golden_ref GOLDEN (a_if);

initial a_if.PRESETn = 1'b0;

initial begin
uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top" ,"APB" , a_if) ;
uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", a_if);

run_test("apb_test");
end
endmodule
