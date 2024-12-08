LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY TimerFSM IS
    PORT (
        clockIn : IN STD_LOGIC;
        setTimer : IN STD_LOGIC;
        startTimer : IN STD_LOGIC;

        hourIn : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        minIn : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        secIn : IN STD_LOGIC_VECTOR (4 DOWNTO 0);

        doneStatus : OUT STD_LOGIC;

        hourOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        minOut : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        secOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
    );
END TimerFSM;

ARCHITECTURE fsm OF TimerFSM IS
    TYPE state_type IS (IDLE, SET, RUN, DONE);
    SIGNAL state, next_state : state_type;
    SIGNAL hourBuffer : signed (4 DOWNTO 0);
    SIGNAL minBuffer : signed (5 DOWNTO 0);
    SIGNAL secBuffer : signed (4 DOWNTO 0);

BEGIN
    PROCESS (clockIn)
    BEGIN
        IF rising_edge(clockIn) THEN
            state <= next_state;
        END IF;
    END PROCESS;

    PROCESS (state, setTimer, startTimer, hourIn, minIn, secIn, hourBuffer, minBuffer, secBuffer)
    BEGIN
        CASE state IS
            WHEN IDLE =>
                IF setTimer = '1' THEN
                    next_state <= SET;
                ELSIF startTimer = '1' THEN
                    next_state <= RUN;
                ELSE
                    next_state <= IDLE;
                END IF;
            WHEN SET =>
                hourBuffer <= signed(hourIn);
                minBuffer <= signed(minIn);
                secBuffer <= signed(secIn);
                next_state <= IDLE;
            WHEN RUN =>
                IF secBuffer = to_signed(0, secBuffer'length) THEN
                    secBuffer <= to_signed(59, secBuffer'length);
                    IF minBuffer = to_signed(0, minBuffer'length) THEN
                        minBuffer <= to_signed(59, minBuffer'length);
                        IF hourBuffer = to_signed(0, hourBuffer'length) THEN
                            next_state <= DONE;
                        ELSE
                            hourBuffer <= hourBuffer - 1;
                        END IF;
                    ELSE
                        minBuffer <= minBuffer - 1;
                    END IF;
                ELSE
                    secBuffer <= secBuffer - 1;
                END IF;
                next_state <= RUN;
            WHEN DONE =>
                doneStatus <= '1';
                next_state <= IDLE;
            WHEN OTHERS =>
                next_state <= IDLE;
        END CASE;
    END PROCESS;

    PROCESS (hourBuffer, minBuffer, secBuffer)
    BEGIN
        IF state /= DONE THEN
            doneStatus <= '0';
        END IF;
    END PROCESS;

    hourOut <= STD_LOGIC_VECTOR(hourBuffer);
    minOut <= STD_LOGIC_VECTOR(minBuffer);
    secOut <= STD_LOGIC_VECTOR(secBuffer);
END fsm;