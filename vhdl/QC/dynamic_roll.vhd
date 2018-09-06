library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity dynamic_roll is
	generic (
		DIRECTION : boolean --true means the same direction as fixed roll
	);
    port (
		roll_count : in unsigned; --must be <= data_in'length
        data_in : in llr_array_t;
		data_out : out llr_array_t
    );
end entity;

architecture base of dynamic_roll is
    function sub_mod(a : integer; n : natural) return integer is
    begin
        if a >= n then
            return a - n;
        else
            return a;
        end if;
    end function;

    function add_mod(a : integer; n : natural) return integer is
    begin
        if a < 0 then
            return a + n;
        else
            return a;
        end if;
    end function;
begin
	gen_i : for i in data_in'range(1) generate
	begin
		gen_j : for j in data_in'range(2) generate
		begin
			data_out(i, j) <= data_in(add_mod(i - to_integer(roll_count), data_in'length), j) when not DIRECTION 
				else data_in(sub_mod(i + to_integer(roll_count), data_in'length), j);
		end generate;
	end generate;

end architecture;
