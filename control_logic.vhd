library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Control Logic Entity Declaration
entity control_logic is
    
    Port ( 
        clk: in std_logic;
        rst: in std_logic;
        
        -- Signals to interact with the MAC address table
        mac_addr_in: in std_logic_vector(47 downto 0);
        port_in: in std_logic_vector(1 downto 0);
        write_enable : out std_logic;
        lookup_enable: out std_logic;
        port_out: out std_logic_vector(1 downto 0);
        hit: in std_logic;
        
        -- Other signals for packet processing
        packet_valid: in std_logic;
        packet_type: in std_logic_vector(1 downto 0)
    );
end control_logic;

architecture arch_control_logic of control_logic is
    -- State machine states
    type state_type is (IDLE, LEARNING, FORWARD, BROADCAST);
    signal state, next_state : state_type;

    -- Signals for controlling MAC table interactions
    signal learning_mac_addr: std_logic_vector(47 downto 0);
    signal learning_port: std_logic_vector(1 downto 0);

begin
    -- State machine process
    process(clk, rst)
    begin
        if(rst = '1')then
            state <= IDLE;
        elsif(rising_edge(clk)) then
            state <= next_state;
        end if;
    end process;

    -- State machine logic
    process(state, packet_valid, hit, packet_type)
    begin
        -- Default values for control signals
        write_enable <= '0';
        lookup_enable <= '0';
        port_out <= (others => '0');
        
        case(state) is
            -- Idle state, waiting for a packet
            when IDLE =>
                if(packet_valid = '1') then
                    if packet_type = "00" then -- Unicast packet
                        next_state <= FORWARD;
                    elsif packet_type = "01" then  -- Broadcast packet
                        next_state <= BROADCAST;
                    else  -- Handle other types
                        next_state <= IDLE;
                    end if;
                else
                    next_state <= IDLE;
                end if;
            -- Learning state, learning new MAC address
            when LEARNING =>
                if(packet_valid) = '1' then
                    -- Enable writing MAC address to the table
                    write_enable <= '1';
                    learning_mac_addr <= mac_addr_in;
                    learning_port <= port_in;
                    next_state <= IDLE;
                else
                    next_state <= IDLE;
                end if;
            -- Forwarding state, unicast packet forwarding
            when FORWARD =>
                if(hit = '1') then
                    -- If the MAC address is found, forward to the corresponding port
                    port_out <= port_in;  -- Port number from MAC address table
                    next_state <= IDLE;
                else
                    -- If MAC address is not found, learn it
                    next_state <= LEARNING;
                end if;
            -- Broadcast state, broadcast packet to all ports
            when BROADCAST =>
                for i in 0 to 3 loop  -- Iterate over all ports (0 to 3)
                    if(std_logic_vector(to_unsigned(i, 2)) /= port_in) then
                    -- Send to all ports except the input port
                        port_out <= std_logic_vector(to_unsigned(i, 2));
                    end if;
                end loop;
                next_state <= IDLE;
            -- In any other state
            when others =>
                next_state <= IDLE;
        end case;
    end process;

end arch_control_logic;
