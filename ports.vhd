library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ports is
    generic (
        PORT_WIDTH: integer := 2; -- Width of port number (2 bits for 4 ports)
        DATA_WIDTH: integer := 64 -- Width of data
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        port_in: in std_logic_vector(PORT_WIDTH-1 downto 0); 
        data_in: in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out: out std_logic_vector(DATA_WIDTH-1 downto 0);
        port_out: out std_logic_vector(PORT_WIDTH-1 downto 0);
        data_valid: out std_logic;
        data_ready: in std_logic;
    );
end ports;

architecture arch_ports of ports is
begin
    -- Process for handling data reception and transmission
    process(clk, rst)
    begin
        if(rst = '1') then
            -- Reset all output values
            data_out <= (others => '0');
            port_out <= (others => '0');
            data_valid <= '0';
        elsif(rising_edge(clk)) then
            if(data_ready = '1') then
                -- Port ready to receive data
                data_out <= data_in;
                port_out <= port_in;
                data_valid <= '1'; 
            else
                data_valid <= '0'; -- Data is not valid when the port is not ready
            end if;
        end if;
    end process;
end arch_ports;
