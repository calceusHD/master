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
	signal valid : std_logic;
begin
	valid <= s_tvalid and s2_tvalid;
	s_tready <= valid;
	s2_tready <= valid;
	process (clk)
	begin
		if rising_edge(clk) then
			if valid = '1' then
				assert s_tdata = s2_tdata report "oh no" severity warning;
			end if;
		end if;
	end process;
end architecture;

