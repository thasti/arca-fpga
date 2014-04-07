-- asd-b test generator
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adsb_gen is

	generic
	(
		clk_div : integer := 4
	);

	port 
	(
		clk	: in std_logic;
		rst	: in std_logic;
		trigger	: in std_logic;
		q	: out std_logic;
		busy	: out std_logic
	);

end adsb_gen;

architecture behav of adsb_gen is

type state_type is (idle, preamble, trdata);
signal state : state_type := idle;
signal clk_cnt : std_logic_vector(7 downto 0) := (others => '0');
signal bit_cnt : std_logic_vector(7 downto 0) := (others => '0');

constant pattern : std_logic_vector(0 to 15) := b"1010000101000000";
constant payload : std_logic_vector(0 to 111) := x"8D75804B580FF2CF7E9BA6F701D0";

begin
	process 
	begin
		wait until rising_edge(clk);	
		if rst = '1' then
			clk_cnt <= (others => '0');
			bit_cnt <= (others => '0');
			state <= idle;
			busy <= '1';
			q <= '0';
		else
				case state is 
					when idle =>
						q <= '0';
						busy <= '0';
						bit_cnt <= (others => '0');
						clk_cnt <= (others => '0');
						if trigger = '1' then
							state <= preamble;
							busy <= '1';
						end if;
					when preamble =>
						clk_cnt <= std_logic_vector(unsigned(clk_cnt) + 1);
						if to_integer(unsigned(clk_cnt)) = integer(clk_div)-1 then
							clk_cnt <= (others => '0');
							busy <= '1';
							bit_cnt <= std_logic_vector(unsigned(bit_cnt) + 1);
							q <= pattern(to_integer(unsigned(bit_cnt)));
							if to_integer(unsigned(bit_cnt)) = pattern'length-1 then
								state <= trdata;
								bit_cnt <= (others => '0');
							end if;
						end if;
					when trdata =>
						clk_cnt <= std_logic_vector(unsigned(clk_cnt) + 1);
						if to_integer(unsigned(clk_cnt)) = integer(clk_div)-1 then
							clk_cnt <= (others => '0');
							bit_cnt <= std_logic_vector(unsigned(bit_cnt) + 1);
							if to_integer(unsigned(bit_cnt)) = 2*payload'length then
								state <= idle;
								busy <= '0';
								q <= '0';
							else
								q <= payload(to_integer(unsigned(bit_cnt(bit_cnt'high downto 1)))) xor bit_cnt(0);
							end if;
						end if;
				end case;
		end if; -- reset
	end process;
end behav;
