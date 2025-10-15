library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Declaracion de entidad

entity ALU is
	generic(
		W: integer := 8
	);
	
	port(
		A_i: in std_logic_vector(W-1 downto 0);
		B_i: in std_logic_vector(W-1 downto 0);
		OP_i: in std_logic_vector(3 downto 0);
		
		Y_o: out std_logic_vector(W-1 downto 0);
		zero_o: out std_logic;
		neg_o: out std_logic;
		carry_o: out std_logic;
		oflow_o: out std_logic
	);
end entity;

architecture ALU_arq of ALU is
-- Parte declarativa
	constant OP_ADD : std_logic_vector(3 downto 0) := "0000"; -- A + B
	constant OP_SUB : std_logic_vector(3 downto 0) := "0001"; -- A - B
	constant OP_MUL : std_logic_vector(3 downto 0) := "0010"; -- A * B (parte baja)
	constant OP_AND : std_logic_vector(3 downto 0) := "0011"; -- A & B
	constant OP_OR 	: std_logic_vector(3 downto 0) := "0100"; -- A | B
	constant OP_XOR : std_logic_vector(3 downto 0) := "0101"; -- A xor B
	constant OP_NOT : std_logic_vector(3 downto 0) := "0110"; -- ~A (B ignorado)
	constant OP_SLL : std_logic_vector(3 downto 0) := "0111"; -- shift logico izq A << B
	constant OP_SRL : std_logic_vector(3 downto 0) := "1000"; -- shift logico der A >> B
	constant OP_SRA : std_logic_vector(3 downto 0) := "1001"; -- shift aritmético der
	constant OP_ROL : std_logic_vector(3 downto 0) := "1010"; -- rotacion izq
	constant OP_ROR : std_logic_vector(3 downto 0) := "1011"; -- rotacion der
	
	component addsub is
		generic ( W : integer := 8 );
		port (
		  EN     : in  std_logic;                            -- habilita el bloque
		  OP    : in  std_logic;                             -- 0: ADD, 1: SUB
		  A_i    : in  std_logic_vector(W-1 downto 0);
		  B_i    : in  std_logic_vector(W-1 downto 0);
		  RES_o  : out std_logic_vector(W-1 downto 0);        -- resultado
		  C_o    : out std_logic;                             -- ADD: carry | SUB: ~borrow
		  oF_o   : out std_logic                              -- overflow con signo
		);
	end component;
	
	component mul is
		generic ( W : integer := 8 );
		port (
		  EN     : in  std_logic;
		  A_i    : in  std_logic_vector(W-1 downto 0);
		  B_i    : in  std_logic_vector(W-1 downto 0);
		  RES_o  : out std_logic_vector(W-1 downto 0);
		  C_o    : out std_logic;                         -- 1 si parte alta != 0
		  oF_o   : out std_logic                          -- overflow 0
		);
	end component;
	
	component logic is
    generic ( W : integer := 8 );
		port (
		  EN     : in  std_logic;
		  OP    : in  std_logic_vector(1 downto 0);
		  A_i    : in  std_logic_vector(W-1 downto 0);
		  B_i    : in  std_logic_vector(W-1 downto 0);
		  RES_o  : out std_logic_vector(W-1 downto 0);
		  C_o    : out std_logic;
		  oF_o   : out std_logic
		);
	end component;
	
	component shifter is
		generic ( W : integer := 8 );
		port (
		  EN     : in  std_logic;
		  OP    : in  std_logic_vector(2 downto 0);
		  A_i    : in  std_logic_vector(W-1 downto 0);
		  B_i    : in  std_logic_vector(W-1 downto 0);
		  RES_o  : out std_logic_vector(W-1 downto 0);
		  C_o    : out std_logic;
		  oF_o   : out std_logic
		);
	end component;

	signal y_aux : std_logic_vector(W-1 downto 0);
	signal z_aux, n_aux, c_aux, oflow_aux : std_logic := '0';
	
	signal en_addsub : std_logic;
	signal en_mul    : std_logic;
	signal en_logic  : std_logic;
	signal en_shift  : std_logic;
	
	signal sel_addsub : std_logic;
	signal sel_logic : std_logic_vector(1 downto 0);
	signal sel_shift : std_logic_vector(2 downto 0);
	
	signal as_y, mu_y, lo_y, sh_y : std_logic_vector(W-1 downto 0);
	signal as_c, mu_c, lo_c, sh_c : std_logic;
	signal as_of, mu_of, lo_of, sh_of : std_logic;

