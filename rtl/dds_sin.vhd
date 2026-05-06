library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dds_sin is
	port
	(
		clk : in std_logic;
		rst_n : in std_logic;
		
		sin_out : out signed(15 downto 0);
		phase_step : in unsigned(31 downto 0)
	);
end entity;

architecture rtl of dds_sin is
	
	type rom_t is array (0 to 255) of signed(15 downto 0);
	signal nco_acc : unsigned(31 downto 0) := (others => '0');
	
	signal sin_lut : rom_t :=
	(
		x"0000",x"0324",x"0647",x"096a",x"0c8b",x"0fab",x"12c7",x"15e1",
		x"18f8",x"1c0b",x"1f19",x"2223",x"2527",x"2826",x"2b1e",x"2e10",
		x"30fb",x"33de",x"36b9",x"398c",x"3c56",x"3f16",x"41cd",x"447a",
		x"471c",x"49b3",x"4c3f",x"4ebf",x"5133",x"539a",x"55f4",x"5842",
		x"5a81",x"5cb3",x"5ed6",x"60eb",x"62f1",x"64e7",x"66ce",x"68a5",
		x"6a6c",x"6c23",x"6dc9",x"6f5e",x"70e1",x"7254",x"73b5",x"7503",
		x"7640",x"776b",x"7883",x"7989",x"7a7c",x"7b5c",x"7c29",x"7ce2",
		x"7d89",x"7e1c",x"7e9c",x"7f08",x"7f61",x"7fa6",x"7fd7",x"7ff5",
		x"7fff",x"7ff5",x"7fd7",x"7fa6",x"7f61",x"7f08",x"7e9c",x"7e1c",
		x"7d89",x"7ce2",x"7c29",x"7b5c",x"7a7c",x"7989",x"7883",x"776b",
		x"7640",x"7503",x"73b5",x"7254",x"70e1",x"6f5e",x"6dc9",x"6c23",
		x"6a6c",x"68a5",x"66ce",x"64e7",x"62f1",x"60eb",x"5ed6",x"5cb3",
		x"5a81",x"5842",x"55f4",x"539a",x"5133",x"4ebf",x"4c3f",x"49b3",
		x"471c",x"447a",x"41cd",x"3f16",x"3c56",x"398c",x"36b9",x"33de",
		x"30fb",x"2e10",x"2b1e",x"2826",x"2527",x"2223",x"1f19",x"1c0b",
		x"18f8",x"15e1",x"12c7",x"0fab",x"0c8b",x"096a",x"0647",x"0324",
		x"0000",x"fcdc",x"f9b9",x"f696",x"f375",x"f055",x"ed39",x"ea1f",
		x"e708",x"e3f5",x"e0e7",x"dddd",x"dad9",x"d7da",x"d4e2",x"d1f0",
		x"cf05",x"cc22",x"c947",x"c674",x"c3aa",x"c0ea",x"be33",x"bb86",
		x"b8e4",x"b64d",x"b3c1",x"b141",x"aecd",x"ac66",x"aa0c",x"a7be",
		x"a57f",x"a34d",x"a12a",x"9f15",x"9d0f",x"9b19",x"9932",x"975b",
		x"9594",x"93dd",x"9237",x"90a2",x"8f1f",x"8dac",x"8c4b",x"8afd",
		x"89c0",x"8895",x"877d",x"8677",x"8584",x"84a4",x"83d7",x"831e",
		x"8277",x"81e4",x"8164",x"80f8",x"809f",x"805a",x"8029",x"800b",
		x"8001",x"800b",x"8029",x"805a",x"809f",x"80f8",x"8164",x"81e4",
		x"8277",x"831e",x"83d7",x"84a4",x"8584",x"8677",x"877d",x"8895",
		x"89c0",x"8afd",x"8c4b",x"8dac",x"8f1f",x"90a2",x"9237",x"93dd",
		x"9594",x"975b",x"9932",x"9b19",x"9d0f",x"9f15",x"a12a",x"a34d",
		x"a57f",x"a7be",x"aa0c",x"ac66",x"aecd",x"b141",x"b3c1",x"b64d",
		x"b8e4",x"bb86",x"be33",x"c0ea",x"c3aa",x"c674",x"c947",x"cc22",
		x"cf05",x"d1f0",x"d4e2",x"d7da",x"dad9",x"dddd",x"e0e7",x"e3f5",
		x"e708",x"ea1f",x"ed39",x"f055",x"f375",x"f696",x"f9b9",x"fcdc"
	);
	
begin
	
	sin_out <= sin_lut(to_integer(nco_acc(31 downto 24)));

	--
	--
	--
	process(clk, rst_n)
	begin
		if rst_n ='0'then
			nco_acc <= (others => '0');
		elsif rising_edge(clk) then
			nco_acc <= nco_acc + phase_step;
		end if;
	end process;
end architecture;
