-- preamble detector
-- 
-- data is sliced chips on inclk
-- output is valid-flag
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity preamble_det is
	generic (
		sam_per_bit	: positive := 8 
	);

	port (
		clk	: in std_logic;
		inclk	: in std_logic;
		rst	: in std_logic;
		d	: in std_logic;
		valid	: out std_logic
	);
end preamble_det;

architecture behav of preamble_det is
	constant pattern : std_logic_vector(15 downto 0) := b"1010000101000000";
	constant sr_len : positive := sam_per_bit * pattern'length;
	signal sr : std_logic_vector(sr_len downto 0) := (others => '0');
begin
	process
	variable match_result : std_logic;
	begin
		wait until rising_edge(clk);
		valid <= '0';
		if rst = '1' then
			sr <= (others => '0');
		else 
			if inclk = '1' then
				sr(sr_len downto 0) <= sr(sr_len-1 downto 0) & d;
				match_result := '0';
				for i in 0 to 15 loop
					match_result := match_result or (pattern(i) xor sr(i*sam_per_bit));
				end loop;
				if match_result = '0' then
					valid <= '1';
				end if;
			end if;
		end if;
	end process;
end behav;
