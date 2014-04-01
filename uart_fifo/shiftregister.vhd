-- Shift Register

library ieee;
use ieee.std_logic_1164.all;

entity shiftregister is

	generic
	(
		NUM_STAGES : natural := 10
	);

	port 
	(
		clk		: in std_logic;
		en		: in std_logic;
		load		: in std_logic;
		P_S		: in std_logic;
		D		: in std_logic_vector(NUM_STAGES-1 downto 0);
		Q		: out std_logic_vector(NUM_STAGES-1 downto 0)
	);

end entity;

architecture rtl of shiftregister is
signal	sr : std_logic_vector(NUM_STAGES-1 downto 0) := (others => '0');
begin

	process (clk)
	begin
		if (rising_edge(clk)) then

			if (en = '1') then
			
				if (P_S = '1') and (load = '1') then
				
					sr <= D;
					
				elsif (P_S = '0') then
				  
					-- Shift data by one stage; data from last stage is lost
					sr((NUM_STAGES-1) downto 1) <= sr((NUM_STAGES-2) downto 0);

					-- Load new data into the first stage
					sr(0) <= D(0);
					
				end if;

			end if;
		end if;
	end process;
	Q <= sr;

end rtl;
