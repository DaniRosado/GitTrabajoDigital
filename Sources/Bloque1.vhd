library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bloque1 is
  port(
    clk     : in  std_logic;
    reset   : in  std_logic;  -- 1 = apagado (estado inicial), 0 = funcionando

    btn_confirm   : in  std_logic;  -- pulso CONFIRMACION (elige nº jugadores)
    btn_continue  : in  std_logic;  -- pulso CONTINUAR (salta los 5s)

    switches        : in  std_logic_vector(3 downto 0);

    fdiv_fin        : in  std_logic;
    fdiv_reset      : out std_logic;  -- Va al reset del FreqDiv: 1=reset(parado), 0=contando
 
    seven_segments  : out std_logic_vector(19 downto 0);
    num_jug         : out std_logic_vector(3 downto 0);

    fin_fase        : out std_logic
  );
end entity;

architecture Behavioral of Bloque1 is

  signal aux   : std_logic_vector(4 downto 0);

  signal started  : std_logic;  -- 1 mientras el divisor está contando (fdiv_reset=0)

begin


  -- último display: 2/3/4/_
  aux <= "00010" when switches = "0010" else
         "00011" when switches = "0011" else
         "00100" when switches = "0100" else
         "10100";

  seven_segments(19 downto 5) <= "100001000110010";
  seven_segments(4 downto 0)  <= aux;

  process(clk)
  begin

    if clk'event and clk = '1' then

      if reset = '1' then
        num_jug  <= "0000";
        fin_fase <= '0';
        started  <= '0';
        fdiv_reset <= '1';
      else
        -- por defecto
        fin_fase <= '0';

        -- por defecto: mantener el reset del divisor según started
        if started = '1' then
          fdiv_reset <= '0';   -- contando
        else
          fdiv_reset <= '1';   -- parado
        end if;

        -- 1) Arranque: solo si NO estamos contando y hay pulso CONFIRM + switches válido
        if started = '0' then
          if btn_confirm = '1' and (switches = "0010" or switches = "0011" or switches = "0100") then
            num_jug   <= switches;
            started   <= '1';
            fdiv_reset <= '0';  -- empezamos a contar ya
          end if;
        end if;

        -- 2) Fin: solo si estamos contando
        if started = '1' then
          -- Fin por tiempo (fdiv_fin) o por CONTINUE (salto de los 5s)
          if fdiv_fin = '1' or btn_continue = '1' then
            fin_fase  <= '1';
            started   <= '0';
            fdiv_reset <= '1';  -- paramos/reseteamos divisor inmediatamente
          end if;
        end if;
      end if;
    end if;
  end process;

end Behavioral;