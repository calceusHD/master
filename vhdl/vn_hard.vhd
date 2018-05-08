library IEEE;
use IEEE.std_logic_1164.all;

entity vn_hard is
	generic (N_IO : natural);
	port (clk : in std_logic;
		load : in std_logic;
		load_data : in std_logic;
		result : out std_logic;
		data_in : in std_logic_vector(N_IO-1 downto 0);
		data_out : out std_logic_vector(N_IO-1 downto 0)
	);
end entity;

architecture hard of vn_hard is
	signal data_out_int : std_logic;
	signal vote_res : std_logic;

	function do_vote(inp : std_logic_vector) return std_logic is
		variable count : integer := 0;
	begin
		for i in inp'range loop
			if inp(i) = '1' then
				count := count + 1;
			else
				count := count - 1;
			end if;
		end loop;
		if count > 0 then
			return '1';
		else
			return '0';
		end if;
	end function;

begin
	vote_res <= do_vote(data_in & data_out_int);
	result <= data_out_int;

	process (clk)
	begin
		if rising_edge(clk) then
			if load = '1' then
				data_out_int <= load_data;
			else
				data_out_int <= vote_res;
			end if;
		end if;
	end process;

	data_out <= (others => data_out_int);
end architecture;
