library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity axi_decoder is
    port (
        clk : in std_logic;
        res : in std_logic;
        s_tvalid : in std_logic;
        s_tlast : in std_logic;
        s_tdata : in std_logic_vector(31 downto 0);
        s_tready : out std_logic;
        m_tvalid : out std_logic;
        m_tlast : out std_logic;
        m_tdata : out std_logic_vector(31 downto 0);
        m_tready : in std_logic
    );
end entity;

architecture base of axi_decoder is
    signal s_wr, s_tready_int : std_logic;
    signal llr_wr : std_logic;
    signal llr_rep : llr_column_t;
    signal llr_vec : std_logic_vector(llr_rep'length * llr_rep(0)'length -1 downto 0);
    signal result : min_signs_t;
    signal res_rd : std_logic;
begin
    --s_tready <= '1';
    s_wr <= s_tvalid and s_tready_int;
    s_tready <= s_tready_int;

    remap_gen : for i in llr_rep'range generate
        constant start : natural := (i+1) * llr_rep(0)'length - 1;
        constant stop : natural := i * llr_rep(0)'length;
    begin
        llr_rep(i) <= 
                     signed(llr_vec(start downto stop));
    end generate;

    decoder_inst : entity work.decoder
    port map (
        clk => clk,
        res => res,
        llr_in => llr_rep,
        wr_in => llr_wr,
        end_in => s_tlast,
        res_out => result,
        res_rd => res_rd,
        res_end => m_tlast
    );

    slave_repack : entity work.bit_repack
    port map (
        clk => clk,
        res => res,
        in_bits => s_tdata,
        out_bits => llr_vec,
        in_rdy => s_tready_int,
        in_wr => s_wr,
        out_rdy => '1',
        out_wr => llr_wr
    );

    master_repack : entity work.bit_repack
    port map (
        clk => clk,
        res => res,
        in_bits => result,
        out_bits => m_tdata,
        in_rdy => res_rd,
        in_wr => res_rd,
        out_rdy => m_tready,
        out_wr => m_tvalid
    );


end architecture;
