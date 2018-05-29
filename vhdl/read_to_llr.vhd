library IEEE;
use IEEE.std_logic_1164.all;
use work.soft_types.all;

entity read_to_llr is 
    generic (DATA_IN_BITS : natural;
        LLR_BITS : natural;
        N_IO : natural;
        SIGMA : real;
        MAX_IN : real
    );
    port (data_in : llr_type_array(N_IO-1 downto 0)(DATA_IN_BITS-1 downto 0);
        data_out : llr_type_array(N_IO-1 downto 0)(LLR_BITS-1 downto 0)
    );
end entity;

architecture binary_flash of read_to_llr is
    type real_array is array(N_IO-1 downto 0) of real;
    signal in_scaled : real_array;
begin
    in_scaled <= real(data_in) / MAX_IN;
end architecture;

