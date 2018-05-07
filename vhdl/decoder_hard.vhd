library IEEE;
use IEEE.std_logic_1164.all;

entity decoder_hard is
	port (clk : in std_logic;
		load : in std_logic;
		done : out std_logic;
		err : out std_logic;
		message_in : in std_logic_vector(15 downto 0);
		decoded_out : out std_logic_vector(15 downto 0)
	);
end entity;

architecture hard of decoder_hard is

signal errors : std_logic_vector(7 downto 0);
signal cn_in_0, cn_out_0 : std_logic_vector(3 downto 0);
signal cn_in_1, cn_out_1 : std_logic_vector(3 downto 0);
signal cn_in_2, cn_out_2 : std_logic_vector(3 downto 0);
signal cn_in_3, cn_out_3 : std_logic_vector(3 downto 0);
signal cn_in_4, cn_out_4 : std_logic_vector(3 downto 0);
signal cn_in_5, cn_out_5 : std_logic_vector(3 downto 0);
signal cn_in_6, cn_out_6 : std_logic_vector(3 downto 0);
signal cn_in_7, cn_out_7 : std_logic_vector(3 downto 0);
signal vn_in_0, vn_out_0 : std_logic_vector(1 downto 0);
signal vn_in_1, vn_out_1 : std_logic_vector(1 downto 0);
signal vn_in_2, vn_out_2 : std_logic_vector(1 downto 0);
signal vn_in_3, vn_out_3 : std_logic_vector(1 downto 0);
signal vn_in_4, vn_out_4 : std_logic_vector(1 downto 0);
signal vn_in_5, vn_out_5 : std_logic_vector(1 downto 0);
signal vn_in_6, vn_out_6 : std_logic_vector(1 downto 0);
signal vn_in_7, vn_out_7 : std_logic_vector(1 downto 0);
signal vn_in_8, vn_out_8 : std_logic_vector(1 downto 0);
signal vn_in_9, vn_out_9 : std_logic_vector(1 downto 0);
signal vn_in_10, vn_out_10 : std_logic_vector(1 downto 0);
signal vn_in_11, vn_out_11 : std_logic_vector(1 downto 0);
signal vn_in_12, vn_out_12 : std_logic_vector(1 downto 0);
signal vn_in_13, vn_out_13 : std_logic_vector(1 downto 0);
signal vn_in_14, vn_out_14 : std_logic_vector(1 downto 0);
signal vn_in_15, vn_out_15 : std_logic_vector(1 downto 0);

begin
err <= or errors;
check_node_0 : entity work.cn_hard
    generic map (N_IO => 4)
    port map (data_in => cn_in_0,
        data_out => cn_out_0,
        has_error => errors(0));
    
check_node_1 : entity work.cn_hard
    generic map (N_IO => 4)
    port map (data_in => cn_in_1,
        data_out => cn_out_1,
        has_error => errors(1));
    
check_node_2 : entity work.cn_hard
    generic map (N_IO => 4)
    port map (data_in => cn_in_2,
        data_out => cn_out_2,
        has_error => errors(2));
    
check_node_3 : entity work.cn_hard
    generic map (N_IO => 4)
    port map (data_in => cn_in_3,
        data_out => cn_out_3,
        has_error => errors(3));
    
check_node_4 : entity work.cn_hard
    generic map (N_IO => 4)
    port map (data_in => cn_in_4,
        data_out => cn_out_4,
        has_error => errors(4));
    
check_node_5 : entity work.cn_hard
    generic map (N_IO => 4)
    port map (data_in => cn_in_5,
        data_out => cn_out_5,
        has_error => errors(5));
    
check_node_6 : entity work.cn_hard
    generic map (N_IO => 4)
    port map (data_in => cn_in_6,
        data_out => cn_out_6,
        has_error => errors(6));
    
check_node_7 : entity work.cn_hard
    generic map (N_IO => 4)
    port map (data_in => cn_in_7,
        data_out => cn_out_7,
        has_error => errors(7));
    
variable_node_0 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(0),
        load_data => message_in(0),
        data_in => vn_in_0,
        data_out => vn_out_0);
    
