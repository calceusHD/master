library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity result_memory is
    port (
        clk : in std_logic;
        res : in std_logic;
        
        res_in : in min_signs_t;
        addr_in : in unsigned;
        wr_in : in std_logic;

        res_out : out min_signs_t;
        res_rd : in std_logic;
        res_end : out std_logic
    );
end entity;

architecture base of result_memory is
    constant addr_bits : natural := integer(ceil(log2(real(HQC_COLUMNS))));
    signal read_addr : unsigned(addr_bits-1 downto 0);
    signal write_data, read_data : std_logic_vector(min_signs_t'range);
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if res = '1' then
                read_addr <= (others => '0');
            else
                if res_rd = '1' then
                    read_addr <= read_addr + 1;
                    if read_addr = HQC_COLUMNS then
                        read_addr <= (others => '0');
                    end if;
                end if;
            end if;
        end if;
    end process;

    write_data <= res_in;
    res_out <= read_data;

    mem : entity work.generic_ram
    port map (
        clk => clk,
        wr_en => wr_in,
        wr_data => write_data,
        wr_addr => addr_in,
        rd_en => res_rd,
        rd_data => read_data,
        rd_addr => read_addr
    );
end architecture;

