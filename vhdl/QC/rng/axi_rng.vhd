library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;
--use IEEE.fixed_pkg.all;
use work.fixed_generic_pkg_mod.all;

entity axi_rng is
    generic (
        PARALLEL : positive := 2
    );
    port (
        clk : in std_logic;
        res_e : in std_logic;
        sigma_v : in std_logic_vector(31 downto 0);
        preload_data : in std_logic_vector(31 downto 0);
        m_tvalid : out std_logic;
        m_tlast : out std_logic;
        m_tdata : out std_logic_vector(PARALLEL * (26)-1 downto 0);
        m_tready : in std_logic
    );
end entity;

architecture base of axi_rng is
    signal do_clock : std_logic;
    signal loading, load_en : std_logic;
    signal m_tvalid_int : std_logic;
    signal load_cnt : unsigned(6 downto 0);
    signal preload_tmp : std_logic_vector(31 downto 0);
    signal sigma_signed : sfixed(7 downto -24);
begin
    m_tvalid <= m_tvalid_int;
    do_clock <= loading or (m_tvalid_int and m_tready);
    sigma_signed <= to_sfixed(sigma_v, 7, -24);
    m_tvalid_int <= not loading;
    
    process (clk)
    begin
        if rising_edge(clk) then
            if res_e = '1' then
                loading <= '1';
                load_en <= '1';
                preload_tmp <= preload_data;
                load_cnt <= (others => '1');
            elsif loading = '1' then
                preload_tmp <= std_logic_vector(shift_right(unsigned(preload_tmp), 1));
                load_cnt <= load_cnt - 1;
                if load_cnt = 16 then
                    load_en <= '0';
                end if;
                if load_cnt = 0 then
                    loading <= '0';
                end if;
            end if;
        end if;
    end process;
    
    gen_ran : for i in 0 to PARALLEL-1 generate
        signal res_slv : std_logic_vector(25 downto 0);
        signal res_signed : sfixed(5 downto -20);
        signal res_out : sfixed(sfixed_high(res_signed, '*', sigma_signed) downto sfixed_low(res_signed, '*', sigma_signed));
    begin
        pcwclt : entity work.grng_pwclt12
        port map (
            iclk => clk,
            ice => do_clock,
            iloaden => load_en,
            iloaddata => preload_tmp(i),
            ores => res_slv
        );
        res_signed <= to_sfixed(res_slv, 5, -20);
        res_out <= res_signed * sigma_signed;
        m_tdata((i+1) * (26) - 1 downto i * (26)) <= std_logic_vector(resize(res_out, 5 + LLR_BITS, -20 + LLR_BITS));
    end generate;
end architecture;
        
        
