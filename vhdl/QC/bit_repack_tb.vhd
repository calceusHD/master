library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity bit_repack_tb is
end entity;

architecture test of bit_repack_tb is
	signal clk, res, in_wr, out_rdy : std_logic := '0';
	signal in_rdy, out_wr : std_logic;
	signal in_bits : std_logic_vector(7 downto 0) := (others => '0');
	signal out_bits : std_logic_vector(4 downto 0);
begin
	process
	begin
		clk <= not clk;
		wait for 5 ns;
	end process;

	process
	begin
		res <= '1';
		wait for 20 ns;
		res <= '0';
		for i in 1 to 10 loop
			wait until in_rdy = '1' and rising_edge(clk);
			in_wr <= '1';
			in_bits <= std_logic_vector(to_unsigned(i, 8));
			wait for 11 ns;
			in_wr <= '0';
		end loop;
	end process;

	process
	begin
		wait for 60 ns;
		out_rdy <= '1';
		wait;
	end process;

	dut : entity work.bit_repack
	port map (
		clk => clk,
		res => res,
		in_bits => in_bits,
		out_bits => out_bits,
		in_rdy => in_rdy,
		in_wr => in_wr,
		out_rdy => out_rdy,
		out_wr => out_wr
	);
end architecture;
