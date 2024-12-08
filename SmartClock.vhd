LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Define the top-level entity
ENTITY SmartClock IS
    PORT (
        -- Inputs
        clockIn : IN STD_LOGIC;
        clockSet : IN STD_LOGIC;
        clockRun : IN STD_LOGIC;
        format12 : IN STD_LOGIC;

        hourIn : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        minIn : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        secIn : IN STD_LOGIC_VECTOR (4 DOWNTO 0);

        inGMTHours : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        inGMTMins : IN STD_LOGIC_VECTOR (5 DOWNTO 0);

        numIn_a : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        numIn_b : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

        -- Outputs
        doneStatus : OUT STD_LOGIC;

        hourOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        minOut : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        secOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);

        runStatus : OUT STD_LOGIC;
        formatStatus : OUT STD_LOGIC;
        meridiemStatus : OUT STD_LOGIC;

        numOut : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END SmartClock;

ARCHITECTURE Behavioral OF SmartClock IS
    -- Signals for internal connections
    SIGNAL timer_doneStatus : STD_LOGIC;
    SIGNAL timer_hourOut : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL timer_minOut : STD_LOGIC_VECTOR (5 DOWNTO 0);
    SIGNAL timer_secOut : STD_LOGIC_VECTOR (4 DOWNTO 0);

    SIGNAL calc_hourOut : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL calc_minOut : STD_LOGIC_VECTOR (5 DOWNTO 0);
    SIGNAL calc_secOut : STD_LOGIC_VECTOR (4 DOWNTO 0);

    SIGNAL clock_hourOut : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL clock_minOut : STD_LOGIC_VECTOR (5 DOWNTO 0);
    SIGNAL clock_secOut : STD_LOGIC_VECTOR (4 DOWNTO 0);

    SIGNAL calculator_numOut : STD_LOGIC_VECTOR (7 DOWNTO 0);
BEGIN
    -- Timer Converter
    TimerConverter_inst : ENTITY work.TimeConverter
        PORT MAP(
            startOp => clockRun,
            inGMTHours => inGMTHours,
            inGMTMins => inGMTMins,
            hourIn => hourIn,
            minIn => minIn,
            secIn => secIn,
            doneStatus => timer_doneStatus,
            outGMTHours => OPEN, -- Unused
            outGMTMins => OPEN, -- Unused
            hourOut => timer_hourOut,
            minOut => timer_minOut,
            secOut => timer_secOut
        );
    -- Time Calculator
    TimeCalculator_inst : ENTITY work.TimeCalculator
        PORT MAP(
            startOp => clockRun,
            -- Example: 0 for subtraction, 1 for addition
            opCode => '0',
            hourIn_a => hourIn,
            minIn_a => minIn,
            secIn_a => secIn,
            hourIn_b => hourIn,
            minIn_b => minIn,
            secIn_b => secIn,
            hourOut => calc_hourOut,
            minOut => calc_minOut,
            secOut => calc_secOut
        );
    -- Clock FSM
    ClockFSM_inst : ENTITY work.ClockFSM
        PORT MAP(
            clockIn => clockIn,
            clockSet => clockSet,
            clockRun => clockRun,
            format12 => format12,
            hourIn => hourIn,
            minIn => minIn,
            secIn => secIn,
            runStatus => runStatus,
            formatStatus => formatStatus,
            meridiemStatus => meridiemStatus,
            hourOut => clock_hourOut,
            minOut => clock_minOut,
            secOut => clock_secOut
        );
    -- Calculator
    Calculator_inst : ENTITY work.Calculator
        PORT MAP(
            startOp => clockRun,
            -- Example: 1 for addition, 0 for subtraction
            opCode => '1',
            numIn_a => numIn_a,
            numIn_b => numIn_b,
            numOut => numOut
        );
    -- Choose which output to drive based on requirements
    PROCESS (timer_doneStatus, clockRun)
    BEGIN
        IF clockRun = '1' THEN
            -- Output the result of the Clock FSM
            hourOut <= clock_hourOut;
            minOut <= clock_minOut;
            secOut <= clock_secOut;
        ELSIF timer_doneStatus = '1' THEN
            -- Output the result from the TimeConverter
            hourOut <= timer_hourOut;
            minOut <= timer_minOut;
            secOut <= timer_secOut;
        ELSE
            -- Default or error state
            hourOut <= (OTHERS => '0');
            minOut <= (OTHERS => '0');
            secOut <= (OTHERS => '0');
        END IF;
    END PROCESS;
END Behavioral;