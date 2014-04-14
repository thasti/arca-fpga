-- Baudrate Generator

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudrategenerator is

	generic
	(
		NUM_BAUD_CLOCK_TICKS : unsigned := to_unsigned(69-1,9); -- 8.000.000 / 115.200 = 69
		TX_TRIGGER_VALUE : unsigned :=  to_unsigned(1-1,9) -- ???
	);

	port 
	(
		clk		: in std_logic;
		enable		: in std_logic;
		rst_n		: in std_logic;
		trigger_flag	: out std_logic
	);

end entity;

architecture rtl of baudrategenerator is

	component counter
	
	port 
	(
		clk		: in std_logic;
		enable		: in std_logic;
		rst_n		: in std_logic;
		clear		: in std_logic;
		cnt_out		: out std_logic_vector(9 downto 0)
	);
			
	end component;
	
	signal cnt_out 		: std_logic_vector(9 downto 0);
	signal cnt_clear	: std_logic;
	signal cnt_flag		: std_logic := '0';

begin

	cnt : counter port map
	(
		clk	=> clk,
		enable	=> enable,
		rst_n	=> rst_n,
		clear	=> cnt_clear,
		cnt_out	=> cnt_out
	);

	cnt_clear	<= (not enable) or cnt_flag;
	cnt_flag	<= '1' when ((unsigned(cnt_out) = NUM_BAUD_CLOCK_TICKS)) else '0';
	trigger_flag 	<= enable when ((unsigned(cnt_out) = TX_TRIGGER_VALUE)) else '0';

end rtl;