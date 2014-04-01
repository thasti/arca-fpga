library ieee;
use ieee.std_logic_1164.all;

entity uart is
	generic
	(
		START_BIT : std_logic := '0';
		STOP_BIT : std_logic := '1'
	);
	
	port
	(
		CLOCK_50	: in std_logic;
		TX	: out std_logic
		-- TODO: add FIFO interface (write, data)
	);	
end uart;

architecture behav of uart is
	component asm
	port(
		clk		: in	std_logic;
		load	 	: in	std_logic;
		rst_n	 	: in	std_logic;
		trigger		: in	std_logic;
		baud_gen_en 	: out	std_logic;
		busy_out	: out	std_logic;
		P_S		: out	std_logic
	);
        end component;
        
        component baudrategenerator
	port 
	(
		clk		: in std_logic;
		enable		: in std_logic;
		rst_n		: in std_logic;
		trigger_flag	: out std_logic
	);
        end component;
        
        component shiftregister
	port 
	(
		clk		: in std_logic;
		en		: in std_logic;
		load		: in std_logic;
		P_S		: in std_logic;
		D		: in std_logic_vector(9 downto 0);
		Q		: out std_logic_vector(9 downto 0)
	);
	end component;

	-- TODO: add FIFO component

	signal load, rst_n, trigger : std_logic := '0'; 
	signal baud_gen_en, busy_out : std_logic;
        
	signal trigger_clk : std_logic := '0';
        
	signal P_S : std_logic;
        
	signal D : std_logic_vector(9 downto 0) := START_BIT & "00110011" & STOP_BIT;
	signal Q : std_logic_vector(9 downto 0);
	
begin
	asm0 : asm 
		port map (clk => CLOCK_50, load => load, rst_n => rst_n, trigger => trigger,
			baud_gen_en => baud_gen_en, busy_out => busy_out, P_S => P_S);
		    
	baud0 : baudrategenerator
		port map (clk => CLOCK_50, enable => baud_gen_en, rst_n => rst_n, trigger_flag => trigger);
		   
	shift0 : shiftregister 
		port map (clk => CLOCK_50, en => trigger,load => load, P_S => P_S, D => D, Q => Q);
	  
	-- TODO: instantiate FIFO, glue logic to load and D
	rst_n	<= '1';
	load	<= '1';
        
	TX	<= q(9) or not baud_gen_en;
        
end behav;