variable_node_1 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(1),
        load_data => message_in(1),
        data_in => vn_in_1,
        data_out => vn_out_1);
    
variable_node_2 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(2),
        load_data => message_in(2),
        data_in => vn_in_2,
        data_out => vn_out_2);
    
variable_node_3 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(3),
        load_data => message_in(3),
        data_in => vn_in_3,
        data_out => vn_out_3);
    
variable_node_4 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(4),
        load_data => message_in(4),
        data_in => vn_in_4,
        data_out => vn_out_4);
    
variable_node_5 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(5),
        load_data => message_in(5),
        data_in => vn_in_5,
        data_out => vn_out_5);
    
variable_node_6 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(6),
        load_data => message_in(6),
        data_in => vn_in_6,
        data_out => vn_out_6);
    
variable_node_7 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(7),
        load_data => message_in(7),
        data_in => vn_in_7,
        data_out => vn_out_7);
    
variable_node_8 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(8),
        load_data => message_in(8),
        data_in => vn_in_8,
        data_out => vn_out_8);
    
variable_node_9 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(9),
        load_data => message_in(9),
        data_in => vn_in_9,
        data_out => vn_out_9);
    
variable_node_10 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(10),
        load_data => message_in(10),
        data_in => vn_in_10,
        data_out => vn_out_10);
    
variable_node_11 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(11),
        load_data => message_in(11),
        data_in => vn_in_11,
        data_out => vn_out_11);
    
variable_node_12 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(12),
        load_data => message_in(12),
        data_in => vn_in_12,
        data_out => vn_out_12);
    
variable_node_13 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(13),
        load_data => message_in(13),
        data_in => vn_in_13,
        data_out => vn_out_13);
    
variable_node_14 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(14),
        load_data => message_in(14),
        data_in => vn_in_14,
        data_out => vn_out_14);
    
variable_node_15 : entity work.vn_hard
    generic map (N_IO => 2)
    port map (clk => clk,
        load => load,
        result => decoded_out(15),
        load_data => message_in(15),
        data_in => vn_in_15,
        data_out => vn_out_15);
    
cn_in_0 <= (vn_out_0(0), vn_out_2(0), vn_out_8(0), vn_out_11(0));
cn_in_1 <= (vn_out_1(0), vn_out_5(0), vn_out_8(1), vn_out_10(0));
cn_in_2 <= (vn_out_1(1), vn_out_6(0), vn_out_9(0), vn_out_15(0));
cn_in_3 <= (vn_out_3(0), vn_out_4(0), vn_out_5(1), vn_out_15(1));
cn_in_4 <= (vn_out_0(1), vn_out_7(0), vn_out_10(1), vn_out_13(0));
cn_in_5 <= (vn_out_3(1), vn_out_6(1), vn_out_12(0), vn_out_13(1));
cn_in_6 <= (vn_out_7(1), vn_out_9(1), vn_out_11(1), vn_out_14(0));
cn_in_7 <= (vn_out_2(1), vn_out_4(1), vn_out_12(1), vn_out_14(1));

vn_in_0 <= (cn_out_0(0), cn_out_4(0));
vn_in_1 <= (cn_out_1(0), cn_out_2(0));
vn_in_2 <= (cn_out_0(0), cn_out_7(0));
vn_in_3 <= (cn_out_3(0), cn_out_5(0));
vn_in_4 <= (cn_out_3(0), cn_out_7(0));
vn_in_5 <= (cn_out_1(0), cn_out_3(0));
vn_in_6 <= (cn_out_2(0), cn_out_5(0));
vn_in_7 <= (cn_out_4(0), cn_out_6(0));
vn_in_8 <= (cn_out_0(0), cn_out_1(0));
vn_in_9 <= (cn_out_2(0), cn_out_6(0));
vn_in_10 <= (cn_out_1(0), cn_out_4(0));
vn_in_11 <= (cn_out_0(0), cn_out_6(0));
vn_in_12 <= (cn_out_5(0), cn_out_7(0));
vn_in_13 <= (cn_out_4(0), cn_out_5(0));
vn_in_14 <= (cn_out_6(0), cn_out_7(0));
vn_in_15 <= (cn_out_2(0), cn_out_3(0));

end architecture;
