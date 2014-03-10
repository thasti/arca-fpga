-- digital rc filter
-- 
-- data is signed samples
-- output is rc-filtered
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rc_filt is
	generic (
		time_const	: positive := 8;
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
end rc_filt;

architecture behav of rc_filt is
	signal fil_out : signed(width-1 downto 0);
	signal fil_out_d : signed(width-1 downto 0);
	signal fil_in : signed(width-1 downto 0);
begin
	process
		-- 8 * 8 bit = 16 bit
		variable product : signed(2*width-1 downto 0);
	begin
		wait until rising_edge(clk);
		outclk <= '0';
		if rst = '1' then
			fil_out <= (others => '0');
			fil_out_d <= (others => '0');
			fil_in <= (others => '0');
			product := (others => '0');
		else 
			if inclk = '1' then
				fil_in <= signed(d);
				fil_out_d <= fil_out;
				-- y[i] := y[i-1] + tc * (x[i] - y[i-1])
				-- intermediate product to help readability
				product := to_signed(time_const, width) * (fil_in - fil_out_d);
				fil_out <= fil_out_d(width-1 downto 0) + product(2*width-1 downto width);
				outclk <= '1';
			end if;
		end if;
	end process;
	q <= std_logic_vector(fil_out);
end behav;