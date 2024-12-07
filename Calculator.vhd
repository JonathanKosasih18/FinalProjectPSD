LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Calculator IS
    PORT (
        startOp : IN STD_LOGIC;
        opCode : IN STD_LOGIC;

        numIn_a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        numIn_b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        numOut : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END Calculator;

ARCHITECTURE Behavioral OF Calculator IS
    SIGNAL num_a, num_b : UNSIGNED(7 DOWNTO 0);
    SIGNAL total_a, total_b, total_res : INTEGER;
BEGIN
    -- Convert inputs to unsigned for computation
    num_a <= UNSIGNED(numIn_a);
    num_b <= UNSIGNED(numIn_b);

    -- Combine numbers into total
    total_a <= to_integer(num_a);
    total_b <= to_integer(num_b);

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

    -- Convert result back to binary for output
    numOut <= STD_LOGIC_VECTOR(TO_UNSIGNED(total_res, 8));

END Behavioral;