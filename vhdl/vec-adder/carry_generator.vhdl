-- CLA generator 4-bit

ENTITY carry_generator IS
    PORT (
        p1, g1, p2, g2, cin : IN STD_LOGIC;
        cout, c : OUT STD_LOGIC
    );
END carry_generator;

ARCHITECTURE behavior OF carry_generator IS

BEGIN
    c <= g1 OR (p1 AND cin);
    cout <= g2 OR (p2 AND c) OR (p1 AND g2 AND cin);
END behavior;