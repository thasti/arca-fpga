-- manchester decoder test bench
--
-- test coverage includes all possible input manchester combinations

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity manchester_dec_tb is
end manchester_dec_tb;

architecture behav of manchester_dec_tb is
	component manchester_dec
	port 
	(
		clk	: in std_logic;
		inclk	: in std_logic;
		outclk	: out std_logic;
		rst	: in std_logic;
		d	: in std_logic;
		q	: out std_logic;
		err	: out std_logic
	);
	end component;

signal clk	: std_logic := '0';
signal inclk	: std_logic := '0';
signal outclk	: std_logic;
signal rst	: std_logic := '1';
signal d	: std_logic := '0';
signal q	: std_logic;
signal err	: std_logic;

begin 
	dut : manchester_dec
	port map (clk, inclk, outclk, rst, d, q, err);
	clk <= not clk after 50 ns;
	rst <= '0' after 200 ns;

	process
	variable l : line;
	file vector_file : text is in "manchester_dec_test.txt";
	begin
		wait until rst <= '0';
		while not endfile(vector_file) loop
			readline(vector_file, l);
			wait until rising_edge(clk);
			inclk <= '1';
			case l(1) is 
				when '0' =>
					d <= '0';
				when '1' => 
					d <= '1';
				when others =>
					assert false 
					report "illegal character";
					exit;
			end case;
			wait until rising_edge(clk);
			inclk <= '0';
			wait until rising_edge(clk);
			wait until rising_edge(clk);
			inclk <= '1';
			case l(3) is 
				when '0' =>
					d <= '0';
				when '1' => 
					d <= '1';
				when others =>
					assert false 
					report "illegal character";
					exit;
			end case;
			wait until rising_edge(clk);
			inclk <= '0';
			wait until rising_edge(clk);
			-- output check
			case l(5) is
				when '0' =>
					if q = '1' then
						assert false
						report "Behavioral error, q=1, exp q=0!";
						exit;
					end if;
				when '1' =>
					if q = '0' then
						assert false
						report "Behavioral error, q=0, exp q=1!";
						exit;
					end if;
				when others =>
					assert false 
					report "illegal character";
					exit;
			end case;
			-- error check
			case l(7) is
				when '0' =>
					if err = '1' then
						assert false
						report "Behavioral error, err=1, exp err=0!";
						exit;
					end if;
				when '1' =>
					if err = '0' then
						assert false
						report "Behavioral error, err=0, exp err=1!";
						exit;
					end if;
				when others =>
					assert false 
					report "illegal character";
					exit;
			end case;
			if outclk = '0' then
				assert false
				report "output clock not active!";
				exit;
			end if;
			wait until rising_edge(clk);
			if outclk = '1' then
				assert false
				report "output clock active too long!";
				exit;
			end if;
		end loop;
	end process;
end behav;
