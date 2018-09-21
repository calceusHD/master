library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.common.all;


entity bit_repack_tb is
end entity;

architecture test of bit_repack_tb is
	signal clk, res, in_wr, out_rdy, in_last : std_logic := '0';
	signal in_rdy, out_wr : std_logic;
	signal in_bits : std_logic_vector(31 downto 0) := (others => '0');
	signal out_bits : std_logic_vector(20 downto 0);

    procedure read_padded_vec(variable line_in : inout line; rv : out std_logic_vector; good : out boolean) is
        variable good_int : boolean := True;
    begin
        good := true;
        for i in rv'range loop
            read(line_in, rv(i), good_int);
            if not good_int then
                rv(i) := '0';
                good := false;
            end if;
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
        variable vec_temp : std_logic_vector(in_bits'range);
        variable good : boolean := true;
	begin
		res <= '1';
		wait for 10 ns;
		res <= '0';
        wait for 15 ns;

		file_open(test_data, "../../test.txt", read_mode);
        
        while not endfile(test_data) loop
            report "start loop";
            readline(test_data, in_line);
			good := true;
            while good loop
                report "start inner loop";
                read_padded_vec(in_line, vec_temp, good);
				wait for 10 ns;
				in_last <= '0';
				while in_rdy /= '1' loop
					in_wr <= '0';
					wait for 10 ns;
					report "looperooni";
				end loop;
                report "got clock";
                --in_wr <= '0';
                --wait on ckl until in_rdy = '1';
                report "got ready";
                in_wr <= '1';
                in_bits <= vec_temp;
				if not good then
					in_last <= '1';
				else
					in_last <= '0';
				end if;
            end loop;
		end loop;
		in_wr <= '0';
        wait;
	end process;

	process
	begin
		wait for 20 ns;
		out_rdy <= '1';
		wait;
	end process;

	dut : entity work.bit_repack
	generic map (
		LAST_WORD_PADDING => 3
	)
	port map (
		clk => clk,
		res => res,
		in_bits => in_bits,
		out_bits => out_bits,
		in_rdy => in_rdy,
		in_wr => in_wr,
		in_last => in_last,
		out_rdy => out_rdy,
		out_wr => out_wr
	);
end architecture;
