LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SmartClock_TB IS
END SmartClock_TB;

ARCHITECTURE behavior OF SmartClock_TB IS
    -- Component Declaration
    COMPONENT SmartClock
        PORT (
            clockIn : IN STD_LOGIC;
            clockSet : IN STD_LOGIC;
            clockRun : IN STD_LOGIC;
            format12 : IN STD_LOGIC;
            hourIn : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            minIn : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            secIn : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            inGMTHours : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            inGMTMins : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            numIn_a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            numIn_b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            doneStatus : OUT STD_LOGIC;
            hourOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            minOut : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
            secOut : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            runStatus : OUT STD_LOGIC;
            formatStatus : OUT STD_LOGIC;
            meridiemStatus : OUT STD_LOGIC;
            numOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    -- Input signals
    SIGNAL clockIn : STD_LOGIC := '0';
    SIGNAL clockSet : STD_LOGIC := '0';
    SIGNAL clockRun : STD_LOGIC := '0';
    SIGNAL format12 : STD_LOGIC := '0';
    SIGNAL hourIn : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL minIn : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL secIn : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL inGMTHours : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL inGMTMins : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL numIn_a : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL numIn_b : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    -- Output signals
    SIGNAL doneStatus : STD_LOGIC;
    SIGNAL hourOut : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL minOut : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL secOut : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL runStatus : STD_LOGIC;
    SIGNAL formatStatus : STD_LOGIC;
    SIGNAL meridiemStatus : STD_LOGIC;
    SIGNAL numOut : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Clock period definitions
    CONSTANT clock_period : TIME := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : SmartClock PORT MAP(
        clockIn => clockIn,
        clockSet => clockSet,
        clockRun => clockRun,
        format12 => format12,
        hourIn => hourIn,
        minIn => minIn,
        secIn => secIn,
        inGMTHours => inGMTHours,
        inGMTMins => inGMTMins,
        numIn_a => numIn_a,
        numIn_b => numIn_b,
        doneStatus => doneStatus,
        hourOut => hourOut,
        minOut => minOut,
        secOut => secOut,
        runStatus => runStatus,
        formatStatus => formatStatus,
        meridiemStatus => meridiemStatus,
        numOut => numOut
    );

    -- Clock process
    clock_process : PROCESS
    BEGIN
        clockIn <= '0';
        WAIT FOR clock_period/2;
        clockIn <= '1';
        WAIT FOR clock_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- Initial state
        WAIT FOR 100 ns;

        -- Test 1: Set time to 14:30:00
        clockSet <= '1';
        hourIn <= "01110"; -- 14
        minIn <= "011110"; -- 30
        secIn <= "00000"; -- 00
        WAIT FOR clock_period;
        clockSet <= '0';
        WAIT FOR clock_period * 2;

        -- Test 2: Start clock running
        clockRun <= '1';
        WAIT FOR clock_period * 10;

        -- Test 3: Switch to 12-hour format
        format12 <= '1';
        WAIT FOR clock_period * 2;

        -- Test 4: Test calculator functionality
        numIn_a <= "00000101"; -- 5
        numIn_b <= "00000011"; -- 3
        WAIT FOR clock_period * 2;

        -- Test 5: Test time zone conversion
        inGMTHours <= "00010"; -- GMT+2
        inGMTMins <= "000000";
        WAIT FOR clock_period * 2;

        -- Test 6: Stop clock
        clockRun <= '0';
        WAIT FOR clock_period * 2;

        -- End simulation
        WAIT;
    END PROCESS;

END behavior;