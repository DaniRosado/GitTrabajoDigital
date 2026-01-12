library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FinJuego is
  port(
    clk           : in  std_logic;
    reset         : in  std_logic;
    
    Num_jugadores : in  std_logic_vector(3 downto 0);
    p1            : in  std_logic_vector(1 downto 0);
    p2            : in  std_logic_vector(1 downto 0);
    p3            : in  std_logic_vector(1 downto 0);
    p4            : in  std_logic_vector(1 downto 0);
    repetir       : out std_logic;
    ganador       : out std_logic_vector(19 downto 0) -- display
  );
end FinJuego;

architecture Behavioral of FinJuego is

  constant FIN_TXT : std_logic_vector(14 downto 0) := "011111011111000";

  constant DIG1 : std_logic_vector(4 downto 0) := "00001";
  constant DIG2 : std_logic_vector(4 downto 0) := "00010";
  constant DIG3 : std_logic_vector(4 downto 0) := "00011";
  constant DIG4 : std_logic_vector(4 downto 0) := "00100";

  signal win   : std_logic := '0';
  signal digit : std_logic_vector(4 downto 0) := (others => '0');

begin

  process(clk, reset)
  begin
    if reset = '1' then
      repetir <= '0';
      ganador <= (others => '0');
      win     <= '0';
      digit  <= (others => '0');

    elsif (clk'event and clk = '1') then

      -- Si ya hay ganador, lo mantenemos fijo
      if win = '1' then
        repetir <= '0';
        ganador(19 downto 5) <= FIN_TXT;
        ganador(4 downto 0)  <= digit;

      else
        -- Por defecto: nadie ha ganado todavía -> repetir ronda
        repetir <= '1';
        ganador <= (others => '0');

        -- Detectar ganador (puntos = 3)
        if p1 = "11" then
          win     <= '1';
          digit  <= DIG1;
          repetir <= '0';
          ganador(19 downto 5) <= FIN_TXT;
          ganador(4 downto 0)  <= DIG1;

        elsif p2 = "11" then
          win     <= '1';
          digit  <= DIG2;
          repetir <= '0';
          ganador(19 downto 5) <= FIN_TXT;
          ganador(4 downto 0)  <= DIG2;

        elsif p3 = "11" then
          win     <= '1';
          digit  <= DIG3;
          repetir <= '0';
          ganador(19 downto 5) <= FIN_TXT;
          ganador(4 downto 0)  <= DIG3;

        elsif p4 = "11" then
          win     <= '1';
          digit  <= DIG4;
          repetir <= '0';
          ganador(19 downto 5) <= FIN_TXT;
          ganador(4 downto 0)  <= DIG4;
        end if;

      end if;
    end if;
  end process;

end Behavioral;
