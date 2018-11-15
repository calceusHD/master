library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;
use work.fixed_generic_pkg_mod.all;

entity unsigned_sub_sat is
	port (
		a : in unsigned;
		b : in unsigned;

		res : out unsigned
	);
end entity;

architecture base of unsigned_sub_sat is
	signal sub_tmp : unsigned(res'length downto 0);
	signal res_zero : unsigned(res'range) := (others => '0');
begin
    --res <= unsigned(resize(to_ufixed(a, a) - to_ufixed(b, b), res));
	--sub_tmp <= ("0" & a) - ("0" & b);
	--res <= res_zero when sub_tmp(sub_tmp'left) = '1' else sub_tmp(res'range);
end architecture;

