library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity dynamic_roll_tb is
end entity;

architecture base of dynamic_roll_tb is
	signal data_in, data_out, data_ref : llr_array_t;
	signal roll_count : roll_t;
begin

	process
	begin
		for i in data_in'range(1) loop
			data_in(i, 0) <= to_signed(i, data_in(0, 0)'length);
		end loop;
		roll_count <= (others => '0');
		for i in 0 to 199 loop
		wait for 10 ns;
			roll_count <= roll_count + 1;
			wait for 10 ns;
			assert data_out = data_ref;
		end loop;
		wait;
	end process;

	dut : entity work.dynamic_roll(mux4)
	generic map (
		DIRECTION => false
	)
	port map (
		roll_count => roll_count,
		data_in => data_in,
		data_out => data_out
	);

	ref : entity work.dynamic_roll(base)
	generic map (
		DIRECTION => false
	)
	port map (
		roll_count => roll_count,
		data_in => data_in,
		data_out => data_ref
	);
		
end architecture;


