-----------------------------------------------------------------------------
--
-- unit name:     MULTIPLY_ADD_UNIT_TB
--
-- description:
--
--   Self-checking testbench for both basic and optimized multiply-add units.
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
--! @brief Testbench for multiply-add units

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Testbench entity
--! @details Entity without ports - generates stimuli internally.

entity multiply_add_unit_tb is
end entity multiply_add_unit_tb;

--! @brief Testbench architecture
--! @details Instantiates both basic and optimized units and checks all outputs
--!          against expected values computed using numeric_std.

architecture arch of multiply_add_unit_tb is

  --! @brief Component for basic unit
  component multiply_add_unit_basic is
    port (
      a_i    : in    std_logic_vector(7 downto 0);
      b_i    : in    std_logic_vector(7 downto 0);
      c_i    : in    std_logic_vector(7 downto 0);
      ctrl_i : in    std_logic_vector(1 downto 0);
      res_o  : out   std_logic_vector(15 downto 0));
  end component multiply_add_unit_basic;

  --! @brief Component for optimized unit
  component multiply_add_unit is
    port (
      a_i    : in    std_logic_vector(7 downto 0);
      b_i    : in    std_logic_vector(7 downto 0);
      c_i    : in    std_logic_vector(7 downto 0);
      ctrl_i : in    std_logic_vector(1 downto 0);
      res_o  : out   std_logic_vector(15 downto 0));
  end component multiply_add_unit;

  --! @brief Test stimulus signal for operand A
  signal a_t : std_logic_vector(7 downto 0);
  --! @brief Test stimulus signal for operand B
  signal b_t : std_logic_vector(7 downto 0);
  --! @brief Test stimulus signal for operand C
  signal c_t : std_logic_vector(7 downto 0);
  --! @brief Test stimulus signal for control input
  signal ctrl_t : std_logic_vector(1 downto 0);
  --! @brief Output from basic unit
  signal res_basic : std_logic_vector(15 downto 0);
  --! @brief Output from optimized unit
  signal res_opt : std_logic_vector(15 downto 0);
  --! @brief Expected result for comparison (shown on waveform)
  signal expected : std_logic_vector(15 downto 0);

begin

  --! @brief Basic unit instantiation
  dut_basic : component multiply_add_unit_basic
    port map (
      a_i    => a_t,
      b_i    => b_t,
      c_i    => c_t,
      ctrl_i => ctrl_t,
      res_o  => res_basic);

  --! @brief Optimized unit instantiation
  dut_opt : component multiply_add_unit
    port map (
      a_i    => a_t,
      b_i    => b_t,
      c_i    => c_t,
      ctrl_i => ctrl_t,
      res_o  => res_opt);

  --! @brief Stimulus and self-checking process
  --! @details Applies representative test vectors covering all four
  --!          operations with distinct operand values, including boundary
  --!          cases (max values, zero operands, carry into upper byte).
  stim : process is

    type t_test is record
      a, b, c : natural;
      ctrl    : std_logic_vector(1 downto 0);
    end record t_test;

    type t_tests is array (0 to 19) of t_test;

    --! @brief Test vectors covering all operations and boundary cases
    constant c_TESTS : t_tests :=
    (
      -- ctrl = "00" (a*b): normal and boundary cases
      (
        5,
        3,
        2,
        "00"
      ),
      (
        10,
        7,
        1,
        "00"
      ),
      (
        255,
        255,
        0,
        "00"
      ),
      (
        0,
        128,
        50,
        "00"
      ),
      -- ctrl = "01" (a*c): normal and boundary cases
      (
        5,
        3,
        2,
        "01"
      ),
      (
        10,
        7,
        1,
        "01"
      ),
      (
        255,
        0,
        255,
        "01"
      ),
      (
        128,
        50,
        200,
        "01"
      ),
      -- ctrl = "10" (a*b+c): with carry into upper byte
      (
        5,
        3,
        2,
        "10"
      ),
      (
        10,
        7,
        1,
        "10"
      ),
      (
        255,
        255,
        255,
        "10"
      ),
      (
        200,
        200,
        100,
        "10"
      ),
      -- ctrl = "11" (b*c): normal and boundary cases
      (
        5,
        3,
        2,
        "11"
      ),
      (
        10,
        7,
        1,
        "11"
      ),
      (
        0,
        255,
        255,
        "11"
      ),
      (
        100,
        200,
        150,
        "11"
      ),
      -- Additional boundary cases
      (
        0,
        0,
        0,
        "00"
      ),
      (
        255,
        255,
        255,
        "01"
      ),
      (
        1,
        1,
        1,
        "10"
      ),
      (
        255,
        1,
        255,
        "11"
      )
    );

    variable v_expected : unsigned(15 downto 0);
    variable v_errors   : integer;

  begin

    v_errors := 0;

    for i in c_TESTS'range loop

      a_t    <= std_logic_vector(to_unsigned(c_tests(i).a, 8));
      b_t    <= std_logic_vector(to_unsigned(c_tests(i).b, 8));
      c_t    <= std_logic_vector(to_unsigned(c_tests(i).c, 8));
      ctrl_t <= c_tests(i).ctrl;
      wait for 50 ns;

      -- Calculate expected result using 8-bit operands
      -- (product of two 8-bit values fits in 16 bits)
      case c_tests(i).ctrl is

        when "00" =>

          v_expected := to_unsigned(c_tests(i).a, 8)
                        * to_unsigned(c_tests(i).b, 8);

        when "01" =>

          v_expected := to_unsigned(c_tests(i).a, 8)
                        * to_unsigned(c_tests(i).c, 8);

        when "10" =>

          v_expected :=
          (
            to_unsigned(c_tests(i).a,
                         8)
            * to_unsigned(c_tests(i).b,
                           8)
          )
            + to_unsigned(c_tests(i).c,
                           8
                         );

        when others =>

          v_expected := to_unsigned(c_tests(i).b, 8)
                        * to_unsigned(c_tests(i).c, 8);

      end case;

      expected <= std_logic_vector(v_expected);

      if unsigned(res_basic) /= v_expected then
        report "Basic unit failed at test " & integer'image(i)
          severity error;
        v_errors := v_errors + 1;
      end if;

      if unsigned(res_opt) /= v_expected then
        report "Optimized unit failed at test " & integer'image(i)
          severity error;
        v_errors := v_errors + 1;
      end if;

    end loop;

    if v_errors = 0 then
      report "Testbench finished successfully: all checks passed"
        severity note;
    else
      report "Testbench finished with " & integer'image(v_errors)
             & " error(s)"
        severity error;
    end if;

    wait;

  end process stim;

end architecture arch;
