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
    signal error_vec : std_logic_vector(15 downto 0);
	signal llr_data : llr_type_array(15 downto 0);


	constant SIGMA : real := 0.1;
begin
	--            message			
	message_in <= "1001010010000100";
    error_vec <=  "0100000000000001";
	

    conv : for i in message_in'range generate
		msg_to_decoder(i) <= to_signed( 20, LLR_BITS) when error_vec(i) = '0' and message_in(i) = '0' else
							 to_signed(-20, LLR_BITS) when error_vec(i) = '0' and message_in(i) = '1' else
							 to_signed(-1, LLR_BITS) when error_vec(i) = '1' and message_in(i) = '0' else
							 to_signed( 1, LLR_BITS) when error_vec(i) = '1' and message_in(i) = '1' else
							 to_signed( 0, LLR_BITS);
--		msg_to_decoder(i) <= (to_signed(2, LLR_BITS) when message_in(i) = '1' else to_signed(-2, LLR_BITS)) when error_vec(i) = '0' else to_signed(-1, LLR_BITS) when message_in(i) = '1' else to_signed(1, LLR_BITS);
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

	converter : entity work.read_to_llr
		generic map (DATA_IN_BITS => LLR_BITS,
			LLR_BITS => LLR_BITS,
			N_IO => 16,
			SIGMA => SIGMA,
			MAX_IN => 1.5)
		port map (data_in => msg_to_decoder,
			data_out => llr_data);



	dut : entity work.decoder_soft
		port map (clk =>clk,
			load => load,
			done => done,
			err => err,
			message_in => llr_data,
			decoded_out => decoded_out);

end architecture;
