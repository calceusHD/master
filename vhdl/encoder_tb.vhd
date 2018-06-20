library IEEE;
use IEEE.std_logic_1164.all;

entity encoder_tb is
end entity;


architecture test of encoder_tb is
	signal clk : std_logic;
	signal to_encode : std_logic_vector(324-1 downto 0);
	signal result1, result2 : std_logic_vector(648-1 downto 0);
begin
	process
	begin
		wait for 5 ns;
		clk <= not clk;
	end process;


	to_encode <= (others => '1');

	dut : entity work.encoder(fast)
	port map (
		clock => clk,
		bits_in => to_encode,
		bits_out => result1);

	ref : entity work.encoder(simple)
	port map (
		clock => clk,
		bits_in => to_encode,
		bits_out => result2);
end architecture;


