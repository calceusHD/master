library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity grng_pwclt10 is port(
  iClk : in std_logic;
  iCE : in std_logic := '1';
  iLoadEn : in std_logic := '0';
  iLoadData : in std_logic := '0';
  oRes : out std_logic_vector(22-1 downto 0)
); end entity;

architecture RTL of grng_pwclt10 is
    signal iURNG : std_logic_vector(234-1 downto 0);
    --Bernoulli
    -- bernoulli_fp, fb=40, frac_width=39, exp_width=7
    --   exp_src_width=83
    signal bernoulli_fp_out : boolean;
    signal bernoulli_fp_thresh : unsigned(46-1 downto 0);
    signal bernoulli_fp_urng : std_logic_vector(122-1 downto 0);
    signal bernoulli_fp_cx_exp_urng : std_logic_vector(83-1 downto 0);
    signal bernoulli_fp_c0_frac_thresh, bernoulli_fp_c0_frac_rand : unsigned(39-1 downto 0);
    signal bernoulli_fp_cx_exp_rand, bernoulli_fp_c0_exp_thresh: unsigned(7-1 downto 0);
    signal bernoulli_fp_c1_exp_greater, bernoulli_fp_c1_exp_equal, bernoulli_fp_c1_frac_greater : boolean;
    signal lmz_branch_1, lmz_branch_1_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_1, lmz_branch_hit_1_sig : boolean;
    signal lmz_branch_2, lmz_branch_2_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_2, lmz_branch_hit_2_sig : boolean;
    signal lmz_branch_3, lmz_branch_3_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_3, lmz_branch_hit_3_sig : boolean;
    signal lmz_branch_4, lmz_branch_4_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_4, lmz_branch_hit_4_sig : boolean;
    signal lmz_branch_5, lmz_branch_5_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_5, lmz_branch_hit_5_sig : boolean;
    signal lmz_branch_6, lmz_branch_6_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_6, lmz_branch_hit_6_sig : boolean;
    signal lmz_branch_7, lmz_branch_7_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_7, lmz_branch_hit_7_sig : boolean;
    signal lmz_branch_8, lmz_branch_8_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_8, lmz_branch_hit_8_sig : boolean;
    signal lmz_branch_9, lmz_branch_9_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_9, lmz_branch_hit_9_sig : boolean;
    signal lmz_branch_10, lmz_branch_10_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_10, lmz_branch_hit_10_sig : boolean;
    signal lmz_branch_11, lmz_branch_11_sig : unsigned(7-1 downto 0);
    signal lmz_branch_hit_11, lmz_branch_hit_11_sig : boolean;
    signal bernoulli_fp_c0_exp_rand : unsigned(7-1 downto 0);
    signal bernoulli_fp_c0_exp_rand_d1 : unsigned(7-1 downto 0);
    signal bernoulli_fp_c0_exp_rand_d2 : unsigned(7-1 downto 0);
    --Alias table
    signal alias_table_urng : std_logic_vector(129-1 downto 0);
    signal alias_table_out, c0_alias_index : unsigned(7-1 downto 0);
    attribute rom_style : string;
    type alias_rom_t is array(0 to 128-1) of unsigned(53-1 downto 0);
    signal alias_rom : alias_rom_t := (
        "00000000000000000011011111100110011111100011110001101", -- i=0, alt=13, thresh=0.999787, actual=0.0501297, err=1.81105e-015
        "00000000110100101110100101000100001011110010110000100", -- i=1, alt=4, thresh=0.794032, actual=0.0994709, err=-1.38778e-017
        "00000000000101000101100011011001011100001111000001100", -- i=2, alt=12, thresh=0.98013, actual=0.0971427, err=-2.85882e-015
        "00000000001010010111011111100010011111111101010010001", -- i=3, alt=17, thresh=0.959504, actual=0.0933828, err=-3.747e-016
        "00000000000001110100011110011000110000100010100000000", -- i=4, alt=0, thresh=0.992891, actual=0.0883621, err=-3.03924e-015
        "00000000010010000011011001100110110011110001110010001", -- i=5, alt=17, thresh=0.92948, actual=0.0823016, err=9.02056e-016
        "00000000001111011110101010100111001111110010010000100", -- i=6, alt=4, thresh=0.939535, actual=0.0754558, err=1.3739e-015
        "00000000100101110100010111100101111100101001100000000", -- i=7, alt=0, thresh=0.852272, actual=0.0680958, err=1.15186e-015
        "00000000110111011011100000000100101110101111010001101", -- i=8, alt=13, thresh=0.783478, actual=0.0604909, err=-3.46251e-015
        "00000000110100000010110011001001010100110110010010001", -- i=9, alt=17, thresh=0.796704, actual=0.0528936, err=3.13638e-015
        "00000000100111111010001111110110111001010011010001101", -- i=10, alt=13, thresh=0.844101, actual=0.0455259, err=2.06779e-015
        "00000000001101011010111000111110111100001011010000100", -- i=11, alt=4, thresh=0.947577, actual=0.0385706, err=-2.74086e-015
        "00000000000000010000011111010000110001000010010000000", -- i=12, alt=0, thresh=0.998994, actual=0.0321661, err=-2.9074e-015
        "00000000000000010000011111010000110001000010010001101", -- i=13, alt=13, thresh=NaN, actual=0.0264047, err=-1.46411e-015
        "00000000101101001110001010111011011001100110110001111", -- i=14, alt=15, thresh=0.823354, actual=0.0213358, err=3.53884e-015
        "00000000000000100010111111110010001001010100110001101", -- i=15, alt=13, thresh=0.997864, actual=0.0169699, err=-8.32667e-016
        "00000000011010001100111010110010111001111111110001100", -- i=16, alt=12, thresh=0.897649, actual=0.0132859, err=3.2474e-015
        "00000000000000111101100010100001111111011100000000000", -- i=17, alt=0, thresh=0.996244, actual=0.0102387, err=1.68095e-015
        "00000000000001011111110001100100010111101011100001101", -- i=18, alt=13, thresh=0.994154, actual=0.00776683, err=1.05818e-015
        "00000001000001111101101110001110011001100000110000000", -- i=19, alt=0, thresh=0.742327, actual=0.00579943, err=5.21284e-016
        "00000001110100010100110010101011101011011110110000010", -- i=20, alt=2, thresh=0.545606, actual=0.00426255, err=-2.50754e-015
        "00000010110101111001010011100001000100011010000000101", -- i=21, alt=5, thresh=0.394736, actual=0.00308387, err=7.36824e-016
        "00000011110000000100100101010111010101110010110000110", -- i=22, alt=6, thresh=0.28111, actual=0.00219617, err=0
        "00000100110110001101101111000000111110110001010010000", -- i=23, alt=16, thresh=0.197056, actual=0.0015395, err=-2.89699e-016
        "00000101110100110001000000011000100111001001110000111", -- i=24, alt=7, thresh=0.135971, actual=0.00106227, err=-7.19693e-016
        "00000111000010110111010000000110010011001101100001110", -- i=25, alt=14, thresh=0.0923519, actual=0.000721499, err=-1.97325e-016
        "00001000000011000110011010000011110100010111000000001", -- i=26, alt=1, thresh=0.0617431, actual=0.000482368, err=9.75782e-018
        "00001001011001100100011001110010111100101010010001000", -- i=27, alt=8, thresh=0.0406326, actual=0.000317442, err=7.69241e-017
        "00001010101000011000001010000010100101110011010001001", -- i=28, alt=9, thresh=0.0263211, actual=0.000205634, err=7.76831e-017
        "00001011110110100000101110010101010101010101010001010", -- i=29, alt=10, thresh=0.0167833, actual=0.000131119, err=-2.19009e-017
        "00001101010011011010010011010110111001111100010001011", -- i=30, alt=11, thresh=0.010534, actual=8.22969e-005, err=2.00984e-017
        "00001110101010101111100100001111001100111010100000011", -- i=31, alt=3, thresh=0.00650808, actual=5.08444e-005, err=-1.5538e-017
        "00001111111110010011110110010011110011011110000001100", -- i=32, alt=12, thresh=0.00395782, actual=3.09205e-005, err=-1.73879e-017
        "00010001100100101110110101000001101010110100100001111", -- i=33, alt=15, thresh=0.00236921, actual=1.85094e-005, err=1.43996e-018
        "00010011001001000001010010100111111011011101100000100", -- i=34, alt=4, thresh=0.00139603, actual=1.09064e-005, err=2.83756e-018
        "00010100101011101111011000101111001110000111000001101", -- i=35, alt=13, thresh=0.000809706, actual=6.32583e-006, err=1.54329e-018
        "00010110001101101000011100111011011110101011110000000", -- i=36, alt=0, thresh=0.00046228, actual=3.61156e-006, err=7.80541e-019
        "00010111110111110010110011011101000101110100000000010", -- i=37, alt=2, thresh=0.000259793, actual=2.02963e-006, err=-8.91079e-019
        "00011001101001010011101010011100101010110000110000101", -- i=38, alt=5, thresh=0.000143712, actual=1.12275e-006, err=8.00446e-019
        "00011011011011111001000010010101000101000010000000110", -- i=39, alt=6, thresh=7.82532e-005, actual=6.11353e-007, err=-4.00752e-019
        "00011101010000000101000111010111100110000011100000111", -- i=40, alt=7, thresh=4.19426e-005, actual=3.27677e-007, err=6.57509e-020
        "00011111000110010111110100100100100010111000000001110", -- i=41, alt=14, thresh=2.21286e-005, actual=1.72879e-007, err=-9.8547e-020
        "00100000111111001100100101001010000000001011100000001", -- i=42, alt=1, thresh=1.1492e-005, actual=8.97811e-008, err=1.90318e-020
        "00100010111010111000010100011010111001101111010001000", -- i=43, alt=8, thresh=5.87463e-006, actual=4.58956e-008, err=1.21695e-020
        "00100100111001100111111000011000011111000001000001001", -- i=44, alt=9, thresh=2.95605e-006, actual=2.30941e-008, err=1.31456e-020
        "00100110111011011111000010101001110011101000100001010", -- i=45, alt=10, thresh=1.46415e-006, actual=1.14387e-008, err=-6.7713e-021
        "00101001000000011000001101010110110001000010110001011", -- i=46, alt=11, thresh=7.13847e-007, actual=5.57693e-009, err=4.06146e-022
        "00101011001000000100110111010010110010011010110000011", -- i=47, alt=3, thresh=3.42585e-007, actual=2.67645e-009, err=-9.33887e-022
        "00101101010010001110101011000000010111000000010001100", -- i=48, alt=12, thresh=1.61837e-007, actual=1.26435e-009, err=5.69927e-022
        "00101111011110011001001010100101001111000110110000100", -- i=49, alt=4, thresh=7.5254e-008, actual=5.87922e-010, err=-2.78863e-022
        "00110001101100000011110011010100111100101001100001101", -- i=50, alt=13, thresh=3.44451e-008, actual=2.69102e-010, err=1.61662e-022
        "00110011111010101100001101110000101111000000110000000", -- i=51, alt=0, thresh=1.55192e-008, actual=1.21244e-010, err=3.39144e-023
        "00110110010011100000110100110000101010101011110000010", -- i=52, alt=2, thresh=6.88268e-009, actual=5.37709e-011, err=2.63276e-023
        "00111000110001100001100001011001001001001010110000101", -- i=53, alt=5, thresh=3.00462e-009, actual=2.34736e-011, err=-9.48673e-024
        "00111011001110100011001001110100100100001000010000110", -- i=54, alt=6, thresh=1.29112e-009, actual=1.00869e-011, err=-3.85318e-024
        "00111101101001111000011111101000000101101000100000111", -- i=55, alt=7, thresh=5.46123e-010, actual=4.26659e-012, err=-2.62371e-024
        "01000000000101111111010011010101001101010111110000001", -- i=56, alt=1, thresh=2.27384e-010, actual=1.77643e-012, err=2.5183e-025
        "01000010110011000100100100011110001011011110100001000", -- i=57, alt=8, thresh=9.31907e-011, actual=7.28053e-013, err=-1.72767e-025
        "01000101011010101001111001110011011011111010000001001", -- i=58, alt=9, thresh=3.75952e-011, actual=2.93712e-013, err=-1.28136e-025
        "01000111111100101011100110101111111011000010000001010", -- i=59, alt=10, thresh=1.49292e-011, actual=1.16634e-013, err=1.15868e-026
        "01001010110010101011010110001111101000000001100001011", -- i=60, alt=11, thresh=5.83562e-012, actual=4.55908e-014, err=6.25409e-027
        "01001101100001111111110110111110001000101111000000011", -- i=61, alt=3, thresh=2.24535e-012, actual=1.75418e-014, err=2.76417e-027
        "01010000010000101000011110010111011000010011110001100", -- i=62, alt=12, thresh=8.50404e-013, actual=6.64379e-015, err=9.6951e-028
        "01010011001101100001011100001110000101110010000000100", -- i=63, alt=4, thresh=3.1704e-013, actual=2.47687e-015, err=-5.89674e-028
        "01010101111101000000011101000110011110000001110000000", -- i=64, alt=0, thresh=1.16345e-013, actual=9.08946e-016, err=7.65195e-029
        "01011001000010101110100010101011111001010000110000010", -- i=65, alt=2, thresh=4.2027e-014, actual=3.28336e-016, err=4.05277e-029
        "01011011111001011001100110011111100110111111000000101", -- i=66, alt=5, thresh=1.49436e-014, actual=1.16747e-016, err=-7.1318e-029
        "01011111000011100011101100101110111001100011110000110", -- i=67, alt=6, thresh=5.23032e-015, actual=4.08619e-017, err=-2.05782e-029
        "01100001111110001001110111100011010101110000000000111", -- i=68, alt=7, thresh=1.80197e-015, actual=1.40779e-017, err=-1.15926e-029
        "01100101001111110111001000101000011011010101100000001", -- i=69, alt=1, thresh=6.11103e-016, actual=4.77424e-018, err=-3.09381e-030
        "01101000010100110011100010100011011001111010110001000", -- i=70, alt=8, thresh=2.03999e-016, actual=1.59374e-018, err=3.94816e-032
        "01101011100101011011101100011100010111011000010001001", -- i=71, alt=9, thresh=6.70329e-017, actual=5.23694e-019, err=1.378e-031
        "01101110111000000001010101101001100111101011100001010", -- i=72, alt=10, thresh=2.16818e-017, actual=1.69389e-019, err=1.9813e-032
        "01110010000001010100010101011001000110110000100001011", -- i=73, alt=11, thresh=6.90318e-018, actual=5.39311e-020, err=-6.6565e-033
        "01110101100000010111010100000011100010001100000000011", -- i=74, alt=3, thresh=2.16347e-018, actual=1.69021e-020, err=-6.14492e-033
        "01111000111011000000110010111011111000110010000000100", -- i=75, alt=4, thresh=6.6742e-019, actual=5.21422e-021, err=1.73635e-033
        "01111100010000101110011110110111010110110010100000000", -- i=76, alt=0, thresh=2.02673e-019, actual=1.58338e-021, err=4.23366e-034
        "01111111110000111101001100111101111011100110110000010", -- i=77, alt=2, thresh=6.05814e-020, actual=4.73292e-022, err=1.85446e-034
        "10000011010111101001011011000101111011111001110000101", -- i=78, alt=5, thresh=1.7825e-020, actual=1.39258e-022, err=-7.31393e-035
        "10000110111100111101100011110000110110011010000000110", -- i=79, alt=6, thresh=5.16262e-021, actual=4.03329e-023, err=1.18901e-035
        "10001010100001100101010110011000001011010111100000111", -- i=80, alt=7, thresh=1.47183e-021, actual=1.14987e-023, err=5.55127e-036
        "10001110000110010101010001100000000100001001010000001", -- i=81, alt=1, thresh=4.1304e-022, actual=3.22688e-024, err=-5.33013e-037
        "10010001110110000100001000100011101110001111010001000", -- i=82, alt=8, thresh=1.14097e-022, actual=8.91387e-025, err=-8.90804e-038
        "10010101101001111110010011110111000100110011010001001", -- i=83, alt=9, thresh=3.10247e-023, actual=2.42381e-025, err=-9.6565e-038
        "10011001011111011000000111101001111011110000110001010", -- i=84, alt=10, thresh=8.30402e-024, actual=6.48752e-026, err=-3.48745e-038
        "10011101010110101110010010110010101100000000110000011", -- i=85, alt=3, thresh=2.18785e-024, actual=1.70926e-026, err=-6.83313e-039
        "10100001010000011001010101010100010001000110110000100", -- i=86, alt=4, thresh=5.67408e-025, actual=4.43287e-027, err=1.9637e-039
        "10100101001100101011101101100111100000011010000000000", -- i=87, alt=0, thresh=1.44851e-025, actual=1.13165e-027, err=-1.78111e-040
        "10100111111111111111111111111111111111111111110000010", -- i=88, alt=2, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000101", -- i=89, alt=5, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000110", -- i=90, alt=6, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000111", -- i=91, alt=7, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000001", -- i=92, alt=1, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110001000", -- i=93, alt=8, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110001001", -- i=94, alt=9, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000011", -- i=95, alt=3, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000100", -- i=96, alt=4, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000010", -- i=97, alt=2, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000101", -- i=98, alt=5, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000110", -- i=99, alt=6, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000111", -- i=100, alt=7, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000001", -- i=101, alt=1, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110001000", -- i=102, alt=8, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000011", -- i=103, alt=3, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000100", -- i=104, alt=4, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000010", -- i=105, alt=2, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000101", -- i=106, alt=5, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000110", -- i=107, alt=6, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000111", -- i=108, alt=7, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000001", -- i=109, alt=1, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000011", -- i=110, alt=3, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000100", -- i=111, alt=4, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000010", -- i=112, alt=2, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000101", -- i=113, alt=5, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000110", -- i=114, alt=6, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000001", -- i=115, alt=1, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000011", -- i=116, alt=3, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000100", -- i=117, alt=4, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000010", -- i=118, alt=2, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000101", -- i=119, alt=5, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000001", -- i=120, alt=1, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000011", -- i=121, alt=3, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000100", -- i=122, alt=4, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000010", -- i=123, alt=2, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000001", -- i=124, alt=1, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000011", -- i=125, alt=3, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000010", -- i=126, alt=2, thresh=0, actual=0, err=0
        "10100111111111111111111111111111111111111111110000001" -- i=127, alt=1, thresh=0, actual=0, err=0
    );
    attribute rom_style of alias_rom:signal is "distributed";
    signal c1_alias_thresh_bits : unsigned(53-1 downto 0);
    signal c1_alias_thresh_bits_d1 : unsigned(53-1 downto 0);
    signal c1_alias_index : unsigned(7-1 downto 0);
    signal c1_alias_index_d1 : unsigned(7-1 downto 0);
    signal c2_alias_alt : unsigned(7-1 downto 0);
    signal c2_alias_alt_d1 : unsigned(7-1 downto 0);
    signal c2_alias_index : unsigned(7-1 downto 0);
    signal c2_alias_index_d1 : unsigned(7-1 downto 0);
    signal cltfx_out : std_logic_vector(16-1 downto 0);
    signal cltfx_urng : std_logic_vector(104-1 downto 0);
    signal cltfx_sum_8_1 : signed(13-1 downto 0);
    signal cltfx_sum_8_2 : signed(13-1 downto 0);
    signal cltfx_sum_8_3 : signed(13-1 downto 0);
    signal cltfx_sum_8_4 : signed(13-1 downto 0);
    signal cltfx_sum_8_5 : signed(13-1 downto 0);
    signal cltfx_sum_8_6 : signed(13-1 downto 0);
    signal cltfx_sum_8_7 : signed(13-1 downto 0);
    signal cltfx_sum_8_8 : signed(13-1 downto 0);
    signal cltfx_sum_4_1 : signed(14-1 downto 0);
    signal cltfx_sum_4_2 : signed(14-1 downto 0);
    signal cltfx_sum_4_3 : signed(14-1 downto 0);
    signal cltfx_sum_4_4 : signed(14-1 downto 0);
    signal cltfx_sum_2_1 : signed(15-1 downto 0);
    signal cltfx_sum_2_2 : signed(15-1 downto 0);
    signal cltfx_sum_1_1 : signed(16-1 downto 0);
    --Mixture PDF
    signal mixture_pdf_urng : std_logic_vector(234-1 downto 0);
    signal c0_mixture_sign_flag : std_logic;
    signal c1_mixture_sindex : signed(8-1 downto 0);
    signal mixture_pdf_out : std_logic_vector(22-1 downto 0);
