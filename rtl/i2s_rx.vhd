library ieee;
use ieee.std_logic_1164.all;

--
--
--
entity i2s_rx is
	port
	(
		clk : in std_logic;
		rst_n : in std_logic;

		bck : out std_logic;
		ws : out std_logic;
		din : in std_logic;
		
		smpl_data : out std_logic_vector(63 downto 0);
		smpl_valid : out std_logic;
		smpl_ready : in std_logic := '0'
	);
end entity;

--
--
--
architecture rtl of i2s_rx is

	signal bck_tick : std_logic := '0';
	signal bck_cnt : natural := 0;
	signal bck_r : std_logic := '0';
	
	signal smpl_reg : std_logic_vector(63 downto 0) := (others => '0');
	signal bit_idx : natural := 63;
	
begin

	bck <= bck_r;

	--
	--
	--
	process(clk, rst_n)
	begin
		 if rst_n = '0' then
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
			bck_r <= '0';
			ws <= '1';
			smpl_reg <= (others => '1');
			smpl_data <= (others => '0');
			bit_idx <= 0;
		elsif rising_edge(clk) then
			
			smpl_valid <=  '0';
			
			if bck_tick = '1' then
				bck_r <= not bck_r;
				
				if bck_r = '1' then
					smpl_reg(63 - bit_idx) <= din;

					if bit_idx = 0 then
						if smpl_ready = '1' then
							smpl_data <= smpl_reg;
							smpl_valid <= '1';	
						end if;
					end if;
				
					if bit_idx = 63 then
						bit_idx <= 0;
					else
						bit_idx <= bit_idx + 1;
					end if;

					if bit_idx = 30 then
						ws <= '1';
					elsif bit_idx = 62 then
						ws <= '0';
					end if;					
					
				end if;
				
			end if;
		end if;
	end process;

end architecture;
