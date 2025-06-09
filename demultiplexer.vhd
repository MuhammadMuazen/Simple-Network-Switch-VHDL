library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Demultiplexer to distribute the incoming data to one of the four output ports based on the selector
entity demultiplexer is
    Port ( 
        clk: in std_logic; -- Clock signal for synchronization
        rst: in std_logic; -- Reset signal to initialize outputs
        data_in: in std_logic_vector(7 downto 0); -- 8-bit input data (e.g., packet data)
        sel: in std_logic_vector(1 downto 0); -- 2-bit selector to decide which output port gets the data
        data_out_0: out std_logic_vector(7 downto 0); -- Data output to port 0
        data_out_1: out std_logic_vector(7 downto 0); -- Data output to port 1
        data_out_2: out std_logic_vector(7 downto 0); -- Data output to port 2
        data_out_3: out std_logic_vector(7 downto 0) -- Data output to port 3
    );
end demultiplexer;

architecture arch_demultiplexer of demultiplexer is
begin
    process(clk, rst)
    begin
        if(rst = '1') then
            -- Reset all output ports to 0 when reset is active
            data_out_0 <= (others => '0');
            data_out_1 <= (others => '0');
            data_out_2 <= (others => '0');
            data_out_3 <= (others => '0');
        elsif(rising_edge(clk)) then
            -- Distribute the incoming data based on the selector signal (sel)
            case(sel) is
                when "00" =>
                    -- Forward data to port 0 and set others to 0
                    data_out_0 <= data_in;  
                    data_out_1 <= (others => '0');
                    data_out_2 <= (others => '0');
                    data_out_3 <= (others => '0');
                when "01" =>
                    -- Forward data to port 1 and set others to 0
                    data_out_0 <= (others => '0');
                    data_out_1 <= data_in;  
                    data_out_2 <= (others => '0');
                    data_out_3 <= (others => '0');
                when "10" =>
                    -- Forward data to port 2 and set others to 0
                    data_out_0 <= (others => '0');
                    data_out_1 <= (others => '0');
                    data_out_2 <= data_in;  
                    data_out_3 <= (others => '0');
                when "11" =>
                    -- Forward data to port 3 and set others to 0
                    data_out_0 <= (others => '0');
                    data_out_1 <= (others => '0');
                    data_out_2 <= (others => '0');
                    data_out_3 <= data_in;  
                when others =>
                    -- Default case
                    data_out_0 <= (others => '0');
                    data_out_1 <= (others => '0');
                    data_out_2 <= (others => '0');
                    data_out_3 <= (others => '0');
            end case;
        end if;
    end process;
end arch_demultiplexer;
