-----------------------------------------------------------------------------
--
-- unit name:     TEST_TB
--
-- description:
--
--   Testbench for the simple two-input AND logic gate.
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
--! @brief Testbench for the AND2 gate

library ieee;
use ieee.std_logic_1164.all;

--! @brief Testbench entity for the AND2 gate
entity test_tb is
end entity test_tb;

--! @brief Testbench architecture
architecture tb of test_tb is

  signal a : std_logic;
  signal b : std_logic;
  signal y : std_logic;

begin

  dut : entity work.test
    port map (
      a_i => a,
      b_i => b,
      y_o => y);

  stim : process is
  begin
    -- Test 00 -> expected '0'
    a <= '0'; b <= '0';
    wait for 10 ns;
    assert y = '0' report "Failed for input 00" severity error;

    -- Test 01 -> expected '0'
    a <= '0'; b <= '1';
    wait for 10 ns;
    assert y = '0' report "Failed for input 01" severity error;

    -- Test 10 -> expected '0'
    a <= '1'; b <= '0';
    wait for 10 ns;
    assert y = '0' report "Failed for input 10" severity error;

    -- Test 11 -> expected '1'
    a <= '1'; b <= '1';
    wait for 10 ns;
    assert y = '1' report "Failed for input 11" severity error;

    report "Testbench finished successfully" severity note;
    wait;
  end process stim;

end architecture tb;