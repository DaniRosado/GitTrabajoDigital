library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bloque1 is
  port(
    clk            : in  std_logic;
    reset          : in  std_logic;  -- 1 = apagado (estado inicial), 0 = funcionando

    btn_confirm        : in  std_logic;  -- boton CONFIRMACION (elige nº jugadores)
    btn_continue       : in  std_logic;  -- boton CONTINUAR (salta los 5s)

    switches       : in  std_logic_vector(3 downto 0);
    fdiv_fin   : in  std_logic;
    fdiv_reset : out std_logic;  -- Va al reset del FreqDiv: 1=reset(parado), 0=contando
    Fin            : out std_logic;
    freq_div_fin   : in  std_logic;
    freq_div_start : out std_logic;  -- Va al reset del FreqDiv: 1=reset(parado), 0=contando
    fin_fase            : out std_logic;
    seven_segments : out std_logic_vector(19 downto 0);
   num_jug            : out std_logic_vector(3 downto 0)
    num_jug            : out std_logic_vector(3 downto 0)
  );
end entity;

architecture Behavioral of Bloque1 is

  signal aux1       : std_logic_vector(14 downto 0);
  signal aux2       : std_logic_vector(4 downto 0);

  signal started    : std_logic;  -- 1 mientras el divisor está contando (fdiv_reset=0)

  -- detector de flanco para CONFIRM
  signal conf_prev  : std_logic := '0';
  signal conf_pulse : std_logic := '0';

  -- detector de flanco para CONTINUE
  signal cont_prev  : std_logic := '0';
  signal cont_pulse : std_logic := '0';

begin

  -- JUG fijo
  aux1 <= "100001000110010";

  -- último display: 2/3/4/_
  aux2 <= "00010" when switches = "0010" else
          "00011" when switches = "0011" else
          "00100" when switches = "0100" else
          "10100";

  seven_segments(19 downto 5) <= aux1;
  seven_segments(4 downto 0)  <= aux2;

  process(clk, reset)
  begin
    -- reset=1 => apagado
    if reset = '1' then
      num_jug <= "0000";
      fin_fase <= '0';
      started <= '0';

      conf_prev  <= '0';
      conf_pulse <= '0';
      cont_prev  <= '0';
      cont_pulse <= '0';

      -- divisor apagado: reset del divisor a 1
      fdiv_reset <= '1';

    elsif (clk'event and clk = '1') then
      -- por defecto
      fin_fase <= '0';

      -- detector de flanco (pulsación) CONFIRM
      conf_pulse <= btn_confirm and (not conf_prev);
      conf_prev  <= btn_confirm;

      -- detector de flanco (pulsación) CONTINUE
      cont_pulse <= btn_continue and (not cont_prev);
      cont_prev  <= btn_continue;

      -- por defecto: mantener el reset del divisor según started
      if started = '1' then
        fdiv_reset <= '0';   -- contando
      else
        fdiv_reset <= '1';   -- parado
      end if;

      -- 1) Arranque: solo si NO estamos contando y hay pulsación de CONFIRM + switches válido
      if started = '0' then
        if conf_pulse = '1' and
           (switches = "0010" or switches = "0011" or switches = "0100") then
          num_jug <= switches;
          started <= '1';
          fdiv_reset <= '0';  -- empezamos a contar ya
        end if;
      end if;

      -- 2) Fin: solo si estamos contando
      if started = '1' then
        -- Fin por tiempo (freq_div_fin) o por CONTINUE (salto de los 5s)
        if freq_div_fin = '1' or cont_pulse = '1' then
          fin_fase <= '1';
          started <= '0';
          fdiv_reset <= '1';  -- paramos/reseteamos divisor inmediatamente
        end if;
      end if;

    end if;
  end process;

end Behavioral;
