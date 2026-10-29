-----------------------------------------------------------------------------
--
-- unit name:     test_tb
--
-- description:
--
--   This file implements a simple NAND2 logic.
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

entity test_tb is
end entity test_tb;

architecture arch of test_tb is component test is port (
      a_i : in    std_logic;
      b_i : in    std_logic;
      y_o : out   std_logic);
  end component test;

  signal s_a : std_logic;
  signal s_b : std_logic;
  signal s_y : std_logic;

begin

  uut : component test
    port map (
      a_i => s_a,
      b_i => s_b,
      y_o => s_y);

  stimulus : process is
  begin

    s_a <= '0';
    s_b <= '0';
    wait for 10 ns;
    assert s_y = '1'
      report "a=0 b=0: expected y=1"
      severity error;

    s_a <= '0';
    s_b <= '1';
    wait for 10 ns;
    assert s_y = '0'
      report "a=0 b=1: expected y=0"
      severity error;

    s_a <= '1';
    s_b <= '0';
    wait for 10 ns;
    assert s_y = '0'
      report "a=1 b=0: expected y=0"
      severity error;

    s_a <= '1';
    s_b <= '1';
    wait for 10 ns;
    assert s_y = '0'
      report "a=1 b=1: expected y=0"
      severity error;

    wait;

  end process stimulus;

end architecture arch;
