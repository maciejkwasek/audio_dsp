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

	signal in1_lsample :signed(31 downto 0);
	signal in1_rsample :signed(31 downto 0);
	
	signal outl : signed(31 downto 0);

begin

	--
	--
	--
	process(clk, rst_n)
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
	process(clk, rst_n)
	begin
		if rst_n = '0' then
		elsif rising_edge(clk) then
		
			in1_ready <= '0';
			if in1_valid = '1' then
				in1_lsample <= signed(in1_data(63 downto 32));
				in1_rsample <= signed(in1_data(63 downto 32)); --signed(in1_data(31 downto 0));
				in1_ready <= '1';
			end if;
			
			outl <= in1_lsample;

			out_valid <= '0';	
			if fs_tick = '1' then
				if out_ready = '1' then
					out_data <= std_logic_vector(outl) & 
									std_logic_vector(in1_rsample);
					out_valid <= '1';
				end if;
			end if;
		end if;
	end process;

end architecture;
