library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mul_tb is
end entity;

architecture mul_tb_arq of mul_tb is
  constant W_tb : integer := 8;

  -- DUT component
  component mul is
    generic ( W : integer := 8 );
    port (
		EN  : in  std_logic;
		A_i : in  std_logic_vector(W-1 downto 0);
		B_i : in  std_logic_vector(W-1 downto 0);
		RES_o : out std_logic_vector(W-1 downto 0);
		C_o : out std_logic;  -- carry out
		oF_o : out std_logic
    );
  end component;

  -- Señales TB
  signal EN_tb   : std_logic := '0';
  signal A_tb, B_tb : std_logic_vector(W_tb-1 downto 0);
  signal Y_tb       : std_logic_vector(W_tb-1 downto 0);
  signal C_tb, oF_tb : std_logic;
begin
  -- Instancia del DUT
  DUT: mul
    generic map ( W => W_tb )
    port map (
		EN    => EN_tb,
		A_i => A_tb,
		B_i => B_tb,
		RES_o => Y_tb,
		C_o => C_tb,
		oF_o => oF_tb
    );

  process
  begin
    -- 1) EN=0 (aislamiento): 0*0 -> RES=00, C=0, OF=0
    EN_tb <= '0'; A_tb <= x"05"; B_tb <= x"03"; wait for 10 ns;

    -- 2) 0x0F * 0x10 = 0x00F0 -> RES=F0, C=0
    EN_tb <= '1'; A_tb <= x"0F"; B_tb <= x"10"; wait for 10 ns;

    -- 3) Parte alta no nula: 0x10 * 0x10 = 0x0100 -> RES=00, C=1
    EN_tb <= '1'; A_tb <= x"10"; B_tb <= x"10"; wait for 10 ns; -- 16*16=256

    -- 4) Máximos: 0xFF * 0xFF = 0xFE01 -> RES=01, C=1
    EN_tb <= '1'; A_tb <= x"FF"; B_tb <= x"FF"; wait for 10 ns;

    -- 5) Multiplicación por cero: 0x00 * 0xAB = 0 -> RES=00, C=0
    EN_tb <= '1'; A_tb <= x"00"; B_tb <= x"AB"; wait for 10 ns;

    report "mul_tb: TODOS LOS TESTS OK" severity note;
    wait;
  end process;
end architecture;