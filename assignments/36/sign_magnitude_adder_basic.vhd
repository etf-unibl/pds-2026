-----------------------------------------------------------------------------
--
-- unit name:     sign_magnitude_adder_basic
--
-- description:
--
--   This file implements the basic realization of a sign magnitude adder.
--   It calculates the result of signed addition based on values of MSB of addends.
--   It uses one adder, two subtractors and a magnitude comparator. If both numbers
--   have the same sign magnitudes will be added one to another. Otherwise smaller
--   magnitude will be subtracted from the larger and sign of larger magnitude will be kept.
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

--! @file sign_magnitude_adder_basic.vhd
--! @brief Basic sign magnitude adder

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Basic sign magnitude adder
--! @details This entity implements a sign magnitude adder with sum module
--! and two subtraction modules.

entity sign_magnitude_adder_basic is
  port (
    a_i   : in    std_logic_vector(7 downto 0);  --! first 8 bit addend
    b_i   : in    std_logic_vector(7 downto 0);  --! second 8 bit addend
    sum_o : out   std_logic_vector(8 downto 0)); --! 9 bit sum
end entity sign_magnitude_adder_basic;

--! @brief Architecture using adder, two subtractors and magnitude comparator
--! @details Architecture contains adder, two subtractors and magnitude comparator
--! @image html 36_basic_rtl.png "RTL view of the basic realization" width=600

architecture arch of sign_magnitude_adder_basic is

begin

  --! @brief Sign magnitude adder process
  --! @details Process contains magnitude comparator which determines which
  --! operation will be executed.

  sign_magnitude_adder_process : process(a_i, b_i) is

    variable mag_a       : unsigned(6 downto 0); -- unsigned value of a_i
    variable mag_b       : unsigned(6 downto 0); -- unsigned value of b_i
    variable add_mag     : unsigned(7 downto 0); -- result of addition
    variable a_sub_b     : unsigned(6 downto 0); -- result of |a| - |b|
    variable b_sub_a     : unsigned(6 downto 0); -- result of |b| - |a|
    variable result_mag  : unsigned(7 downto 0); -- output magnitude
    variable result_sign : std_logic;            -- output sign

  begin

    -- input conversion std_logic_vector -> unsigned
    mag_a := unsigned(a_i(6 downto 0));
    mag_b := unsigned(b_i(6 downto 0));

    add_mag := resize(mag_a, 8) + resize(mag_b, 8);        -- adder
    a_sub_b := mag_a - mag_b;                              -- subtractor |a| - |b|
    b_sub_a := mag_b - mag_a;                              -- subtractor |b| - |a|

    -- magnitude comparator with adder and two subtractors.
    -- If signs are matching, result_mag will be result of addition,
    -- if magnitude of first number is larger than of second number,
    -- result_mag will be result of |a| - |b|, otherwise result_mag is |b| - |a|,
    -- Sign will always have a value of larger magnitude.

    if a_i(7) = b_i(7) then
      result_mag  := add_mag;
      result_sign := a_i(7);
    elsif mag_a > mag_b then
      result_mag  := resize(a_sub_b, 8);
      result_sign := a_i(7);
    else
      result_mag  := resize(b_sub_a, 8);
      result_sign := b_i(7);
    end if;

    -- If result_mag equals 0 output is "000000000", otherwise it is concatenation of
    -- result_sign and result_mag.
    if result_mag = 0 then
      sum_o <= (others => '0');
    else
      sum_o <= result_sign & std_logic_vector(result_mag);
    end if;

  end process sign_magnitude_adder_process;

end architecture arch;
