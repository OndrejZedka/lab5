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
    signal sg_cont, sg_to, sg_ito, sg_run,sg_stop,sg_start, sg_read: std_logic;
    signal sg_address: std_logic_vector(1 DOWNTO 0);
    signal sg_counter, sg_periode, sg_control, sg_status : std_logic_vector(31 DOWNTO 0);
    signal sg_count, sg_next_count : integer;
    type state is (counting, notcouting);
    signal s_state,s_nextsate: state;
begin
    counting : Process (clk,n_reset) is
        if n_reset = '0' then
            sg_cont <= '0';
            sg_to <= '0'; 
            sg_ito <= '0';
            sg_run <= '0'; 
            sg_stop <= '0';
            sg_start <= '0';
            sg_count <= 0;
            sg_counter <= (others => '0')
            sg_periode <= (others => '0')
        elsif rising_edge(clk) then
            sg_count <= sg_next_count;

        end if;
    end process;
    
    sg_next_count <= to_integer(unsigned(sg_periode)) when sg_count = 0 else sg_count - 1;

    
    --read
    process(clk)
    begin
        if (rising_edge(clk)) then
            sg_read    <= cs and read;
            sg_address <= address;
        end if;
    end process;

    process(sg_read, sg_address)
    begin
        rddata <= (others => 'Z');
        if (sg_read = '1') then
            rddata <= sg_counter when sg_address = "00" else
                    sg_periode when sg_address = "01" else
                    sg_control when sg_address = "10" else 
                    sg_status;
        end if;
    end process;

    -- write
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (cs = '1' and write = '1') then
                if address = "00" then 

                elsif address = "01" then

                elsif address = "10" then

                else
                
                end if;
            end if;
        end if;
    end process;


    -- assigning control and status registers
    sg_control <= (3 => sg_start, 2 => sg_stop, 1 => sg_ito, 0 => sg_cont, OTHERS => '0');
    
    sg_status <= (1 => sg_to, 0 => sg_run, OTHERS => '0');
    
end synth;
