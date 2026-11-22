-----------------------------------------------------------------------------
--
-- unit name:     sign_magnitude_adder_tb
--
-- description:
--
--   This file implements the test bench for both basic and optimised
--   sign magnitude adders.
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
--! @file sign_magnitude_adder_tb.vhd
--! @brief Sign magnitude adder testbench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Testbench entity for basic and optimized sign-magnitude adders.
--! @details Tests every combination of the two 8-bit input operands and
--! checks both DUT outputs against the mathematically expected result.

entity sign_magnitude_adder_tb is
end entity sign_magnitude_adder_tb;

--! @brief Test architecture for sign-magnitude adders.
--! @details The test process checks all 65,536 input pairs. It uses no helper
--! procedures or functions; the expected sum is calculated directly in the
--! process. A zero result is checked in its canonical positive representation.

architecture arch of sign_magnitude_adder_tb is

  signal a_i       : std_logic_vector(7 downto 0);
  signal b_i       : std_logic_vector(7 downto 0);
  signal sum_basic : std_logic_vector(8 downto 0);
  signal sum_optim : std_logic_vector(8 downto 0);

  component sign_magnitude_adder is
    port (
      a_i   : in    std_logic_vector(7 downto 0);
      b_i   : in    std_logic_vector(7 downto 0);
      sum_o : out   std_logic_vector(8 downto 0));
  end component sign_magnitude_adder;

  component sign_magnitude_adder_basic is
    port (
      a_i   : in    std_logic_vector(7 downto 0);
      b_i   : in    std_logic_vector(7 downto 0);
      sum_o : out   std_logic_vector(8 downto 0));
  end component sign_magnitude_adder_basic;

begin

  --! @brief Instance of the basic sign-magnitude adder.
  dut_basic : component sign_magnitude_adder_basic
    port map (
      a_i   => a_i,
      b_i   => b_i,
      sum_o => sum_basic);

  --! @brief Instance of the optimized sign-magnitude adder.
  dut_optimized : component sign_magnitude_adder
    port map (
      a_i   => a_i,
      b_i   => b_i,
      sum_o => sum_optim);

  --! @brief Exhaustive stimulus and checking process.
  --! @details The integer loops enumerate all 256 encodings for each input.
  --! Each pair is applied, allowed to settle, then checked against a reference
  --! result computed directly from its sign bits and magnitude bits.
  stimulus : process is

    variable a_vector           : std_logic_vector(7 downto 0);
    variable b_vector           : std_logic_vector(7 downto 0);
    variable expected_output    : std_logic_vector(8 downto 0);
    variable a_magnitude        : integer;
    variable b_magnitude        : integer;
    variable a_integer          : integer;
    variable b_integer          : integer;
    variable expected_integer   : integer;
    variable expected_magnitude : integer;
    variable expected_sign      : std_logic;

  begin

    for a_encoding in 0 to 255 loop

      for b_encoding in 0 to 255 loop

        a_vector := std_logic_vector(to_unsigned(a_encoding, 8));
        b_vector := std_logic_vector(to_unsigned(b_encoding, 8));

        a_i <= a_vector;
        b_i <= b_vector;
        wait for 1 ns;

        a_magnitude := to_integer(unsigned(a_vector(6 downto 0)));
        b_magnitude := to_integer(unsigned(b_vector(6 downto 0)));

        if a_vector(7) = '1' then
          a_integer := -a_magnitude;
        else
          a_integer := a_magnitude;
        end if;

        if b_vector(7) = '1' then
          b_integer := -b_magnitude;
        else
          b_integer := b_magnitude;
        end if;

        expected_integer := a_integer + b_integer;

        if expected_integer < 0 then
          expected_sign      := '1';
          expected_magnitude := -expected_integer;
        else
          expected_sign      := '0';
          expected_magnitude := expected_integer;
        end if;

        expected_output(8)          := expected_sign;
        expected_output(7 downto 0) := std_logic_vector(to_unsigned(expected_magnitude, 8));

        if expected_magnitude = 0 then
          expected_output := (others => '0');
        end if;

        assert sum_basic = expected_output
          report "Basic adder mismatch at a encoding " &
                 integer'image(a_encoding) & " and b encoding " &
                 integer'image(b_encoding)
          severity error;

        assert sum_optim = expected_output
          report "Optimized adder mismatch at a encoding " &
                 integer'image(a_encoding) & " and b encoding " &
                 integer'image(b_encoding)
          severity error;

        assert sum_basic = sum_optim
          report "Basic and optimized adder outputs differ at a encoding " &
                 integer'image(a_encoding) & " and b encoding " &
                 integer'image(b_encoding)
          severity error;

      end loop;

    end loop;

    --! @brief Report successful completion of exhaustive verification.
    report "PASS: all 65,536 input combinations verified."
      severity note;
    wait;

  end process stimulus;

end architecture arch;
