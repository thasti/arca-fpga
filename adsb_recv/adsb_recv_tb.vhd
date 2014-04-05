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
		uart_tx	: out std_logic;
		sof_led	: out std_logic
	);
	end component;

signal clk	: std_logic := '0';
signal rst	: std_logic := '1';
signal adcclk	: std_logic;
signal adc_d	: std_logic_vector(7 downto 0) := (others => '0');
signal uart_tx	: std_logic;
signal sof_led	: std_logic;

begin 
	dut : adsb_recv
	generic map (width => 8, samp_rate => 16)
	port map (clk, rst, adcclk, adc_d, uart_tx, sof_led);
	clk <= not clk after 50 ns;
	rst <= '0' after 200 ns;

	in_file : process
	variable input : integer;
	variable l : line;
	file vector_file : text is in "adsb_recv_test.txt";
	begin
		wait until rst <= '0';
		while not endfile(vector_file) loop
			readline(vector_file, l);
			read(l, input);
			wait until rising_edge(clk);
			--if adcclk = '1' then
				adc_d <= std_logic_vector(to_signed(input, 8));
			--end if;
		end loop;
	end process;
end behav;
