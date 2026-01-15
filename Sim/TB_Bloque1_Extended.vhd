library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bloque1_AR_TB is
end Bloque1_AR_TB;

architecture Behavioral of Bloque1_AR_TB is

  --------------------------------------------------------------------
  -- Componentes
  --------------------------------------------------------------------
  component Antirrebotes is
    Port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      boton    : in  std_logic;
      filtrado : out std_logic
    );
  end component;

  component Bloque1 is
    port(
      clk     : in  std_logic;
      reset   : in  std_logic;  -- 1 = apagado, 0 = funcionando

      btn_confirm   : in  std_logic;
      btn_continue  : in  std_logic;

      switches      : in  std_logic_vector(3 downto 0);

      fdiv_fin      : in  std_logic;
      fdiv_reset    : out std_logic;  -- 1=reset(parado), 0=contando

      seven_segments : out std_logic_vector(19 downto 0);
      num_jug        : out std_logic_vector(3 downto 0);

      fin_fase       : out std_logic
    );
  end component;

  component Freqdiv is
    Port (
      clk    : in  std_logic;
      reset  : in  std_logic;
      Output : out std_logic
    );
  end component;

  --------------------------------------------------------------------
  -- Señales TB
  --------------------------------------------------------------------
  signal clk_tb      : std_logic := '0';

  signal reset_tb    : std_logic := '1'; -- Bloque1 apagado al inicio (como tu diseño)
  signal reset_ar_tb : std_logic := '1'; -- Antirrebotes reseteado al inicio

  -- "botones crudos" (con rebote simulado)
  signal boton_confirm_tb  : std_logic := '0';
  signal boton_continue_tb : std_logic := '0';

  -- botones filtrados (salidas del antirrebotes)
  signal confirm_filt_tb   : std_logic;
  signal continue_filt_tb  : std_logic;

  signal switches_tb       : std_logic_vector(3 downto 0) := "0000";

  -- divisor (instanciado)
  signal fdiv_reset_tb     : std_logic;
  signal fdiv_fin_tb       : std_logic;

  -- salidas Bloque1
  signal seven_segments_tb : std_logic_vector(19 downto 0);
  signal num_jug_tb        : std_logic_vector(3 downto 0);
  signal fin_fase_tb       : std_logic;

begin

  --------------------------------------------------------------------
  -- Antirrebotes (2 botones)
  --------------------------------------------------------------------
  AR_CONFIRM: Antirrebotes
    port map(
      clk      => clk_tb,
      reset    => reset_ar_tb,
      boton    => boton_confirm_tb,
      filtrado => confirm_filt_tb
    );

  AR_CONTINUE: Antirrebotes
    port map(
      clk      => clk_tb,
      reset    => reset_ar_tb,
      boton    => boton_continue_tb,
      filtrado => continue_filt_tb
    );

  --------------------------------------------------------------------
  -- Bloque1 (selección jugadores)
  --------------------------------------------------------------------
  DUT: Bloque1
    port map(
      clk            => clk_tb,
      reset          => reset_tb,
      btn_confirm    => confirm_filt_tb,
      btn_continue   => continue_filt_tb,
      switches       => switches_tb,
      fdiv_fin       => fdiv_fin_tb,
      fdiv_reset     => fdiv_reset_tb,
      seven_segments => seven_segments_tb,
      num_jug        => num_jug_tb,
      fin_fase       => fin_fase_tb
    );

  --------------------------------------------------------------------
  -- Freqdiv (usa TU entity Freqdiv)
  -- OJO: su reset ES fdiv_reset_tb (1=reset, 0=cuenta)
  --------------------------------------------------------------------
  FDIV: Freqdiv
    port map(
      clk    => clk_tb,
      reset  => fdiv_reset_tb,
      Output => fdiv_fin_tb
    );

  --------------------------------------------------------------------
  -- Reloj 10 ns
  --------------------------------------------------------------------
  Clock_TB: process
  begin
    while true loop
      clk_tb <= '0'; wait for 5 ns;
      clk_tb <= '1'; wait for 5 ns;
    end loop;
  end process;

  --------------------------------------------------------------------
  -- Estímulos
  --------------------------------------------------------------------
  Stim_TB: process
  begin
    ------------------------------------------------------------
    -- RESET GLOBAL (primero todo a reset)
    ------------------------------------------------------------
    reset_tb    <= '1';
    reset_ar_tb <= '1';
    boton_confirm_tb  <= '0';
    boton_continue_tb <= '0';
    switches_tb <= "0000";
    wait for 200 ns;

    -- Activamos antirrebotes
    reset_ar_tb <= '0';
    wait for 200 ns;

    -- Activamos Bloque1
    reset_tb <= '0';
    wait for 500 ns;

    ------------------------------------------------------------
    -- CASO 1 (PRIMERO): switches inválido = 1 + CONFIRM (NO arranca)
    ------------------------------------------------------------
    switches_tb <= "0001";
    wait for 200 ns;

    boton_confirm_tb <= '1';
    wait for 2 us;          -- >>> IMPORTANTE: pulso largo para Antirrebotes
    boton_confirm_tb <= '0';
    wait for 3 us;

    ------------------------------------------------------------
    -- CASO 2: switches = 2 -> start y cancelación con CONTINUE
    ------------------------------------------------------------
    switches_tb <= "0010";
    wait for 200 ns;

    boton_confirm_tb <= '1';
    wait for 2 us;          -- pulso largo
    boton_confirm_tb <= '0';
    wait for 3 us;

    boton_continue_tb <= '1';
    wait for 2 us;          -- pulso largo
    boton_continue_tb <= '0';
    wait for 3 us;

    ------------------------------------------------------------
    -- CASO 3: switches = 3 -> start y fin por fdiv_fin (del divisor)
    ------------------------------------------------------------
    switches_tb <= "0011";
    wait for 200 ns;

    boton_confirm_tb <= '1';
    wait for 2 us;          -- pulso largo
    boton_confirm_tb <= '0';

    wait for 10 us;         -- esperamos a que Freqdiv (rápido) termine


    wait;
  end process;

end Behavioral;
