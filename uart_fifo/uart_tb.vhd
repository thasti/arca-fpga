library ieee;
use ieee.std_logic_1164.all;

entity uart_tb is
end uart_tb;
     
architecture behav of uart_tb is
	component uart
	port
	(
		CLOCK_50 : in std_logic;
		TX	 : out std_logic
		-- TODO: add updated interface
	);
	end component;
        
	-- TODO: add updated interface 
	signal clk : std_logic := '1'; 
	signal TX : std_logic;
begin	
	tx0 : uart
		port map (CLOCK_50 => clk, TX => TX);
		-- TODO: use updated interface

	-- TODO: add process to stimulate the FIFO interface

        clk	<= not clk after 10 ns;
        
end behav;	