begin
--Render glue
    urng : entity work.urng_w234 generic map(W=>234) port map(clk=>iClk,ce=>iCE,load_en=>iLoadEn,load_data=>iLoadData,rng=>iURNG);
    mixture_pdf_urng<=iURNG;
    oRes<=std_logic_vector(mixture_pdf_out);
--Implementation
    --Bernoulli
    bernoulli_fp_cx_exp_urng <= bernoulli_fp_urng(122-1 downto 39);
    bernoulli_fp_c0_exp_thresh <= unsigned(bernoulli_fp_thresh(46-1 downto 39));
    bernoulli_fp_c0_frac_rand <= unsigned(bernoulli_fp_urng(39-1 downto 0));
    bernoulli_fp_c0_frac_thresh <= unsigned(bernoulli_fp_thresh(39-1 downto 0));
    bernoulli_fp_out <= bernoulli_fp_c1_exp_greater or (bernoulli_fp_c1_exp_equal and bernoulli_fp_c1_frac_greater);

    lmz_branch_1_sig <=  to_unsigned(0,7) when bernoulli_fp_cx_exp_urng(0) = '1' else
             to_unsigned(1,7) when bernoulli_fp_cx_exp_urng(1) = '1' else
             to_unsigned(2,7) when bernoulli_fp_cx_exp_urng(2) = '1' else
             to_unsigned(3,7) when bernoulli_fp_cx_exp_urng(3) = '1' else
             to_unsigned(4,7) when bernoulli_fp_cx_exp_urng(4) = '1' else
             to_unsigned(5,7) when bernoulli_fp_cx_exp_urng(5) = '1' else
             to_unsigned(6,7) when bernoulli_fp_cx_exp_urng(6) = '1' else
             to_unsigned(7,7);
    lmz_branch_hit_1_sig <= bernoulli_fp_cx_exp_urng(7 downto 0) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_2_sig <=  to_unsigned(8,7) when bernoulli_fp_cx_exp_urng(8) = '1' else
             to_unsigned(9,7) when bernoulli_fp_cx_exp_urng(9) = '1' else
             to_unsigned(10,7) when bernoulli_fp_cx_exp_urng(10) = '1' else
             to_unsigned(11,7) when bernoulli_fp_cx_exp_urng(11) = '1' else
             to_unsigned(12,7) when bernoulli_fp_cx_exp_urng(12) = '1' else
             to_unsigned(13,7) when bernoulli_fp_cx_exp_urng(13) = '1' else
             to_unsigned(14,7) when bernoulli_fp_cx_exp_urng(14) = '1' else
             to_unsigned(15,7);
    lmz_branch_hit_2_sig <= bernoulli_fp_cx_exp_urng(15 downto 8) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_3_sig <=  to_unsigned(16,7) when bernoulli_fp_cx_exp_urng(16) = '1' else
             to_unsigned(17,7) when bernoulli_fp_cx_exp_urng(17) = '1' else
             to_unsigned(18,7) when bernoulli_fp_cx_exp_urng(18) = '1' else
             to_unsigned(19,7) when bernoulli_fp_cx_exp_urng(19) = '1' else
             to_unsigned(20,7) when bernoulli_fp_cx_exp_urng(20) = '1' else
             to_unsigned(21,7) when bernoulli_fp_cx_exp_urng(21) = '1' else
             to_unsigned(22,7) when bernoulli_fp_cx_exp_urng(22) = '1' else
             to_unsigned(23,7);
    lmz_branch_hit_3_sig <= bernoulli_fp_cx_exp_urng(23 downto 16) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_4_sig <=  to_unsigned(24,7) when bernoulli_fp_cx_exp_urng(24) = '1' else
             to_unsigned(25,7) when bernoulli_fp_cx_exp_urng(25) = '1' else
             to_unsigned(26,7) when bernoulli_fp_cx_exp_urng(26) = '1' else
             to_unsigned(27,7) when bernoulli_fp_cx_exp_urng(27) = '1' else
             to_unsigned(28,7) when bernoulli_fp_cx_exp_urng(28) = '1' else
             to_unsigned(29,7) when bernoulli_fp_cx_exp_urng(29) = '1' else
             to_unsigned(30,7) when bernoulli_fp_cx_exp_urng(30) = '1' else
             to_unsigned(31,7);
    lmz_branch_hit_4_sig <= bernoulli_fp_cx_exp_urng(31 downto 24) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_5_sig <=  to_unsigned(32,7) when bernoulli_fp_cx_exp_urng(32) = '1' else
             to_unsigned(33,7) when bernoulli_fp_cx_exp_urng(33) = '1' else
             to_unsigned(34,7) when bernoulli_fp_cx_exp_urng(34) = '1' else
             to_unsigned(35,7) when bernoulli_fp_cx_exp_urng(35) = '1' else
             to_unsigned(36,7) when bernoulli_fp_cx_exp_urng(36) = '1' else
             to_unsigned(37,7) when bernoulli_fp_cx_exp_urng(37) = '1' else
             to_unsigned(38,7) when bernoulli_fp_cx_exp_urng(38) = '1' else
             to_unsigned(39,7);
    lmz_branch_hit_5_sig <= bernoulli_fp_cx_exp_urng(39 downto 32) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_6_sig <=  to_unsigned(40,7) when bernoulli_fp_cx_exp_urng(40) = '1' else
             to_unsigned(41,7) when bernoulli_fp_cx_exp_urng(41) = '1' else
             to_unsigned(42,7) when bernoulli_fp_cx_exp_urng(42) = '1' else
             to_unsigned(43,7) when bernoulli_fp_cx_exp_urng(43) = '1' else
             to_unsigned(44,7) when bernoulli_fp_cx_exp_urng(44) = '1' else
             to_unsigned(45,7) when bernoulli_fp_cx_exp_urng(45) = '1' else
             to_unsigned(46,7) when bernoulli_fp_cx_exp_urng(46) = '1' else
             to_unsigned(47,7);
    lmz_branch_hit_6_sig <= bernoulli_fp_cx_exp_urng(47 downto 40) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_7_sig <=  to_unsigned(48,7) when bernoulli_fp_cx_exp_urng(48) = '1' else
             to_unsigned(49,7) when bernoulli_fp_cx_exp_urng(49) = '1' else
             to_unsigned(50,7) when bernoulli_fp_cx_exp_urng(50) = '1' else
             to_unsigned(51,7) when bernoulli_fp_cx_exp_urng(51) = '1' else
             to_unsigned(52,7) when bernoulli_fp_cx_exp_urng(52) = '1' else
             to_unsigned(53,7) when bernoulli_fp_cx_exp_urng(53) = '1' else
             to_unsigned(54,7) when bernoulli_fp_cx_exp_urng(54) = '1' else
             to_unsigned(55,7);
    lmz_branch_hit_7_sig <= bernoulli_fp_cx_exp_urng(55 downto 48) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_8_sig <=  to_unsigned(56,7) when bernoulli_fp_cx_exp_urng(56) = '1' else
             to_unsigned(57,7) when bernoulli_fp_cx_exp_urng(57) = '1' else
             to_unsigned(58,7) when bernoulli_fp_cx_exp_urng(58) = '1' else
             to_unsigned(59,7) when bernoulli_fp_cx_exp_urng(59) = '1' else
             to_unsigned(60,7) when bernoulli_fp_cx_exp_urng(60) = '1' else
             to_unsigned(61,7) when bernoulli_fp_cx_exp_urng(61) = '1' else
             to_unsigned(62,7) when bernoulli_fp_cx_exp_urng(62) = '1' else
             to_unsigned(63,7);
    lmz_branch_hit_8_sig <= bernoulli_fp_cx_exp_urng(63 downto 56) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_9_sig <=  to_unsigned(64,7) when bernoulli_fp_cx_exp_urng(64) = '1' else
             to_unsigned(65,7) when bernoulli_fp_cx_exp_urng(65) = '1' else
             to_unsigned(66,7) when bernoulli_fp_cx_exp_urng(66) = '1' else
             to_unsigned(67,7) when bernoulli_fp_cx_exp_urng(67) = '1' else
             to_unsigned(68,7) when bernoulli_fp_cx_exp_urng(68) = '1' else
             to_unsigned(69,7) when bernoulli_fp_cx_exp_urng(69) = '1' else
             to_unsigned(70,7) when bernoulli_fp_cx_exp_urng(70) = '1' else
             to_unsigned(71,7);
    lmz_branch_hit_9_sig <= bernoulli_fp_cx_exp_urng(71 downto 64) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_10_sig <=  to_unsigned(72,7) when bernoulli_fp_cx_exp_urng(72) = '1' else
             to_unsigned(73,7) when bernoulli_fp_cx_exp_urng(73) = '1' else
             to_unsigned(74,7) when bernoulli_fp_cx_exp_urng(74) = '1' else
             to_unsigned(75,7) when bernoulli_fp_cx_exp_urng(75) = '1' else
             to_unsigned(76,7) when bernoulli_fp_cx_exp_urng(76) = '1' else
             to_unsigned(77,7) when bernoulli_fp_cx_exp_urng(77) = '1' else
             to_unsigned(78,7) when bernoulli_fp_cx_exp_urng(78) = '1' else
             to_unsigned(79,7);
    lmz_branch_hit_10_sig <= bernoulli_fp_cx_exp_urng(79 downto 72) /= std_logic_vector(to_unsigned(0,8));

    lmz_branch_11_sig <=  to_unsigned(80,7) when bernoulli_fp_cx_exp_urng(80) = '1' else
             to_unsigned(81,7) when bernoulli_fp_cx_exp_urng(81) = '1' else
             to_unsigned(82,7);
    lmz_branch_hit_11_sig <= bernoulli_fp_cx_exp_urng(82 downto 80) /= std_logic_vector(to_unsigned(0,3));
    bernoulli_fp_cx_exp_rand <=
        lmz_branch_1 when lmz_branch_hit_1 else
        lmz_branch_2 when lmz_branch_hit_2 else
        lmz_branch_3 when lmz_branch_hit_3 else
        lmz_branch_4 when lmz_branch_hit_4 else
        lmz_branch_5 when lmz_branch_hit_5 else
        lmz_branch_6 when lmz_branch_hit_6 else
        lmz_branch_7 when lmz_branch_hit_7 else
        lmz_branch_8 when lmz_branch_hit_8 else
        lmz_branch_9 when lmz_branch_hit_9 else
        lmz_branch_10 when lmz_branch_hit_10 else
        lmz_branch_11 when lmz_branch_hit_11 else
        to_unsigned(83,7);

    bernoulli_fp_c0_exp_rand <= bernoulli_fp_c0_exp_rand_d2;
    --Alias table
    c0_alias_index <= unsigned(alias_table_urng(7-1 downto 0));
    bernoulli_fp_urng <= alias_table_urng(129-1 downto 7);
    bernoulli_fp_thresh <= c1_alias_thresh_bits(53-1 downto 7);

    c1_alias_thresh_bits <= c1_alias_thresh_bits_d1;

    c1_alias_index <= c1_alias_index_d1;

    c2_alias_alt <= c2_alias_alt_d1;

    c2_alias_index <= c2_alias_index_d1;

    cltfx_sum_8_1 <= signed(cltfx_urng(13-1 downto 0));
    cltfx_sum_8_2 <= signed(cltfx_urng(26-1 downto 13));
    cltfx_sum_8_3 <= signed(cltfx_urng(39-1 downto 26));
    cltfx_sum_8_4 <= signed(cltfx_urng(52-1 downto 39));
    cltfx_sum_8_5 <= signed(cltfx_urng(65-1 downto 52));
    cltfx_sum_8_6 <= signed(cltfx_urng(78-1 downto 65));
    cltfx_sum_8_7 <= signed(cltfx_urng(91-1 downto 78));
    cltfx_sum_8_8 <= signed(cltfx_urng(104-1 downto 91));
    cltfx_out<= std_logic_vector(cltfx_sum_1_1);
    --Alias table
    alias_table_urng <= mixture_pdf_urng(129-1 downto 0);
    cltfx_urng <= mixture_pdf_urng(233-1 downto 129);
    c0_mixture_sign_flag <= mixture_pdf_urng(233);
