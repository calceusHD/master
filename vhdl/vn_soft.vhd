library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package soft_types is
	constant LLR_BITS : natural := 4;
	subtype llr_type is signed;
	type llr_type_array is array(natural range <>) of llr_type;
end package;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.soft_types.all;

entity vn_soft is
	generic (N_IO : natural;
			LLR_BITS : natural);
	port (clk : in std_logic;
		load : in std_logic;
		load_data : in llr_type(LLR_BITS-1 downto 0);
		result : out std_logic;
		data_in : in llr_type_array(N_IO-1 downto 0)(LLR_BITS-1 downto 0);
		data_out : out llr_type_array(N_IO-1 downto 0)(LLR_BITS-1 downto 0)
	);
end entity;

architecture soft of vn_soft is
	constant MAX_BITS : integer := LLR_BITS + integer(ceil(log2(real(N_IO))));
	signal sum_int : llr_type_array(N_IO-1 downto 0)(MAX_BITS-1 downto 0);
	signal data_out_int : llr_type_array(data_in'range)(data_in(0)'range);
	function sum_all(inp : llr_type_array) return llr_type is
		variable sum : llr_type(inp'range)	:= to_signed(0, inp'high);
	begin
		for i in inp'range loop
			sum := sum + inp(i);
		end loop;
		return sum;
	end function;

	function llr_array_sub(a : llr_type_array; b : llr_type_array) return llr_type_array  is
		variable rv : llr_type_array(a'range)(a(0)'range);
	begin
		for i in a'range loop
			rv(i) := a(i) - b(i);
		end loop;
	end function;
begin
	
	process (clk)
	begin
		if rising_edge(clk) then
			if load = '1' then
				data_out_int <= (others => load_data);
			else
				data_out_int <= llr_array_sub(sum_int, data_in);
			end if;
		end if;
	end process;
	sum_int <= (others => sum_all(data_in));
	data_out <= data_out_int;
end architecture;