begin
-- Parte descriptiva
	-- enables y selects
	en_addsub  <= 	'1' when (OP_i = OP_ADD or OP_i = OP_SUB) else '0';
	sel_addsub <= 	'1' when OP_i = OP_SUB else '0';  -- 0: ADD, 1: SUB
	
	en_mul <= 		'1' when OP_i = OP_MUL else '0';
	
	en_logic  <= 	'1' when (OP_i = OP_AND or OP_i = OP_OR or OP_i = OP_XOR or OP_i = OP_NOT) else '0';
	sel_logic <= 	"00" when OP_i = OP_AND else  -- AND
					"01" when OP_i = OP_OR  else  -- OR
					"10" when OP_i = OP_XOR else  -- XOR
					"11";                          -- NOT (default)
					
	en_shift  <= 	'1' when (OP_i = OP_SLL or OP_i = OP_SRL or OP_i = OP_SRA or OP_i = OP_ROL or OP_i = OP_ROR) else '0';
	sel_shift <= 	"000" when OP_i = OP_SLL else  -- SLL
					"001" when OP_i = OP_SRL else  -- SRL
					"010" when OP_i = OP_SRA else  -- SRA
					"011" when OP_i = OP_ROL else  -- ROL
					"100";                         -- ROR (por descarte)
	
	U_ADDSUB: addsub
    generic map ( W => W )
    port map (
		EN     => en_addsub,
		OP    => sel_addsub,
		A_i    => A_i,
		B_i    => B_i,
		RES_o  => as_y,
		C_o    => as_c,
		oF_o   => as_of
    );
	
	U_MUL: mul
    generic map ( W => W )
    port map (
		EN     => en_mul,
		A_i    => A_i,
		B_i    => B_i,
		RES_o  => mu_y,
		C_o    => mu_c,
		oF_o   => mu_of
    );
	
	U_LOGIC: logic
    generic map ( W => W )
    port map (
		EN     => en_logic,
		OP    => sel_logic,
		A_i    => A_i,
		B_i    => B_i,
		RES_o  => lo_y,
		C_o    => lo_c,
		oF_o   => lo_of
    );
	
	U_SHIFT: shifter
    generic map ( W => W )
    port map (
		EN     => en_shift,
		OP    => sel_shift,
		A_i    => A_i,
		B_i    => B_i,
		RES_o  => sh_y,
		C_o    => sh_c,
		oF_o   => sh_of
    );

	
	process(OP_i, as_y, as_c, as_of, mu_y, mu_c, mu_of, lo_y, lo_c, lo_of, sh_y, sh_c, sh_of)
    variable y_v          : std_logic_vector(W-1 downto 0);
	begin
	
	-- Valores por defecto
	y_v        := (others => '0');
    c_aux      <= '0';
    oflow_aux  <= '0';
      
	case OP_i is
		when OP_ADD | OP_SUB =>
			y_v := as_y; c_aux <= as_c; oflow_aux <= as_of;

		when OP_MUL =>
			y_v := mu_y; c_aux <= mu_c; oflow_aux <= mu_of;

		when OP_AND | OP_OR | OP_XOR | OP_NOT =>
			y_v := lo_y; c_aux <= lo_c; oflow_aux <= lo_of;

		when OP_SLL | OP_SRL | OP_SRA | OP_ROL | OP_ROR =>
			y_v := sh_y; c_aux <= sh_c; oflow_aux <= sh_of;

		when others =>
			null;
    end case;
	
	-- Flags Z y N
	if unsigned(y_v) = 0 then
        z_aux <= '1';
    else
        z_aux <= '0';
    end if;
    n_aux <= y_v(W-1);
    
    -- Copia a señales
    y_aux     <= y_v;
	end process;
	
	Y_o     <= y_aux;
    zero_o  <= z_aux;
    neg_o   <= n_aux;
    carry_o <= c_aux;
    oflow_o <= oflow_aux;
end;