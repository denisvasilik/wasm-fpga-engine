library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

package tb_pkg_helper is

    	procedure GetRandInt( variable Seed1 : inout positive;
    						  variable Seed2 : inout positive;
    						  variable LowestValue : in integer;
    						  variable UtmostValue : in integer;
    						  variable RandInt : out integer);

end tb_pkg_helper;

package body tb_pkg_helper is

    	procedure GetRandInt( variable Seed1 : inout positive;
    						  variable Seed2 : inout positive;
    						  variable LowestValue : in integer;
    						  variable UtmostValue : in integer;
    						  variable RandInt : out integer) is
    	variable RandReal : real;
    	variable IntDelta : integer;
    begin
        IntDelta := UtmostValue - LowestValue;
    	uniform(seed1, seed2, RandReal); -- generate random number
        RandInt := integer(trunc(RandReal * (real(IntDelta) + 1.0) )) + LowestValue; -- rescale to delta, find integer part, adjust
    end;

end tb_pkg_helper;
