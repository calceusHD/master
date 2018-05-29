library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.soft_types.all;
entity decoder_soft_tb is
end entity;

architecture test of decoder_soft_tb is
	signal clk, load, done, err : std_logic := '0';
	signal decoded_out : std_logic_vector(15 downto 0);
	signal message_in : std_logic_vector(15 downto 0);
    signal msg_to_decoder : llr_type_array(15 downto 0) := (others => (others => '0'));
    signal error_vec : llr_type_array(15 downto 0);

begin
	--            message				 error vector
	message_in <= "1001010010000100" xor "0000000000000000";
/*
    error_vec <= (x"05", x"00", x"00", x"00",
                 x"00", x"00", x"00", x"00",
                 x"00", x"00", x"00", x"00",
                 x"00", x"00", x"00", x"00");

*/
    conv : for i in message_in'range generate
        msg_to_decoder(i) <= to_signed(2, LLR_BITS) when message_in(i) = '0' else to_signed(-2, LLR_BITS); -- + error_vec(i);
    end generate;

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


	dut : entity work.decoder_soft
		port map (clk =>clk,
			load => load,
			done => done,
			err => err,
			message_in => msg_to_decoder,
			decoded_out => decoded_out);

end architecture;
