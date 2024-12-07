LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY TimeCalculator IS
    PORT (
        startOp : IN STD_LOGIC;
        opCode : IN STD_LOGIC;

        hourIn_a : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        minIn_a : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        secIn_a : IN STD_LOGIC_VECTOR (4 DOWNTO 0);

        hourIn_b : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        minIn_b : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
        secIn_b : IN STD_LOGIC_VECTOR (4 DOWNTO 0);

        hourOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        minOut : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
        secOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
    );
END TimeCalculator;

ARCHITECTURE Behavioral OF TimeCalculator IS
    SIGNAL hour_a, hour_b, hour_res : UNSIGNED(4 DOWNTO 0);
    SIGNAL min_a, min_b, min_res : UNSIGNED(5 DOWNTO 0);
    SIGNAL sec_a, sec_b, sec_res : UNSIGNED(4 DOWNTO 0);
    SIGNAL total_a, total_b, total_res : INTEGER;
    SIGNAL total_diff : INTEGER;
BEGIN

    -- Convert inputs to unsigned for computation
    hour_a <= UNSIGNED(hourIn_a);
    hour_b <= UNSIGNED(hourIn_b);
    min_a <= UNSIGNED(minIn_a);
    min_b <= UNSIGNED(minIn_b);
    sec_a <= UNSIGNED(secIn_a);
    sec_b <= UNSIGNED(secIn_b);

    -- Combine hours, minutes, and seconds into total seconds
    total_a <= (to_integer(hour_a) * 3600) + (to_integer(min_a) * 60) + to_integer(sec_a);
    total_b <= (to_integer(hour_b) * 3600) + (to_integer(min_b) * 60) + to_integer(sec_b);

    PROCESS (startOp, opCode, total_a, total_b)
    BEGIN
        IF startOp = '1' THEN
            IF opCode = '1' THEN
                -- Perform addition
                total_res <= total_a + total_b;
            ELSE
                -- Perform subtraction and ensure positive result
                IF total_a > total_b THEN
                    total_res <= total_a - total_b;
                ELSE
                    total_res <= total_b - total_a;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Convert total seconds back into hours, minutes, and seconds
    PROCESS (total_res)
    BEGIN
        hour_res <= to_unsigned((total_res / 3600), 5);
        min_res <= to_unsigned(((total_res MOD 3600) / 60), 6);
        sec_res <= to_unsigned((total_res MOD 60), 5);
    END PROCESS;

    -- Output the results
    hourOut <= STD_LOGIC_VECTOR(hour_res);
    minOut <= STD_LOGIC_VECTOR(min_res);
    secOut <= STD_LOGIC_VECTOR(sec_res);
END Behavioral;