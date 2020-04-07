library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity sap_1 is
	port(
		clk, reset : in std_logic;
		--register outputs
		pc_out : out std_logic_vector(3 downto 0);
		ac_out : out std_logic_vector(7 downto 0);
		dr_out : out std_logic_vector(7 downto 0);
		ar_out : out std_logic_vector(3 downto 0);
		cf_out, zf_out : out std_logic;
		mem_wr_out : out std_logic
	);
end sap_1;

architecture arch of sap_1 is
	type state_type is(reset_pc,fetch, decode,execute_nop, execute_add, execute_sub,
							 execute_sta, execute_sta2, execute_ldi, execute_jmp, execute_jc,
							 execute_jz, execute_out, execute_hlt, execute_lda);
	signal state_reg, state_next : state_type;
	signal inst_reg, inst_next : std_logic_vector(7 downto 0);
	signal mem_data_reg : std_logic_vector(7 downto 0);
	signal mem_data : std_logic_vector(7 downto 0);
	signal ac_reg, ac_next : std_logic_vector(8 downto 0);
	signal pc_reg, pc_next : std_logic_vector(3 downto 0);
	signal mem_addr_reg : std_logic_vector(3 downto 0);
	signal mem_addr : std_logic_vector(3 downto 0);
	signal memory_write : std_logic;
	signal zf_reg, zf_next, cf_reg, cf_next : std_logic;
begin
		memory : altsyncram
 		generic map(operation_mode => "SINGLE_PORT",
						width_a => 8,
						widthad_a => 4,
						lpm_type => "altsyncram",
						outdata_reg_a => "UNREGISTERED",
						init_file => "program.mif",
						intended_device_family => "Cyclone")
		port map(wren_a => memory_write, clock0 => clk,
					address_a => mem_addr, data_a => ac_reg(7 downto 0),
					q_a => mem_data);
	process(clk, reset)
	begin
		if(reset = '1') then
			state_reg <= reset_pc;
			inst_reg <= (others => '0');
			--mem_data_reg <= (others => '0');
			ac_reg <= (others => '0');
			pc_reg <= (others => '0');
			mem_addr_reg <= (others => '0');
			cf_reg <= '0';
			zf_reg <= '0';
		elsif(clk'event and clk = '1') then
			state_reg <= state_next;
			inst_reg <= inst_next;
			mem_data_reg <= mem_data;
			ac_reg <= ac_next;
			pc_reg <= pc_next;
			mem_addr_reg <= mem_addr;
			cf_reg <= cf_next;
			zf_reg <= zf_next;
		end if;
	end process;
	
	process(state_reg, inst_reg, mem_data_reg, mem_data, ac_reg, pc_reg, cf_reg, zf_reg)
	begin
		state_next <= state_reg;
		inst_next <= inst_reg;
		ac_next <= ac_reg;
		pc_next <= pc_reg;
		memory_write <= '0';
		case state_reg is
			when reset_pc =>
				pc_next <= (others => '0');
				ac_next <= (others => '0');
				state_next <= fetch;
			when fetch =>
				inst_next <= mem_data;
				pc_next <= pc_reg + 1;
				state_next <= decode;
			when decode =>
				case inst_reg(7 downto 4) is
					when "0000" =>
						state_next <= execute_nop;
					when "0001" =>
						state_next <= execute_lda;
					when "0010" =>
						state_next <= execute_add;
					when "0011" =>
						state_next <= execute_sub;
					when "0100" =>
						state_next <= execute_sta;
					when "0101" =>
						state_next <= execute_ldi;
					when "0110" =>
						state_next <= execute_jmp;
					when "0111" =>
						state_next <= execute_jc;
					when "1000" =>
						state_next <= execute_jz;
					when "1110" =>
						state_next <= execute_out;
					when "1111" =>
						state_next <= execute_hlt;
					when others =>
						state_next <= fetch;
				end case;
			when execute_nop =>
				state_next <= fetch;
			when execute_lda =>
				ac_next <= '0' & mem_data;
				state_next <= fetch; 
			when execute_add =>
				ac_next <= ('0' & ac_reg(7 downto 0)) + ('0' & mem_data);
				state_next <= fetch;
			when execute_sub =>
				ac_next <= ('0' & ac_reg(7 downto 0)) - ('0' & mem_data);
				state_next <= fetch;
			when execute_sta =>
				memory_write <= '1';
				state_next <= execute_sta2;
			when execute_sta2 =>
				state_next <= fetch;
			when execute_ldi =>
				ac_next <= "00000" & inst_reg(3 downto 0);
				state_next <= fetch;
			when execute_jmp =>
				pc_next <= inst_reg(3 downto 0);
				state_next <= fetch;
			when execute_jc =>
				if(cf_reg = '1') then	
					pc_next <= inst_reg(3 downto 0);
				end if;
				state_next <= fetch;
			when execute_jz =>
				if(zf_reg = '1') then	
					pc_next <= inst_reg(3 downto 0);
				end if;
				state_next <= fetch;
			when execute_out =>
				state_next <= fetch;
			when execute_hlt =>
				--state_next <= fetch;
		end case;
	end process;
	
	mem_addr   <= (others => '0') when state_reg = reset_pc else
						pc_reg when state_reg = fetch else
						inst_reg(3 downto 0) when state_reg = decode else
						pc_reg when state_reg = execute_nop else
						pc_reg when state_reg = execute_add else
						pc_reg when state_reg = execute_sub else
						inst_reg(3 downto 0) when state_reg = execute_sta else
						pc_reg when state_reg = execute_sta2 else
						pc_reg when state_reg = execute_lda else
						pc_reg when state_reg = execute_ldi else
						inst_reg(3 downto 0) when state_reg = execute_jmp else
						inst_reg(3 downto 0) when (state_reg = execute_jz) and zf_reg = '1' else
						pc_reg when (state_reg = execute_jz) and zf_reg = '0' else
						inst_reg(3 downto 0) when (state_reg = execute_jc) and cf_reg = '1' else
						pc_reg when (state_reg = execute_jc) and cf_reg = '0' else
						pc_reg when state_reg = execute_out else
						pc_reg when state_reg = execute_hlt;
	
	zf_next <= '1' when ac_reg  = 0 else
				  '0';
	cf_next <= '1' when ac_reg(8) = '1' else
				  '0';
	pc_out <= pc_reg;
	ac_out <= ac_reg(7 downto 0);
	dr_out <= mem_data;
	ar_out <= mem_addr;
	cf_out <= cf_reg;
	zf_out <= zf_reg;
end arch;				