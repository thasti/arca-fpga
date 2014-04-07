library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	

entity uart_tb is
end uart_tb;
     
architecture behav of uart_tb is
	component uart
	port
	(
		clk : in std_logic;
		rst : in std_logic;
		d   : in std_logic_vector(7 downto 0);
		we  : in std_logic;
		full : out std_logic;
		tx  : out std_logic
	);
	end component;
        
	signal clk : std_logic := '1'; 
	signal rst : std_logic := '1';
	signal d : std_logic_vector(7 downto 0) := x"00";
	signal we : std_logic := '0';
	signal tx : std_logic;
	signal full : std_logic;
begin	
	tx0 : uart
		port map (clk => clk, rst => rst, d => d, we => we, tx => tx, full => full);

        clk	<= not clk after 10 ns;
	rst 	<= '0' after 50 ns;
        
	process
	begin
		wait until falling_edge(rst);
		wait until rising_edge(clk);
		d <= x"01";
		we <= '1';
		wait until rising_edge(clk);
		d <= x"02";
		wait until rising_edge(clk);
		d <= x"03";
		wait until rising_edge(clk);
		we <= '0';
	end process;
end behav;	

