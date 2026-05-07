library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
--
--
entity dsp_core is
	port
	(
		clk : in std_logic;
		rst_n : in std_logic;
		
		out_data : out std_logic_vector(63 downto 0);
		out_valid : out std_logic;
		out_ready : in std_logic := '0';
		
		in1_data : in std_logic_vector(63 downto 0) := (others => '0');
		in1_valid : in std_logic := '0';
		in1_ready : out std_logic
		
		--in2_data : in std_logic_vector(23 downto 0);
		--in2_valid : in std_logic;
		--in2_ready : out std_logic
	);
end entity;

--
--
--
architecture rtl of dsp_core is

	signal fs_cnt : natural := 0;
	signal fs_tick : std_logic := '0';

	signal lfo_raw : signed(15 downto 0);
	signal lfo_sample : signed(15 downto 0);

	signal in1_lsample :signed(31 downto 0);
	signal in1_rsample :signed(31 downto 0);

	signal lfo1 : signed(16 downto 0);
	signal lfo2 : signed(15 downto 0);
	signal env1 : signed(31 downto 0);
	signal env2 : signed(15 downto 0);
	signal env3 : signed(15 downto 0);

	signal mull : signed(47 downto 0);
	signal mulr : signed(47 downto 0);

	signal depth : signed(15 downto 0) := to_signed(25000, 16);
	signal one_minus_depth : signed(15 downto 0);

	signal outl : signed(31 downto 0);
	signal outr : signed(31 downto 0);

begin

	lfo_inst : entity work.dds_sin
		port map
		(
			clk => clk,
			rst_n => rst_n,
			sin_out => lfo_raw,

			-- ok 5Hz
			phase_step => x"000000ff"
		);

	--
	--
	--
	fs_gen : process(clk, rst_n)
	begin
		if rst_n = '0' then
			fs_cnt <= 0;
			fs_tick <= '0';
		elsif rising_edge(clk) then
			fs_tick <= '0';

			-- 96MHz/2000 = 48kHz
			if fs_cnt = 1999 then 
				fs_cnt <= 0;
				fs_tick <= '1';
			else
				fs_cnt <= fs_cnt + 1;
			end if;
		end if;
	end process;
	
	--
	--
	--
	sample_rx : process(clk, rst_n)
	begin
		if rst_n = '0' then
		elsif rising_edge(clk) then
			in1_ready <= '0';
			if in1_valid = '1' then
				in1_lsample <= signed(in1_data(63 downto 32)) sll 3;
				in1_rsample <= signed(in1_data(63 downto 32)) sll 3;
				--in1_rsample <= signed(in1_data(31 downto 0)) sll 3;
				in1_ready <= '1';
			end if;
		end if;
	end process;

	--
	--
	--
	sample_tx : process(clk, rst_n)
	begin
		if rst_n = '0' then
		elsif rising_edge(clk) then
			out_valid <= '0';
			if fs_tick = '1' then
				if out_ready = '1' then
					out_data <= std_logic_vector(outl) & 
									std_logic_vector(outr);
					out_valid <= '1';
				end if;
			end if;
		end if;
	end process;

	--
	--
	--
	lfo_sampler : process(clk, rst_n)
	begin
		if rst_n = '0' then
		elsif rising_edge(clk) then
			if fs_tick = '1' then
				lfo_sample <= lfo_raw;
			end if;
		end if;
	end process;

	--
	--
	--
	dsp_math : process(clk, rst_n)
	begin
		if rst_n = '0' then
		elsif rising_edge(clk) then

			-- tremolo equation
			-- out[n] = in[n] * env
			-- env = [(1 - depth) + depth * LFO]
			-- LFO = lfo_sample + 32767

			lfo1 <= resize(lfo_sample, 17) + to_signed(32767, 17);
			lfo2 <= resize(shift_right(lfo1, 1), 16);

			env1 <= lfo2 * depth;
			env2 <= resize(shift_right(env1, 15), 16);
			one_minus_depth <= to_signed(32767,16) - depth;
			env3 <= one_minus_depth + env2;

			mull <= in1_lsample * env3;
			mulr <= in1_rsample * env3;

			outl <= resize(shift_right(mull, 15), 32);
			outr <= resize(shift_right(mulr, 15), 32);
		end if;
	end process;

end architecture;

