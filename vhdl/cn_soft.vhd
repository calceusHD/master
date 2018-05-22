library IEEE;
use IEEE.std_logic_1164.all;
use work.soft_types.all;

entity cn_soft is
	generic (
		N_IO : natural;
		LLR_BITS : natural
	);
	port (
		data_in : in llr_type_array(N_IO-1 downto 0)(LLR_BITS-1 downto 0);
		data_out : out llr_type_array(N_IO-1 downto 0)(LLR_BITS-1 downto 0);
		has_error : out std_logic
	);
end entity;

architecture soft of cn_soft is
	function sign_llr_array(inp : llr_type_array) return std_logic_vector is
		variable rv : std_logic_vector(inp'range);
		for i in inp'range loop
			rv(i) := inp(i)(inp(i)'left);
		end loop;
		return rv;
	end function;

	function abs_min_all(inp : llr_type_array) return llr_type is
		variable min : llr_type(inp'range) := inp'high;
	begin
		for i in inp'range loop
			min := min(min, abs(inp(i)));
		end loop;
		return min;
	end function;

begin

end architecture;
	


