library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity message_accu is
	port (
		clk : in std_logic;

		col_sum : in column_sum_array_t;
		roll_count : in roll_t;
		
		row_end : in std_logic;

		xor_out : out min_signs_t
	);
end entity;

architecture base of message_accu is
	signal xor_acc, xor_res, col_sign, col_sign_roll : min_signs_t;
begin
	xor_out <= xor_res;
	
	gen_signs : for i in col_sign'range generate
		col_sign(i) <= '1' when col_sum(i) < 0 else '0';
	end generate;
	
	roll_sign : entity work.dynamic_roll_sign(mux2)
	generic map (
		DIRECTION => true
	)
	port map (
		roll_count => roll_count,
		data_in => col_sign,
		data_out => col_sign_roll
	);

	process (clk)
	begin
		if rising_edge(clk) then
			if row_end = '1' then
				xor_acc <= (others => '0');
			else
				xor_acc <= xor_res;
			end if;
		end if;
	end process;

	xor_res <= xor_acc xor col_sign_roll;

end architecture;
