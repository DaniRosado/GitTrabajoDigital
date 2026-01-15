library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity TB_RNG_Generator is
end entity;

architecture Behavioral of TB_RNG_Generator is
    -- Component Declaration for the Unit Under Test (UUT)
    component RNG_Generator
    Port ( clk     : in  STD_LOGIC;
           reset   : in  STD_LOGIC; --Reset de la placa
           rng_out : out STD_LOGIC_VECTOR (5 downto 0));
    end component;

    -- Signals to connect to UUT
    signal clk_tb     : std_logic := '0';
    signal reset_tb   : std_logic := '0';
    signal rng_out_tb : std_logic_vector (5 downto 0);

    signal gon_rng   : integer range 0 to 3  := 0;
    signal santi_rng : integer range 0 to 12 := 0;

    constant clk_period : time := 10 ns;
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: RNG_Generator
    Port map (
          clk => clk_tb,
          reset => reset_tb,
          rng_out => rng_out_tb
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk_tb <= '1';
        wait for clk_period/2;
        clk_tb <= '0';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        -- hold reset state for 20 ns.
        reset_tb <= '1';
        wait for 20 ns;	

        reset_tb <= '0';
        wait for 2000 ns;

        wait;
    end process;

    div_tb_process: process(clk_tb)
    begin
        if clk_tb'event and clk_tb = '1' then
            gon_rng <= to_integer(unsigned(rng_out_tb)) mod 4;
            santi_rng <= to_integer(unsigned(rng_out_tb)) mod 13;
        end if;
    end process;

end Behavioral;