process(iClk) begin if(rising_edge(iClk)) then if(iCE='1') then
    --Bernoulli

    lmz_branch_1 <= lmz_branch_1_sig;
    lmz_branch_hit_1 <= lmz_branch_hit_1_sig;
    lmz_branch_2 <= lmz_branch_2_sig;
    lmz_branch_hit_2 <= lmz_branch_hit_2_sig;
    lmz_branch_3 <= lmz_branch_3_sig;
    lmz_branch_hit_3 <= lmz_branch_hit_3_sig;
    lmz_branch_4 <= lmz_branch_4_sig;
    lmz_branch_hit_4 <= lmz_branch_hit_4_sig;
    lmz_branch_5 <= lmz_branch_5_sig;
    lmz_branch_hit_5 <= lmz_branch_hit_5_sig;
    lmz_branch_6 <= lmz_branch_6_sig;
    lmz_branch_hit_6 <= lmz_branch_hit_6_sig;
    lmz_branch_7 <= lmz_branch_7_sig;
    lmz_branch_hit_7 <= lmz_branch_hit_7_sig;
    lmz_branch_8 <= lmz_branch_8_sig;
    lmz_branch_hit_8 <= lmz_branch_hit_8_sig;
    lmz_branch_9 <= lmz_branch_9_sig;
    lmz_branch_hit_9 <= lmz_branch_hit_9_sig;
    lmz_branch_10 <= lmz_branch_10_sig;
    lmz_branch_hit_10 <= lmz_branch_hit_10_sig;
    lmz_branch_11 <= lmz_branch_11_sig;
    lmz_branch_hit_11 <= lmz_branch_hit_11_sig;

    bernoulli_fp_c0_exp_rand_d1 <= bernoulli_fp_cx_exp_rand;
    bernoulli_fp_c0_exp_rand_d2 <= bernoulli_fp_c0_exp_rand_d1;
    bernoulli_fp_c1_exp_greater <= bernoulli_fp_c0_exp_rand > bernoulli_fp_c0_exp_thresh;
    bernoulli_fp_c1_exp_equal <= bernoulli_fp_c0_exp_rand = bernoulli_fp_c0_exp_thresh;
    bernoulli_fp_c1_frac_greater <= bernoulli_fp_c0_frac_rand > bernoulli_fp_c0_frac_thresh;
    --Alias table

    c1_alias_thresh_bits_d1 <= alias_rom(to_integer(c0_alias_index));

    c1_alias_index_d1 <= c0_alias_index;

    c2_alias_alt_d1 <= c1_alias_thresh_bits(7-1 downto 0);

    c2_alias_index_d1 <= c1_alias_index;
    if bernoulli_fp_out then
        alias_table_out <= c2_alias_index;
    else
        alias_table_out <= c2_alias_alt;
    end if;

    cltfx_sum_4_1 <= resize(cltfx_sum_8_2,14) - resize(cltfx_sum_8_1,14);
    cltfx_sum_4_2 <= resize(cltfx_sum_8_4,14) - resize(cltfx_sum_8_3,14);
    cltfx_sum_4_3 <= resize(cltfx_sum_8_6,14) - resize(cltfx_sum_8_5,14);
    cltfx_sum_4_4 <= resize(cltfx_sum_8_8,14) - resize(cltfx_sum_8_7,14);
    cltfx_sum_2_1 <= resize(cltfx_sum_4_2,15) - resize(cltfx_sum_4_1,15);
    cltfx_sum_2_2 <= resize(cltfx_sum_4_4,15) - resize(cltfx_sum_4_3,15);
    cltfx_sum_1_1 <= resize(cltfx_sum_2_2,16) - resize(cltfx_sum_2_1,16);
    --Alias table
    if c0_mixture_sign_flag='1' then
        c1_mixture_sindex <= signed(resize(unsigned(alias_table_out),8));
    else
        c1_mixture_sindex <= -signed(resize(unsigned(alias_table_out),8));
    end if;
    mixture_pdf_out <= std_logic_vector(resize(signed(cltfx_out),22) + ((resize(c1_mixture_sindex,22) sll 13)));
end if; end if; end process;
end RTL;
