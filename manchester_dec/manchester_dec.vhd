-- manchester decoder
-- 
-- data is manchester input on inclk, 
-- output is binary on outclk
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity manchester_dec is
	generic (
		width	: positive := 16
	);

	port (
		clk	: in std_logic;
		inclk	: in std_logic;
		outclk	: out std_logic;
		rst	: in std_logic;
		d	: in std_logic;
		q	: out std_logic;
		err	: out std_logic
	);
end manchester_dec;

architecture behav of manchester_dec is
signal d_d	: std_logic;
signal state	: std_logic;
begin
	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			state <= '0';
			d_d <= '0';
			q <= '0';
			outclk <= '0';
			err <= '0';
		else 
			outclk <= '0';
			if inclk = '1' then
				d_d <= d;
				state <= not state;
				if state = '1' then
					outclk <= '1';
					err <= '0';
					q <= d_d;
					-- 11 or 00 is error condition
					if (d xor d_d) = '0' then
						err <= '1';
					end if;
					-- binary output is first manchester chip
				end if;
			end if;
		end if;
	end process;
end behav;
