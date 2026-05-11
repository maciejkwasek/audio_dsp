library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
--
--
entity echo_buffer is
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
architecture rtl of echo_buffer is
	signal mem_addr : natural range 0 to 4095 := 0;
	signal mem_data_in : std_logic_vector(31 downto 0);
	signal wren : std_logic := '0';
	signal mem_data_out : std_logic_vector(31 downto 0);
	
	signal sample_out_r : signed(31 downto 0);
	signal sample_in_r : signed(31 downto 0);
	
	type echo_ram_state_t is (IDLE, READ_OLD, WRITE_NEW, UPDATE_IDX);
	
	signal echo_ram_state : echo_ram_state_t := IDLE;

begin

	sample_out <= sample_out_r;

	echo_ram_inst : entity work.echo_ram
		port map
		(
			address =>	std_logic_vector(to_unsigned(mem_addr, 12)),
			clock => clk,
			data => mem_data_in,
			wren => wren,
			q =>mem_data_out	
		);
		
	--
	--
	--
	process(clk, rst_n)
	begin
		if rst_n = '0' then
			mem_addr <= 0;
		elsif rising_edge(clk) then

			wren <= '0';
			case echo_ram_state is
				when IDLE =>
					if valid = '1' then
						sample_in_r <= sample_in;
						echo_ram_state <= READ_OLD;
					end if;
					
				when READ_OLD =>
					sample_out_r <= signed(mem_data_out);
					echo_ram_state <= WRITE_NEW;
					
				when WRITE_NEW =>
					mem_data_in <= std_logic_vector(sample_in_r);
					wren <= '1';
					echo_ram_state <= UPDATE_IDX;
					
				when UPDATE_IDX =>
					if mem_addr = 4095 then
						mem_addr <= 0;
					else
						mem_addr <= mem_addr + 1;
					end if;
					echo_ram_state <= IDLE;
					
			end case;
		end if;
	end process;
		
end architecture;
