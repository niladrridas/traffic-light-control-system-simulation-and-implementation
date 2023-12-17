library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TrafficLightController is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           pedestrian_request : in STD_LOGIC;
           red_light : out STD_LOGIC;
           yellow_light : out STD_LOGIC;
           green_light : out STD_LOGIC;
           pedestrian_light : out STD_LOGIC);
end TrafficLightController;

architecture Behavioral of TrafficLightController is
    type TrafficState is (STOP, READY, GO, SLOWDOWN);
    signal current_state, next_state : TrafficState;

    constant CLOCK_FREQ : integer := 50000000;  -- Adjust based on your clock frequency
    constant TICKS_PER_SECOND : integer := 1;   -- For a 1Hz clock

    signal timer_count : integer range 0 to CLOCK_FREQ - 1 := 0;
    signal pedestrian_timer : integer range 0 to CLOCK_FREQ - 1 := 0;

begin
    -- State machine process
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= STOP;
        elsif rising_edge(clk) then
            if timer_count = CLOCK_FREQ - 1 then
                current_state <= next_state;
                timer_count <= 0;
            else
                timer_count <= timer_count + 1;
            end if;
        end if;
    end process;

    -- Traffic light control logic
    process(current_state, pedestrian_request, pedestrian_timer)
    begin
        case current_state is
            when STOP =>
                red_light <= '1';
                yellow_light <= '0';
                green_light <= '0';
                pedestrian_light <= '0';

                if pedestrian_request = '1' then
                    next_state <= READY;
                    pedestrian_timer <= 0;
                else
                    next_state <= STOP;
                end if;

            when READY =>
                red_light <= '1';
                yellow_light <= '1';
                green_light <= '0';
                pedestrian_light <= '0';

                if timer_count = CLOCK_FREQ - 1 then
                    next_state <= GO;
                else
                    next_state <= READY;
                end if;

            when GO =>
                red_light <= '0';
                yellow_light <= '0';
                green_light <= '1';
                pedestrian_light <= '0';

                if timer_count = CLOCK_FREQ - 1 then
                    next_state <= SLOWDOWN;
                else
                    next_state <= GO;
                end if;

            when SLOWDOWN =>
                red_light <= '0';
                yellow_light <= '1';
                green_light <= '0';
                pedestrian_light <= '0';

                if timer_count = CLOCK_FREQ - 1 then
                    next_state <= STOP;
                else
                    next_state <= SLOWDOWN;
                end if;

            when others =>
                next_state <= STOP;
        end case;

        if pedestrian_timer = CLOCK_FREQ - 1 then
            pedestrian_light <= '0';
        else
            pedestrian_timer <= pedestrian_timer + 1;
        end if;

    end process;

end Behavioral;
