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
--! @details Applies test vectors and checks the subtraction result.

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
  stim : process is

    variable v_a, v_b : unsigned(3 downto 0);
    variable v_cin    : unsigned(0 downto 0);
    variable v_result : unsigned(4 downto 0);

  begin

    -- Test 1: 5 - 3 - 0 = 2, no borrow out
    a   <= "0101";
    b   <= "0011";
    cin <= '0';
    wait for 10 ns;
    assert sub = "0010"
      report "Failed test 1: 5 - 3 - 0"
      severity error;
    assert cout = '0'
      report "Failed test 1: borrow out should be 0"
      severity error;

    -- Test 2: 3 - 5 - 0 = -2 (14 with borrow), borrow out = 1
    a   <= "0011";
    b   <= "0101";
    cin <= '0';
    wait for 10 ns;
    assert sub = "1110"
      report "Failed test 2: 3 - 5 - 0"
      severity error;
    assert cout = '1'
      report "Failed test 2: borrow out should be 1"
      severity error;

    -- Test 3: 7 - 2 - 1 = 4, no borrow out
    a   <= "0111";
    b   <= "0010";
    cin <= '1';
    wait for 10 ns;
    assert sub = "0100"
      report "Failed test 3: 7 - 2 - 1"
      severity error;
    assert cout = '0'
      report "Failed test 3: borrow out should be 0"
      severity error;

    -- Test 4: 0 - 0 - 1 = 15 with borrow, borrow out = 1
    a   <= "0000";
    b   <= "0000";
    cin <= '1';
    wait for 10 ns;
    assert sub = "1111"
      report "Failed test 4: 0 - 0 - 1"
      severity error;
    assert cout = '1'
      report "Failed test 4: borrow out should be 1"
      severity error;

    -- Test 5: 15 - 0 - 0 = 15, no borrow out
    a   <= "1111";
    b   <= "0000";
    cin <= '0';
    wait for 10 ns;
    assert sub = "1111"
      report "Failed test 5: 15 - 0 - 0"
      severity error;
    assert cout = '0'
      report "Failed test 5: borrow out should be 0"
      severity error;

    report "Testbench finished successfully"
      severity note;
    wait;

  end process stim;

end architecture arch;
