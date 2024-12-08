LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ClockFSM IS
    PORT (
        clockIn : IN STD_LOGIC;
        clockSet : IN STD_LOGIC;
        clockRun : IN STD_LOGIC;
        format12 : IN STD_LOGIC;

        hourIn : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        minIn : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        secIn : IN STD_LOGIC_VECTOR (4 DOWNTO 0);

        runStatus : OUT STD_LOGIC;
        formatStatus : OUT STD_LOGIC;
        meridiemStatus : OUT STD_LOGIC;

        hourOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        minOut : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        secOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
    );
END ClockFSM;

ARCHITECTURE fsm OF ClockFSM IS
    TYPE state_type IS (IDLE, SET, RUN);
    SIGNAL state, next_state : state_type;
    SIGNAL hourBuffer : unsigned (4 DOWNTO 0);
    SIGNAL minBuffer : unsigned (5 DOWNTO 0);
    SIGNAL secBuffer : unsigned (4 DOWNTO 0);
    SIGNAL am_pm : STD_LOGIC;
BEGIN
    PROCESS (clockIn)
    BEGIN
        IF rising_edge(clockIn) THEN
            state <= next_state;
        END IF;
    END PROCESS;

    PROCESS (state, clockSet, clockRun, hourIn, minIn, secIn, hourBuffer, minBuffer, secBuffer)
    BEGIN
        CASE state IS
            WHEN IDLE =>
                IF clockSet = '1' THEN
                    next_state <= SET;
                ELSIF clockRun = '1' THEN
                    next_state <= RUN;
                ELSE
                    next_state <= IDLE;
                END IF;
            WHEN SET =>
                hourBuffer <= unsigned(hourIn);
                minBuffer <= unsigned(minIn);
                secBuffer <= unsigned(secIn);
                next_state <= IDLE;
            WHEN RUN =>
                IF secBuffer = 59 THEN
                    secBuffer <= (OTHERS => '0');
                    IF minBuffer = 59 THEN
                        minBuffer <= (OTHERS => '0');
                        IF hourBuffer = 23 THEN
                            hourBuffer <= (OTHERS => '0');
                        ELSE
                            hourBuffer <= hourBuffer + 1;
                        END IF;
                    ELSE
                        minBuffer <= minBuffer + 1;
                    END IF;
                ELSE
                    secBuffer <= secBuffer + 1;
                END IF;
                next_state <= RUN;
            WHEN OTHERS =>
                next_state <= IDLE;
        END CASE;
    END PROCESS;

    PROCESS (hourBuffer, format12)
    BEGIN
        IF format12 = '1' THEN
            IF hourBuffer = 0 THEN
                hourOut <= STD_LOGIC_VECTOR(to_unsigned(12, 5));
                am_pm <= '0'; -- AM
            ELSIF hourBuffer < 12 THEN
                hourOut <= STD_LOGIC_VECTOR(hourBuffer);
                am_pm <= '0'; -- AM
            ELSIF hourBuffer = 12 THEN
                hourOut <= STD_LOGIC_VECTOR(hourBuffer);
                am_pm <= '1'; -- PM
            ELSE
                hourOut <= STD_LOGIC_VECTOR(hourBuffer - 12);
                am_pm <= '1'; -- PM
            END IF;
        ELSE
            hourOut <= STD_LOGIC_VECTOR(hourBuffer);
            am_pm <= '0'; -- Placeholder for 24-hour format
        END IF;
    END PROCESS;

    minOut <= STD_LOGIC_VECTOR(minBuffer);
    secOut <= STD_LOGIC_VECTOR(secBuffer);

    runStatus <= clockRun;
    formatStatus <= format12;
    meridiemStatus <= am_pm;
END fsm;