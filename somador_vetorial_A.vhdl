LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY SomadorVetorial IS
  PORT (
    --input
    A_i        : IN  std_logic_vector(31 DOWNTO 0); -- Entrada A_i 
    B_i        : IN  std_logic_vector(31 DOWNTO 0); -- Entrada B_i 
    vecSize_i : IN  std_logic_vector(1 DOWNTO 0); -- Tamanho do vetor
    mode_i 	: IN std_logic; -- '0' para adição e '1' para subtração
    --output
    S_o        : OUT std_logic_vector(31 DOWNTO 0)  -- Resultado da Operação
    );

END SomadorVetorial;

ARCHITECTURE TypeArchitecture OF SomadorVetorial IS

signal s_C : std_logic_vector(31 downto 0); --Gerador Carry
signal s_P : std_logic_vector(31 downto 0); --Propagador Carry
signal Carry : std_logic_vector(31 downto 0); 

signal s_Soma  : std_logic_vector(31 downto 0); 
signal B_op : std_logic_vector(31 downto 0); -- Inverte bits de B para caso de subtração

-- sinais para lookahead de 4 bits (grupos)
signal GG     : std_logic_vector(7 downto 0);
signal PP     : std_logic_vector(7 downto 0);

BEGIN

--Complemento de 2 na subtração
B_op <= B_i when (mode_i = '0') else not(B_i);

--Gera C e P, que são auxiliares para gerar o carry antecipado
GERADORCARRY : for i in 0 to 31 generate
    s_C(i)   <= A_i(i) and B_op(i); 
    s_P(i)   <= A_i(i) xor B_op(i); 
  end generate GERADORCARRY;

-- lookahead de 4 bits para cada grupo
gen_group: for blk in 0 to 7 generate
    GG(blk) <= s_C(4*blk+3)
               or (s_P(4*blk+3) and s_C(4*blk+2))
               or (s_P(4*blk+3) and s_P(4*blk+2) and s_C(4*blk+1))
               or (s_P(4*blk+3) and s_P(4*blk+2) and s_P(4*blk+1) and s_C(4*blk));
    PP(blk) <= s_P(4*blk+3) and s_P(4*blk+2) and s_P(4*blk+1) and s_P(4*blk);
  end generate gen_group;

-- inicialização do carry
  Carry(0) <= mode_i;
  
  Carry(1) <= s_C(0) or (s_P(0) and Carry(0));
  Carry(2) <= s_C(1) or (s_P(1) and Carry(1));
  Carry(3) <= s_C(2) or (s_P(2) and Carry(2));
  
  Carry(4) <= GG(0) or (PP(0) and Carry(0)) when vecSize_i /= "00" else
              s_C(3) or (s_P(3) and Carry(3));
  			
  Carry(5) <= s_C(4) or (s_P(4) and Carry(4));
  Carry(6) <= s_C(5) or (s_P(5) and Carry(5));
  Carry(7) <= s_C(6) or (s_P(6) and Carry(6));
  
  Carry(8) <= GG(1) or (PP(1) and Carry(4)) when vecSize_i /= "00" and vecSize_i /= "01" else
              s_C(7) or (s_P(7) and Carry(7));
  
  Carry(9) <= s_C(8) or (s_P(8) and Carry(8)); 
  Carry(10) <= s_C(9) or (s_P(9) and Carry(9));
  Carry(11) <= s_C(10) or (s_P(10) and Carry(10));
  
  Carry(12) <= GG(2) or (PP(2) and Carry(8)) when vecSize_i /= "00" and vecSize_i /= "01" else
               s_C(11) or (s_P(11) and Carry(11));

  Carry(13) <= s_C(12) or (s_P(12) and Carry(12)); 
  Carry(14) <= s_C(13) or (s_P(13) and Carry(13));
  Carry(15) <= s_C(14) or (s_P(14) and Carry(14));
  
  Carry(16) <= GG(3) or (PP(3) and Carry(12)) when vecSize_i /= "00" and vecSize_i /= "01" and vecSize_i /= "10" else
               s_C(15) or (s_P(15) and Carry(15));
  
  Carry(17) <= s_C(16) or (s_P(16) and Carry(16));
  Carry(18) <= s_C(17) or (s_P(17) and Carry(17));
  Carry(19) <= s_C(18) or (s_P(18) and Carry(18));
  
  Carry(20) <= GG(4) or (PP(4) and Carry(16)) when vecSize_i /= "00" and vecSize_i /= "01" and vecSize_i /= "10" else
               s_C(19) or (s_P(19) and Carry(19));
  			
  Carry(21) <= s_C(20) or (s_P(20) and Carry(20)); 
  Carry(22) <= s_C(21) or (s_P(21) and Carry(21));
  Carry(23) <= s_C(22) or (s_P(22) and Carry(22));
  
  Carry(24) <= GG(5) or (PP(5) and Carry(20)) when vecSize_i /= "00" and vecSize_i /= "01" and vecSize_i /= "10" else
               s_C(23) or (s_P(23) and Carry(23));
  			
  Carry(25) <= s_C(24) or (s_P(24) and Carry(24));
  Carry(26) <= s_C(25) or (s_P(25) and Carry(25));
  Carry(27) <= s_C(26) or (s_P(26) and Carry(26)); 
  
  Carry(28) <= GG(6) or (PP(6) and Carry(24)) when vecSize_i /= "00" and vecSize_i /= "01" and vecSize_i /= "10" else
               s_C(27) or (s_P(27) and Carry(27));
  			
  Carry(29) <= s_C(28) or (s_P(28) and Carry(28));
  Carry(30) <= s_C(29) or (s_P(29) and Carry(29));
  Carry(31) <= s_C(30) or (s_P(30) and Carry(30));
  
-- Finalmente, realizamos as somas
  GERADOR_SOMA : for mm in 0 to 31 generate
    s_Soma (mm) <= A_i(mm) xor B_op(mm) xor Carry(mm);
  end generate GERADOR_SOMA;

  S_o <= s_Soma;
END TypeArchitecture;