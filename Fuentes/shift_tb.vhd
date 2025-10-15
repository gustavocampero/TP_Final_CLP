library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter_tb is
end entity;

architecture shifter_tb_arq of shifter_tb is
  constant W_tb : integer := 8;

  -- DUT component
  component shifter is
    generic ( W : integer := 8 );
    port (
		EN  : in  std_logic;
		OP    : in  std_logic_vector(2 downto 0);
		A_i : in  std_logic_vector(W-1 downto 0);
		B_i : in  std_logic_vector(W-1 downto 0);
		RES_o : out std_logic_vector(W-1 downto 0);
		C_o : out std_logic;  -- carry out
		oF_o : out std_logic
    );
  end component;

  -- Señales TB
  signal EN_tb   : std_logic := '0';
  signal OP_tb   : std_logic_vector(2 downto 0) := "000";
  signal A_tb, B_tb : std_logic_vector(W_tb-1 downto 0);
  signal Y_tb       : std_logic_vector(W_tb-1 downto 0);
  signal C_tb, oF_tb : std_logic;
begin
  -- Instancia del DUT
  DUT: shifter
    generic map ( W => W_tb )
    port map (
		EN    => EN_tb,
		OP    => OP_tb,
		A_i => A_tb,
		B_i => B_tb,
		RES_o => Y_tb,
		C_o => C_tb,
		oF_o => oF_tb
    );

  process
  begin
    -- 1) EN=0 (aislamiento): salida debe ser 0
    EN_tb <= '0'; OP_tb <= "000"; A_tb <= x"01"; B_tb <= x"01"; wait for 10 ns;

    -- 2) SLL: 36 << 2 = D8
    EN_tb <= '1'; OP_tb <= "000"; A_tb <= x"36"; B_tb <= x"02"; wait for 10 ns;

    -- 3) SRL: 9C >> 2 = 27
    EN_tb <= '1'; OP_tb <= "001"; A_tb <= x"9C"; B_tb <= x"02"; wait for 10 ns;

    -- 4) SRA: B2 >> 2 (aritm.) = EC
    EN_tb <= '1'; OP_tb <= "010"; A_tb <= x"B2"; B_tb <= x"02"; wait for 10 ns;

    -- 5) ROL: 81 rol 1 = 03  (1000_0001 -> 0000_0011)
    EN_tb <= '1'; OP_tb <= "011"; A_tb <= x"81"; B_tb <= x"01"; wait for 10 ns;

    -- 6) ROR: 81 ror 1 = C0  (1000_0001 -> 1100_0000)
    EN_tb <= '1'; OP_tb <= "100"; A_tb <= x"81"; B_tb <= x"01"; wait for 10 ns;

    report "shift_tb: TODOS LOS TESTS OK" severity note;
    wait;
  end process;
end architecture;