library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use std.textio.all;
use IEEE.fixed_pkg.all;
--use work.fixed_generic_pkg_mod.all;

entity rng_tb is
end entity;

architecture test of rng_tb is
	signal clk, m_tready, load, load_data : std_logic := '0';
	signal preload_data : std_logic_vector(31 downto 0);
	signal res : std_logic;
	signal fix_res : sfixed(5 downto -20);
	file test_data : text;
begin

	process
	begin
		wait for 5 ns;
		clk <= not clk;
	end process;

	process
	begin
		res <= '1';
		preload_data <= x"0f344123";
		wait for 10 ns;
		res <= '0';
		wait for 15.01 ns;
		m_tready <= '1';
		wait for 100 ns;
		m_tready <= '0';
		wait for 50 ns;
		m_tready <= '1';
		wait;
	end process;

	dut : entity work.axi_rng
	generic map (
        PARALLEL => 1
    )
	port map (
        clk => clk,
        res_e => res,
        sigma_v => "00100000000000000000000000000000",
        preload_data => preload_data,
        m_tready => '1'
	);
end architecture;


 
