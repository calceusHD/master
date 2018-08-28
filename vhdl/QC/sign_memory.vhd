library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity sign_memory is
	port (
		clk : in std_logic;
		signs_in : in signs_t;
		wr_in : in std_logic;
		wr_addr : in signs_addr_t;

		signs_out : out signs_t;
		rd_in : in std_logic;
		rd_addr : in signs_addr_t
	);
end entity;

architecture base of sign_memory is
	constant bit_width : natural := signs_in'length * sign_in(0)'length;
	signal conc_in, conc_out : std_logic_vector(bit_width-1 downto 0);
begin

	sign_gen : i in signs_in'range generate
		constant start : natural := (i+1) * signs_in(0)'length - 1;
		constant stop : natural := i * signs_in(0)'length;
	begin
		conc_in(start downto stop) <= signs_in(i);
		sign_out(i) <= conc_out(start downto stop);
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

end architecture;
