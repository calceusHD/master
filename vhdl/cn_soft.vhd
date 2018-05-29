library IEEE;
use IEEE.std_logic_1164.all;
use work.soft_types.all;
use IEEE.numeric_std.all;

entity cn_soft is
	generic (
		N_IO : natural;
		LLR_BITS : natural
	);
	port (
		data_in : in llr_type_array(N_IO-1 downto 0);
		data_out : out llr_type_array(N_IO-1 downto 0);
		has_error : out std_logic
	);
end entity;

architecture soft of cn_soft is
    signal sign_out : std_logic_vector(data_in'range);
    signal sign_temp : std_logic_vector(data_in'range);
    signal out_unsigned : llr_type_array(data_out'range);
	function sign_llr_array(inp : llr_type_array) return std_logic_vector is
		variable rv : std_logic_vector(inp'range);
    begin
		for i in inp'range loop
			rv(i) := inp(i)(inp(i)'left);
		end loop;
		return rv;
	end function;

    function attach_sign(inp : llr_type_array; signs : std_logic_vector) return llr_type_array is
        variable rv : llr_type_array(inp'range);
    begin
        for i in signs'range loop
            rv(i) := inp(i) when signs(i) = '1' else -inp(i);
        end loop;
        return rv;
    end function;


	function abs_min_all(inp : llr_type_array) return llr_type is
		variable min_res : llr_type(inp(0)'range) := to_signed(2 ** (inp(0)'length-1) - 1, inp(0)'length);
        variable temp : llr_type(inp'range);
	begin
        for i in inp'range loop
            temp := abs(inp(i));
			min_res := minimum(min_res, temp);
		end loop;
		return min_res;
	end function;

begin
    sign_temp <= (others => (xor sign_llr_array(data_in)));
    sign_out <= sign_llr_array(data_in) xor sign_temp;
    out_unsigned <= (others => abs_min_all(data_in));
    data_out <= attach_sign(out_unsigned, sign_out);
end architecture;
	


