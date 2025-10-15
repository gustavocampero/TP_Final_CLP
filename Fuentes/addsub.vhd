library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Declaracion de entidad

entity addsub is
  generic (W: integer := 8);
  port (
	EN     : in  std_logic;
	OP	   : in std_logic;
    A_i, B_i  : in  std_logic_vector(W-1 downto 0);
    RES_o   : out std_logic_vector(W-1 downto 0);
    C_o     : out std_logic;  -- carry
    oF_o     : out std_logic   -- overflow con signo
  );
end entity;

architecture addsub_arq of addsub is
	signal a_aux, b_aux : std_logic_vector(W-1 downto 0);
begin
	--  Si EN = 0 pone las entradas en 0 y no conmuta
	a_aux <= A_i when EN = '1' else (others => '0');
	b_aux <= B_i when EN = '1' else (others => '0');
	
	process(a_aux, b_aux, OP)
		variable res_v : unsigned(W downto 0); -- +1 bit para carry
		variable y_v   : std_logic_vector(W-1 downto 0);
	begin
		if OP = '0' then
			res_v := ('0' & unsigned(a_aux)) + ('0' & unsigned(b_aux));
			y_v := std_logic_vector(res_v(W-1 downto 0));
		
			-- Salidas
			RES_o <= y_v;
			C_o <= res_v(W);
				-- Overflow suma: (Amsb = Bmsb) and (Ymsb ≠ Amsb)
			if ((a_aux(W-1) = b_aux(W-1)) and (y_v(W-1) /= a_aux(W-1))) then
				oF_o <= '1';
			else
				oF_o <= '0';
			end if;
			
			-- oF_o <= (a_aux(W-1) and b_aux(W-1) and not y_v(W-1)) or
			--		((not a_aux(W-1)) and (not b_aux(W-1)) and y_v(W-1));
		else
			res_v := ('0' & unsigned(a_aux)) - ('0' & unsigned(b_aux));
			y_v := std_logic_vector(res_v(W-1 downto 0));
			
			-- Salidas
			RES_o <= y_v;
			C_o   <= not res_v(W); -- ~borrow
				-- Overflow resta: (Amsb ≠ Bmsb) and (Ymsb ≠ Amsb)
			if ((a_aux(W-1) /= b_aux(W-1)) and (y_v(W-1) /= a_aux(W-1))) then
				oF_o <= '1';
			else
				oF_o <= '0';
			end if;
        end if;
	end process;
end architecture;