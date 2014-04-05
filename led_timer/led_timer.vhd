library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_timer is

	generic
	(
		on_time_exp : positive := 10
	);

	port 
	(
		clk	: in std_logic;
		rst	: in std_logic;
		input	: in std_logic;
		led	: out std_logic
	);

end entity;

architecture rtl of led_timer is
signal cnt 	: std_logic_vector((on_time_exp-1) downto 0);
begin
	process 
	begin
		wait until rising_edge(clk);	
		if rst = '1' then
			cnt <= (others => '0');
			led <= '0';
		else
			-- advance the counter
			cnt <= std_logic_vector(unsigned(cnt) + 1);
			-- reset the LED if the MSB goes high
			if cnt(cnt'high) = '1' then
				led <= '0';
			end if;
			-- set the LED and reset the counter
			if input = '1' then
				cnt <= (others => '0');
				led <= '1';
			end if;
		end if;
	end process;
end rtl;
