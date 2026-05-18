library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
--
--
entity fir is
	port
	(
		clk : in std_logic;
		rst_n : in std_logic;
		
		sample_in : in signed(31 downto 0);
		sample_out : out signed(31 downto 0);
		
		valid : in std_logic := '0'
	);
end entity;

--
--
--
architecture rtl of fir is

	signal write_idx : unsigned(5 downto 0) := (others => '0');
	signal read_idx : unsigned(5 downto 0) := (others => '0');
	signal sample_addr : std_logic_vector(5 downto 0) := (others => '0');
	signal sample_rd_vector : std_logic_vector(31 downto 0);
	signal sample_rd : signed(31 downto 0);
	
	signal sample_wr : std_logic_vector(31 downto 0);
	signal sample_wren : std_logic := '0';
	
	signal coeff_idx : unsigned(5 downto 0) := (others => '0');
	signal coeff_addr : std_logic_vector(5 downto 0) := (others => '0');
	signal coeff_value_vector : std_logic_vector(15 downto 0);
	signal coeff_value : signed(15 downto 0);
	
	type fir_state_t is
	(
		IDLE, 
		WAIT_WRITE, 
		LOAD, 
		WAIT_READ, 
		CALC, 
		UPDATE_INDEXES, 
		FINISH
	);
	
	signal fir_state : fir_state_t;
	signal acc : signed(63 downto 0) := (others => '0');
	signal tap_cnt : natural := 0;
	
	
begin

	fir_ram_inst : entity work.fir_ram
		port map
		(
			clock		=> clk,
			address => sample_addr,
			data =>	sample_wr,
			wren =>	sample_wren,
			q =>	sample_rd_vector
		);
		
	sample_rd <= signed(sample_rd_vector);
		
	fir_rom_inst : entity work.fir_rom
		port map
		(
			clock => clk,
			address =>	coeff_addr,
			q =>	coeff_value_vector
		);
		
	coeff_value <= signed(coeff_value_vector);

	--
	--
	--	
	process(clk, rst_n)
	begin
	
		if rst_n = '0' then
		
			acc <= (others => '0');
			sample_wren <= '0';
			write_idx <= (others => '0');
			read_idx <= (others => '0');
			coeff_idx <= (others => '0');
			tap_cnt <= 0;
			
			fir_state <= IDLE;
			
		elsif rising_edge(clk) then
		
			sample_wren <= '0';
			
			case fir_state is
			
				when IDLE =>
					if valid = '1' then

						sample_addr <= std_logic_vector(write_idx);
						sample_wr <= std_logic_vector(sample_in);
						sample_wren <= '1';
						
						tap_cnt <= 0;
						acc <= (others => '0');
						
						coeff_idx <= to_unsigned(1, 6);
						if write_idx = 0 then
							read_idx <= to_unsigned(46, 6);
						else
							read_idx <= write_idx - 1;
						end if;
						
						fir_state <= WAIT_WRITE;
					end if;
					
				when WAIT_WRITE =>
					fir_state <= LOAD;
					
				when LOAD =>
					sample_addr <= std_logic_vector(read_idx);
					coeff_addr <= std_logic_vector(coeff_idx);						
					fir_state <= WAIT_READ;
					
				when WAIT_READ =>
					fir_state <= CALC;
	
				when CALC =>
					acc <= acc + resize(sample_rd * coeff_value, acc'length);
					fir_state <= UPDATE_INDEXES;
					
				when UPDATE_INDEXES =>

					-- read_idx-- mod 47
					if read_idx = 0 then
						read_idx <= to_unsigned(46, 6);
					else
						read_idx <= read_idx - 1;
					end if;
					
					-- inc coeff_idx mod 47
					if coeff_idx = 46 then
						coeff_idx <= to_unsigned(0, 6);
					else
						coeff_idx <= coeff_idx + 1;
					end if;

					-- tap_cnt++
					if tap_cnt = 46 then
						fir_state <= FINISH;	
					else
						tap_cnt <= tap_cnt + 1;
						fir_state <= LOAD;
					end if;
					
				when FINISH =>
						if write_idx = 46 then
							write_idx <= (others => '0');
						else
							write_idx <= write_idx + 1;
						end if;
						
					sample_out <= resize(shift_right(acc, 15), 32);
					fir_state <= IDLE;
					
			end case;
		end if;
	end process;

end architecture;
