library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_Bloque1 is
end entity;

architecture Behavioral of TB_Bloque1 is

  component Bloque1 is
    port(
      clk            : in  std_logic;
      reset          : in  std_logic;

      confirm        : in  std_logic;
      continue       : in  std_logic;

      switches       : in  std_logic_vector(3 downto 0);
      freq_div_fin   : in  std_logic;
      freq_div_start : out std_logic;
      Fin            : out std_logic;
      seven_segments : out std_logic_vector(19 downto 0);
      Num            : out std_logic_vector(3 downto 0)
    );
  end component;

  signal clk_tb            : std_logic := '0';
  signal reset_tb          : std_logic := '1'; -- apagado al inicio

  signal confirm_tb        : std_logic := '0';
  signal continue_tb       : std_logic := '0';

  signal switches_tb       : std_logic_vector(3 downto 0) := "0000";
  signal freq_div_fin_tb   : std_logic := '0';

  signal freq_div_start_tb : std_logic;
  signal Fin_tb            : std_logic;
  signal seven_segments_tb : std_logic_vector(19 downto 0);
  signal Num_tb            : std_logic_vector(3 downto 0);

begin

  CUT: Bloque1
    port map(
      clk            => clk_tb,
      reset          => reset_tb,
      confirm        => confirm_tb,
      continue       => continue_tb,
      switches       => switches_tb,
      freq_div_fin   => freq_div_fin_tb,
      freq_div_start => freq_div_start_tb,
      Fin            => Fin_tb,
      seven_segments => seven_segments_tb,
      Num            => Num_tb
    );

  -- Reloj 10 ns
  Clock_TB: process
  begin
    while true loop
      clk_tb <= '0'; wait for 5 ns;
      clk_tb <= '1'; wait for 5 ns;
    end loop;
  end process;

  -- Estímulos
  Signal_TB: process
  begin
    -- Encender bloque (reset activo a 1)
    reset_tb <= '1';
    wait for 30 ns;
    reset_tb <= '0';
    wait for 50 ns;

    ----------------------------------------------------------------------
    -- CASO 1: confirmar 2 y SALTAR antes de freq_div_fin con CONTINUE
    ----------------------------------------------------------------------
    switches_tb <= "0010";
    wait for 20 ns;

    -- Start con CONFIRM (pulsación larga)
    confirm_tb <= '1'; wait for 60 ns; confirm_tb <= '0';
    wait for 200 ns;

    -- Saltar (antes de fin) con CONTINUE
    continue_tb <= '1'; wait for 60 ns; continue_tb <= '0';
    wait for 200 ns;

    ----------------------------------------------------------------------
    -- CASO 2: confirmar 3 y terminar por freq_div_fin
    ----------------------------------------------------------------------
    switches_tb <= "0011";
    wait for 20 ns;

    -- Start con CONFIRM
    confirm_tb <= '1'; wait for 60 ns; confirm_tb <= '0';
    wait for 200 ns;

    -- Simular que pasaron 5s
    freq_div_fin_tb <= '1'; wait for 30 ns; freq_div_fin_tb <= '0';
    wait for 200 ns;

    ----------------------------------------------------------------------
    -- CASO 3 (extra): switches inválido + confirm -> NO debe arrancar
    ----------------------------------------------------------------------
    switches_tb <= "0001";
    wait for 20 ns;

    confirm_tb <= '1'; wait for 60 ns; confirm_tb <= '0';
    wait for 200 ns;

    wait;
  end process;

end Behavioral;