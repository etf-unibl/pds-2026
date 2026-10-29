-----------------------------------------------------------------------------
--
-- unit name:     test_tb
--
-- description:
--
--   This file implements a self-checking testbench for the XOR2 logic.
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

--! @file test_tb.vhd
--! @brief Self-checking testbench for the two-input XOR gate

--! Use standard library

library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Testbench for the test entity
--! @details The testbench has no ports.

entity test_tb is
end entity test_tb;

--! @brief Self-checking testbench architecture
--! @details Applies all four input combinations to the XOR gate and
--! checks the output against the expected XOR value after each one.

architecture arch of test_tb is

  component test is
    port (
      a_i : in    std_logic;
      b_i : in    std_logic;
      y_o : out   std_logic);
  end component test;

  signal a_s : std_logic; --! Stimulus for input a_i
  signal b_s : std_logic; --! Stimulus for input b_i
  signal y_s : std_logic; --! Observed output y_o

begin

  uut : component test
    port map (
      a_i => a_s,
      b_i => b_s,
      y_o => y_s);

  stimulus : process is
  begin

    a_s <= '0';
    b_s <= '0';
    wait for 10 ns;
    assert y_s = '0'
      report "a=0 b=0: expected y=0"
      severity error;

    a_s <= '0';
    b_s <= '1';
    wait for 10 ns;
    assert y_s = '1'
      report "a=0 b=1: expected y=1"
      severity error;

    a_s <= '1';
    b_s <= '0';
    wait for 10 ns;
    assert y_s = '1'
      report "a=1 b=0: expected y=1"
      severity error;

    a_s <= '1';
    b_s <= '1';
    wait for 10 ns;
    assert y_s = '0'
      report "a=1 b=1: expected y=0"
      severity error;

    wait;

  end process stimulus;

end architecture arch;
