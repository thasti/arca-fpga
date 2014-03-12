-- clock recovery
-- 
-- data is match filtered samples
-- output is clock
-- NOTE: this does not yet implement early/late, but only gives static timing
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity early_late is
	generic (
		width		: positive := 8;
		sam_per_bit	: positive := 8
	);

	port (
		clk	: in std_logic;
		rst	: in std_logic;
		inclk	: in std_logic;
		d	: in std_logic_vector(width-1 downto 0);
		outclk	: out std_logic
	);
end early_late;

architecture behav of early_late is
	constant cnt_len 	: integer := integer(ceil(log2(real(sam_per_bit))));
	signal cnt 	 	: unsigned(cnt_len-1 downto 0);
begin
	process
	begin
		wait until rising_edge(clk);
		outclk <= '0';
		if rst = '1' then
			cnt <= to_unsigned(sam_per_bit/2, cnt'length);
		else 
			if inclk = '1' then
				cnt <= cnt + to_unsigned(1, cnt'length);
				if cnt = to_unsigned(sam_per_bit-1, cnt'length) then
					outclk <= '1';
					cnt <= to_unsigned(0, cnt'length);
				end if;
			end if;
		end if;
	end process;
end behav;
