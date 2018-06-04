library IEEE;
use IEEE.std_logic_1164.all;
use work.soft_types.all;
use IEEE.numeric_std.all;

entity test is
end entity;


architecture test of test is
	signal signed_test : signed(3 downto 0);
	signal result : signed(3 downto 0);
begin
	process
	begin
		signed_test <= "UUUU";
		result <= abs(signed_test);
		report integer'image(result'length);
			for i in 0 to result'LENGTH-1 loop
            	report "vectB("&integer'image(i)&") value is" &   
                	std_logic'image(result(i));
			end loop;
			report "blobb";

		wait;
	end process;
end architecture;
