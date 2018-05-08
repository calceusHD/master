library IEEE;
use IEEE.std_logic_1164.all;

entity decoder_hard_tb is
end entity;

architecture test of decoder_hard_tb is
	signal clk, load, done, err : std_logic := '0';
	signal message_in, decoded_out : std_logic_vector(15 downto 0);

begin
	message_in <= "1001010010000100" xor "1000000000000000";

	process
	begin
		clk <= not clk;
		wait for 5 ns;
	end process;

	process
	begin
		wait for 5 ns;
		load <= '1';
		wait for 20 ns;
		load <= '0';
		wait;
	end process;


	dut : entity work.decoder_hard
		port map (clk =>clk,
			load => load,
			done => done,
			err => err,
			message_in => message_in,
			decoded_out => decoded_out);

end architecture;
