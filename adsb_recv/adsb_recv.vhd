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
		adcclk	: out std_logic;
		adc_d	: in std_logic_vector(width-1 downto 0);
		uart_tx	: out std_logic
	);
end adsb_recv;

architecture behav of adsb_recv is
	constant adc_bits : positive := 8;
	constant fs_msps : positive := 16;
	constant fsys	: positive := 32;

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

	signal bit_reset : std_logic;
begin

	
	matched_filt : entity work.matched_filt
		generic map (filter_len => fs_msps/2, width => width)
		port map (clk => clk,
			  rst => rst,
			  inclk => clk,
			  outclk => mf_clk,
			  d => adc_d,
			  q => mf_q);
	
	early_late : entity work.early_late
		generic map (width => width, sam_per_bit => fs_msps/2)
		port map (clk => clk,
			  rst => bit_reset,
			  inclk => mf_clk,
			  d => mf_q,
			  outclk => rec_clk);

	data_slicer : entity work.data_slicer
		generic map (width => adc_bits, sam_per_bit => fs_msps/2)
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
		generic map (sam_per_bit => fs_msps/2)
		port map (clk => clk,
			  rst => rst,
		 	  inclk => ds_clk,
			  d => ds_d,
			  valid => preamble_found);

	bit_reset <= rst or preamble_found;
	process
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			-- reset all outputs that are not reset by other components
		else 
			-- whatever
		end if;
	end process;
end behav;
