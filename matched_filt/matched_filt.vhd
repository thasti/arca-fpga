-- matched filter
-- 
-- data is signed samples
-- output is matched filtered
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity matched_filt is
	generic (
		filter_len	: positive := 8;
		width		: positive := 8
	);

	port (
		clk	: in std_logic;
		inclk	: in std_logic;
		outclk	: out std_logic;
		rst	: in std_logic;
		d	: in std_logic_vector(width-1 downto 0);
		q	: out std_logic_vector(width-1 downto 0)
	);
end matched_filt;

architecture behav of matched_filt is
	type delay_sr is array (0 to filter_len-2) of signed(width-1 downto 0);
	signal delay : delay_sr;
	constant sum_len : integer := integer(ceil(log2(real(filter_len))));
begin
	process
		variable sum : signed(width+sum_len-1 downto 0);
	begin
		wait until rising_edge(clk);
		outclk <= '0';
		if rst = '1' then
			q <= (others => '0');
			delay <= (others => (others => '0'));
		else 
			if inclk = '1' then
				delay(1 to delay'high) <= delay(0 to delay'high-1);
				delay(0) <= signed(d);
				sum := (others => '0');
				for i in 0 to delay'high loop
					sum := sum + resize(delay(i), width + sum_len);
				end loop;
				sum := sum + resize(signed(d), width + sum_len);
				q <= std_logic_vector(sum(sum'length-1 downto sum'length-width));
				outclk <= '1';
			end if;
		end if;
	end process;
end behav;
