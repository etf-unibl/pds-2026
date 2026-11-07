-----------------------------------------------------------------------------
--
-- unit name:     FOUR_BIT_FULL_SUBTRACTOR_TB
--
-- description:
--
--   Testbench for the 4-bit full subtractor.
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
--! @brief Testbench for the 4-bit full subtractor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--! @brief Testbench entity for the 4-bit full subtractor

entity four_bit_full_subtractor_tb is
end entity four_bit_full_subtractor_tb;

--! @brief Testbench architecture
--! @details Applies all 512 input combinations and checks the subtraction result.

architecture arch of four_bit_full_subtractor_tb is

  --! @brief Component declaration for the DUT
  component four_bit_full_subtractor is
    port (
      a_i   : in    std_logic_vector(3 downto 0);
      b_i   : in    std_logic_vector(3 downto 0);
      c_i   : in    std_logic;
      sub_o : out   std_logic_vector(3 downto 0);
      c_o   : out   std_logic);
  end component four_bit_full_subtractor;

  --! Signals connected to the DUT
  signal a    : std_logic_vector(3 downto 0);
  signal b    : std_logic_vector(3 downto 0);
  signal cin  : std_logic;
  signal sub  : std_logic_vector(3 downto 0);
  signal cout : std_logic;

begin

  --! @brief Device Under Test (DUT) instantiation
  dut : component four_bit_full_subtractor
    port map (
      a_i   => a,
      b_i   => b,
      c_i   => cin,
      sub_o => sub,
      c_o   => cout);

  --! @brief Stimulus and self-checking process
  --! @details Iterates through all 512 input combinations (16x16x2),
  --!          calculates expected results using numeric_std, and counts errors.
  stim : process is

    variable v_a      : unsigned(3 downto 0);
    variable v_b      : unsigned(3 downto 0);
    variable v_cin    : std_logic;
    variable v_diff   : integer;
    variable v_sub    : unsigned(3 downto 0);
    variable v_cout   : std_logic;
    variable v_errors : integer;

  begin

    v_errors := 0;

    for i in 0 to 15 loop

      for j in 0 to 15 loop

        for k in 0 to 1 loop

          v_a := to_unsigned(i, 4);
          v_b := to_unsigned(j, 4);

          if k = 0 then
            v_cin := '0';
          else
            v_cin := '1';
          end if;

          a      <= std_logic_vector(v_a);
          b      <= std_logic_vector(v_b);
          cin    <= v_cin;
          wait for 10 ns;
          v_diff := i - j - k;

          if v_diff < 0 then
            v_cout := '1';
            v_sub  := to_unsigned(v_diff + 16, 4);
          else
            v_cout := '0';
            v_sub  := to_unsigned(v_diff, 4);
          end if;

          if sub /= std_logic_vector(v_sub) then
            report "Failed: " & integer'image(i) & " - " & integer'image(j) & " - " & integer'image(k) & " sub mismatch"
              severity error;
            v_errors := v_errors + 1;
          end if;

          if cout /= v_cout then
            report "Failed: " & integer'image(i) & " - " & integer'image(j) & " - " & integer'image(k) & " cout mismatch"
              severity error;
            v_errors := v_errors + 1;
          end if;

        end loop;

      end loop;

    end loop;

    if v_errors = 0 then
      report "Testbench finished successfully: all 512 combinations passed"
        severity note;
    else
      report "Testbench finished with " & integer'image(v_errors) & " error(s)"
        severity error;
    end if;

    wait;

  end process stim;

end architecture arch;
