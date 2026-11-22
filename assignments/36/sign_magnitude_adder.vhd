-----------------------------------------------------------------------------
--
-- unit name:     sign_magnitude_adder
--
-- description:
--
--   This file implements the optimised realization of a sign magnitude adder.
--   It uses one adder-subtractor and one magnitude comparator.
--   If sign addends is equeal, addition of magnitudes will be calculated.
--   Otherwise subtraction will be calculated using the two's complement method on a smaller magnitude.
--
-----------------------------------------------------------------------------
-- The MIT License
-----------------------------------------------------------------------------
-- Copyright (c) 2026 Faculty of Electrical Engineering
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE
-----------------------------------------------------------------------------

--! @file sign_magnitude_adder.vhd
--! @brief Optimised sign magnitude adder

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Optimised sign magnitude adder
--! @details This entity implements a sign magnitude adder
--! with a sum-subtraction module.

entity sign_magnitude_adder is
  port (
    a_i   : in    std_logic_vector(7 downto 0);  --! first 8 bit addend
    b_i   : in    std_logic_vector(7 downto 0);  --! second 8 bit addend
    sum_o : out   std_logic_vector(8 downto 0)); --! 9 bit sum
end entity sign_magnitude_adder;

--! @brief Architecture using adder-subtraction module
--! @details Architecture contains sum-subtraction module and magnitude comparator
--! @image html 36_rtl.png "RTL view of the optimised realization" width=600
--! @image html 36_waveform.png "Sample of simulation of both realizations" width=100%
--! Resource usage from the Quartus Flow Summary:
--!
--! | Resource   | Basic | Optimised |
--! |------------|------:|----------:|
--! | ALMs       |    22 |        12 |
--! | Registers  |     0 |         0 |
--! | DSP blocks |     0 |         0 |
--!
--! - difference: 10 ALMs (45% less than the basic realization)
--! - removed: two subtractors and an adder
--! - added: adder-subtractor
--! - the savings are in combinational logic, neither realization uses Registers

architecture arch of sign_magnitude_adder is

begin

  --! @brief Sign magnitude adder process
  --! @details Process contains sum-subtraction logic and magnitude comparator
  --! which sets values for sum-subtractor module.

  sign_magnitude_adder_process : process(a_i, b_i) is

    variable mag_a       : unsigned(6 downto 0); -- unsigned value of a_i
    variable mag_b       : unsigned(6 downto 0); -- unsigned value of b_i
    variable lhs         : unsigned(6 downto 0); -- left hand value
    variable rhs         : unsigned(6 downto 0); -- right hand value
    variable srcone      : unsigned(8 downto 0); -- adder-subtractor input
    variable srctwo      : unsigned(8 downto 0); -- adder-subtractor input
    variable sum         : unsigned(8 downto 0); -- adder-subtractor output
    variable result_sign : std_logic;            -- output sign
    variable is_adding   : boolean;              -- operation flag

  begin

    -- input conversion std_logic_vector -> unsigned
    mag_a := unsigned(a_i(6 downto 0));
    mag_b := unsigned(b_i(6 downto 0));

    -- magnitude comparator with adder-subtractor module.
    -- If signs are matching, addition will be executed.
    -- if magnitude of first number is larger than of second number,
    -- left hand value will be the first number, and subtraction will be executed
    -- otherwise the left hand value will be the second number.
    -- Sign will always have a value of larger magnitude.

    if a_i(7) = b_i(7) then
      lhs         := mag_a;
      rhs         := mag_b;
      is_adding   := true;
      result_sign := a_i(7);
    elsif mag_a >= mag_b then
      lhs         := mag_a;
      rhs         := mag_b;
      is_adding   := false;
      result_sign := a_i(7);
    else
      lhs         := mag_b;
      rhs         := mag_a;
      is_adding   := false;
      result_sign := b_i(7);
    end if;

    -- srcone and srctwo are appended so subtraction can be done using the two's complement method.
    -- srcone will always be appended the same way. srctwo will be appended depending is_adding variable
    srcone := unsigned('0' & std_logic_vector(lhs) & '1');

    -- If is_adding is false, the second number will be transformed into a negative counterpart.
    if is_adding then
      srctwo := unsigned('0' & std_logic_vector(rhs) & '0');
    else
      srctwo := unsigned('1' & std_logic_vector(not rhs) & '1');
    end if;

    -- subtraction is calculated: sum = lhs + not rhs + 1, sum is calculated: sum = lhs + rhs
    sum := srcone + srctwo;

    -- If sum(8 downto 1) equals x00 output is "000000000", otherwise it is concatenation of
    -- result_sign and sum(8 downto 1).
    if sum(8 downto 1) = x"00" then
      sum_o <= (others => '0');
    else
      sum_o <= result_sign & std_logic_vector(sum(8 downto 1));
    end if;

  end process sign_magnitude_adder_process;

end architecture arch;
