-----------------------------------------------------------------------------
--
-- unit name:     four_bit_full_adder
--
-- description:
--
--   This file implements a four-bit full adder in structural style,
--   built from four one-bit full adders connected in a ripple-carry chain.
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

--! @file four_bit_full_adder.vhd
--! @brief Four-bit full adder

library ieee;
use ieee.std_logic_1164.all;

--! @brief Four-bit full adder
--! @details Four-bit full adder that adds two four-bit numbers and
--! the input carry. The outputs are the four-bit sum and the carry
--! to the next stage.

entity four_bit_full_adder is
  port (
    a_i   : in    std_logic_vector(3 downto 0); --! First four-bit operand
    b_i   : in    std_logic_vector(3 downto 0); --! Second four-bit operand
    c_i   : in    std_logic;                    --! Input carry from the previous stage
    sum_o : out   std_logic_vector(3 downto 0); --! Four-bit sum
    c_o   : out   std_logic);                   --! Carry to the next stage
end entity four_bit_full_adder;

--! @brief Structural architecture of the four-bit full adder
--! @details The architecture is described in structural style. The
--! previously designed one-bit full adder is instantiated four times.
--! The four one-bit adders are connected in a cascade, so the carry
--! output c_o of each adder goes to the carry input c_i of the next one.
--! For this connection a 5-bit internal signal carry is declared,
--! whose bits are the carries between neighbouring one-bit adders.
--! Each instance adds one bit of the operands a_i and b_i and drives
--! one bit of the four-bit sum_o.

architecture arch of four_bit_full_adder is

  --! @brief Carry chain between the one-bit full adders
  --! @details Bit 0 is the input carry c_i, bit i+1 is the carry out of
  --! the adder for bit i and bit 4 is the output carry c_o.
  signal carry : std_logic_vector(4 downto 0);

  --! One-bit full adder used for each bit of the operands
  component one_bit_full_adder is
    port (
      a_i   : in    std_logic;
      b_i   : in    std_logic;
      c_i   : in    std_logic;
      sum_o : out   std_logic;
      c_o   : out   std_logic);
  end component one_bit_full_adder;

begin

  carry(0) <= c_i; -- input carry is the lowest bit of the carry vector

  --! Adder for bit 0 (lowest bit), gets the input carry c_i
  adder0 : component one_bit_full_adder
    port map (
      a_i   => a_i(0),
      b_i   => b_i(0),
      c_i   => carry(0),
      sum_o => sum_o(0),
      c_o   => carry(1));

  --! Adder for bit 1
  adder1 : component one_bit_full_adder
    port map (
      a_i   => a_i(1),
      b_i   => b_i(1),
      c_i   => carry(1),
      sum_o => sum_o(1),
      c_o   => carry(2));

  --! Adder for bit 2
  adder2 : component one_bit_full_adder
    port map (
      a_i   => a_i(2),
      b_i   => b_i(2),
      c_i   => carry(2),
      sum_o => sum_o(2),
      c_o   => carry(3));

  --! Adder for bit 3 (highest bit), drives the output carry c_o
  adder3 : component one_bit_full_adder
    port map (
      a_i   => a_i(3),
      b_i   => b_i(3),
      c_i   => carry(3),
      sum_o => sum_o(3),
      c_o   => carry(4));

  c_o <= carry(4); -- output carry is the highest bit of the carry vector

end architecture arch;
