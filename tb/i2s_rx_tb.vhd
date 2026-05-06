library ieee;
use ieee.std_logic_1164.all;

--
--
--
entity i2s_rx_tb is
end entity;

--
--
--
architecture sim of i2s_rx_tb is
	signal clk : std_logic := '0';
	signal rst_n : std_logic := '0';
	
	signal bck : std_logic := '0';
	signal ws : std_logic  := '0';
	signal din : std_logic := '0';

	signal smpl_data : std_logic_vector(63 downto  0);
	signal input_data :   std_logic_vector(63 downto 0) := x"ffff0000ffff0000";
begin

	i2s_rx_inst : entity work.i2s_rx
		port map
		(
			clk => clk,
			rst_n => rst_n,
			
			bck => bck,
			ws => ws,
			din => din,
		
			smpl_data => smpl_data
		);
		
	--
	--
	--
	process
	begin
		while true loop
			clk <= '1';
			wait for 20.345 ns;
			clk <= '0';
			wait for 20.345 ns;
		end loop;
	end process;

	--
	--
	--
	process
	begin
	
		wait until rising_edge(clk);
		rst_n <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		rst_n <= '1';
		wait until rising_edge(clk);
		
		report "ready = " & std_logic'image(din);
		report "ready = " & std_logic'image(smpl_data(0));
		
		wait until falling_edge(ws);
		wait until falling_edge(bck);
		
		while true loop
			for bit_idx in 63 downto 0 loop
				wait until falling_edge(bck);
				din <= input_data(bit_idx);
			end loop;
			
			input_data <= not input_data;
		end loop;
		
		
		--wait;
		
	end process;
		
end architecture;
