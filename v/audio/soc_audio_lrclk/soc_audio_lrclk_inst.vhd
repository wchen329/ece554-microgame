	component soc_audio_lrclk is
		port (
			clk       : in  std_logic := 'X'; -- clk
			reset     : in  std_logic := 'X'; -- reset
			AUD_BCLK  : in  std_logic := 'X'; -- clk
			AUD_LRCLK : out std_logic         -- clk
		);
	end component soc_audio_lrclk;

	u0 : component soc_audio_lrclk
		port map (
			clk       => CONNECTED_TO_clk,       --       clk.clk
			reset     => CONNECTED_TO_reset,     --     reset.reset
			AUD_BCLK  => CONNECTED_TO_AUD_BCLK,  --  AUD_BCLK.clk
			AUD_LRCLK => CONNECTED_TO_AUD_LRCLK  -- AUD_LRCLK.clk
		);

