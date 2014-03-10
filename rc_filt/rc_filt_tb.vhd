-- rc filter test bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity rc_filt_tb is
end rc_filt_tb;

architecture behav of rc_filt_tb is
	component rc_filt
	generic (
		time_const	: positive := 8;
		width		: positive := 8
	);

	port (
		clk	: in std_logic;
		inclk	: in std_logic;
		outclk	: out std_logic;
		rst	: in std_logic;
		d	: in std_logic_vector(width-1 downto 0);
		q	: out std_logic_vector(width-1 downto 0)
	);
	end component;

signal clk	: std_logic := '0';
signal inclk	: std_logic := '0';
signal outclk	: std_logic;
signal rst	: std_logic := '1';
signal d	: std_logic_vector(7 downto 0) := (others => '0');
signal q	: std_logic_vector(7 downto 0);

begin 
	dut : rc_filt
	generic map (time_const => 20, width => 8)
	port map (clk, inclk, outclk, rst, d, q);
	clk <= not clk after 50 ns;
	rst <= '0' after 200 ns;

	in_file : process
	variable input : integer;
	variable l : line;
	file vector_file : text is in "rc_filt_test.txt";
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
			wait until rising_edge(clk);
			wait until rising_edge(clk);
		end loop;
	end process;

	out_file : process
	variable lo : line;
	file output_file : text is out "rc_filt_out.txt";
	begin
		wait until rising_edge(clk);
		if outclk = '1' then
			write(lo, to_integer(signed(q)));
			writeline(output_file, lo);
		end if;
	end process;
end behav;