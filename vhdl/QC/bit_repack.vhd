library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;


entity bit_repack is
	port (
		clk : in std_logic;
		res : in std_logic;
		in_bits : in std_logic_vector;
		out_bits : out std_logic_vector;
		in_rdy : out std_logic;
		in_wr : in std_logic;
		out_rdy : in std_logic;
		out_wr : out std_logic
	);
end entity;

architecture base of bit_repack is
	signal bit_store : std_logic_vector(2 * in_bits'length - 1 downto 0);
	signal out_wr_int : std_logic;
	signal store_cnt : unsigned(7 downto 0) := (others => '0');
	signal in_rdy_int : std_logic := '0';
	signal zero_pad : std_logic_vector(in_bits'range) := (others => '0');
begin
	out_wr <= out_wr_int;
	in_rdy <= in_rdy_int;

	in_rdy_int <= '1' when store_cnt <= bit_store'length - in_bits'length  and res = '0' else '0';
	out_wr_int <= '1' when store_cnt >= out_bits'length and res = '0' and out_rdy = '1' else '0';

	process (clk)
		variable store_cnt_tmp : unsigned(store_cnt'range);
		variable bit_store_tmp : std_logic_vector(bit_store'range);
	begin
		if rising_edge(clk) then
			bit_store_tmp := bit_store;
			store_cnt_tmp := store_cnt;
			if out_wr_int = '1' then
				bit_store_tmp := std_logic_vector(shift_right(unsigned(bit_store_tmp), out_bits'length));
				out_bits <= bit_store(out_bits'range);
				store_cnt_tmp := store_cnt_tmp - out_bits'length;
			end if;
			if in_wr = '1' then
				bit_store_tmp := bit_store_tmp or std_logic_vector(shift_left(unsigned(in_bits & zero_pad), to_integer(store_cnt_tmp)));
				store_cnt_tmp := store_cnt_tmp + in_bits'length;
			end if;
			if res = '1' then
				bit_store <= (others => '0');
			else
				bit_store <= bit_store_tmp;
			end if;
			store_cnt <= store_cnt_tmp;


		end if;
	end process;

end architecture;
