library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity grng_pwclt6 is port(
  iClk : in std_logic;
  iCE : in std_logic := '1';
  iLoadEn : in std_logic := '0';
  iLoadData : in std_logic := '0';
  oRes : out std_logic_vector(15-1 downto 0)
); end entity;

architecture RTL of grng_pwclt6 is
    signal iURNG : std_logic_vector(70-1 downto 0);
    --Bernoulli
    signal bernoulli_fix_out : boolean;
    signal bernoulli_fix_urng : std_logic_vector(32-1 downto 0);
    signal bernoulli_fix_thresh : unsigned(32-1 downto 0);
    --Alias table
    signal alias_table_urng : std_logic_vector(37-1 downto 0);
    signal alias_table_out, c0_alias_index : unsigned(5-1 downto 0);
    attribute rom_style : string;
    type alias_rom_t is array(0 to 32-1) of unsigned(37-1 downto 0);
    signal alias_rom : alias_rom_t := (
        "1111111111100011110111101111100000110", -- i=0, alt=6, thresh=0.999571, actual=0.100792, err=3.62421e-012
        "1111111100010111010001111100111100000", -- i=1, alt=0, thresh=0.996449, actual=0.195253, err=-9.02056e-013
        "1111000110000011101010101101001100110", -- i=2, alt=6, thresh=0.943415, actual=0.177424, err=2.01095e-012
        "1111100111011100111000010000100100001", -- i=3, alt=1, thresh=0.976027, actual=0.151254, err=2.76862e-012
        "1110111110101101110100010010101100000", -- i=4, alt=0, thresh=0.936246, actual=0.12097, err=1.49043e-012
        "1110111100010100101000111101011100001", -- i=5, alt=1, thresh=0.933909, actual=0.0907675, err=9.50351e-013
        "0000000000000000000000000000000000110", -- i=6, alt=6, thresh=1, actual=0.0638944, err=1.943e-007
        "1101011000101010000011000011011000001", -- i=7, alt=1, thresh=0.836579, actual=0.0421963, err=-1.72795e-012
        "1101011000101011110000011001001100000", -- i=8, alt=0, thresh=0.836605, actual=0.0261439, err=3.29253e-012
        "0111110001111101111101001100101100111", -- i=9, alt=7, thresh=0.486297, actual=0.0151968, err=-2.48764e-012
        "0100001111100011111110111101101100010", -- i=10, alt=2, thresh=0.265198, actual=0.00828742, err=3.36182e-012
        "0010001010111100001001001101010100011", -- i=11, alt=3, thresh=0.135683, actual=0.0042401, err=-1.48884e-012
        "0001000010101100010011011000111100100", -- i=12, alt=4, thresh=0.0651291, actual=0.00203529, err=2.60684e-012
        "0000011110000010001100101110101000101", -- i=13, alt=5, thresh=0.0293304, actual=0.000916576, err=2.52132e-012
        "0000001100101100001001111000100000110", -- i=14, alt=6, thresh=0.0123925, actual=0.000387265, err=3.62128e-012
        "0000000101000001111100010111000100000", -- i=15, alt=0, thresh=0.00491246, actual=0.000153514, err=-6.39242e-013
        "0000000001110111101111000101000000001", -- i=16, alt=1, thresh=0.00182702, actual=5.70944e-005, err=-2.32006e-012
        "0000000000101001110001111101010000010", -- i=17, alt=2, thresh=0.000637521, actual=1.99225e-005, err=3.09296e-012
        "0000000000001101101011011010111000011", -- i=18, alt=3, thresh=0.000208716, actual=6.52239e-006, err=3.63284e-012
        "0000000000000100001100111001101100100", -- i=19, alt=4, thresh=6.41111e-005, actual=2.00347e-006, err=3.59636e-012
        "0000000000000001001101011111110100101", -- i=20, alt=5, thresh=1.84767e-005, actual=5.77398e-007, err=-2.43385e-012
        "0000000000000000010100111101001100000", -- i=21, alt=0, thresh=4.99631e-006, actual=1.56135e-007, err=2.13822e-012
        "0000000000000000000101010100010000001", -- i=22, alt=1, thresh=1.26753e-006, actual=3.96103e-008, err=-2.78853e-012
        "0000000000000000000001010001000000010", -- i=23, alt=2, thresh=3.01749e-007, actual=9.42964e-009, err=-3.43795e-013
        "0000000000000000000000010010000100011", -- i=24, alt=3, thresh=6.72881e-008, actual=2.10275e-009, err=-3.58429e-012
        "0000000000000000000000000011110100100", -- i=25, alt=4, thresh=1.42027e-008, actual=4.43833e-010, err=2.39995e-012
        "0000000000000000000000000000110000001", -- i=26, alt=1, thresh=2.79397e-009, actual=8.73115e-011, err=4.97413e-013
        "0000000000000000000000000000001000010", -- i=27, alt=2, thresh=4.65661e-010, actual=1.45519e-011, err=-1.46471e-012
        "0000000000000000000000000000000000011", -- i=28, alt=3, thresh=0, actual=0, err=-2.77403e-012
        "0000000000000000000000000000000000001", -- i=29, alt=1, thresh=0, actual=0, err=-4.50435e-013
        "0000000000000000000000000000000000010", -- i=30, alt=2, thresh=0, actual=0, err=-6.8578e-014
        "0000000000000000000000000000000000001" -- i=31, alt=1, thresh=0, actual=0, err=-1.02202e-014
    );
    attribute rom_style of alias_rom:signal is "distributed";
    signal c1_alias_thresh_bits : unsigned(37-1 downto 0);
    signal c1_alias_thresh_bits_d1 : unsigned(37-1 downto 0);
    signal c1_alias_index : unsigned(5-1 downto 0);
    signal c1_alias_index_d1 : unsigned(5-1 downto 0);
    signal c2_alias_alt : unsigned(5-1 downto 0);
    signal c2_alias_alt_d1 : unsigned(5-1 downto 0);
    signal c2_alias_index : unsigned(5-1 downto 0);
    signal c2_alias_index_d1 : unsigned(5-1 downto 0);
    signal cltfx_out : std_logic_vector(10-1 downto 0);
    signal cltfx_urng : std_logic_vector(32-1 downto 0);
    signal cltfx_sum_4_1 : signed(8-1 downto 0);
    signal cltfx_sum_4_2 : signed(8-1 downto 0);
    signal cltfx_sum_4_3 : signed(8-1 downto 0);
    signal cltfx_sum_4_4 : signed(8-1 downto 0);
    signal cltfx_sum_2_1 : signed(9-1 downto 0);
    signal cltfx_sum_2_2 : signed(9-1 downto 0);
    signal cltfx_sum_1_1 : signed(10-1 downto 0);
    --Mixture PDF
    signal mixture_pdf_urng : std_logic_vector(70-1 downto 0);
    signal c0_mixture_sign_flag : std_logic;
    signal c1_mixture_sindex : signed(6-1 downto 0);
    signal mixture_pdf_out : std_logic_vector(15-1 downto 0);
