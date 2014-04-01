-- Algorithmic State Machine

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity asm is

	port(
		clk		: in	std_logic;
		load	 	: in	std_logic;
		rst_n	 	: in	std_logic;
		trigger		: in	std_logic;
		baud_gen_en 	: out	std_logic;
		busy_out	: out	std_logic;
		P_S		: out	std_logic
	);

end entity;

architecture rtl of asm is

	-- Build an enumerated type for the state machine
	type state_type is (IDLE, BUSY);

	-- Register to hold the current state
	signal state   		: state_type;
	
	signal cnt		: unsigned(3 downto 0);
	
	signal cnt_en		: std_logic;
	
	signal cnt_reached	: std_logic;

begin

	-- Logic to advance to the next state
	process (clk, rst_n)
	begin
		if rst_n = '0' then
			state <= IDLE;
		elsif (rising_edge(clk)) then
			case state is
				when IDLE=>
					if load = '1' then
						state <= BUSY;
					else
						state <= IDLE;
					end if;
				when BUSY=>
					if cnt_reached = '1' then
						state <= IDLE;
					else
						state <= BUSY;
					end if;
			end case;
		end if;
	end process;

	-- Output depends solely on the current state
	process (state)
	begin
		case state is
			when IDLE =>
				cnt_en		<= '0';
				busy_out	<= '0';
				baud_gen_en	<= '0';
			when BUSY =>
				cnt_en		<= '1';
				busy_out	<= '1';
				baud_gen_en 	<= '1';
		end case;
	end process;
	
	process (clk, cnt_en, trigger)
	begin
		if (cnt_en = '0') then
		
			cnt		<= (others => '0');
			cnt_reached 	<= '0';
			P_S		<= '1';
			
		elsif (rising_edge(clk)) then
		
			if (trigger = '1') then
			  cnt		<= cnt + 1;
			  P_S		<= '0';
			end if;
			
			if (cnt = 11) then
			  cnt_reached	<= '1';
			end if;
			
		end if;
	end process;

end rtl;

