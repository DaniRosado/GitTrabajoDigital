library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FinJuegoTB is
end FinJuegoTB;

architecture Behavioral of FinJuegoTB is

  signal clk_tb           : std_logic := '0';
  signal reset_tb         : std_logic := '1';
  signal Num_jugadores_tb : std_logic_vector(3 downto 0) := "0100";

  signal p1_tb : std_logic_vector(1 downto 0) := "00";
  signal p2_tb : std_logic_vector(1 downto 0) := "00";
  signal p3_tb : std_logic_vector(1 downto 0) := "00";
  signal p4_tb : std_logic_vector(1 downto 0) := "00";

  signal repetir_tb : std_logic;
  signal ganador_tb : std_logic_vector(19 downto 0);

begin

  -- Circuito bajo test
  DUT: entity work.Bloque5
    port map(
      clk           => clk_tb,
      reset         => reset_tb,
      Num_jugadores => Num_jugadores_tb,
      p1            => p1_tb,
      p2            => p2_tb,
      p3            => p3_tb,
      p4            => p4_tb,
      repetir       => repetir_tb,
      ganador       => ganador_tb
    );

  -- Reloj: periodo 10 ns
  Clock_TB: process
  begin
    clk_tb <= '0';
    wait for 5 ns;
    clk_tb <= '1';
    wait for 5 ns;
  end process;

  -- Estímulos
  Signal_TB: process
  begin
    ------------------------------------------------
    -- RESET 1
    ------------------------------------------------
    reset_tb <= '1';
    wait for 30 ns;
    reset_tb <= '0';
    wait for 40 ns;

    ------------------------------------------------
    -- CASO 1: nadie ha ganado
    ------------------------------------------------
    p1_tb <= "01";
    p2_tb <= "10";
    p3_tb <= "00";
    p4_tb <= "00";
    wait for 60 ns;

    ------------------------------------------------
    -- CASO 2: gana jugador 2
    ------------------------------------------------
    p2_tb <= "11";
    wait for 60 ns;

    ------------------------------------------------
    -- CASO 3: cambiar puntos, ganador se mantiene
    ------------------------------------------------
    p2_tb <= "00";
    p1_tb <= "11";
    wait for 60 ns;

    ------------------------------------------------
    -- RESET 2 (reinicio bloque)
    ------------------------------------------------
    reset_tb <= '1';
    wait for 30 ns;

    -- Durante el reset dejamos valores "seguros"
    -- para que al volver a reset=0 NO gane p1 por error
    p1_tb <= "00";
    p2_tb <= "00";
    p3_tb <= "11";  -- p3 = 3 (queremos que gane 3 en el siguiente arranque)
    p4_tb <= "10";  -- p4 = 2 

    wait for 10 ns; -- seguimos en reset un poco más
    reset_tb <= '0';
    wait for 60 ns;

    ------------------------------------------------
    -- Ahora cambiamos algo para que no sea siempre el mismo caso
    -- (opcional)
    ------------------------------------------------
    p3_tb <= "01";
    p4_tb <= "00";
    wait for 60 ns;

    ------------------------------------------------
    -- RESET 3 alrededor de ~400 ns para probar que ahora gana el 4
    ------------------------------------------------
    reset_tb <= '1';
    wait for 30 ns;

    -- Preparar el escenario que tú dices:
    -- p3 = 2 y p4 = 3 cuando quitamos reset
    p1_tb <= "00";
    p2_tb <= "00";
    p3_tb <= "10";
    p4_tb <= "11";

    wait for 10 ns;
    reset_tb <= '0';
    wait for 80 ns;

    wait;
  end process;

end Behavioral;
