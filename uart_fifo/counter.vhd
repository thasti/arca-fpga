library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is

	generic
	(
		NUM_STAGES : natural := 10
	);

	port 
	(
		clk	: in std_logic;
		enable	: in std_logic;
		rst_n	: in std_logic;
		clear	: in std_logic;
		cnt_out: out std_logic_vector((NUM_STAGES-1) downto 0)
	);

end entity;

architecture rtl of counter is

signal cnt 	: std_logic_vector((NUM_STAGES-1) downto 0);

begin

	process (clk, rst_n)
	begin
	
		if (rst_n = '0') then
		cnt <= (others => '0');
		elsif (rising_edge(clk)) then
			if (clear = '1') then
			cnt <= (others => '0');
			elsif (enable = '1') then
				-- count up
				cnt <= std_logic_vector(unsigned(cnt) + 1);
			end if;
		end if;
	end process;

	cnt_out <= cnt;
	
end rtl;
