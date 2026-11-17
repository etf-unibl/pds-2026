-----------------------------------------------------------------------------
--
-- unit name:      dual_mode_barrel_rotator_tb
--
-- description:
--
--   This file implements a self-checking testbench for the 16-bit dual-mode
--   barrel rotator. It instantiates both basic and optimized versions, applies
--   identical stimuli, and automatically compares their outputs.
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

--! @file dual_mode_barrel_rotator_tb.vhd
--! @brief Self-checking testbench for dual-mode barrel rotator

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Testbench entity

entity dual_mode_barrel_rotator_tb is
end entity dual_mode_barrel_rotator_tb;

--! @brief Architecture of the testbench
--! @details Instantiates both the basic and optimized barrel rotators,
--! applies identical stimuli across all combinations, and checks for mismatches.

architecture arch of dual_mode_barrel_rotator_tb is

  -- Basic component declaration
  component dual_mode_barrel_rotator_basic is
    port (
      a_i    : in    std_logic_vector(15 downto 0);
      amt_i  : in    std_logic_vector(3 downto 0);
      mode_i : in    std_logic;
      y_o    : out   std_logic_vector(15 downto 0));
  end component dual_mode_barrel_rotator_basic;

  -- Optimized component declaration
  component dual_mode_barrel_rotator is
    port (
      a_i    : in    std_logic_vector(15 downto 0);
      amt_i  : in    std_logic_vector(3 downto 0);
      mode_i : in    std_logic;
      y_o    : out   std_logic_vector(15 downto 0));
  end component dual_mode_barrel_rotator;

  -- Testbench signals
  signal a_i    : std_logic_vector(15 downto 0);
  signal amt_i  : std_logic_vector(3 downto 0);
  signal mode_i : std_logic;

  signal y_basic : std_logic_vector(15 downto 0);
  signal y_opt   : std_logic_vector(15 downto 0);

  -- Definition of an array for test vectors (edge and asymmetric cases)

  type t_test_vector_array is array (0 to 4) of std_logic_vector(15 downto 0);

  constant c_TEST_VECTORS : t_test_vector_array :=
  (
    x"ABCD", -- asymmetric pattern
    x"0001", -- one bit at the bottom
    x"8000", -- one bit at the top
    x"FFFF", -- all ones
    x"0000"  -- all zeros
  );

begin

  -- Instantiate basic rotator
  dut_basic : component dual_mode_barrel_rotator_basic
    port map (
      a_i    => a_i,
      amt_i  => amt_i,
      mode_i => mode_i,
      y_o    => y_basic);

  -- Instantiate optimized rotator
  dut_opt : component dual_mode_barrel_rotator
    port map (
      a_i    => a_i,
      amt_i  => amt_i,
      mode_i => mode_i,
      y_o    => y_opt);

  -- Stimulus and checking process
  stim_proc : process is

    variable expected_y : std_logic_vector(15 downto 0);
    variable current_a  : std_logic_vector(15 downto 0);

  begin

    -- Outer loop: iterate through all test vectors
    for v in c_TEST_VECTORS'range loop

      current_a := c_TEST_VECTORS(v);
      a_i       <= current_a;

      -- Middle loop: iterate through modes (0 = left, 1 = right)
      for m in 0 to 1 loop

        if m = 0 then
          mode_i <= '0';
        else
          mode_i <= '1';
        end if;

        -- Inner loop: iterate through all shift amounts (0 to 15)
        for i in 0 to 15 loop

          amt_i <= std_logic_vector(to_unsigned(i, 4));

          -- Wait for signals to propagate
          wait for 10 ns;

          -- Reference model: calculate expected value using array slicing
          if i = 0 then
            expected_y := current_a;
          elsif m = 0 then
            -- Left rotation
            expected_y := current_a(15 - i downto 0) & current_a(15 downto 16 - i);
          else
            -- Right rotation
            expected_y := current_a(i - 1 downto 0) & current_a(15 downto i);
          end if;

          -- Check basic realization and print inputs on error
          assert (y_basic = expected_y)
            report "Basic realization error! a_i: " & to_hstring(current_a)
                   & ", mode: " & integer'image(m)
                   & ", amount: " & integer'image(i)
            severity error;

          -- Check optimized realization and print inputs on error
          assert (y_opt = expected_y)
            report "Optimized realization error! a_i: " & to_hstring(current_a)
                   & ", mode: " & integer'image(m)
                   & ", amount: " & integer'image(i)
            severity error;

        end loop;

      end loop;

    end loop;

    report "Simulation finished";
    wait;

  end process stim_proc;

end architecture arch;
