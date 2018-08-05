library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity decoder is
	port (
		clk : std_logic;
		res : std_logic;
		llr_in : llr_column_t;
		bits_out : std_logic_vector

	);
end entity;
