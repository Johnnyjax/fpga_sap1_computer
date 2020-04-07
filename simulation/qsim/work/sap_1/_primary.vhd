library verilog;
use verilog.vl_types.all;
entity sap_1 is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        pc_out          : out    vl_logic_vector(3 downto 0);
        ac_out          : out    vl_logic_vector(7 downto 0);
        dr_out          : out    vl_logic_vector(7 downto 0);
        ar_out          : out    vl_logic_vector(3 downto 0);
        cf_out          : out    vl_logic;
        zf_out          : out    vl_logic;
        mem_wr_out      : out    vl_logic
    );
end sap_1;
