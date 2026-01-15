library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bloque5TB is
end entity;

architecture Behavioral of Bloque5TB is

  signal clk_tb           : std_logic := '0';
  signal reset_tb         : std_logic := '1';
  signal Num_jugadores_tb : std_logic_vector(3 downto 0) := "0100";

  signal p1_tb : std_logic_vector(1 downto 0) := "00";
  signal p2_tb : std_logic_vector(1 downto 0) := "00";
  signal p3_tb : std_logic_vector(1 downto 0) := "00";
  signal p4_tb : std_logic_vector(1 downto 0) := "00";

  signal fin_fase_tb : std_logic;
  signal segments7_tb : std_logic_vector(19 downto 0);

begin

  -- Circuito bajo test
  DUT: entity work.Bloque5
    port map(
      clk       => clk_tb,
      reset     => reset_tb,

      num_jug   => Num_jugadores_tb,
      R_Puntos1 => p1_tb,
      R_Puntos2 => p2_tb,
      R_Puntos3 => p3_tb,
      R_Puntos4 => p4_tb,

      fin_fase  => fin_fase_tb,
      segments7 => segments7_tb
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
    p1_tb <= "00";
    p2_tb <= "00";
    p3_tb <= "11";  -- queremos que gane 3 al salir de reset
    p4_tb <= "10";

    wait for 10 ns;
    reset_tb <= '0';
    wait for 60 ns;

    ------------------------------------------------
    -- Cambiar puntos (opcional)
    ------------------------------------------------
    p3_tb <= "01";
    p4_tb <= "00";
    wait for 60 ns;

    ------------------------------------------------
    -- RESET 3 para probar que ahora gana el 4
    ------------------------------------------------
    reset_tb <= '1';
    wait for 30 ns;

    p1_tb <= "00";
    p2_tb <= "00";
    p3_tb <= "10";
    p4_tb <= "11";  -- gana 4

    wait for 10 ns;
    reset_tb <= '0';
    wait for 80 ns;

    wait;
  end process;

end Behavioral;