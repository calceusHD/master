library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity vn_memory is
	port (
		clk : in std_logic;
		sum_in : in column_sum_array_t;
		wr_in : in std_logic;
		wr_addr : in std_logic_vector;
		
		sum_out : out column_sum_array_t;
		rd_in : in std_logic;
		rd_addr : in std_logic_vector
	);
end entity;

architecture base of vn_memory is
	constant bit_width : natural := sum_in'length * sum_in(0)'length;
	signal conc_in, conc_out : std_logic_vector(bit_width-1 downto o);
begin

	sum_gen : for i in sum_in'range generate
		constant start : natural := (i+1) * sum_in(0)'length - 1;
		constant stop : natural := i * sum_in(0)'length;
	begin
		conc_in(start downto stop) <= std_logic_vector(sum_in(i));
		sum_out(i) <= unsigned(conc_out(start downto stop));
	end generate;

	ram_impl : entity work.generic_ram
	port map (
		clk => clk,
		wr_en => wr_in,
		wr_data => conc_in,
		wr_addr => wr_addr,
		rd_en => rd_in,
		rd_data => conc_out,
		rd_addr => rd_addr
	);
