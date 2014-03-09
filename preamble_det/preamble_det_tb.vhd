-- preamble detector test bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity preamble_det_tb is
end preamble_det_tb;

architecture behav of preamble_det_tb is
	component preamble_det
	generic
	( 
		sam_per_bit : positive := 8
	);
	port 
	(
		clk	: in std_logic;
		inclk	: in std_logic;
		rst	: in std_logic;
		d	: in std_logic;
		valid	: out std_logic
	);
	end component;

signal clk	: std_logic := '0';
signal inclk	: std_logic := '0';
signal rst	: std_logic := '1';
signal d	: std_logic := '0';
signal valid 	: std_logic;

begin 
	dut : preamble_det
	generic map (sam_per_bit => 4)
	port map (clk, inclk, rst, d, valid);
	clk <= not clk after 50 ns;
	rst <= '0' after 200 ns;

	process
	variable l : line;
	file vector_file : text is in "preamble_det_test.txt";
	begin
		wait until rst <= '0';
		while not endfile(vector_file) loop
			readline(vector_file, l);
			wait until rising_edge(clk);
			inclk <= '1';
			case l(1) is 
				when '0' =>
					d <= '0';
				when '1' => 
					d <= '1';
				when others =>
					assert false 
					report "illegal character";
					exit;
			end case;
			wait until rising_edge(clk);
			inclk <= '0';
		end loop;
	end process;
end behav;
