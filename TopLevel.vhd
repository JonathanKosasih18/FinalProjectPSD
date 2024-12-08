library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Define the top-level entity
entity TopLevel is
    port (
        -- Inputs
        clockIn      : in std_logic;
        clockSet     : in std_logic;
        clockRun     : in std_logic;
        format12     : in std_logic;

        hourIn       : in std_logic_vector (4 downto 0);
        minIn        : in std_logic_vector (5 downto 0);
        secIn        : in std_logic_vector (4 downto 0);

        inGMTHours   : in std_logic_vector (4 downto 0);
        inGMTMins    : in std_logic_vector (5 downto 0);

        numIn_a      : in std_logic_vector (7 downto 0);
        numIn_b      : in std_logic_vector (7 downto 0);

        -- Outputs
        doneStatus   : out std_logic;

        hourOut      : out std_logic_vector (4 downto 0);
        minOut       : out std_logic_vector (5 downto 0);
        secOut       : out std_logic_vector (4 downto 0);

        runStatus    : out std_logic;
        formatStatus : out std_logic;
        meridiemStatus : out std_logic;

        numOut       : out std_logic_vector (7 downto 0)
    );
end TopLevel;

architecture Behavioral of TopLevel is

    -- Signals for internal connections
    signal timer_doneStatus : std_logic;
    signal timer_hourOut    : std_logic_vector (4 downto 0);
    signal timer_minOut     : std_logic_vector (5 downto 0);
    signal timer_secOut     : std_logic_vector (4 downto 0);

    signal calc_hourOut     : std_logic_vector (4 downto 0);
    signal calc_minOut      : std_logic_vector (5 downto 0);
    signal calc_secOut      : std_logic_vector (4 downto 0);

    signal clock_hourOut    : std_logic_vector (4 downto 0);
    signal clock_minOut     : std_logic_vector (5 downto 0);
    signal clock_secOut     : std_logic_vector (4 downto 0);

    signal calculator_numOut : std_logic_vector (7 downto 0);

begin

    -- Timer Converter
    TimerConverter_inst : entity work.TimeConverter
        port map (
            startOp        => clockRun,
            inGMTHours     => inGMTHours,
            inGMTMins      => inGMTMins,
            hourIn         => hourIn,
            minIn          => minIn,
            secIn          => secIn,
            doneStatus     => timer_doneStatus,
            outGMTHours    => open,  -- Unused
            outGMTMins     => open,  -- Unused
            hourOut        => timer_hourOut,
            minOut         => timer_minOut,
            secOut         => timer_secOut
        );

    -- Time Calculator
    TimeCalculator_inst : entity work.TimeCalculator
        port map (
            startOp        => clockRun,
            opCode         => '0',  -- Example: 0 for subtraction, 1 for addition
            hourIn_a       => hourIn,
            minIn_a        => minIn,
            secIn_a        => secIn,
            hourIn_b       => hourIn,
            minIn_b        => minIn,
            secIn_b        => secIn,
            hourOut        => calc_hourOut,
            minOut         => calc_minOut,
            secOut         => calc_secOut
        );

    -- Clock FSM
    ClockFSM_inst : entity work.ClockFSM
        port map (
            clockIn        => clockIn,
            clockSet       => clockSet,
            clockRun       => clockRun,
            format12       => format12,
            hourIn         => hourIn,
            minIn          => minIn,
            secIn          => secIn,
            runStatus      => runStatus,
            formatStatus   => formatStatus,
            meridiemStatus => meridiemStatus,
            hourOut        => clock_hourOut,
            minOut         => clock_minOut,
            secOut         => clock_secOut
        );

    -- Calculator
    Calculator_inst : entity work.Calculator
        port map (
            startOp        => clockRun,
            opCode         => '1',  -- Example: 1 for addition, 0 for subtraction
            numIn_a        => numIn_a,
            numIn_b        => numIn_b,
            numOut         => numOut
        );

    -- Choose which output to drive based on requirements
    process(timer_doneStatus, clockRun)
    begin
        if clockRun = '1' then
            -- Output the result of the Clock FSM
            hourOut <= clock_hourOut;
            minOut  <= clock_minOut;
            secOut  <= clock_secOut;
        elsif timer_doneStatus = '1' then
            -- Output the result from the TimeConverter
            hourOut <= timer_hourOut;
            minOut  <= timer_minOut;
            secOut  <= timer_secOut;
        else
            -- Default or error state
            hourOut <= (others => '0');
            minOut  <= (others => '0');
            secOut  <= (others => '0');
        end if;
    end process;

end Behavioral;
