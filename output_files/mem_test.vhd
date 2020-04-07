library ieee;
use ieee.std_logic_1164.all;

entity mem_test is
	port(
		CLOCK_50 : in std_logic;
		KEY      : in std_logic_vector(3 downto 0);
		SW       : in std_logic_vector(9 downto 0);
		LEDG     : out std_logic_vector(7 downto 0)
	);
end mem_test;

architecture arch of mem_test is
begin
	mem_unit : work.altera_one_port_ram
		port map(clk => CLOCK_50, we => not(KEY(0)), 
					addr => "00" & SW(9 downto 8), 
					d => SW(7 downto 0), q => LEDG);
end arch;