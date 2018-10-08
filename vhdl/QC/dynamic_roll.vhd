library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.common.all;

entity dynamic_roll is
	generic (
		DIRECTION : boolean --true means the same direction as fixed roll
	);
    port (
		roll_count : in unsigned; --must be <= data_in'length
        data_in : in llr_array_t;
		data_out : out llr_array_t
    );
end entity;

architecture base of dynamic_roll is
    function sub_mod(a : integer; n : natural) return integer is
    begin
        if a >= n then
            return a - n;
        else
            return a;
        end if;
    end function;

    function add_mod(a : integer; n : natural) return integer is
    begin
        if a < 0 then
            return a + n;
        else
            return a;
        end if;
    end function;
begin
	gen_i : for i in data_in'range(1) generate
	begin
		gen_j : for j in data_in'range(2) generate
		begin
			data_out(i, j) <= data_in(add_mod(i - to_integer(roll_count), data_in'length), j) when not DIRECTION 
				else data_in(sub_mod(i + to_integer(roll_count), data_in'length), j);
		end generate;
	end generate;

end architecture;

architecture mux2 of dynamic_roll is
	type temp_type is array(0 to roll_count'length) of llr_array_t;
	signal temp : temp_type;

begin
	temp(0) <= data_in;
	gen_bits : for bit_id in 0 to temp'length-2 generate
		signal cnt : integer;
	begin
		cnt <= 2 ** bit_id when DIRECTION else - 2 ** bit_id;
		gen_i : for i in data_in'range(1) generate
			gen_j : for j in data_in'range(2) generate
					temp(bit_id + 1)(i, j) <= temp(bit_id)((i + cnt) mod data_in'length, j) 
						when roll_count(bit_id) = '1' 
						else temp(bit_id)(i, j);
			end generate;
		end generate;
	end generate;
	data_out <= temp(temp'length-1);
end architecture;

architecture mux4 of dynamic_roll is
    constant MAX_MUX : integer := 16;
    constant LOG_MAX_MUX : integer := integer(log2(real(MAX_MUX)));
    function calc_levels(mux_width : integer; in_width : integer) return integer is
        variable rv : integer := 0;
        variable temp : integer := in_width;
    begin
        for i in LOG_MAX_MUX downto 1 loop
            rv := rv + temp / i;
            temp := temp mod i;
            report "rv:" & integer'image(rv);
            report "temp:" & integer'image(temp);
        end loop;
        return rv;
    end function;

    procedure calc_loop(it : in integer; offset : out integer; cur_width : out integer) is
        variable temp, temp_w : integer := 0;
    begin
        temp := 0;
        for i in 0 to it loop
            for j in LOG_MAX_MUX downto 1 loop
                if temp + j <= roll_count'length then
                    temp := temp + j;
                    report "j:" & integer'image(j);
                    cur_width := j;
                    temp_w := j;
                    exit;
                end if;
            end loop;

        end loop;
        offset := temp - temp_w;
    end procedure;


    type temp_type is array(0 to calc_levels(1, roll_count'length)+1) of llr_array_t;
    signal temp : temp_type;
begin
    temp(0) <= data_in;

    gen_bits : for bit_id in 0 to temp'length-2 generate
    begin
        gen_i : for i in data_in'range(1) generate
            gen_j : for j in data_in'range(2) generate
                process (data_in, roll_count)
                    variable rv : signed(data_in(0, 0)'range);
                    variable offset, cur_width : integer;
                begin
                    calc_loop(bit_id, offset, cur_width);
                    report integer'image(cur_width);
                    report integer'image(offset);
                    report integer'image(bit_id);
                    for k in 0 to 2 ** cur_width loop
                        if k = to_integer(roll_count(cur_width + offset - 1 downto offset)) then
                            rv := temp(bit_id)((i + k * (2 ** offset)) mod data_in'length, j);
                        end if;
                    end loop;
                    temp(bit_id + 1)(i, j) <= rv;
                end process;
            end generate;
        end generate;
    end generate;


    data_out <= temp(temp'length-1);

end architecture;

