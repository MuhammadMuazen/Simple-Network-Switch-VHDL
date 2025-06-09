library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity packet_buffer is
    generic (
        DATA_WIDTH: integer := 64;   -- Width of the Ethernet frame data (64 bits)
        PORT_WIDTH: integer := 2;    -- Port ID width (2 bits for 4 ports)
        BUFFER_SIZE: integer := 16    -- Number of entries in the buffer
    );
    port (
        clk: in std_logic; 
        rst: in std_logic;
        data_in: in std_logic_vector(DATA_WIDTH-1 downto 0); 
        port_in: in std_logic_vector(PORT_WIDTH-1 downto 0);
        write_enable: in std_logic;
        read_enable: in std_logic;
        data_out: out std_logic_vector(DATA_WIDTH-1 downto 0);
        port_out: out std_logic_vector(PORT_WIDTH-1 downto 0);
        buffer_full: out std_logic;
        buffer_empty: out std_logic;
    );
end packet_buffer;

architecture arch_packet_buffer of packet_buffer is
    type buffer_entry is record -- each entry in the Buffer which is a ram module will consist of a data (ethernet frame) and the assosciated port number
        data: std_logic_vector(DATA_WIDTH-1 downto 0);
        port: std_logic_vector(PORT_WIDTH-1 downto 0);
    end record;

    type buffer_array is array (0 to BUFFER_SIZE-1) of buffer_entry; -- RAM module of the buffer 

    signal buffer_mem: buffer_array; -- Buffer memory
    signal write_ptr: integer range 0 to BUFFER_SIZE-1 := 0; -- Write pointer
    signal read_ptr: integer range 0 to BUFFER_SIZE-1 := 0; -- Read pointer
    signal count: integer range 0 to BUFFER_SIZE := 0;   -- Number of packets in the buffer
begin
    process (clk, rst)
    begin
        if(rst = '1') then
            -- Reset all signals
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
            data_out <= (others => '0');
            port_out <= (others => '0');
            buffer_full <= '0';
            buffer_empty <= '1';
        elsif rising_edge(clk) then
            -- Write Logic
            if(write_enable = '1' and count < BUFFER_SIZE) then
                buffer_mem(write_ptr).data <= data_in;
                buffer_mem(write_ptr).port <= port_in;
                write_ptr <= (write_ptr + 1) mod BUFFER_SIZE;
                count <= count + 1;
            end if;

            -- Read Logic
            if(read_enable = '1' and count > 0) then 
                data_out <= buffer_mem(read_ptr).data;
                port_out <= buffer_mem(read_ptr).port; 
                read_ptr <= (read_ptr + 1) mod BUFFER_SIZE;
                count <= count - 1;
            end if;

            -- Buffer Status
            buffer_full <= '1' when count = BUFFER_SIZE else '0';
            buffer_empty <= '1' when count = 0 else '0';
        end if;
    end process;
end arch_packet_buffer;
