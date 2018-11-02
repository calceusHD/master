library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity tausworthe_tb is
end entity;

architecture test of tausworthe_tb is
	signal clk, res, m_tready : std_logic := '0';
	signal preload_data : std_logic_vector(31 downto 0);
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

	dut : entity work.tausworthe
	port map (
		clk => clk,
		res_e => res,
		m_tready => m_tready,
		preload_data => preload_data
	);
end architecture;


