library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
	generic
	(
		start_bit : std_logic := '0';
		stop_bit : std_logic := '1';
		fifo_depth : positive := 8
	);
	
	port
	(
		clk	: in std_logic;
		rst	: in std_logic;
		we	: in std_logic;
		d	: in std_logic_vector(7 downto 0);
		tx	: out std_logic
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

	component fifo
        generic
        (
                num_words       : positive;                 
                word_width      : positive;               
                al_full_lvl     : natural;               
                al_empty_lvl    : natural               
        );

        port
        (
                clk     : in std_logic;                                 -- System Clock
                rst     : in std_logic;                                 -- System Reset

                d       : in std_logic_vector(word_width-1 downto 0);   -- Input Data
                we      : in std_logic;                                 -- Write Enable
                full    : out std_logic;                                -- Full Flag
                al_full : out std_logic;                                -- Almost Full Flag

                q       : out std_logic_vector(word_width-1 downto 0);  -- Output Data
                re      : in std_logic;                                 -- Read Signal
                empty   : out std_logic;                                -- Empty Flag
                al_empty: out std_logic                                 -- Almost Empty Flag
        );
	end component;

	type state_type is (idle, load_byte, sleep1, sleep2);
	signal state : state_type := idle;
	signal load, rst_n, trigger : std_logic := '0'; 
	signal baud_gen_en, busy_out : std_logic;
        
	signal trigger_clk : std_logic := '0';
        
	signal P_S : std_logic;
        
	signal uart_d : std_logic_vector(9 downto 0) := start_bit & "00000000" & stop_bit;
	signal sr_Q : std_logic_vector(9 downto 0);

	signal fifo_re : std_logic;
	signal fifo_empty : std_logic;
	
begin
	asm0 : asm 
		port map (clk => clk, load => load, rst_n => rst_n, trigger => trigger,
			baud_gen_en => baud_gen_en, busy_out => busy_out, P_S => P_S);
		    
	baud0 : baudrategenerator
		port map (clk => clk, enable => baud_gen_en, rst_n => rst_n, trigger_flag => trigger);
		   
	shift0 : shiftregister 
		port map (clk => clk, en => trigger, load => load, P_S => P_S, D => uart_d, Q => sr_Q);
	 
	fifo0 : fifo
		generic map(num_words => 32, word_width => 8) 
		port map (clk => clk, rst => rst, d => d, we => we, q => uart_d(8 downto 1), re => fifo_re, empty => fifo_empty);
		
	uart_d(9) <= start_bit;
	uart_d(0) <= stop_bit;

	rst_n	<= not rst;
        
	TX	<= sr_Q(9) or not baud_gen_en;

	process 
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			state <= idle;
		else
			case state is
				when idle =>
					if fifo_empty = '0' and busy_out = '0' then
						state <= load_byte;
						fifo_re <= '1';
					end if;
				when load_byte =>
					fifo_re <= '0';
					load <= '1';
					state <= sleep1;
				when sleep1 => 
					state <= sleep2;
				when sleep2 =>
					load <= '0';
					state <= idle;
			end case;
		end if; -- reset
	end process;
end behav;
