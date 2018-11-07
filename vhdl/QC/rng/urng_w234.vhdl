LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity urng_w234 is
  generic(
    W:integer:=234
  );
  port(
    clk:in std_logic;
    ce : in std_logic;
    load_en : in std_logic;
    load_data : in std_logic;
    rng:out std_logic_vector(W-1 downto 0)
  );
end urng_w234;

architecture RTL of urng_w234 is
begin
  assert W=234 report "This RNG only does W=234" severity failure;

  the : entity work.rng_n234_r234_t5_k0_s3206
    port map(clk=>clk,ce=>ce,mode=>load_en,s_in=>load_data,rng=>rng);
end RTL;
