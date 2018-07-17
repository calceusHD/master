library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity cn_global is
    port (
        data_in : in llr_array_t;
        min_in, min2_in : in min_array_t;
        min_id_in : in min_id_array_t;
        sign_in : min_signs_t;
        offset : unsigned;

        min_out, min2_out : out min_array_t;
        min_id_out : out min_id_array_t;
        sign_out : out min_signs_t;

        signs_out : out signs_t
    );
end entity;

architecture base of cn_global is
	signal data_rolled : llr_array_t;

	function llr_slice(llr_in : llr_array_t; pos : natural) return llr_row_t is
		variable rv : llr_row_t;
	begin
		for i in llr_in'range(2) loop
			rv(i) := llr_in(pos, i);
		end loop;
	end function;
begin

	roller : entity work.fixed_roll
	generic map (ROLL_COUNTS => ROLL_COUNT)
	port map ( data_in => data_in,
		data_out => data_rolled
	);

    sign_i: for i in data_in'range(1) generate
    begin
        sign_j : for j in data_in'range(2) generate
        begin
            signs_out(i)(j) <= '1' when data_in(i, j) < 0 else '0';
        end generate;
    end generate;
    
    min_gen : for i in data_in'range generate
		signal row_tmp : llr_row_t;
    begin
		row_tmp <= llr_slice(data_rolled, i);
        find_min : entity work.row_min
        port map (
            min_in => min_in(i),
            min2_in => min2_in(i),
            min_id_in => min_id_in(i),
            row_in => row_tmp,
            min_out => min_out(i),
            min2_out => min2_out(i),
            min_id_out => min_id_out(i),
            offset => offset
        );
    end generate;
    

end architecture;


