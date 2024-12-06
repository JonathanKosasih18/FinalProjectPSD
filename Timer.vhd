library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TimerFSM is 
    port (
        clockIn    : in std_logic;
        setTimer   : in std_logic;
        startTimer : in std_logic;

        hourIn : in std_logic_vector (4 downto 0);
        minIn  : in std_logic_vector (5 downto 0);
        secIn  : in std_logic_vector (4 downto 0);

        doneStatus : out std_logic;

        hourOut : out std_logic_vector (4 downto 0);
        minOut  : out std_logic_vector (5 downto 0);
        secOut  : out std_logic_vector (4 downto 0)
    );
end TimerFSM;

architecture fsm of TimerFSM is 

    type state_type is (IDLE, SET, RUN, DONE);
    signal state, next_state : state_type;

    signal hourBuffer : signed (4 downto 0);
    signal minBuffer  : signed (5 downto 0);
    signal secBuffer  : signed (4 downto 0);

begin

    process(clockIn)
    begin
        if rising_edge(clockIn) then
            state <= next_state;
        end if;
    end process;

    process(state, setTimer, startTimer, hourIn, minIn, secIn, hourBuffer, minBuffer, secBuffer)
    begin
        case state is
            when IDLE =>
                if setTimer = '1' then
                    next_state <= SET;
                elsif startTimer = '1' then
                    next_state <= RUN;
                else
                    next_state <= IDLE;
                end if;

            when SET =>
                hourBuffer <= signed(hourIn);
                minBuffer  <= signed(minIn);
                secBuffer  <= signed(secIn);
                next_state <= IDLE;

            when RUN =>
                if secBuffer = to_signed(0, secBuffer'length) then
                    secBuffer <= to_signed(59, secBuffer'length);
                    if minBuffer = to_signed(0, minBuffer'length) then
                        minBuffer <= to_signed(59, minBuffer'length);
                        if hourBuffer = to_signed(0, hourBuffer'length) then
                            next_state <= DONE;
                        else
                            hourBuffer <= hourBuffer - 1;
                        end if;
                    else
                        minBuffer <= minBuffer - 1;
                    end if;
                else
                    secBuffer <= secBuffer - 1;
                end if;
                next_state <= RUN;

            when DONE =>
                doneStatus <= '1';
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    process(hourBuffer, minBuffer, secBuffer)
    begin
        if state /= DONE then
            doneStatus <= '0';
        end if;
    end process;

    hourOut <= std_logic_vector(hourBuffer);
    minOut  <= std_logic_vector(minBuffer);
    secOut  <= std_logic_vector(secBuffer);

end fsm;

