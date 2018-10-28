library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;


entity axi_repack is
	generic (
		LAST_WORD_PADDING : natural := 0
	);
	port (
		clk : in std_logic;
		res : in std_logic;
		in_bits : in std_logic_vector;
		out_bits : out std_logic_vector;
		in_ready : out std_logic;
		in_valid : in std_logic;
		in_last : in std_logic;
		out_ready : in std_logic;
		out_valid : out std_logic;
		out_last : out std_logic
	);
end entity;

architecture base of axi_repack is
    attribute mark_debug : string;
    attribute keep : string;
	signal bit_store : std_logic_vector(out_bits'length + in_bits'length - 1 downto 0);
	signal store_cnt : unsigned(12 downto 0) := (others => '0');
	signal in_ready_int, out_valid_int : std_logic := '0';
	signal zero_pad : std_logic_vector(out_bits'range) := (others => '0');
	signal flusing : std_logic := '0';
	signal do_in_shift, do_out_shift, out_last_int : std_logic;
	
	attribute mark_debug of store_cnt : signal is "true";
	attribute mark_debug of flusing : signal is "true";
begin
	in_ready <= in_ready_int;
	out_valid <= out_valid_int;
	out_last <= out_last_int;
	
	in_ready_int <= '1' when in_bits'length <= bit_store'length + out_bits'length - store_cnt  and res = '0' and flusing = '0' else '0';
	
	out_valid_int <= '1' when (out_last_int = '1' or store_cnt >= out_bits'length) else '0';
	out_last_int <= '1' when flusing = '1' and store_cnt = LAST_WORD_PADDING else '0';
	
	out_bits <= bit_store(bit_store'length-1 downto bit_store'length - out_bits'length);
	
	do_in_shift <= in_ready_int and in_valid;
	do_out_shift <= out_ready and out_valid_int;
	process (clk)
		variable store_cnt_tmp : unsigned(store_cnt'range);
		variable bit_store_tmp : std_logic_vector(bit_store'range);
	begin
		if rising_edge(clk) then
			if in_last = '1' and do_in_shift = '1' then
				flusing <= '1';
			end if;
			bit_store_tmp := bit_store;
			store_cnt_tmp := store_cnt;
			if do_out_shift = '1' then
                bit_store_tmp := std_logic_vector(shift_left(unsigned(bit_store_tmp), out_bits'length));
                store_cnt_tmp := store_cnt_tmp - out_bits'length;
            else
			end if;
			if do_in_shift = '1' then
				bit_store_tmp := bit_store_tmp or std_logic_vector(shift_right(unsigned(in_bits & zero_pad), to_integer(store_cnt_tmp)));
				store_cnt_tmp := store_cnt_tmp + in_bits'length;
			end if;
			if out_last_int = '1' and do_out_shift = '1' then
				store_cnt_tmp := (others => '0');
				flusing <= '0';
			end if;
			if res = '1' then
				flusing <= '0';
				bit_store <= (others => '0');
				store_cnt <= (others => '0');
			else
				bit_store <= bit_store_tmp;
				store_cnt <= store_cnt_tmp;
			end if;
			


		end if;
	end process;

end architecture;

