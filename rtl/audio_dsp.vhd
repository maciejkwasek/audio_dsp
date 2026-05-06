library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

--
--
--
entity audio_dsp is
	port
	(
		clk : in std_logic;
		rst_n : in std_logic;

		dac_lrck : out std_logic;
		dac_bck : out std_logic;
		dac_dout : out std_logic;
		
		in1_bck : out std_logic;
		in1_ws : out std_logic;
		in1_din : in std_logic
	);
end entity;

--
--
--
architecture rtl of audio_dsp is

	signal clk96 : std_logic := '0';
	signal locked96 : std_logic := '0';
	
	signal clk24_576 : std_logic := '0';
	signal locked24_576 : std_logic := '0';
	
	signal data_from_in1_to_fifo : std_logic_vector(63 downto 0) := (others => '0');
	signal valid_from_in1_to_fifo : std_logic := '0';
	signal ready_from_fifo_to_in1 : std_logic := '0';
	
	signal data_from_fifo_to_dspcore : std_logic_vector(63 downto 0) := (others => '0');
	signal valid_from_fifo_to_dspcore : std_logic := '0';
	signal ready_from_dspcore_to_fifo : std_logic := '0';

	signal data_from_dspcore_to_fifo : std_logic_vector(63 downto 0) := (others => '0');
	signal valid_from_dspcore_to_fifo : std_logic := '0';
	signal ready_from_fifo_to_dspcore : std_logic := '0';
	
	signal data_from_fifo_to_dac : std_logic_vector(63 downto 0) := (others => '0');
	signal valid_from_fifo_to_dac : std_logic := '0';
	signal ready_from_dac_to_fifo : std_logic := '0';	
	
begin
	--
	
	pll96 : entity work.pll_96mhz
		port map
		(
			areset => not rst_n,
			inclk0 => clk,
			c0 =>  clk96,
			locked => locked96
		);
		
	pll24_576 :entity work.pll_24mhz576
		port map
		(
			areset => not rst_n,
			inclk0 => clk96,
			c0 => clk24_576,
			locked => locked24_576
		);
		
	dsp_core_inst : entity work.dsp_core
		port map
		(
			clk => clk96,
			rst_n => rst_n and locked96,

			out_data => data_from_dspcore_to_fifo,
			out_valid => valid_from_dspcore_to_fifo,
			out_ready => not ready_from_fifo_to_dspcore,
			
			in1_data => data_from_fifo_to_dspcore,
			in1_valid => not valid_from_fifo_to_dspcore,
			in1_ready => ready_from_dspcore_to_fifo
		);
		
	dac_i2stx_inst : entity work.i2s_tx
		port map
		(
			clk => clk24_576,
			rst_n => rst_n and locked24_576,
			
			lrck => dac_lrck,
			bck => dac_bck,
			dout => dac_dout,
			
			smpl_data => data_from_fifo_to_dac,
			smpl_valid => not valid_from_fifo_to_dac,
			smpl_ready => ready_from_dac_to_fifo
		);
		
	mic_i2srx_inst : entity work.i2s_rx
		port map
		(
			clk => clk24_576,
			rst_n => rst_n and locked24_576,
			
			bck => in1_bck,
			ws => in1_ws,
			din => in1_din,
			
			smpl_data => data_from_in1_to_fifo,
			smpl_valid => valid_from_in1_to_fifo,
			smpl_ready => not ready_from_fifo_to_in1 
		);
		
	in1_to_dspcore_fifo : entity work.smpl64bit_fifo
		port map
		(
			wrclk	=>	clk24_576,
			rdclk =>	clk96,
		
			data => data_from_in1_to_fifo,
			wrreq	=>	valid_from_in1_to_fifo,
			wrfull => ready_from_fifo_to_in1,
			
			q => data_from_fifo_to_dspcore,
			rdreq	=>	ready_from_dspcore_to_fifo,
			rdempty => valid_from_fifo_to_dspcore
		);
		
	dspcore_to_dac_fifo : entity work.smpl64bit_fifo
		port map
		(
			wrclk	=>	clk96,
			rdclk =>	clk24_576,
		
			data => data_from_dspcore_to_fifo,
			wrreq	=>	valid_from_dspcore_to_fifo,
			wrfull => ready_from_fifo_to_dspcore,
			
			q => data_from_fifo_to_dac,
			rdreq	=>	ready_from_dac_to_fifo,
			rdempty => valid_from_fifo_to_dac
		);		
	
end architecture;
