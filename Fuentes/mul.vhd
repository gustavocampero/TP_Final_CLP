library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Declaracion de entidad

entity mul is
  generic (W: integer := 8);
  port (
	EN     : in  std_logic;
    A_i, B_i  : in  std_logic_vector(W-1 downto 0);
    RES_o   : out std_logic_vector(W-1 downto 0);
    C_o     : out std_logic;  -- carry
    oF_o     : out std_logic   -- overflow con signo
  );
end entity;

architecture mul_arq of mul is
	signal a_aux, b_aux : std_logic_vector(W-1 downto 0);
begin
	--  Si EN = 0 pone las entradas en 0 y no conmuta
	a_aux <= A_i when EN = '1' else (others => '0');
	b_aux <= B_i when EN = '1' else (others => '0');
	
	process(a_aux, b_aux)
		variable res_v : unsigned((2*W)-1 downto 0);
		variable y_v   : std_logic_vector(W-1 downto 0);
		variable upper  : std_logic_vector(W-1 downto 0);
	begin
		res_v := unsigned(a_aux) * unsigned(b_aux);
		y_v := std_logic_vector(res_v(W-1 downto 0));
		upper  := std_logic_vector(res_v((2*W)-1 downto W)); -- parte alta
		
		-- Salidas
		RES_o <= y_v;
			-- C: 1 si parte alta != 0
		if unsigned(upper) /= 0 then
			C_o <= '1';
		else
			C_o <= '0';
		end if;
			-- oF: no se implementa overflow
		oF_o <= '0';
	end process;
end architecture;