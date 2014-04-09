-- adsb receiver test bench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity adsb_recv_tb is
end adsb_recv_tb;

architecture behav of adsb_recv_tb is
	component adsb_recv
	generic (
		width		: positive;
		samp_rate	: positive
	);

	port (
		clk	: in std_logic;
		rst	: in std_logic;
		adcclk	: in std_logic;
		adc_d	: in std_logic_vector(width-1 downto 0);
		adsb_tx	: out std_logic;
		uart_tx	: out std_logic;
		sof_led	: out std_logic;
		full_led: out std_logic
	);
	end component;

signal clk	: std_logic := '0';
signal rst	: std_logic := '1';
signal adcclk	: std_logic;
signal adc_d	: std_logic_vector(7 downto 0);
signal adsb_tx	: std_logic;
signal uart_tx	: std_logic;
signal sof_led	: std_logic;
signal full_led : std_logic;

begin 
	dut : adsb_recv
	generic map (width => 8, samp_rate => 16)
	port map (clk, rst, adcclk, adc_d, adsb_tx, uart_tx, sof_led, full_led);
	clk <= not clk after 50 ns;
	rst <= '0' after 200 ns;
	adc_d(7) <= '0';
	adc_d(6) <= '0';
	adc_d(5) <= adsb_tx;
	adc_d(4) <= '0';
	adc_d(3) <= '0';
	adc_d(2) <= '0';
	adc_d(1) <= '0';
	adc_d(0) <= '0';
end behav;
