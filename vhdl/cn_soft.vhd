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
	signal min_out, min2_out : llr_type(data_in(0)'range);
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
            rv(i) := inp(i) when signs(i) = '0' else -inp(i);
        end loop;
        return rv;
    end function;


	procedure abs_min_all(inp : llr_type_array; signal min_res : out llr_type; signal min2_res : out llr_type) is
		variable min_tmp, min2_tmp : llr_type(inp(0)'range);
	begin
		min_tmp := to_signed(2 ** (inp(0)'length-1)-1, inp(0)'length);
		min2_tmp := min_tmp;
        for i in inp'range loop
			if abs(inp(i)) < min_tmp then
				min2_tmp := min_tmp;
				min_tmp := abs(inp(i));
			end if;
		end loop;
		min_res <= min_tmp;
		min2_res <= min2_tmp;
	end procedure;

begin
    sign_temp <= (others => (xor sign_llr_array(data_in)));
    sign_out <= sign_llr_array(data_in) xor sign_temp;
	put_mins : for i in out_unsigned'range generate
		out_unsigned(i) <= min_out when abs(data_in(i)) /= min_out else min2_out;
	end generate;
	abs_min_all(data_in, min_out, min2_out);
    data_out <= attach_sign(out_unsigned, sign_out);
end architecture;
	


