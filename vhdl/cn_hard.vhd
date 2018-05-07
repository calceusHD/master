library IEEE;
use IEEE.std_logic_1164.all;

entity cn_hard is
    generic (N_IO : natural);
    port (data_in : in std_logic_vector(N_IO-1 downto 0);
        data_out : out std_logic_vector(N_IO-1 downto 0);
        has_error : out std_logic
    );
end entity;

architecture hard of cn_hard is
    signal xor_sum : std_logic;
begin
    xor_sum <= xor data_in;

    has_error <= xor_sum;
    result : for i in 0 to N_IO-1 generate
        data_out(i) <= xor_sum xor data_in(i);
    end generate;
end architecture;
