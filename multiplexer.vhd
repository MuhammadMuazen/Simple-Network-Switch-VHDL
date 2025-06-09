library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Multiplexer to select which output port gets the incoming data based on the selector
entity multiplexer is
    Port ( 
        clk: in std_logic;
        rst: in std_logic;
        data_in: in std_logic_vector(7 downto 0);
        sel: in std_logic_vector(1 downto 0); -- 2-bit selector to choose between 4 output ports
        data_out: out std_logic_vector(7 downto 0)
    );
end multiplexer;

architecture arch_multiplexer of multiplexer is
begin
    process(clk, rst)
    begin
        if(rst = '1') then
            data_out <= (others => '0');
        elsif(rising_edge(clk)) then
            -- Select the output port based on the selector signal (sel)
            case sel is
                when "00" => data_out <= data_in;
                when "01" => data_out <= data_in;
                when "10" => data_out <= data_in;
                when "11" => data_out <= data_in;
                when others => data_out <= (others => '0');
            end case;
        end if;
    end process;
end arch_multiplexer;
