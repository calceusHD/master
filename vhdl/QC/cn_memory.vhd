library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

-- entity to abstract the actual memory implementation away

entity cn_memory is
	port (
		clk : in std_logic;
		min_in, min2_in : in min_array_t;
		min_id_in : in min_id_array_t;
		sign_in : in min_signs_t;
		wr_in : in std_logic;
		wr_addr : in std_logic_vector;

		min_out, min2_out : out min_id_array_t;
		min_id_out : out min_id_array_t;
		sign_out : out min_signs_t;
		rd_in : in std_logic;
		rd_addr : in std_logic_vector
	);
end entity;

architecture base of cn_memory is
	constant bit_width : natural := min_in'length * min_in(0)'length * 2 + min_id_in'length * min_id_in(0)'length + sign_in'length;
	signal conc_in : std_logic_vector(bit_width-1 downto 0);
	signal conc_out : std_logic_vector(bit_width-1 downto 0);
begin

	min_gen : for i in min_in'range generate
		constant start : natural := (i+1) * min_in(0)'length-1;
		constant stop : natural := i * min_in(0)'length;
	begin
		conc_in(start downto stop) <= std_logic_vector(min_in(i));
		min_out(i) <= unsigned(conc_out(start downto stop));
	end generate;


	min2_gen : for i in min2_in'range generate
		constant offset : natural := min_in'length * min_in(0)'length;
		constant start : natural := (i+1) * min2_in(0)'length-1;
		constant stop : natural := i * min2_in(0)'length;
	begin
		conc_in(start downto stop) <= std_logic_vector(min2_in(i));
		min2_out(i) <= unsigned(conc_out(start downto stop));
	end generate;

	min_id_gen : for i in min_id_in'range generate
		constant offset : natural := min_in'length * min_in(0)'length * 2;
		constant start : natural := (i+1) * min_id_in(0)'length-1;
		constant stop : natural := i * min_id_in(0)'length;
	begin
		conc_in(start downto stop) <= std_logic_vector(min_id_in(i));
		min_id_out(i) <= unsigned(conc_out(start downto stop));
	end generate;
	
	conc_in(bit_width-1 downto min_in'length * min_in(0)'length * 2 + min_id_in'length * min_id_in(0)'length) <= sign_in;
	sign_out <= conc_out(bit_width-1 downto min_in'length * min_in(0)'length * 2 + min_id_in'length * min_id_in(0)'length);
	
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

end architecture;
