library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TimeConverter is
    port (
        startOp : in std_logic;

        inGMTHours  : in std_logic_vector (4 downto 0);
        inGMTMins   : in std_logic_vector (5 downto 0);
        hourIn      : in std_logic_vector (4 downto 0);
        minIn       : in std_logic_vector (5 downto 0);
        secIn       : in std_logic_vector (4 downto 0);

        doneStatus  : out std_logic;

        outGMTHours : out std_logic_vector (4 downto 0);
        outGMTMins  : out std_logic_vector (5 downto 0);
        hourOut     : out std_logic_vector (4 downto 0);
        minOut      : out std_logic_vector (5 downto 0);
        secOut      : out std_logic_vector (4 downto 0)
    );
end TimeConverter;

architecture Behavioral of TimeConverter is

    signal localHours : signed (4 downto 0);
    signal localMins  : signed (5 downto 0);
    signal gmtHours   : signed (4 downto 0);
    signal gmtMins    : signed (5 downto 0);

begin

    process(startOp)
    begin
        if rising_edge(startOp) then
            -- Convert local time to GMT
            gmtHours <= signed(hourIn) - signed(inGMTHours);
            gmtMins  <= signed(minIn) - signed(inGMTMins);

            -- Adjust for negative minutes
            if gmtMins < 0 then
                gmtMins <= gmtMins + 60;
                gmtHours <= gmtHours - 1;
            end if;

            -- Adjust for negative hours
            if gmtHours < 0 then
                gmtHours <= gmtHours + 24;
            end if;

            -- Output the converted time
            hourOut <= std_logic_vector(gmtHours);
            minOut  <= std_logic_vector(gmtMins);
            secOut  <= secIn;

            -- Set done status
            doneStatus <= '1';
        else
            doneStatus <= '0';
        end if;
    end process;

end Behavioral;

