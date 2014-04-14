-- ads-b receiver
--
-- www.bexus-arca.de

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adsb_recv is
	generic (
		width		: positive := 8;
		samp_rate	: positive := 16
	);

	port (
		clk	: in std_logic;
		rst	: in std_logic;
		adcclk	: in std_logic;
		adc_d	: in std_logic_vector(width-1 downto 0);
		adsb_tx	: out std_logic;
		uart_tx	: out std_logic;
		sof_led	: out std_logic;
		full_led : out std_logic
	);
end adsb_recv;

architecture behav of adsb_recv is
	-- matched filter
	signal mf_clk : std_logic;
	signal mf_q : std_logic_vector(width-1 downto 0);
	-- clock recovery
	signal rec_clk : std_logic;
	-- data slicer output
	signal ds_d : std_logic;	
	signal ds_clk : std_logic;
	-- manchester decoder output
	signal bit_d : std_logic;
	signal bit_clk : std_logic;
	signal manchester_err : std_logic;
	-- preamble detector
	signal preamble_found : std_logic;
	-- UART FIFO
	signal fifo_d : std_logic_vector(7 downto 0);
	signal fifo_we : std_logic;

	signal bit_reset : std_logic;
	signal fifo_full : std_logic;
	
	signal cnt_trg :std_logic;
	signal cnt : std_logic_vector(23 downto 0) := (others => '0');
begin

	adsb_gen : entity work.adsb_gen
		generic map (clk_div => samp_rate/2)
		port map (clk => clk,
			  rst => rst,
			  trigger => cnt_trg,
			  q => adsb_tx,
			  busy => open);

	matched_filt : entity work.matched_filt
		generic map (filter_len => samp_rate/2, width => width)
		port map (clk => clk,
			  rst => rst,
			  inclk => adcclk,
			  outclk => mf_clk,
			  d => adc_d,
			  q => mf_q);
	
	early_late : entity work.early_late
		generic map (width => width, sam_per_bit => samp_rate/2)
		port map (clk => clk,
			  rst => bit_reset,
			  inclk => mf_clk,
			  d => mf_q,
			  outclk => rec_clk);

	data_slicer : entity work.data_slicer
		generic map (width => width, sam_per_bit => samp_rate/2)
		port map (clk => clk, 
			  rst => rst, 
			  inclk => mf_clk, 
			  d => mf_q, 
			  outclk => ds_clk, 
			  q => ds_d); 

	manchester_dec : entity work.manchester_dec
		port map (clk => clk,
			  rst => bit_reset,
			  inclk => rec_clk,
			  d => ds_d,
			  outclk => bit_clk,
			  q => bit_d,
			  err => manchester_err);

	preamble_det : entity work.preamble_det
		generic map (sam_per_bit => samp_rate/2)
		port map (clk => clk,
			  rst => rst,
		 	  inclk => ds_clk,
			  d => ds_d,
			  valid => preamble_found);
	uart_fifo : entity work.uart
		generic map (fifo_depth => 512)
		port map (clk => clk,
			  rst => rst,
			  we => fifo_we,
			  d => fifo_d,
			  tx => uart_tx,
		  	  full => fifo_full);
	frame_ctrl : entity work.frame_ctrl
		port map (clk => clk,
			  rst => rst,
			  sof => preamble_found,
			  inclk => bit_clk,
			  d => bit_d,
			  fifo_d => fifo_d,
			  fifo_we => fifo_we);

	sof_led_timer : entity work.led_timer
		generic map (on_time_exp => 22)
		port map (clk => clk,
			  rst => rst,
			  input => preamble_found,
			  led => sof_led);

	full_led_timer : entity work.led_timer
		generic map (on_time_exp => 22)
		port map (clk => clk,
			  rst => rst,
			  input => fifo_full,
			  led => full_led);

	bit_reset <= rst or preamble_found;

	process
	begin
	 	wait until rising_edge(clk);
		if rst = '1' then
			-- reset all outputs that are not reset by other components
			cnt <= (others => '0');
			cnt_trg <= '0';
		else 
			-- whatever
			cnt <= std_logic_vector(unsigned(cnt) + 1);
			if unsigned(cnt) = to_unsigned(0, cnt'length) then
				cnt_trg <= '1';
			else
				cnt_trg <= '0';
			end if;
				
		end if; -- reset
	end process;
end behav;
