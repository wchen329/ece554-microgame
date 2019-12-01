	component soc_audio is
		port (
			clk         : in  std_logic                     := 'X';             -- clk
			reset       : in  std_logic                     := 'X';             -- reset
			address     : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- address
			chipselect  : in  std_logic                     := 'X';             -- chipselect
			read        : in  std_logic                     := 'X';             -- read
			write       : in  std_logic                     := 'X';             -- write
			writedata   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			readdata    : out std_logic_vector(31 downto 0);                    -- readdata
			irq         : out std_logic;                                        -- irq
			AUD_BCLK    : in  std_logic                     := 'X';             -- BCLK
			AUD_DACDAT  : out std_logic;                                        -- DACDAT
			AUD_DACLRCK : in  std_logic                     := 'X'              -- DACLRCK
		);
	end component soc_audio;

	u0 : component soc_audio
		port map (
			clk         => CONNECTED_TO_clk,         --                clk.clk
			reset       => CONNECTED_TO_reset,       --              reset.reset
			address     => CONNECTED_TO_address,     -- avalon_audio_slave.address
			chipselect  => CONNECTED_TO_chipselect,  --                   .chipselect
			read        => CONNECTED_TO_read,        --                   .read
			write       => CONNECTED_TO_write,       --                   .write
			writedata   => CONNECTED_TO_writedata,   --                   .writedata
			readdata    => CONNECTED_TO_readdata,    --                   .readdata
			irq         => CONNECTED_TO_irq,         --          interrupt.irq
			AUD_BCLK    => CONNECTED_TO_AUD_BCLK,    -- external_interface.BCLK
			AUD_DACDAT  => CONNECTED_TO_AUD_DACDAT,  --                   .DACDAT
			AUD_DACLRCK => CONNECTED_TO_AUD_DACLRCK  --                   .DACLRCK
		);

