library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity axi_cmp is
    port (
        clk : in std_logic;
        res_e : in std_logic;
        s_tvalid : in std_logic;
        s_tlast : in std_logic;
        s_tdata : in std_logic_vector(31 downto 0);
        s_tready : out std_logic;
		s2_tvalid : in std_logic;
		s2_tlast : in std_logic;
		s2_tdata : in std_logic_vector(31 downto 0);
		s2_tready : out std_logic;
        m_tvalid : out std_logic;
        m_tlast : out std_logic;
        m_tdata : out std_logic_vector(31 downto 0);
        m_tready : in std_logic
    );
end entity;

architecture base of axi_cmp is
	signal valid, ready : std_logic;
	signal m_tvalid_int : std_logic;
	signal counter : unsigned(31 downto 0) := (others => '0');
	
	function count_ones(v : std_logic_vector) return unsigned is
        variable tmp : unsigned(31 downto 0);
    begin
        tmp := (others => '0');
        for i in v'range loop
            if v(i) = '1' then
                tmp := tmp + 1;
            end if;
        end loop;
        return tmp;
    end function;
begin
    m_tdata <= std_logic_vector(counter);
    m_tvalid <= m_tvalid_int;
	valid <= s_tvalid and s2_tvalid;
	s_tready <= valid and ready;
	s2_tready <= valid and ready;
	m_tlast <= '1';
	process (clk)
	begin
		if rising_edge(clk) then
            if res_e = '1' then
                m_tvalid_int <= '0';
                counter <= (others => '0');
                ready <= '1';
			elsif valid = '1' and ready = '1' then
                counter <= counter + count_ones(s_tdata xor s2_tdata);
                if s_tlast = '1' then
                    ready <= '0';
                    m_tvalid_int <= '1';
                end if;
			end if;
			if m_tvalid_int = '1' and m_tready = '1' then
                m_tvalid_int <= '0';
                ready <= '1';
                counter <= (others => '0');
            end if;
		end if;
	end process;
end architecture;

