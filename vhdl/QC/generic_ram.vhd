library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity generic_ram is
	port (
		clk : in std_logic;
		wr_en : in std_logic;
		wr_data : in std_logic_vector;
		wr_addr : in unsigned;
		rd_en : in std_logic;
		rd_data : out std_logic_vector;
		rd_addr : in unsigned
	);
end entity;

architecture base of generic_ram is
	type ram_t is array(0 to 2**wr_addr'length-1) of std_logic_vector(wr_data'range);
	signal memory : ram_t;
begin
	process (clk)
	begin
		if rising_edge(clk) then
			if wr_en = '1' then
				memory(to_integer(unsigned(wr_addr))) <= wr_data;
			end if;

			if rd_en = '1' then
				rd_data <= memory(to_integer(unsigned(rd_addr)));
			end if;
		end if;
	end process;
end architecture;

