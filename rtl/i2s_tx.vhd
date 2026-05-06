library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_tx is
	port
	(
		clk : in std_logic;
		rst_n : in std_logic;
		
		lrck : out std_logic;
		bck : out std_logic;
		dout : out std_logic;
		
		smpl_data : in std_logic_vector(63 downto 0) := (others => '0');
		smpl_valid : in std_logic := '0';
		smpl_ready : out std_logic
	);
end entity;

--
-- fs = 48Khz
-- bck = 48kHz * 32bits * 2channels = 3.072Mhz
-- clk = 3.072Mhz * 8 = 24.576MHz
--

architecture rtl of i2s_tx is
	
	signal bck_r : std_logic := '0';
	signal lrck_r : std_logic := '1';

	signal bck_cnt : natural := 0;
	signal bit_idx : natural := 0;
	
	signal bck_tick : std_logic := '0';
		
	-- format: chanL padding | chanR  padding
	signal smpl_reg : std_logic_vector(63 downto 0) := (others => '0');

begin

	lrck <= lrck_r;
	bck <= bck_r;

	--
	--
	--
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			bck_tick <= '0';
			bck_cnt <= 0;
		elsif rising_edge(clk) then
			bck_tick <= '0';
			if bck_cnt = 3 then
				bck_cnt <= 0;
				bck_tick <= '1';
			else
				bck_cnt <= bck_cnt + 1;
			end if;
			
		end if;
	end process;

	--
	--
	--
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			bit_idx <= 0;
			bck_r <= '0';
		elsif rising_edge(clk) then
			if bck_tick = '1' then
				bck_r <= not bck_r;
				
				if bck_r = '1' then
					
					dout <= smpl_reg(63 - bit_idx);
					
					smpl_ready <= '0';
				
					if bit_idx = 63 then
						bit_idx <= 0;

						if smpl_valid = '1' then
							smpl_reg <= smpl_data;
							smpl_ready <= '1';
						else
							--smpl_reg <= (others => '0');
						end if;

					else
						bit_idx <= bit_idx + 1;
					end if;
					
					if bit_idx = 31 then
						lrck_r <= '0';
					elsif bit_idx = 63 then
						lrck_r <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
	
end architecture;
