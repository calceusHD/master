library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity cn_global_accu is
	port (
		clk : in std_logic;

		data_in : in llr_array_t;
		
		row_end : in std_logic;
        offset : in unsigned;

		min_out, min2_out : out min_array_t;
		min_id_out : out min_id_array_t;
		sign_out : out min_signs_t;

		signs_out : out signs_t
	);
end entity;

architecture base of cn_global_accu is
	signal min_acc, min2_acc, min_res, min2_res : min_array_t;
	signal min_id_acc, min_id_res : min_id_array_t;
	signal sign_acc, sign_res : min_signs_t;
begin

	min_out <=  min_res;
	min2_out <= min2_res;
	min_id_out <= min_id_res;
	sign_out <= sign_res;

	process (clk) 
	begin
		if rising_edge(clk) then
			if row_end = '1' then
				min_acc <= (others => (others => '1'));
				min2_acc <= (others => (others => '1'));
				min_id_acc <= (others => (others => '0'));
				sign_acc <= (others => '0');
			else
				min_acc <= min_res;
				min2_acc <= min2_res;
				min_id_acc <= min_id_res;
				sign_acc <= sign_res;
			end if;
        end if;
    end process;


	node : entity work.cn_global
	port map (
		data_in => data_in,
		min_in => min_acc,
        min2_in => min2_acc,
        min_id_in => min_id_acc,
        sign_in => sign_acc,
        offset => offset,
        min_out => min_res,
        min2_out => min2_res,
        min_id_out => min_id_res,
        sign_out => sign_res,
        signs_out => signs_out
    );
end architecture;

