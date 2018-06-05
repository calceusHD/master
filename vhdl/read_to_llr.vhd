library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.soft_types.all;

entity read_to_llr is 
    generic (DATA_IN_BITS : natural;
        LLR_BITS : natural;
        N_IO : natural;
        SIGMA : real;
        MAX_IN : real
    );
    port (data_in : in llr_type_array(N_IO-1 downto 0);
        data_out : out llr_type_array(N_IO-1 downto 0)
    );
end entity;

architecture binary_flash of read_to_llr is
    type real_array is array(N_IO-1 downto 0) of real;
	function to_real(rhs : llr_type_array) return real_array is
		variable rv : real_array;
	begin
		for i in rhs'range loop
			rv(i) := real(to_integer(rhs(i))) / real(2 ** LLR_BITS);
			rv(i) := realmax(-100.0, realmin(100.0, rv(i)));
		end loop;
		return rv;
	end function;

    signal in_scaled : real_array;
	signal out_real : real_array;
begin
    in_scaled <= to_real(data_in);
	make_out : for i in in_scaled'range generate
		out_real(i) <= ( 1.0 - 2.0 * in_scaled(i) * MAX_IN ) / ( 2.0 * SIGMA );
		data_out(i) <= to_signed(integer(out_real(i)), LLR_BITS);
	end generate;

end architecture;

