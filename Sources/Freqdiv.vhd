library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.estados_pkg.all;


entity Freqdiv is
    Port (clk    :  in  std_logic;

          estado_in :  in  estados;

          reset1  :  in  std_logic;
          reset2  :  in  std_logic;
          reset3  :  in  std_logic;
          reset4  :  in  std_logic;
          reset5  :  in  std_logic;
          
          fdiv_out :  out std_logic);
end Freqdiv;

architecture Behavioral of Freqdiv is

    constant max_count : integer := 5*125000000/1000000 -1;
    -- constant max_count : integer := 20; -- Para simulación rápida
    signal count : integer range 0 to max_count := 0 ;

begin

    process(clk)
    begin
        if (estado_in=SJug and reset1= '1') or (estado_in=ExtPied and reset2= '1') or
           (estado_in=IntrApuesta and reset3= '1') or (estado_in=ResRonda and reset4= '1') or
           (estado_in=FinJug and reset5= '1') then
                count <= 0;
                fdiv_out <= '0';
        elsif clk'event and clk = '1' then
            if count < max_count - 1 then
                count <= count + 1;
                fdiv_out <= '0';
            else
                count <= 0;
                fdiv_out <= '1';
            end if;
        end if;
    end process;

end Behavioral;