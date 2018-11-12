library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity tausworthe is
    port (
        clk : in std_logic;
        res_e : in std_logic;
        do_gen : in std_logic;
        m_tvalid : out std_logic;
        m_tlast : out std_logic;
        m_tdata : out std_logic_vector(31 downto 0);
        m_tready : in std_logic;
		preload_data : in std_logic_vector(31 downto 0)
    );
end entity; 

architecture base of tausworthe is
	signal s1, s2, s3 : std_logic_vector(31 downto 0);
    signal m_tvalid_int : std_logic;
    signal block_counter : unsigned(7 downto 0) := (others => '0');
    signal do_gen_reg : std_logic;
    signal m_tlast_int : std_logic;
	function taus(s : std_logic_vector; a : natural; b : natural; c : std_logic_vector; d : natural) return std_logic_vector is
	begin
		return std_logic_vector(shift_left(unsigned(s and c), d) xor shift_right(shift_left(unsigned(s), a) xor unsigned(s), b));
	end function;

	function seed(v : std_logic_vector; m : natural) return std_logic_vector is
		variable tmp : unsigned(v'range);
	begin
		tmp := unsigned(v) + 69069;
		if tmp < m then
			return std_logic_vector(tmp + m);
		else
			return std_logic_vector(tmp);
		end if;
	end function;
begin
    m_tlast <= m_tlast_int;
    m_tvalid <= m_tvalid_int;
	m_tvalid_int <= do_gen_reg;
	m_tdata <= s1 xor s2 xor s3;
	process (clk)
	begin
        if rising_edge(clk) then
            if res_e = '1' or do_gen_reg = '0' then
                m_tlast_int <= '0';
                do_gen_reg <= do_gen;
                block_counter <= (others => '0');
            elsif m_tready = '1' and m_tvalid_int = '1' then
                if m_tlast_int = '1' then
                    m_tlast_int <= '0';
                    do_gen_reg <= do_gen;
                else
                    block_counter <= block_counter + 1;
                end if;
                if block_counter = RNG_WORDS-2 then
                    block_counter <= (others => '0');
                    
                    m_tlast_int <= '1';
                end if;
            end if;
        end if;
    end process;
                

	process (clk)
	begin
		if rising_edge(clk) then
			if m_tready = '1' then
				s1 <= taus(s1, 13, 19, x"FFFFFFFE", 12);
				s2 <= taus(s2, 2, 25, x"FFFFFFF8", 4);
				s3 <= taus(s3, 3, 11, x"FFFFFFF0", 17);
			elsif res_e  = '1' then
				s1 <= seed(preload_data, 1);
				s2 <= seed(seed(preload_data, 1), 7);
				s3 <= seed(seed(seed(preload_data, 1), 7), 15);
			end if;
		end if;
	end process;
end architecture;
