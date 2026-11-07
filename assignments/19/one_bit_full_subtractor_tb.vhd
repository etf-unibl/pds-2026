-----------------------------------------------------------------------------
--
-- unit name:     one_bit_full_subtractor_tb
--
-- description:
--
--   This file implements a testbench of simple full subtractor circuit.
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
--! @brief one bit full subtractor testbench testing all input cases

library ieee;
use ieee.std_logic_1164.all;

entity one_bit_full_subtractor_tb is
end entity one_bit_full_subtractor_tb;

architecture arch of one_bit_full_subtractor_tb is

  -- Component declaration for the Device Under Test (DUT)
  component one_bit_full_subtractor is
    port (
      x_i        : in    std_logic;
      y_i        : in    std_logic;
      carry_i    : in    std_logic;
      subtract_o : out   std_logic;
      carry_o    : out   std_logic);
  end component one_bit_full_subtractor;

  -- Stimulus signals
  signal x_s        : std_logic;
  signal y_s        : std_logic;
  signal carry_in_s : std_logic;

  -- Observed signals
  signal subtract_s  : std_logic;
  signal carry_out_s : std_logic;

begin

  -- Instantiate the Device Under Test (DUT)
  dut : component one_bit_full_subtractor
    port map (
      x_i        => x_s,
      y_i        => y_s,
      carry_i    => carry_in_s,
      subtract_o => subtract_s,
      carry_o    => carry_out_s);

  -- Stimulus process
  stim_proc : process is
  begin

    -- Test Case 1: 0 - 0 - 0 = 0 Borrow 0
    x_s        <= '0';
    y_s        <= '0';
    carry_in_s <= '0';
    wait for 10 ns;
    assert (subtract_s = '0' and carry_out_s = '0')
      report "Failed Test Case 000"
      severity error;

    -- Test Case 2: 0 - 0 - 1 = 1 Borrow 1
    x_s        <= '0';
    y_s        <= '0';
    carry_in_s <= '1';
    wait for 10 ns;
    assert (subtract_s = '1' and carry_out_s = '1')
      report "Failed Test Case 001"
      severity error;

    -- Test Case 3: 0 - 1 - 0 = 1 Borrow 1
    x_s        <= '0';
    y_s        <= '1';
    carry_in_s <= '0';
    wait for 10 ns;
    assert (subtract_s = '1' and carry_out_s = '1')
      report "Failed Test Case 010"
      severity error;

    -- Test Case 4: 0 - 1 - 1 = 0 Borrow 1
    x_s        <= '0';
    y_s        <= '1';
    carry_in_s <= '1';
    wait for 10 ns;
    assert (subtract_s = '0' and carry_out_s = '1')
      report "Failed Test Case 011"
      severity error;

    -- Test Case 5: 1 - 0 - 0 = 1 Borrow 0
    x_s        <= '1';
    y_s        <= '0';
    carry_in_s <= '0';
    wait for 10 ns;
    assert (subtract_s = '1' and carry_out_s = '0')
      report "Failed Test Case 100"
      severity error;

    -- Test Case 6: 1 - 0 - 1 = 0 Borrow 0
    x_s        <= '1';
    y_s        <= '0';
    carry_in_s <= '1';
    wait for 10 ns;
    assert (subtract_s = '0' and carry_out_s = '0')
      report "Failed Test Case 101"
      severity error;

    -- Test Case 7: 1 - 1 - 0 = 0 Borrow 0
    x_s        <= '1';
    y_s        <= '1';
    carry_in_s <= '0';
    wait for 10 ns;
    assert (subtract_s = '0' and carry_out_s = '0')
      report "Failed Test Case 110"
      severity error;

    -- Test Case 8: 1 - 1 - 1 = 1 Borrow 1
    x_s        <= '1';
    y_s        <= '1';
    carry_in_s <= '1';
    wait for 10 ns;
    assert (subtract_s = '1' and carry_out_s = '1')
      report "Failed Test Case 111"
      severity error;

    -- End simulation
    report "Simulation completed successfully!"
      severity note;
    wait;

  end process stim_proc;

end architecture arch;
