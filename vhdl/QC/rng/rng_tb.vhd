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
	signal clk, m_tready, m_tvalid, load, load_data : std_logic := '0';
	signal preload_data : std_logic_vector(31 downto 0);
	signal res : std_logic;
	signal fix_res : sfixed(5 downto -20);
	signal res_data : std_logic_vector(7 downto 0);
	file test_data : text;
	signal sigma : std_logic_vector(31 downto 0);
begin

	process
	begin
		wait for 5 ns;
		clk <= not clk;
	end process;

	process
        variable l_line : line;
	begin
        file_open(test_data, "../../../../test.txt", write_mode);
		res <= '1';
		sigma <= std_logic_vector(shift_left(to_signed(40, 32), 24));
		preload_data <= x"0f344123";
		wait for 10 ns;
		res <= '0';
		wait for 15.01 ns;
		m_tready <= '1';
		wait for 100 ns;
		m_tready <= '0';
		wait for 50 ns;
		m_tready <= '1';
		wait until m_tvalid = '1';
		while true loop
            wait until rising_edge(clk);
            write(l_line, signed(res_data));
            writeline(test_data, l_line);
		end loop;
        
        
		wait;
	end process;

	dut : entity work.axi_rng
	generic map (
        PARALLEL => 1
    )
	port map (
        clk => clk,
        res_e => res,
        sigma_v => sigma,
        preload_data => preload_data,
        m_tvalid => m_tvalid,
        m_tready => '1',
        m_tdata => res_data
	);
end architecture;


 
