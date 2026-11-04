-----------------------------------------------------------------------------
--
-- unit name:     FOUR_BIT_FULL_SUBTRACTOR
--
-- description:
--
--   This file implements a 4-bit full subtractor using structural style,
--   instantiated from four 1-bit full subtractors.
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
--! @brief 4-bit full subtractor

library ieee;
use ieee.std_logic_1164.all;

--! @brief 4-bit full subtractor
--! @details Subtracts two 4-bit numbers (a_i - b_i) with borrow in (c_i).
--!          Outputs the 4-bit difference (sub_o) and borrow out (c_o).
--!          Implemented in structural style using four 1-bit full subtractors.

entity four_bit_full_subtractor is
  port (
    a_i   : in    std_logic_vector(3 downto 0); --! Minuend (4-bit)
    b_i   : in    std_logic_vector(3 downto 0); --! Subtrahend (4-bit)
    c_i   : in    std_logic;                    --! Borrow in
    sub_o : out   std_logic_vector(3 downto 0); --! Difference (4-bit)
    c_o   : out   std_logic);                   --! Borrow out
end entity four_bit_full_subtractor;

--! @brief Structural architecture of the 4-bit full subtractor
--! @details Instantiates four 1-bit full subtractors with ripple borrow.

architecture arch of four_bit_full_subtractor is

  --! @brief Component declaration for the 1-bit full subtractor
  component full_subtractor is
    port (
      x_i    : in    std_logic;
      y_i    : in    std_logic;
      bin_i  : in    std_logic;
      d_o    : out   std_logic;
      bout_o : out   std_logic);
  end component full_subtractor;

  --! @brief Internal borrow signals between stages
  signal b0 : std_logic;
  signal b1 : std_logic;
  signal b2 : std_logic;

begin

  --! @brief Stage 0: least significant bit
  stage0 : component full_subtractor
    port map (
      x_i    => a_i(0),
      y_i    => b_i(0),
      bin_i  => c_i,
      d_o    => sub_o(0),
      bout_o => b0);

  --! @brief Stage 1
  stage1 : component full_subtractor
    port map (
      x_i    => a_i(1),
      y_i    => b_i(1),
      bin_i  => b0,
      d_o    => sub_o(1),
      bout_o => b1);

  --! @brief Stage 2
  stage2 : component full_subtractor
    port map (
      x_i    => a_i(2),
      y_i    => b_i(2),
      bin_i  => b1,
      d_o    => sub_o(2),
      bout_o => b2);

  --! @brief Stage 3: most significant bit
  stage3 : component full_subtractor
    port map (
      x_i    => a_i(3),
      y_i    => b_i(3),
      bin_i  => b2,
      d_o    => sub_o(3),
      bout_o => c_o);

end architecture arch;
