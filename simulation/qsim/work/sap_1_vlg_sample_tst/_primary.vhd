library verilog;
use verilog.vl_types.all;
entity sap_1_vlg_sample_tst is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end sap_1_vlg_sample_tst;
