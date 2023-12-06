library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_registers is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        write_n   : in  std_logic;
        backup_n  : in  std_logic;
        restore_n : in  std_logic;
        address   : in  std_logic_vector(2 downto 0);
        irq       : in  std_logic_vector(31 downto 0);
        wrdata    : in  std_logic_vector(31 downto 0);

        ipending  : out std_logic;
        rddata    : out std_logic_vector(31 downto 0)
    );
end control_registers;

architecture synth of control_registers is
    SIGNAL ctl0,ctl1,ctl2,ctl3,ctl4,ctl5 : std_logic_vector(31 downto 0);
begin
    ctl4 <= irq and ctl3;
    
    hihi : process(clk,reset_n) is 
    begin
        if (reset_n = '0') then
            ctl0 <= (others => '0');
            ctl1 <= (others => '0');
            ctl2 <= (others => '0');
            ctl3 <= (others => '0');
            ctl5 <= (others => '0');
        elsif rising_edge(clk) then
            if write_n = '0' and backup_n = '1' and restore_n = '1' then
                case address is 
                    when "000" => ctl0 <= wrdata;
                    when "001" => ctl1 <= wrdata;
                    when "011" => ctl3 <= wrdata;
                    when "101" => ctl5 <= wrdata;
                    when others => ctl2 <= wrdata;
                end case;
            elsif write_n = '1' and backup_n = '0' and restore_n = '1' then
                ctl1(0) <= ctl0(0);
                ctl0(0) <= '0';
            elsif write_n = '1' and backup_n = '1' and restore_n = '0' then
                ctl0(0) <= ctl1(0);
            end if;
        end if;
    end process hihi;
    with address select rddata <= 
        (0 => ctl0(0) , others => '0') when "000",
        (0 => ctl1(0) , others => '0') when "001",
        ctl3 when "011",
        ctl5 when "101",
        ctl4 when "100",
        ctl2 when others;
    ipending <= '1' when ctl0(0) = '1' and ctl4 /= "00000000000000000000000000000000" else '0';
end synth;
