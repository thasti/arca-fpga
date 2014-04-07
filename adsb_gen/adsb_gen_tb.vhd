-- ads-b test generator test bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adsb_gen_tb is
end adsb_gen_tb;

architecture behav of adsb_gen_tb is
	component adsb_gen
	generic (
		clk_div : integer
	);

	port (
		clk	: in std_logic;
		rst	: in std_logic;
		trigger	: in std_logic;
		q	: out std_logic;
		busy	: out std_logic
	);
	end component;

signal clk	: std_logic := '0';
signal rst	: std_logic := '1';
signal trigger	: std_logic := '0';
signal q	: std_logic;
signal busy	: std_logic;

begin 
	dut : adsb_gen
	generic map (clk_div => 8)
	port map (clk, rst, trigger, q, busy);
	clk <= not clk after 50 ns;
	rst <= '0' after 200 ns;

	process
	begin
	wait until falling_edge(rst);
	wait until rising_edge(clk);
	trigger <= '1';
	wait until rising_edge(clk);
	trigger <= '0';
	end process;
end behav;
