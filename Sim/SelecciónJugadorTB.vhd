library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SeleccionJugadoresTB is
end SeleccionJugadoresTB;

architecture Behavioral of SeleccionJugadoresTB is

  component Bloque1 is
    port(
      clk            : in  std_logic;
      reset          : in  std_logic;
      enable         : in  std_logic;
      continue       : in  std_logic;
      switches       : in  std_logic_vector(3 downto 0);
      freq_div_fin   : in  std_logic;
      freq_div_start : out std_logic;
      Fin            : out std_logic;
      seven_segments : out std_logic_vector(19 downto 0);
      Num            : out std_logic_vector(3 downto 0)
    );
  end component;

  -- Señales TB
  signal clk_tb            : std_logic := '0';
  signal reset_tb          : std_logic := '0';
  signal enable_tb         : std_logic := '1';
  signal continue_tb       : std_logic := '0';
  signal switches_tb       : std_logic_vector(3 downto 0) := "0000";
  signal freq_div_fin_tb   : std_logic := '0';

  signal freq_div_start_tb : std_logic;
  signal Fin_tb            : std_logic;
  signal seven_segments_tb : std_logic_vector(19 downto 0);
  signal Num_tb            : std_logic_vector(3 downto 0);

begin

  -- Circuito bajo test
  CUT: Bloque1
    port map(
      clk            => clk_tb,
      reset          => reset_tb,
      enable         => enable_tb,
      continue       => continue_tb,
      switches       => switches_tb,
      freq_div_fin   => freq_div_fin_tb,
      freq_div_start => freq_div_start_tb,
      Fin            => Fin_tb,
      seven_segments => seven_segments_tb,
      Num            => Num_tb
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
    ----------------------------------------------------------------------
    -- RESET
    ----------------------------------------------------------------------
    reset_tb <= '1';
    wait for 30 ns;
    reset_tb <= '0';
    wait for 40 ns;

    ----------------------------------------------------------------------
    -- CASO 1: switches inválidos + pulsación larga -> NO start, NO Fin
    ----------------------------------------------------------------------
    report "CASO 1: switches invalidos + continue largo" severity note;
    switches_tb <= "0001";
    wait for 20 ns;

    continue_tb <= '1';
    wait for 60 ns;      -- pulsación larga (varios ciclos)
    continue_tb <= '0';
    wait for 80 ns;

    ----------------------------------------------------------------------
    -- CASO 2: switches=2 válido + pulsación larga -> start (1 pulso) y NO Fin
    ----------------------------------------------------------------------
    report "CASO 2: start valido con switches=2 (continue largo)" severity note;
    switches_tb <= "0010";
    wait for 20 ns;

    continue_tb <= '1';
    wait for 60 ns;      -- pulsación larga: SOLO debe contar 1 vez
    continue_tb <= '0';
    wait for 120 ns;     -- tiempo "antes de 5s"

    ----------------------------------------------------------------------
    -- CASO 3: termina por freq_div_fin
    ----------------------------------------------------------------------
    report "CASO 3: fin por freq_div_fin" severity note;
    freq_div_fin_tb <= '1';
    wait for 30 ns;      -- pulso de fin
    freq_div_fin_tb <= '0';
    wait for 120 ns;

    ----------------------------------------------------------------------
    -- CASO 4: switches=3 válido + start y luego segunda pulsación -> Fin por continue
    ----------------------------------------------------------------------
    report "CASO 4: start con switches=3 y fin por segunda pulsacion" severity note;
    switches_tb <= "0011";
    wait for 20 ns;

    -- Start (pulsación larga)
    continue_tb <= '1';
    wait for 60 ns;
    continue_tb <= '0';
    wait for 120 ns;     -- todavía no llega freq_div_fin

    -- Segunda pulsación (finish anticipado)
    continue_tb <= '1';
    wait for 60 ns;
    continue_tb <= '0';
    wait for 120 ns;

    ----------------------------------------------------------------------
    -- CASO 5: enable = 0 (bloque "parado") aunque pulses continue
    ----------------------------------------------------------------------
    report "CASO 5: enable=0, no debe arrancar ni terminar" severity note;
    enable_tb <= '0';
    switches_tb <= "0100";  -- válido, pero enable=0
    wait for 20 ns;

    continue_tb <= '1';
    wait for 60 ns;
    continue_tb <= '0';
    wait for 120 ns;

    -- Volvemos a enable=1
    enable_tb <= '1';
    wait for 40 ns;

    ----------------------------------------------------------------------
    -- CASO 6: switches=4 válido + start + fin por freq_div_fin
    ----------------------------------------------------------------------
    report "CASO 6: start con switches=4 y fin por freq_div_fin" severity note;
    switches_tb <= "0100";
    wait for 20 ns;

    continue_tb <= '1';
    wait for 60 ns;
    continue_tb <= '0';
    wait for 120 ns;

    freq_div_fin_tb <= '1';
    wait for 30 ns;
    freq_div_fin_tb <= '0';
    wait for 120 ns;

    wait;
  end process;

end Behavioral;