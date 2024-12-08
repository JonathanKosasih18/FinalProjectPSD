LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY TimeConverter IS
    PORT (
        startOp : IN STD_LOGIC;

        inGMTHours : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        inGMTMins : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        hourIn : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        minIn : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        secIn : IN STD_LOGIC_VECTOR (4 DOWNTO 0);

        doneStatus : OUT STD_LOGIC;

        outGMTHours : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        outGMTMins : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        hourOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        minOut : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        secOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
    );
END TimeConverter;

ARCHITECTURE Behavioral OF TimeConverter IS
    SIGNAL localHours : signed (4 DOWNTO 0);
    SIGNAL localMins : signed (5 DOWNTO 0);
    SIGNAL gmtHours : signed (4 DOWNTO 0);
    SIGNAL gmtMins : signed (5 DOWNTO 0);
BEGIN
    PROCESS (startOp)
    BEGIN
        IF rising_edge(startOp) THEN
            -- Convert local time to GMT
            gmtHours <= signed(hourIn) - signed(inGMTHours);
            gmtMins <= signed(minIn) - signed(inGMTMins);
            -- Adjust for negative minutes
            IF gmtMins < 0 THEN
                gmtMins <= gmtMins + 60;
                gmtHours <= gmtHours - 1;
            END IF;
            -- Adjust for negative hours
            IF gmtHours < 0 THEN
                gmtHours <= gmtHours + 24;
            END IF;
            -- Output the converted time
            hourOut <= STD_LOGIC_VECTOR(gmtHours);
            minOut <= STD_LOGIC_VECTOR(gmtMins);
            secOut <= secIn;
            -- Set done status
            doneStatus <= '1';
        ELSE
            doneStatus <= '0';
        END IF;
    END PROCESS;
END Behavioral;