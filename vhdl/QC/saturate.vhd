library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

-- does symmetric saturation to be able to squeeze the absolute of the result into an unsigned with 1 bit less width

entity saturate is
	port (
		data_in : in signed;
		data_out : out signed
	);
end entity;

architecture base of saturate is
	signal rv : signed(data_out'range);
	constant rv_width : integer := data_out'width;
begin
	data_out <= rv;

	rv <= to_signed( 2 ** (rv_width - 1) - 1, rv_width) when data_in >  2 ** (rv_width - 1) - 1 else
		  to_signed(-2 ** (rv_width - 1) + 1, rv_width) when data_in < -2 ** (rv_width - 1) + 1 else
		  data_in(data_out'range);

end architecture;
