library ieee;
use ieee.std_logic_1164.all;

entity i2s_tx_tb is
end entity;

architecture sim of i2s_tx_tb is
	signal clk : std_logic := '0';
	signal rst_n : std_logic := '0';
	signal lrck : std_logic := '0';
	signal bck : std_logic := '0';
	signal dout : std_logic := '0';
	
	signal smpl_data : std_logic_vector(63 downto 0);
	signal smpl_valid : std_logic;
	signal smpl_ready : std_logic;

begin

	i2s_tx_inst : entity work.i2s_tx
		port map
		(
			clk => clk,
			rst_n => rst_n,
			
			lrck => lrck,
			bck => bck,
			dout => dout,

			smpl_data => smpl_data,
			smpl_valid => smpl_valid,
			smpl_ready => smpl_ready
		);
		
		
	process
	begin
		while true loop
			clk <= '1';
			wait for 20.345 ns;
			clk <= '0';
			wait for 20.345 ns;
		end loop;
	end process;
	
	process
	begin
	
		wait until rising_edge(clk);
		rst_n <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		rst_n <= '1';
		wait until rising_edge(clk);
		
		report "ready = " & std_logic'image(smpl_ready);
		
		smpl_data <= x"aa55aa55aa55aa55";
		smpl_valid <= '1';
		
		wait until smpl_ready = '1';
		
		smpl_data <= x"55aa55aaaa55aa55";
		smpl_valid <= '1';
		
		wait;
		
	end process;
		
end architecture;