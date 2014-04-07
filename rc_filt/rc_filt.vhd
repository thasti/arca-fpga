-- digital rc filter
-- 
-- data is unsigned samples
-- output is rc-filtered
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rc_filt is
	generic (
		time_const	: positive := 8;
		width		: positive := 8;
		pd_min		: std_logic := '0';
		pd_max		: std_logic := '0'
	);

	port (
		clk	: in std_logic;
		inclk	: in std_logic;
		outclk	: out std_logic;
		rst	: in std_logic;
		d	: in std_logic_vector(width-1 downto 0);
		q	: out std_logic_vector(width-1 downto 0)
	);
end rc_filt;

architecture behav of rc_filt is
	signal fil_out : unsigned(width-1 downto 0);
	signal alpha : unsigned(width-1 downto 0) := to_unsigned(integer(real((2**(width-1)-1))/(real(time_const)+1.0)), width);
begin
	process
	begin
		wait until rising_edge(clk);
		outclk <= '0';
		if rst = '1' then
			fil_out <= (others => '0');
		else 
			if inclk = '1' then
				-- y[i] := y[i-1] + tc * (x[i] - y[i-1])
				fil_out <= fil_out +
					   resize(shift_right(alpha * unsigned(d) - alpha * fil_out,8),8);
				if pd_min = '1' then
					if unsigned(d) < fil_out then
						fil_out <= unsigned(d);
					end if;
				end if;
				if pd_max = '1' then
					if unsigned(d) > fil_out then
						fil_out <= unsigned(d);
					end if;
				end if;
				
				outclk <= '1';
			end if;
		end if;
	end process;
	q <= std_logic_vector(fil_out);
end behav;
