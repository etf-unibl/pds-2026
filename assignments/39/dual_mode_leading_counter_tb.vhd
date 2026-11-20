-----------------------------------------------------------------------------
--
-- unit name:     DUAL_MODE_LEADING_COUNTER_TB
--
-- description:
--
--   This file implements a self-checking testbench for the basic and the
--   optimized implementation of the dual-mode leading zero/one counter.
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

--! @file dual_mode_leading_counter_tb.vhd
--! @brief self-checking testbench for the dual-mode leading zero/one counter

--! Use standard library

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief testbench for dual_mode_leading_counter_basic and
--! dual_mode_leading_counter

entity dual_mode_leading_counter_tb is
end entity dual_mode_leading_counter_tb;

--! @brief Self-checking testbench architecture
--! @details Both implementations receive the same inputs and their outputs
--! are compared with the expected value computed by an independent reference
--! function. Directed tests (examples from the assignment and corner cases)
--! are applied first, followed by an exhaustive test of all 2^17 input
--! combinations.

architecture arch of dual_mode_leading_counter_tb is

  --! basic implementation component
  component dual_mode_leading_counter_basic is
    port (
      data_i  : in    std_logic_vector(15 downto 0);
      mode_i  : in    std_logic;
      count_o : out   std_logic_vector(4 downto 0));
  end component dual_mode_leading_counter_basic;

  --! optimized implementation component
  component dual_mode_leading_counter is
    port (
      data_i  : in    std_logic_vector(15 downto 0);
      mode_i  : in    std_logic;
      count_o : out   std_logic_vector(4 downto 0));
  end component dual_mode_leading_counter;

  constant c_STEP : time := 10 ns; --! Duration of one test vector

  signal data_s        : std_logic_vector(15 downto 0); --! Input data
  signal mode_s        : std_logic;                     --! Mode select
  signal count_basic_s : std_logic_vector(4 downto 0);  --! Basic implementation output
  signal count_s       : std_logic_vector(4 downto 0);  --! Optimized implementation output
  signal count_exp_s   : std_logic_vector(4 downto 0);  --! Expected value (for the waveform)

  --! Reference model: counts the bits equal to mode, starting from the MSB.

  function expected_count (
    data : std_logic_vector(15 downto 0);
    mode : std_logic
  ) return natural
  is

    variable count_v : natural;

  begin

    count_v := 0;

    for i in 15 downto 0 loop

      if data(i) /= mode then
        return count_v;
      end if;

      count_v := count_v + 1;

    end loop;

    return count_v;

  end function expected_count;

begin

  --! Basic implementation under test
  dut_basic : component dual_mode_leading_counter_basic
    port map (
      data_i  => data_s,
      mode_i  => mode_s,
      count_o => count_basic_s);

  --! Optimized implementation under test
  dut : component dual_mode_leading_counter
    port map (
      data_i  => data_s,
      mode_i  => mode_s,
      count_o => count_s);

  --! Stimulus and checking process
  stimulus : process is

    variable errors_v : natural;
    variable data_v   : std_logic_vector(15 downto 0);

    --! Applies the inputs, waits and checks the outputs of both implementations.

    procedure check (
      data : std_logic_vector(15 downto 0);
      mode : std_logic
    )
    is

      variable exp_v : natural;

    begin

      exp_v       := expected_count(data, mode);
      data_s      <= data;
      mode_s      <= mode;
      count_exp_s <= std_logic_vector(to_unsigned(exp_v, count_exp_s'length));
      wait for c_STEP;

      if to_integer(unsigned(count_basic_s)) /= exp_v then
        errors_v := errors_v + 1;
        report "BASIC: data = " & integer'image(to_integer(unsigned(data))) &
               ", mode = " & std_logic'image(mode) &
               ", expected " & integer'image(exp_v) &
               ", got " & integer'image(to_integer(unsigned(count_basic_s)))
          severity error;
      end if;

      if to_integer(unsigned(count_s)) /= exp_v then
        errors_v := errors_v + 1;
        report "OPTIMIZED: data = " & integer'image(to_integer(unsigned(data))) &
               ", mode = " & std_logic'image(mode) &
               ", expected " & integer'image(exp_v) &
               ", got " & integer'image(to_integer(unsigned(count_s)))
          severity error;
      end if;

    end procedure check;

  begin

    errors_v := 0;

    -- Examples from the assignment
    check("0001011100000000", '0');                                          -- 3
    check("1111111111111111", '1');                                          -- 16

    -- Corner cases
    check("0000000000000000", '0');                                          -- 16
    check("0000000000000000", '1');                                          -- 0
    check("1111111111111111", '0');                                          -- 0
    check("1000000000000000", '0');                                          -- 0
    check("1000000000000000", '1');                                          -- 1
    check("0000000000000001", '0');                                          -- 15
    check("1111111111111110", '1');                                          -- 15
    check("1110100011111111", '1');                                          -- 3
    check("0111111111111111", '1');                                          -- 0

    -- Every run length of leading zeros/ones (0 to 16)
    for n in 0 to 16 loop

      data_v := std_logic_vector(shift_right(to_unsigned(16#FFFF#, 16), n));
      check(data_v, '0');
      check(not data_v, '1');

    end loop;

    -- Exhaustive test of all input combinations
    for i in 0 to 65535 loop

      check(std_logic_vector(to_unsigned(i, 16)), '0');
      check(std_logic_vector(to_unsigned(i, 16)), '1');

    end loop;

    assert errors_v /= 0
      report "TEST PASSED: both implementations give the expected results"
      severity note;
    assert errors_v = 0
      report "TEST FAILED: number of errors = " & integer'image(errors_v)
      severity failure;

    wait;

  end process stimulus;

end architecture arch;
