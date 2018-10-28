library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
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
        m_tvalid : out std_logic;
        m_tlast : out std_logic;
        m_tdata : out std_logic_vector(31 downto 0);
        m_tready : in std_logic
    );
end entity;

architecture base of bit_to_signed is
	signal bits_in : std_logic_vector(0 downto 0);
	signal bits_out : std_logic_vector(6 downto 0);
	signal last, valid, ready : std_logic;
begin
	
	
	bits_out <= std_logic_vector(to_signed(-BIT_VAL, 7)) when bits_in(0) = '1' else std_logic_vector(to_signed(BIT_VAL, 7));

	slave_repack : entity work.axi_repack
	generic map (
		LAST_WORD_PADDING => 25
	)
	port map (
		clk => clk,
		res => res_e,
		in_bits => s_tdata,
		out_bits => bits_in,
		in_ready => s_tready,
		in_valid => s_tvalid,
		in_last => s_tlast,
		out_ready => ready,
		out_valid => valid,
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
		in_ready => ready,
		in_valid => valid,
		in_last => last,
		out_ready => m_tready,
		out_valid => m_tvalid,
		out_last => m_tlast
	);

end architecture;
