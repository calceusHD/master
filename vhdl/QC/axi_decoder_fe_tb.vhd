library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.common.all;


entity axi_decoder_fe_tb is
end entity;

architecture test of axi_decoder_fe_tb is
	signal clk, res : std_logic := '0';
	signal s_tvalid, s_tlast, s_tready, m_tready : std_logic;
	signal s_tdata : std_logic_vector(31 downto 0) := (others => '0');
	signal out_bits : std_logic_vector(20 downto 0);
	signal max_iter, param_1, param_2 : std_logic_vector(31 downto 0);

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
    max_iter <= std_logic_vector(to_unsigned(2, 32));
    param_1 <= std_logic_vector(to_unsigned(0, 32));
    param_2 <= std_logic_vector(to_unsigned(0, 32));
    
	process
	begin
		wait for 5 ns;
		clk <= not clk;
	end process;

	process
        variable in_line : line;
        variable vec_temp : std_logic_vector(s_tdata'range);
        variable good : boolean := true;
	begin
		res <= '1';
		wait for 10 ns;
		res <= '0';
        wait for 15 ns;

		file_open(test_data, "../../test.txt", read_mode);
 		s_tvalid <= '1';
        while not endfile(test_data) loop
            report "start loop";
            readline(test_data, in_line);
			good := true;
            while good loop
                report "start inner loop";
                read_padded_vec(in_line, vec_temp, good);
				wait for 10 ns;
				s_tlast <= '0';
				while s_tready /= '1' loop
					wait for 10 ns;
					report "looperooni";
				end loop;
                report "got clock";
                --in_wr <= '0';
                --wait on ckl until in_rdy = '1';
                report "got ready";
                s_tdata <= vec_temp;
				if not good then
					s_tlast <= '1';
				else
					s_tlast <= '0';
				end if;
            end loop;
		end loop;
		wait for 10 ns;
		s_tlast <= '0';
		s_tvalid <= '0';
        wait;
	end process;

	process
	begin
		wait for 20 ns;
		m_tready <= '1';
		wait;
	end process;

	dut : entity work.axi_decoder
	port map (
		clk => clk,
		res_e => res,
		s_tvalid => s_tvalid,
		s_tlast => s_tlast,
		s_tdata => s_tdata,
		s_tready => s_tready,
		m_tready => m_tready,
		max_iter => max_iter,
		param_1 => param_1,
		param_2 => param_2
	);

end architecture;
