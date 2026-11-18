-----------------------------------------------------------------------------
--
-- unit name:     three_mode_barrel_shifter_tb
--
-- description:
--
--   Self-checking testbench for the basic and the optimized
--   three-mode barrel shifter. It applies all combinations of lar_i,
--   amt_i and a_i and compares both outputs with the expected values.
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench for the three-mode barrel shifter.
-- It has no ports. It instantiates the basic and the optimized
-- implementation and drives both with the same inputs.

entity three_mode_barrel_shifter_tb is
end entity three_mode_barrel_shifter_tb;

-- Self-checking testbench architecture.
-- The process stimuli_verifier applies all 8192 input combinations
-- (4 modes, 8 shift amounts, 256 input values). For every combination it
-- computes the expected result with numeric_std functions and compares it
-- with the outputs of both implementations.

architecture arch of three_mode_barrel_shifter_tb is

  component three_mode_barrel_shifter_basic is
    port (
      a_i   : in    std_logic_vector(7 downto 0);
      lar_i : in    std_logic_vector(1 downto 0);
      amt_i : in    std_logic_vector(2 downto 0);
      y_o   : out   std_logic_vector(7 downto 0));
  end component three_mode_barrel_shifter_basic;

  component three_mode_barrel_shifter is
    port (
      a_i   : in    std_logic_vector(7 downto 0);
      lar_i : in    std_logic_vector(1 downto 0);
      amt_i : in    std_logic_vector(2 downto 0);
      y_o   : out   std_logic_vector(7 downto 0));
  end component three_mode_barrel_shifter;

  signal test_a       : std_logic_vector(7 downto 0); -- Input data
  signal test_y_basic : std_logic_vector(7 downto 0); -- Output of the basic implementation
  signal test_y_opti  : std_logic_vector(7 downto 0); -- Output of the optimized implementation
  signal test_lar     : std_logic_vector(1 downto 0); -- Shift mode select
  signal test_amt     : std_logic_vector(2 downto 0); -- Number of positions to shift

begin

  -- Basic implementation (three shifters and a multiplexer)
  uut1 : component three_mode_barrel_shifter_basic
    port map (
      a_i   => test_a,
      lar_i => test_lar,
      amt_i => test_amt,
      y_o   => test_y_basic);

  -- Optimized implementation (single shifter)
  uut2 : component three_mode_barrel_shifter
    port map (
      a_i   => test_a,
      lar_i => test_lar,
      amt_i => test_amt,
      y_o   => test_y_opti);

  -- Stimuli and verification process.
  -- Loops over all modes, shift amounts and input values
  stimuli_verifier : process is

    variable errors   : integer;                      -- number of failed checks
    variable expected : std_logic_vector(7 downto 0); -- expected output

  begin

    errors := 0;

    for i in 0 to 3 loop                                                       -- mode: 00, 01, 10 or 11

      for j in 0 to 7 loop                                                     -- shift amount: 0 to 7

        for k in 0 to (2 ** 8) - 1 loop                                        -- 8-bit input value

          test_a   <= std_logic_vector(to_unsigned(k, 8));
          test_amt <= std_logic_vector(to_unsigned(j, 3));
          test_lar <= std_logic_vector(to_unsigned(i, 2));
          wait for 20 ns;                                                      -- let the outputs settle

          case i is

            when 0 =>

              expected := std_logic_vector(rotate_right(unsigned(test_a), j));

            when 1 =>

              expected := std_logic_vector(shift_right(unsigned(test_a), j));

            when 2 =>

              expected := std_logic_vector(shift_right(signed(test_a), j));

            when others =>

              expected := test_a;

          end case;

          -- Count failed checks
          if test_y_basic /= expected then
            errors := errors + 1;
          elsif test_y_opti /= expected then
            errors := errors + 1;
          end if;

          -- Report a failure of the basic implementation
          assert test_y_basic = expected
            report "BASIC ARCHITECTURE fail: a_i = " & to_string(test_a) &
                   ", lar_i = " & to_string(test_lar) &
                   ", amt_i = " & to_string(test_amt) &
                   ", result = " & to_string(test_y_basic) &
                   ", expected result = " & to_string(expected)
            severity error;

          -- Report a failure of the optimized implementation
          assert test_y_opti = expected
            report "OPTIMIZED ARCHITECTURE fail: a_i = " & to_string(test_a) &
                   ", lar_i = " & to_string(test_lar) &
                   ", amt_i = " & to_string(test_amt) &
                   ", result = " & to_string(test_y_opti) &
                   ", expected result = " & to_string(expected)
            severity error;

        end loop;

      end loop;

    end loop;

    if errors /= 0 then
      report "Test failed!"
        severity error;
    elsif errors = 0 then
      report "Test passed!"
        severity note;
    end if;

    wait;

  end process stimuli_verifier;

end architecture arch;
