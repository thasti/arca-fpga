-- data slicer
-- 
-- data is signed samples
-- output is binary data
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_slicer is
	generic (
		width		: positive := 8;
		sam_per_bit	: positive := 8
	);

	port (
		clk	: in std_logic;
		inclk	: in std_logic;
		outclk	: out std_logic;
		rst	: in std_logic;
		d	: in std_logic_vector(width-1 downto 0);
		q	: out std_logic
	);
end data_slicer;

architecture behav of data_slicer is
	component rc_filt
	generic (
		time_const	: positive;
		width		: positive;
		pd_min		: std_logic;
		pd_max		: std_logic
	);

	port (
		clk	: in std_logic;
		inclk	: in std_logic;
		outclk	: out std_logic;
		rst	: in std_logic;
		d	: in std_logic_vector(width-1 downto 0);
		q	: out std_logic_vector(width-1 downto 0)
	);
	end component;

	signal thresh_min : signed(width-1 downto 0);
	signal thresh_max : signed(width-1 downto 0);
	signal thresh : signed(width-1 downto 0);
begin
	min_pd : rc_filt
	generic map(time_const => sam_per_bit*5, width => width, pd_min => '1', pd_max => '0')
	port map(clk, inclk, open, rst, d, signed(q) => thresh_min);

	max_pd : rc_filt
	generic map(time_const => sam_per_bit*5, width => width, pd_min => '0', pd_max => '1')
	port map(clk, inclk, open, rst, d, signed(q) => thresh_max);
	process
	begin
		wait until rising_edge(clk);
		outclk <= '0';
		if rst = '1' then
			q <= '0';
		else 
			if inclk = '1' then
				if signed(d) > thresh then
					q <= '1';
				else
					q <= '0';
				end if;
				outclk <= '1';
			end if;
		end if;
	end process;
	thresh <= (thresh_max - thresh_min) / 2;
end behav;
