-----------------------------------------------------------------------------
--
-- unit name:     sign_magnitude_adder
--
-- description:
--
--   This file implements the basic realization of a sign magnitude adder.
--   It optimises result of signed addition based on values of MSB of addends.
--   It uses two adders, two comparators, eight MUXs and xor circuit.
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
--! with sum-subtraction module.

entity sign_magnitude_adder is
  port (
    a_i   : in    std_logic_vector(7 downto 0);  --! first 8 bit addend
    b_i   : in    std_logic_vector(7 downto 0);  --! second 8 bit addend
    sum_o : out   std_logic_vector(8 downto 0)); --! 9 bit sum
end entity sign_magnitude_adder;

architecture arch of sign_magnitude_adder is

--! @brief Architecture using adder-subtraction module
--! @details Architecture contains sum-subtraction module and magnitude comparator
--! @image html 36_rtl.png "RTL view of the optimised realization" width=600
--! @image html 36_waveform.png "Sample of simulation of both realizations" width=100%
--! Resource usage from the Quartus Flow Summary:
--!
--! | Resource   | Basic | Optimized |
--! |------------|------:|----------:|
--! | ALMs       |    23 |        14 |
--! | Registers  |     0 |         0 |
--! | DSP blocks |     0 |         0 |
--!
--! - difference: 9 ALMs (39% less than the basic realization)
--! - removed: one adder, and nine MUX-es.
--! -the savings are in combinational logic, neither realization uses Registers

begin

  sign_magnitude_adder_process : process(a_i, b_i) is

    variable mag_a_s        : unsigned(7 downto 0); --! unsigned value of a_i
    variable mag_b_s        : unsigned(7 downto 0); --! unsigned value of b_i
    variable lhs_s          : unsigned(7 downto 0); --! left hand value
    variable rhs_s          : unsigned(7 downto 0); --! right hand value
    variable arith_result_s : unsigned(7 downto 0); --! adder-subtractor output
    variable result_sign_s  : std_logic;            --! output sign
    variable is_adding_s    : boolean;              --! operation flag

  begin

    --! input conversion std_logic_vector -> unsigned
    mag_a_s := resize(unsigned(a_i(6 downto 0)), 8);
    mag_b_s := resize(unsigned(b_i(6 downto 0)), 8);

    --! @brief magnitude comparator with adder-subtractor module.
    --! @details If signs are matching, addition will be exicuted.
    --! if magnitude of first number is larger than of second number,
    --! left hand value will be the first number, and addition will be exicuted
    --! otherwise left hand value will be second number.
    --! Sign will always have value of larger magnitude.

    if a_i(7) = b_i(7) then
      lhs_s         := mag_a_s;
      rhs_s         := mag_b_s;
      is_adding_s   := true;
      result_sign_s := a_i(7);
    elsif mag_a_s >= mag_b_s then
      lhs_s         := mag_a_s;
      rhs_s         := mag_b_s;
      is_adding_s   := false;
      result_sign_s := a_i(7);
    else
      lhs_s         := mag_b_s;
      rhs_s         := mag_a_s;
      is_adding_s   := false;
      result_sign_s := b_i(7);
    end if;

    --! If is_adding_s is false, subtraction will be done, else addition.
    if is_adding_s then
      arith_result_s := lhs_s + rhs_s;
    else
      arith_result_s := lhs_s - rhs_s;
    end if;

    --! If arith_result_s  equals 0 output is "000000000", otherwise it is concatenation of
    --! result_sign_s and arith_result_s .
    if arith_result_s = 0 then
      sum_o <= '0' & std_logic_vector(to_unsigned(0, 8));
    else
      sum_o <= result_sign_s & std_logic_vector(arith_result_s);
    end if;

  end process sign_magnitude_adder_process;

end architecture arch;
