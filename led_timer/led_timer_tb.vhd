-- led timer test bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_timer_tb is
end led_timer_tb;

architecture behav of led_timer_tb is
	component led_timer
	generic (
		on_time_exp : positive
	);

	port (
		clk	: in std_logic;
		rst	: in std_logic;
		input	: in std_logic;
		led	: out std_logic
	);
	end component;

signal clk	: std_logic := '0';
signal rst	: std_logic := '1';
signal input	: std_logic := '0';
signal led	: std_logic;

begin 
	dut : led_timer
	generic map (on_time_exp => 10)
	port map (clk, rst, input, led);
	clk <= not clk after 50 ns;
	rst <= '0' after 200 ns;

	process
	begin
	wait until falling_edge(rst);
	wait until rising_edge(clk);
	input <= '1';
	wait until rising_edge(clk);
	input <= '0';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	end process;
end behav;
