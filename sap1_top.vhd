library ieee;
use ieee.std_logic_1164.all;

entity sap1_top is
	port(
		CLOCK_50 : in std_logic;
		KEY      : in std_logic_vector(3 downto 0);
		SW       : in std_logic_vector(9 downto 0);
		HEX3, HEX2, HEX1, HEX0 : out std_logic_vector(6 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		LEDG : out std_logic_vector(7 downto 0)
	);
end sap1_top;

architecture arch of sap1_top is
	signal output : std_logic_vector(7 downto 0);
	signal output_tick : std_logic;
	signal bcd3, bcd2, bcd1, bcd0 : std_logic_vector(3 downto 0);
begin
	sap1_unit : work.sap_1_2(arch)
		port map(clk => CLOCK_50, reset => not(KEY(0)),
					pc_out => open, ac_out => LEDR(7 downto 0), dr_out => open,
					ar_out => open, cf_out => open, zf_out => open, output_tick => output_tick,
					mem_wr_out => open, output => output, prog_or_run => SW(9),
					memory_leds => LEDG, addr_sw => ('0' & SW(8) & not(KEY(3 downto 2))),
					data_sw => SW(7 downto 0), write_en => not(KEY(1)));
	bin2bcd_unit : work.bin2bcd(arch)
		port map(clk => CLOCK_50, reset => not(KEY(0)), ready => open, 
					start => output_tick, bin => "00000" & output, done_tick => open,
					bcd3 => bcd3, bcd2 => bcd2, bcd1 => bcd1, bcd0 => bcd0);
	bcd3_unit : work.bin_to_sseg
		port map(bin => bcd3, sseg => HEX3);
	bcd2_unit : work.bin_to_sseg
		port map(bin => bcd2, sseg => HEX2);
	bcd1_unit : work.bin_to_sseg
		port map(bin => bcd1, sseg => HEX1);
	bcd0_unit : work.bin_to_sseg
		port map(bin => bcd0, sseg => HEX0);
	--LEDR(9 downto 8) <= output(1 downto 0);
end arch;