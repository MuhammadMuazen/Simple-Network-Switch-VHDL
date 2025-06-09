library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mac_table is
    generic (
        TABLE_SIZE: integer := 256;  -- Number of MAC entries
        MAC_WIDTH: integer := 48;   -- Width of MAC address
        PORT_WIDTH: integer := 2     -- Width of port number
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        mac_addr_in: in std_logic_vector(MAC_WIDTH-1 downto 0); 
        port_in: in std_logic_vector(PORT_WIDTH-1 downto 0);
        write_enable : in std_logic; 
        lookup_enable: in std_logic;
        port_out: out std_logic_vector(PORT_WIDTH-1 downto 0);
        hit: out std_logic;
    );
end mac_table;

architecture arch_mac_table of mac_table is
    -- Define RAM for MAC table
    -- It is an array the is of size 256 (TABLE_SIZE) and each element in it have the size of the mac address the relative port
    type mac_table_ram is array (0 to TABLE_SIZE-1) of std_logic_vector(MAC_WIDTH+PORT_WIDTH-1 downto 0);
    signal mac_table_mem: mac_table_ram; -- Singal that represet the table we want to work on

    -- Temporary variables
    signal write_index : integer range 0 to TABLE_SIZE-1 := 0;
    signal lookup_index: integer range 0 to TABLE_SIZE-1;
    signal found: std_logic := '0';
begin

    -- MAC table process
    process(clk, rst)
    begin
        if(rst = '1') then
            -- Reset logic
            for i in 0 to TABLE_SIZE-1 loop
                mac_table_mem(i) <= (others => '0'); -- Clear the table
            end loop;
            -- Make all the values 0
            port_out <= (others => '0');
            hit <= '0';
            write_index <= 0;
        elsif(rising_edge(clk)) then
            if(write_enable = '1') then
                -- Write MAC address and port
                mac_table_mem(write_index)(MAC_WIDTH-1 downto 0) <= mac_addr_in; 
                mac_table_mem(write_index)(MAC_WIDTH+PORT_WIDTH-1 downto MAC_WIDTH) <= port_in;
                write_index <= (write_index + 1) mod TABLE_SIZE;
            elsif(lookup_enable = '1') then
                -- Lookup MAC address
                found <= '0'; 
                for i in 0 to TABLE_SIZE-1 loop
                    if(mac_table_mem(i)(MAC_WIDTH-1 downto 0) = mac_addr_in) then
                        port_out <= mac_table_mem(i)(MAC_WIDTH+PORT_WIDTH-1 downto MAC_WIDTH); 
                        found <= '1';
                        exit;
                    end if;
                end loop;
                hit <= found;
            end if;
        end if;
    end process;

end arch_mac_table;
