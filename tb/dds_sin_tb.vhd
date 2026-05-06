library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dds_sin_tb is
end entity;

architecture sim of dds_sin_tb is
	signal clk : std_logic := '0';
	signal rst_n : std_logic := '0';
	signal sin_out : signed(15 downto 0);
begin

	dds_sin_inst : entity work.dds_sin
		port map
		(
			clk => clk,
			rst_n => rst_n,
			sin_out => sin_out,
			phase_step => x"0000afcb"
		);
	
	--
	--
	--
	process
	begin
		while true loop
			clk <= '1';
			wait for 5.2083 ns;
			clk <= '0';
			wait for 5.2083 ns;
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

		report "clk = " & std_logic'image(clk);
		--

		wait;
	end process;
	
end architecture;