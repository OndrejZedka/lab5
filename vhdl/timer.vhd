library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    port(
        -- bus interface
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(1 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);

        irq     : out std_logic;
        rddata  : out std_logic_vector(31 downto 0)
    );
end timer;

architecture synth of timer is
    signal sg_cont, sg_to, sg_ito, sg_run,sg_stop,sg_start: std_logic;
    signal sg_counter, sg_periode : std_logic_vector(31 DOWNTO 0);
    type state is (counting, notcouting);
    signal s_state,s_nextsate: state;
begin
    counting : Process (clk,n_reset) is
        if n_reset = '1' then
            sg_cont <= '0';
            sg_to <= '0'; 
            sg_ito <= '0';
            sg_run <= '0'; 
            sg_stop <= '0';
            sg_start <= '0';
            sg_counter <= (others => '0')
            sg_periode <= (others => '0')
        elsif rising_edge(clk) then

        end if;
    
    -- TEST
end synth;
