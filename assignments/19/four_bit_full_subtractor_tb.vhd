-----------------------------------------------------------------------------
--
-- unit name:     four_bit_full_subtractor_tb
--
-- description:
--
--   This file implements a testbench for simple full subtractor circuit.
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

--! @file
--! @brief four bit full subtractor testbench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Exhaustive testbench for the four-bit full subtractor.
--! @details Has no ports. Reports an error through an assertion on any
--! mismatch, and reports completion after all input combinations pass.

entity four_bit_full_subtractor_tb is
end entity four_bit_full_subtractor_tb;

architecture arch of four_bit_full_subtractor_tb is

  component four_bit_full_subtractor is
    port (
      a_i   : in    std_logic_vector(3 downto 0);
      b_i   : in    std_logic_vector(3 downto 0);
      c_i   : in    std_logic;
      sub_o : out   std_logic_vector(3 downto 0);
      c_o   : out   std_logic);
  end component four_bit_full_subtractor;

  --! DUT input operands.
  signal a_s   : std_logic_vector(3 downto 0);
  signal b_s   : std_logic_vector(3 downto 0);
  signal c_i_s : std_logic;

  --! DUT outputs: difference and final borrow.
  signal sub_s : std_logic_vector(3 downto 0);
  signal c_o_s : std_logic;

begin

  --! Device under test.
  dut : component four_bit_full_subtractor
    port map (
      a_i   => a_s,
      b_i   => b_s,
      c_i   => c_i_s,
      sub_o => sub_s,
      c_o   => c_o_s);

  --! Exhaustively apply every operand and borrow-in combination.
  stimulus : process is

    variable tested_cases        : integer;
    variable arithmetic_result   : integer;
    variable expected_difference : integer;
    variable expected_borrow     : std_logic;

  begin

    tested_cases := 0;

    for a_value in 0 to 15 loop

      for b_value in 0 to 15 loop

        for borrow_in in 0 to 1 loop

          a_s <= std_logic_vector(to_unsigned(a_value, a_s'length));
          b_s <= std_logic_vector(to_unsigned(b_value, b_s'length));

          if borrow_in = 0 then
            c_i_s <= '0';
          else
            c_i_s <= '1';
          end if;

          -- Allow combinational DUT logic to settle.
          wait for 10 ns;

          -- Calculate the mathematical subtraction and wrap the difference
          -- into the range 0..15, as represented by the four-bit output.
          arithmetic_result := a_value - b_value - borrow_in;

          if arithmetic_result < 0 then
            expected_borrow     := '1';
            expected_difference := arithmetic_result + 16;
          else
            expected_borrow     := '0';
            expected_difference := arithmetic_result;
          end if;

          assert sub_s = std_logic_vector(to_unsigned(expected_difference, sub_s'length))
            report "Difference mismatch: a=" & integer'image(a_value) &
                   ", b=" & integer'image(b_value) &
                   ", c_i=" & integer'image(borrow_in) &
                   ", expected=" & integer'image(expected_difference)
            severity error;

          assert c_o_s = expected_borrow
            report "Borrow mismatch: a=" & integer'image(a_value) &
                   ", b=" & integer'image(b_value) &
                   ", c_i=" & integer'image(borrow_in) &
                   ", expected borrow=" & std_logic'image(expected_borrow)
            severity error;

          tested_cases := tested_cases + 1;

        end loop;

      end loop;

    end loop;

    report "PASS: all " & integer'image(tested_cases) &
           " four-bit subtractor input combinations passed."
      severity note;
    wait;

  end process stimulus;

end architecture arch;
