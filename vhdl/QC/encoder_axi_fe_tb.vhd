library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.common.all;


entity axi_encoder_fe_tb is
end entity;

architecture test of axi_encoder_fe_tb is
	signal clk, res, do_gen : std_logic := '0';
	signal s_tvalid, s_tlast, s_tready, m_tvalid1, m_tready_out, m_tvalid2, m_tready, m_tvalid, m_tlast, m_tready_2, m_tvalid_2, m_tlast_2, m_tready_3, m_tlast_3, m_tvalid_3, s2_tvalid, s2_tready, m_tready2, m_tready1, fifo_cmp_tlast, fifo_cmp_tready, fifo_cmp_tvalid : std_logic := '0';
	signal s_tdata, m_tdata, m_tdata_2, m_tdata_3, fifo_cmp_tdata : std_logic_vector(31 downto 0) := (others => '0');
	signal s2_tdata : std_logic_vector(15 downto 0) := (others => '0');
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
    max_iter <= std_logic_vector(to_unsigned(5, 32));
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
        variable count : integer := 0;
	begin
		res <= '1';
		wait for 10 ns;
		res <= '0';
        wait for 15.01 ns;
		do_gen <= '1';
		wait for 100 ns;
		do_gen <= '0';
		wait;
	end process;
/*		
		while true loop
		count := count + 12345;
		file_open(test_data, "../../test.txt", read_mode);
 		
        while not endfile(test_data) loop
            report "start loop";
            readline(test_data, in_line);
			good := true;
            while good loop
                report "start inner loop";
                read_padded_vec(in_line, vec_temp, good);
                --vec_temp := std_logic_vector(to_unsigned(count, 32));
				wait for 10 ns;
				s_tlast <= '0';
				s_tvalid <= '1';
				while s_tready /= '1' loop
					wait for 10 ns;
					--report "looperooni";
				end loop;
                report "got clock";
                --in_wr <= '0';
                --wait on ckl until in_rdy = '1';
                report "got ready";
                s_tdata <= std_logic_vector(unsigned(vec_temp) + count);
				if not good then
					s_tlast <= '1';
				else
					s_tlast <= '0';
				end if;
            end loop;
		end loop;
		file_close(test_data);
		end loop;
		wait for 10 ns;
		--s_tlast <= '0';
		s_tvalid <= '0';
        wait;
	end process;
*/
	process
	begin
		wait until res = '0';
		wait for 16 ns;
		while True loop
			wait for 10 ns;
			s2_tvalid <= '1';
			while s2_tready /= '1' loop
				wait for 10 ns;
			end loop;
			s2_tdata <= std_logic_vector(unsigned(s2_tdata) + 3);
		end loop;
	end process;

	process
	begin
		wait for 20 ns;
		--m_tready_3 <= '1';
		wait;
	end process;

	data_gen : entity work.tausworthe
	port map (
		clk => clk,
		res_e => res,
		do_gen => do_gen,
		m_tvalid => s_tvalid,
		m_tlast => s_tlast,
		m_tdata => s_tdata,
		m_tready => s_tready,
		preload_data => x"1234acbd"
	);

	encode : entity work.axi_encoder
	port map (
		clk => clk,
		res_e => res,
		s_tvalid => s_tvalid,
		s_tlast => s_tlast,
		s_tdata => s_tdata,
		s_tready => s_tready,
		m_tvalid => m_tvalid,
		m_tlast => m_tlast,
		m_tdata => m_tdata,
		m_tready => m_tready
	);

	m_tready <= m_tready1 and m_tready2;
	m_tvalid1 <= m_tready2 and m_tvalid;
	m_tvalid2 <= m_tready1 and m_tvalid;

	convert_bits : entity work.bit_to_signed
	port map (
		clk => clk,
		res_e => res,
		s_tvalid => m_tvalid1,
		s_tlast => m_tlast,
		s_tdata => m_tdata,
		s_tready => m_tready1,
		s2_tvalid => s2_tvalid,
		s2_tlast => '0',
		s2_tdata => "0000000000000000000000000000000000000000000000000000",
		s2_tready => s2_tready,
		m_tvalid => m_tvalid_2,
		m_tlast => m_tlast_2,
		m_tdata => m_tdata_2,
		m_tready => m_tready_2,
		sigma_inv => (others => '0'),
		bit_val => "0000000"
	);

	decode : entity work.axi_decoder
	port map (
		clk => clk,
		res_e => res,
		s_tvalid => m_tvalid_2,
		s_tlast => m_tlast_2,
		s_tdata => m_tdata_2,
		s_tready => m_tready_2,
		m_tvalid => m_tvalid_3,
		m_tlast => m_tlast_3,
		m_tdata => m_tdata_3,
		m_tready => m_tready_3,

		max_iter => max_iter,
		param_1 => param_1,
		param_2 => param_2
	);

	process
	begin
        m_tready_out <= '0';
        wait for 15 us;
        wait for 5 ns;
        m_tready_out <= '1';
        wait for 2 us;
        m_tready_out <= '0';
        wait;
    end process;

	fifo : entity work.axi_fifo
	generic map (
        g_DEPTH => 512
    )
	port map (
		clk => clk,
		res => res,
		s_tvalid => m_tvalid2,
		s_tdata => m_tdata,
		s_tlast => m_tlast,
		s_tready => m_tready2,
		m_tvalid => fifo_cmp_tvalid,
		m_tlast => fifo_cmp_tlast,
		m_tdata => fifo_cmp_tdata,
		m_tready => fifo_cmp_tready
	);

	compare : entity work.axi_cmp
	port map (
		clk => clk,
		res_e => res,
		s_tvalid => m_tvalid_3,
		s_tlast => m_tlast_3,
		s_tdata => m_tdata_3,
		s_tready => m_tready_3,
		s2_tvalid => fifo_cmp_tvalid,
		s2_tlast => fifo_cmp_tlast,
		s2_tdata => fifo_cmp_tdata,
		s2_tready => fifo_cmp_tready,
		m_tready => m_tready_out
	);

end architecture;
