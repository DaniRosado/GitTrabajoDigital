library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_Bloque1 is
end entity;

architecture Behavioral of TB_Bloque1 is

  component Bloque1 is
    port(
    clk     : in  std_logic;
    reset   : in  std_logic;  -- 1 = apagado (estado inicial), 0 = funcionando

    btn_confirm   : in  std_logic;  -- boton CONFIRMACION (elige nº jugadores)
    btn_continue  : in  std_logic;  -- boton CONTINUAR (salta los 5s)

    switches        : in  std_logic_vector(3 downto 0);

    fdiv_fin        : in  std_logic;
    fdiv_reset      : out std_logic;  -- Va al reset del FreqDiv: 1=reset(parado), 0=contando

    seven_segments  : out std_logic_vector(19 downto 0);
    num_jug         : out std_logic_vector(3 downto 0);

    fin_fase        : out std_logic
    );
  end component;

  signal clk_tb   : std_logic := '0';
  signal reset_tb : std_logic := '1'; -- apagado al inicio

  signal btn_confirm_tb   : std_logic := '0';
  signal btn_continue_tb  : std_logic := '0';

  signal switches_tb    : std_logic_vector(3 downto 0) := "0000";

  signal fdiv_fin_tb    : std_logic := '0';
  signal fdiv_reset_tb  : std_logic;
  
  signal seven_segments_tb  : std_logic_vector(19 downto 0);
  signal num_jug_tb         : std_logic_vector(3 downto 0);
  
  signal fin_fase_tb  : std_logic;

begin

  CUT: Bloque1
    port map(
      clk     =>  clk_tb,
      reset   =>  reset_tb,

      btn_confirm   =>  btn_confirm_tb,
      btn_continue  =>  btn_continue_tb,

      switches  =>  switches_tb,

      fdiv_fin    =>  fdiv_fin_tb,
      fdiv_reset  =>  fdiv_reset_tb,
      
      seven_segments  =>  seven_segments_tb,
      num_jug   =>  num_jug_tb,
      fin_fase  =>  fin_fase_tb
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
    btn_confirm_tb <= '1'; wait for 60 ns; btn_confirm_tb <= '0';
    wait for 200 ns;

    -- Saltar (antes de fin) con CONTINUE
    btn_continue_tb <= '1'; wait for 60 ns; btn_continue_tb <= '0';
    wait for 200 ns;

    ----------------------------------------------------------------------
    -- CASO 2: confirmar 3 y terminar por freq_div_fin
    ----------------------------------------------------------------------
    switches_tb <= "0011";
    wait for 20 ns;

    -- Start con CONFIRM
    btn_confirm_tb <= '1'; wait for 60 ns; btn_confirm_tb <= '0';
    wait for 200 ns;

    -- Simular que pasaron 5s
    fdiv_fin_tb <= '1'; wait for 30 ns; fdiv_fin_tb <= '0';
    wait for 200 ns;

    ----------------------------------------------------------------------
    -- CASO 3 (extra): switches inválido + confirm -> NO debe arrancar
    ----------------------------------------------------------------------
    switches_tb <= "0001";
    wait for 20 ns;

    btn_confirm_tb <= '1'; wait for 60 ns; btn_confirm_tb <= '0';
    wait for 200 ns;

    wait;
  end process;

end Behavioral;