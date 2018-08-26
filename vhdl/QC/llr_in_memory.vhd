library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity llr_in_memory is
	port (
		clk : in std_logic;
		res : in std_logic;
		
		llr_in : in llr_column_t;
		wr_in : in std_logic;
		end_in : in std_logic;

		llr_out : out column_sum_array_t;
		rd_in : in std_logic;
		rd_addr : in row_addr_t
	);
end entity;

architecture base of llr_in_memory is
	constant addr_bits : natural := integer(ceil(log2(real(HQC_COLUMNS))));
	signal write_addr : unsigned(addr_bits-1 downto 0);
    signal write_data, read_data : std_logic_vector(llr_column_t'length * llr_in(0)'length - 1 downto 0);
begin


	process (clk)
	begin
		if rising_edge(clk) then
			if res = '1' then
                write_addr <= (others => '0');
            else
                if wr_in = '1' then
                    write_addr <= write_addr + 1;
                end if;
            end if;
        end if;
    end process;

    io_map : for i in llr_in'range generate
        constant start : natural := (i + 1) * llr_in(0)'length - 1;
        constant stop : natural := i * llr_in(0)'length;
	begin
        write_data(start downto stop) <= std_logic_vector(llr_in(i));
        llr_out(i) <= resize( signed(read_data(start downto stop)), llr_out(0)'length);
    end generate;


    mem : entity work.generic_ram
    port map (
        clk => clk,
        wr_en => wr_in,
        wr_data => write_data,
        wr_addr => write_addr,
        rd_en => rd_in,
        rd_data => read_data,
        rd_addr => rd_addr
    );
end architecture;
