library verilog;
use verilog.vl_types.all;
entity sap_1_vlg_check_tst is
    port(
        ac_out          : in     vl_logic_vector(7 downto 0);
        ar_out          : in     vl_logic_vector(3 downto 0);
        cf_out          : in     vl_logic;
        dr_out          : in     vl_logic_vector(7 downto 0);
        mem_wr_out      : in     vl_logic;
        pc_out          : in     vl_logic_vector(3 downto 0);
        zf_out          : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end sap_1_vlg_check_tst;
