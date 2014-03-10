-- data slicer test bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity data_slicer_tb is
end data_slicer_tb;

architecture behav of data_slicer_tb is
	component data_slicer
	generic (
		width		: positive;
		sam_per_bit	: positive
	);

	port (
		clk	: in std_logic;
		inclk	: in std_logic;
		outclk	: out std_logic;
		rst	: in std_logic;
		d	: in std_logic_vector(width-1 downto 0);
		q	: out std_logic
	);
	end component;

signal clk	: std_logic := '0';
signal inclk	: std_logic := '0';
signal outclk	: std_logic;
signal rst	: std_logic := '1';
signal d	: std_logic_vector(7 downto 0) := (others => '0');
signal q	: std_logic;

begin 
	dut : data_slicer
	generic map (width => 8, sam_per_bit => 8)
	port map (clk, inclk, outclk, rst, d, q);
	clk <= not clk after 50 ns;
	rst <= '0' after 200 ns;

	in_file : process
	variable input : integer;
	variable l : line;
	file vector_file : text is in "data_slicer_test.txt";
	begin
		wait until rst <= '0';
		while not endfile(vector_file) loop
			readline(vector_file, l);
			read(l, input);
			wait until rising_edge(clk);
			inclk <= '1';
			d <= std_logic_vector(to_signed(input, 8));
			wait until rising_edge(clk);
			inclk <= '0';
			-- insert delay cycles
			wait until rising_edge(clk);
			wait until rising_edge(clk);
		end loop;
	end process;

end behav;
