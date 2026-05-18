library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_tb is
end entity;

architecture sim of fir_tb is
	signal clk : std_logic := '0';
	signal rst_n : std_logic := '0';
	
	signal sample_in : signed(31 downto 0) := (others => '0');
   signal sample_out : signed(31 downto 0);
		
	signal valid : std_logic := '0';

begin

	fir_inst : entity work.fir
		port map
		(
			clk => clk,
			rst_n => rst_n,
			
			sample_in => sample_in,
			sample_out => sample_out,
		
			valid => valid
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
		
		report "valid = " & std_logic'image(valid);
		report "sample_out = " & std_logic'image(sample_out(0));
		
		sample_in <= shift_left(to_signed(1, 32), 15);
		valid <= '1';
		wait until rising_edge(clk);
		valid <= '0';
		
		for i in 1 to 200  loop
			wait until rising_edge(clk);	
		end loop;
				
		for j in 1 to 46 loop
			sample_in <= to_signed(0, 32);
			valid <= '1';
			wait until rising_edge(clk);
			valid <= '0';
			
			for i in 1 to 200  loop
				wait until rising_edge(clk);	
			end loop;
		end loop;
		
	
		wait;
		
	end process;
		
end architecture;