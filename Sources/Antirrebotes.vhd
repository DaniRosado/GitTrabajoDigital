library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity Antirrebotes is
Port (clk      : in  std_logic;
      reset    : in  std_logic;
      
      boton    : in  std_logic;
      filtrado : out std_logic);
end entity;

architecture Behavioral of Antirrebotes is
    signal Q1, Q2, Q3, E, T : std_logic;
    signal flanco : std_logic ;
    type state_type is  (S_NADA, S_BOTON);
    signal ESTADO : StaTe_tYpE;

    constant Max_count: integer := 25;
    --constant Max_count: integer := 125000;
    signal contador : integer range 0 to max_count; 
begin
    process(clk, reset)
    begin
        if reset = '1' then
            Q1 <= '0';
            Q2 <= '0';
            Q3 <= '0'; 
        elsif clk'event and clk = '1' then
            Q1 <= boton;
            Q2 <= Q1;
            Q3 <= Q2;
        end if;
    end process;

    flanco <= not Q3 and Q2;
    
    FMS : process(clk, reset)
    begin
        if(reset = '1') then
            ESTADO <= S_NADA;
        elsif clk'event and clk = '1' then
            case ESTADO is 
                when S_NADA =>
                    if flanco = '1' and T = '0' then
                        ESTADO <= S_BOTON;
                    end if;
                when S_BOTON =>
                    if (T = '1') then
                        ESTADO <= S_NADA;
                    end if;
             end case;                                    
        end if;
    end process;

    filtrado <= '1' when (ESTADO = S_BOTON and Q2 = '1' and T = '1') else '0';
    E <= '1' when ESTADO = S_BOTON else '0';
    
    Temporizador : process(clk, reset)
    begin
        if reset = '1' then
            contador <= 0; 
            T <= '0';
        elsif clk'event and clk = '1' then
            if E = '1' then
                if contador < max_count-1 then 
                    contador <= contador + 1;
                    T <= '0';
                else
                    contador <= 0;
                    T <= '1';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
