library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ClockFSM is
    port(
        clockIn  : in std_logic;
        clockSet : in std_logic;
        clockRun : in std_logic;
        format12 : in std_logic;

        hourIn : in std_logic_vector (4 downto 0);
        minIn  : in std_logic_vector (5 downto 0);
        secIn  : in std_logic_vector (4 downto 0);

        runStatus      : out std_logic;
        formatStatus   : out std_logic;
        meridiemStatus : out std_logic;

        hourOut : out std_logic_vector (4 downto 0);
        minOut  : out std_logic_vector (5 downto 0);
        secOut  : out std_logic_vector (4 downto 0)
    );
end ClockFSM;

architecture fsm of ClockFSM is

    type state_type is (IDLE, SET, RUN);
    signal state, next_state : state_type;

    signal hourBuffer : unsigned (4 downto 0);
    signal minBuffer  : unsigned (5 downto 0);
    signal secBuffer  : unsigned (4 downto 0);
    signal am_pm      : std_logic;

begin

    process(clockIn)
    begin
        if rising_edge(clockIn) then
            state <= next_state;
        end if;
    end process;

    process(state, clockSet, clockRun, hourIn, minIn, secIn, hourBuffer, minBuffer, secBuffer)
    begin
        case state is
            when IDLE =>
                if clockSet = '1' then
                    next_state <= SET;
                elsif clockRun = '1' then
                    next_state <= RUN;
                else
                    next_state <= IDLE;
                end if;

            when SET =>
                hourBuffer <= unsigned(hourIn);
                minBuffer  <= unsigned(minIn);
                secBuffer  <= unsigned(secIn);
                next_state <= IDLE;

            when RUN =>
                if secBuffer = 59 then
                    secBuffer <= (others => '0');
                    if minBuffer = 59 then
                        minBuffer <= (others => '0');
                        if hourBuffer = 23 then
                            hourBuffer <= (others => '0');
                        else
                            hourBuffer <= hourBuffer + 1;
                        end if;
                    else
                        minBuffer <= minBuffer + 1;
                    end if;
                else
                    secBuffer <= secBuffer + 1;
                end if;
                next_state <= RUN;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    process(hourBuffer, format12)
    begin
        if format12 = '1' then
            if hourBuffer = 0 then
                hourOut <= std_logic_vector(to_unsigned(12, 5));
                am_pm <= '0'; -- AM
            elsif hourBuffer < 12 then
                hourOut <= std_logic_vector(hourBuffer);
                am_pm <= '0'; -- AM
            elsif hourBuffer = 12 then
                hourOut <= std_logic_vector(hourBuffer);
                am_pm <= '1'; -- PM
            else
                hourOut <= std_logic_vector(hourBuffer - 12);
                am_pm <= '1'; -- PM
            end if;
        else
            hourOut <= std_logic_vector(hourBuffer);
            am_pm <= '0'; -- Placeholder for 24-hour format
        end if;
    end process;

    minOut  <= std_logic_vector(minBuffer);
    secOut  <= std_logic_vector(secBuffer);

    runStatus      <= clockRun;
    formatStatus   <= format12;
    meridiemStatus <= am_pm;

end fsm;

