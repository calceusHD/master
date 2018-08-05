library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity llr_in_memory is
	port (
		clk : in std_logic;
		res : in std_logic;
		
		llr_in : in llr_column_t;
		wr_in : in std_logic;
		end_in : in std_logic;

		llr_out : out column_sum_array_t;
		rd_in : in std_logic;
		rd_addr : in std_logic_vector;
		
	);
end entity;

architecture base of llr_in_memory is
	constant addr_bits : natural := integer(ceil(log2(real(HQC_COLUMNS))));
	signal write_addr : unsigned(addr_bits-1 downto 0);
begin
	

	process (clk)
	begin
		if rising_edge(clk) then
			if res = '1' then

end architecture;
