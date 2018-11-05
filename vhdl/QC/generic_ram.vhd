library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity generic_ram is
    generic (
        DOUBLE_REGISER : boolean := true;
        NO_REGISTER : boolean := false
    );
	port (
		clk : in std_logic;
		wr_en : in std_logic;
		wr_data : in std_logic_vector;
		wr_addr : in unsigned;
		rd_en : in std_logic;
		rd_data : out std_logic_vector;
		rd_addr : in unsigned
	);
end entity;

architecture base of generic_ram is
	type ram_t is array(0 to 2**wr_addr'length-1) of std_logic_vector(wr_data'range);
	signal memory : ram_t;
    signal rd_data_reg : std_logic_vector(rd_data'range);
begin
	process (clk)
	begin
		if rising_edge(clk) then
            
			if wr_en = '1' then
				memory(to_integer(unsigned(wr_addr))) <= wr_data;
			end if;
        end if;
    end process;
    
    double_reg : if DOUBLE_REGISER generate
    process (clk)
    begin
        if rising_edge(clk) then
            rd_data <= rd_data_reg;
        end if;
    end process;
    end generate;
    
    normal_reg : if not DOUBLE_REGISER generate
        rd_data <= rd_data_reg;
    end generate;
    
    no_reg : if NO_REGISTER generate
        rd_data_reg <= memory(to_integer(unsigned(rd_addr)));
    end generate;
    
    no_reg_not : if not NO_REGISTER generate
        process (clk)
        begin
            if rising_edge(clk) then
                --if rd_en = '1' then
                    rd_data_reg <= memory(to_integer(unsigned(rd_addr)));
                --end if;
            end if;
        end process;
    end generate;
    
end architecture;

