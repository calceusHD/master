library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.soft_types.all;

entity vn_soft is
	generic (N_IO : natural;
			LLR_BITS : natural);
	port (clk : in std_logic;
		load : in std_logic;
		load_data : in llr_type(LLR_BITS-1 downto 0);
		result : out std_logic;
		data_in : in llr_type_array(N_IO-1 downto 0);
		data_out : out llr_type_array(N_IO-1 downto 0)
	);
end entity;

architecture soft of vn_soft is
    constant MAX_BITS : integer := LLR_BITS + integer(ceil(log2(real(N_IO + 1)))); -- + 1 is needed for adding initial llr val
	signal sum_int : llr_type(MAX_BITS-1 downto 0);
    signal init_llr : llr_type(LLR_BITS-1 downto 0);
	signal data_out_int : llr_type_array(data_in'range);
	function sum_all(inp : llr_type_array) return llr_type is
		variable sum : llr_type(MAX_BITS-1 downto 0) := to_signed(0, MAX_BITS);
	begin
		for i in inp'range loop
			sum := sum + inp(i);
		end loop;
		return sum;
	end function;

	function llr_array_sub(a : llr_type; b : llr_type_array) return llr_type_array  is
		variable rv_trunc : llr_type_array(b'range);
		variable rv : llr_type(a'range);
	begin
		for i in b'range loop
			rv := a - b(i);
			if rv < (- 2 ** (LLR_BITS-1)) + 1 then
				rv_trunc(i) := to_signed((- 2 ** (LLR_BITS-1)) + 1, LLR_BITS);
			elsif rv > 2 ** (LLR_BITS-1) - 1 then
				rv_trunc(i) := to_signed(2 ** (LLR_BITS-1) - 1, LLR_BITS);
			else
				rv_trunc(i) := to_signed(to_integer(rv), LLR_BITS);
			end if;
		end loop;
		return rv_trunc;
	end function;
begin
	
	process (clk)
	begin
		if rising_edge(clk) then
			if load = '1' then
                init_llr <= load_data;
				data_out_int <= (others => load_data);
			else
				data_out_int <= llr_array_sub(sum_int, data_in);
			end if;
		end if;
	end process;
	sum_int <= sum_all(data_in) + init_llr;
	data_out <= data_out_int;
    result <= '1' when sum_int < 0 else '0';
end architecture;
