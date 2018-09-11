library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;
use IEEE.math_real.all;
use work.common.all;

entity decoder_tb is
end entity;

architecture test of decoder_tb is
    signal clk, res, wr_in, end_in, res_rd : std_logic := '0';
    signal llr_in : llr_column_t;
    
    procedure read_llr_column(variable line_in : inout line; rv : out llr_column_t) is
    begin
        for i in rv'range loop
            read(line_in, rv(i));
        end loop;
    end procedure;
        
    file test_data : text;
begin

	process
	begin
		wait for 5 ns;
		clk <= not clk;
	end process;

    process
        variable in_line : line;
        variable llr_temp : llr_column_t;
    begin
        res <= '1';
		wait for 10 ns;
		res <= '0';
		wait for 10 ns;


		
		file_open(test_data, "../../test.txt", read_mode);
		wr_in <= '1';
		while not endfile(test_data) loop
			report "test";
			readline(test_data, in_line);
			read_llr_column(in_line, llr_temp);
			llr_in <= llr_temp;
			wait for 10 ns;
		end loop;
		wr_in <= '0';
		end_in <= '1';
		wait for 10 ns;
		end_in <= '0';

        wait;
    end process;











    dut : entity work.decoder
    port map (
        clk => clk,
        res => res,
        llr_in => llr_in,
        wr_in => wr_in,
        end_in => end_in,
        res_rd => res_rd
    );

end architecture;
