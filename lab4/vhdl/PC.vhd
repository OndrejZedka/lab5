library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        en           : in  std_logic;
        sel_a        : in  std_logic;
        sel_imm      : in  std_logic;
        sel_ihandler : in  std_logic;
        add_imm      : in  std_logic;
        imm          : in  std_logic_vector(15 downto 0);
        a            : in  std_logic_vector(15 downto 0);
        addr         : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
    SIGNAL s_address, s_next_address : std_logic_vector(15 downto 0);
begin

    addr <= X"0000" & s_address;

    flipflop : Process (clk, reset_n) is
    begin
        if reset_n = '0' then
            s_address <= (others => '0');
        else
            if rising_edge(clk) then
                if en = '1' then
                    s_address <= s_next_address;
                end if;
            end if;
        end if;
    end process flipflop;

    s_next_address <= 
            std_logic_vector(unsigned(s_address) + unsigned(imm))   when add_imm = '1'      else
            imm(13 downto 0) & "00"                                 when sel_imm = '1'      else
            a(15 downto 2) & "00"                                   when sel_a = '1'        else
            X"0004"                                                 when sel_ihandler = '1' else
            std_logic_vector(unsigned(s_address) + 4); 
end synth;