begin
--Render glue
    urng : entity work.urng_w70 generic map(W=>70) port map(clk=>iClk,ce=>iCE,load_en=>iLoadEn,load_data=>iLoadData,rng=>iURNG);
    mixture_pdf_urng<=iURNG;
    oRes<=std_logic_vector(mixture_pdf_out);
--Implementation
    --Bernoulli

    --Alias table
    c0_alias_index <= unsigned(alias_table_urng(5-1 downto 0));
    bernoulli_fix_urng <= alias_table_urng(37-1 downto 5);
    bernoulli_fix_thresh <= c1_alias_thresh_bits(37-1 downto 5);

    c1_alias_thresh_bits <= c1_alias_thresh_bits_d1;

    c1_alias_index <= c1_alias_index_d1;

    c2_alias_alt <= c2_alias_alt_d1;

    c2_alias_index <= c2_alias_index_d1;

    cltfx_sum_4_1 <= signed(cltfx_urng(8-1 downto 0));
    cltfx_sum_4_2 <= signed(cltfx_urng(16-1 downto 8));
    cltfx_sum_4_3 <= signed(cltfx_urng(24-1 downto 16));
    cltfx_sum_4_4 <= signed(cltfx_urng(32-1 downto 24));
    cltfx_out<= std_logic_vector(cltfx_sum_1_1);
    --Alias table
    alias_table_urng <= mixture_pdf_urng(37-1 downto 0);
    cltfx_urng <= mixture_pdf_urng(69-1 downto 37);
    c0_mixture_sign_flag <= mixture_pdf_urng(69);
process(iClk) begin if(rising_edge(iClk)) then if(iCE='1') then
    --Bernoulli
    bernoulli_fix_out<= unsigned(bernoulli_fix_urng)<bernoulli_fix_thresh;
    --Alias table

    c1_alias_thresh_bits_d1 <= alias_rom(to_integer(c0_alias_index));

    c1_alias_index_d1 <= c0_alias_index;

    c2_alias_alt_d1 <= c1_alias_thresh_bits(5-1 downto 0);

    c2_alias_index_d1 <= c1_alias_index;
    if bernoulli_fix_out then
        alias_table_out <= c2_alias_index;
    else
        alias_table_out <= c2_alias_alt;
    end if;

    cltfx_sum_2_1 <= resize(cltfx_sum_4_2,9) - resize(cltfx_sum_4_1,9);
    cltfx_sum_2_2 <= resize(cltfx_sum_4_4,9) - resize(cltfx_sum_4_3,9);
    cltfx_sum_1_1 <= resize(cltfx_sum_2_2,10) - resize(cltfx_sum_2_1,10);
    --Alias table
    if c0_mixture_sign_flag='1' then
        c1_mixture_sindex <= signed(resize(unsigned(alias_table_out),6));
    else
        c1_mixture_sindex <= -signed(resize(unsigned(alias_table_out),6));
    end if;
    mixture_pdf_out <= std_logic_vector(resize(signed(cltfx_out),15) + ((resize(c1_mixture_sindex,15) sll 8)));
end if; end if; end process;
end RTL;
