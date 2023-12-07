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
    signal sg_cont, sg_to, sg_clear_to, sg_ito, sg_run, sg_read, sg_write_period, sg_start, sg_stop : std_logic;
    signal sg_address: std_logic_vector(1 DOWNTO 0);
    signal sg_counter, sg_periode, sg_control, sg_status : std_logic_vector(31 DOWNTO 0);
    signal sg_count, sg_next_count : unsigned(31 DOWNTO 0);
    type state is (counting, notcounting);
    signal s_state: state; -- s_nextsate
begin
    process (clk,reset_n) is
    begin
        if reset_n = '0' then
            sg_count <= (others => '0');
        elsif rising_edge(clk) then
            if (s_state = counting or sg_count = X"00000000") then
                sg_count <= sg_next_count;
            elsif sg_write_period = '1' then
                sg_count <= unsigned(sg_periode);
            end if;       
        end if;
    end process;

    
    
    --read
    process(clk)
    begin
        if (rising_edge(clk)) then
            sg_read    <= cs and read;
            sg_address <= address;
        end if;
    end process;

    process(sg_read, sg_address,reset_n, sg_status, sg_control, sg_periode, sg_counter)
    begin
        rddata <= (others => 'Z');
        if (sg_read = '1') then
            if sg_address = "00" then
                rddata <= sg_counter;
            elsif sg_address = "01" then
                rddata <= sg_periode;
            elsif sg_address = "10" then
                rddata <= sg_control;
            else
                rddata <= sg_status;
            end if;
        end if;
    end process;

    -- write
    process(clk,reset_n)
    begin
        if (reset_n = '0') then
            sg_cont <= '0';
            sg_ito <= '0';
            sg_start <= '0'; 
            sg_stop <= '0';  
            sg_periode <= (others => '0'); 
            sg_write_period <= '0';-------------------------
        elsif (rising_edge(clk)) then
            sg_clear_to <= '0';
            sg_start <= '0'; 
            sg_stop <= '0'; 
            sg_write_period <= '0';-----------------------------
            if (cs = '1' and write = '1') then
                if address = "00" then 
                    -- RIEN car counter est read only (j'ai laissé la condition comme ça on a les addresses dans l'ordre)
                elsif address = "01" then
                    sg_periode <= wrdata;
                    sg_stop <= '1'; -- écrire dans période arrete le compteur (et vu que stop est write only on peut l'utiliser ici)
 --                   s_state <= notcounting;
                    sg_write_period <= '1';------------------------
 --                   sg_next_count <= to_integer(unsigned(sg_periode));
                elsif address = "10" then
                    sg_ito <= wrdata(1);
                    sg_cont <= wrdata(0);
                    if wrdata(3) = '1' then
                        sg_start <= '1'; 
 --                       s_state <= counting; 
                    end if;
                    if wrdata(2) = '1' then
                        sg_stop <= '1'; 
  --                      s_state <= notcounting;
                    end if;
                else
                    if wrdata = X"00000000" then
                        sg_clear_to <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;



    -- assigning control and status and counter registers (resets not needed as every signal that they depend on is reset individually)
    sg_control <= (1 => sg_ito, 0 => sg_cont, OTHERS => '0');
    
    sg_status <= (1 => sg_to, 0 => sg_run, OTHERS => '0');

    sg_counter <= std_logic_vector(sg_count);

    
    -- EXPERIMENTAL ------------------------

    -- sg_to
    process(reset_n, sg_count, sg_clear_to)
    begin
        if (reset_n = '0' or sg_clear_to = '1') then
            sg_to <= '0';
        elsif (sg_count = X"00000000" and s_state = counting) then
            sg_to <= '1';
        end if;
    end process;

    -- sg_run
    sg_run <= '1' when s_state = counting else '0';

    -- irq
    irq <= sg_ito and sg_to;

    -- s_state
    process(reset_n, sg_start, sg_stop, sg_cont, sg_count)
    begin
        if (reset_n = '0' or sg_stop = '1' or (sg_cont = '0' and sg_count = X"00000000")) then 
            s_state <= notcounting;
        elsif sg_start = '1' then
            s_state <= counting;
              
        end if;
    end process;

    -- sg_next_count
    sg_next_count <= unsigned(sg_periode) when  sg_count = X"00000000" else sg_count - 1;


end synth;
