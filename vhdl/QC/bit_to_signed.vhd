library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.fixed_generic_pkg_mod.all;
use work.common.all;


entity bit_to_signed is
	generic (
		BIT_VAL : integer
	);
    port (
        clk : in std_logic;
        res_e : in std_logic;
        s_tvalid : in std_logic;
        s_tlast : in std_logic;
        s_tdata : in std_logic_vector(31 downto 0);
        s_tready : out std_logic;
		s2_tvalid : in std_logic;
		s2_tlast : in std_logic;
		s2_tdata : in std_logic_vector(15 downto 0);
		s2_tready : out std_logic;
        m_tvalid : out std_logic;
        m_tlast : out std_logic;
        m_tdata : out std_logic_vector(31 downto 0);
        m_tready : in std_logic;
        sigma_inv : in std_logic_vector(31 downto 0)
    );
end entity;

architecture base of bit_to_signed is
	signal bits_in : std_logic_vector(1 downto 0);
	signal bits_out : std_logic_vector(13 downto 0);
	signal last, valid_i, valid_o, ready_i, ready_o : std_logic;
begin
	valid_o <= valid_i and s2_tvalid;
	s2_tready <= ready_o and valid_o;
	ready_i <= ready_o and valid_o;

	oof : for i in 0 to 1 generate
		signal tmp : sfixed(6 downto 0);
	begin
		tmp <= (to_sfixed(-BIT_VAL, 6, 0)) when bits_in(i) = '1' else (to_sfixed(BIT_VAL, 6, 0));
		bits_out((i+1) * 7-1 downto i * 7) <= std_logic_vector(resize(to_sfixed(sigma_inv, 4, -27) * (tmp + to_sfixed(s2_tdata((i+1) * 7 -1 downto i *7), 6, 0)), 6, 0));
	end generate;

	slave_repack : entity work.axi_repack
	generic map (
		LAST_WORD_PADDING => 26
	)
	port map (
		clk => clk,
		res => res_e,
		in_bits => s_tdata,
		out_bits => bits_in,
		in_ready => s_tready,
		in_valid => s_tvalid,
		in_last => s_tlast,
		out_ready => ready_i,
		out_valid => valid_i,
		out_last => last	
	);

	master_repack : entity work.axi_repack
	generic map (
		LAST_WORD_PADDING => 24
	)
	port map (
		clk => clk,
		res => res_e,
		in_bits => bits_out,
		out_bits => m_tdata,
		in_ready => ready_o,
		in_valid => valid_o,
		in_last => last,
		out_ready => m_tready,
		out_valid => m_tvalid,
		out_last => m_tlast
	);

end architecture;
