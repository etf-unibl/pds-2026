-----------------------------------------------------------------------------
--
-- unit name:     FOUR_BIT_COMPARATOR
--
-- description:
--
--   This file implements a 4-bit comparator of unsigned numbers
--   using two 2-bit comparators.
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
--! @brief 4-bit comparator, structural description

library ieee;
use ieee.std_logic_1164.all;

--! @brief 4-bit comparator of unsigned numbers
--! @details The entity implements a 4-bit comparator that compares two unsigned numbers.
--! Based on the values of the input operands, the corresponding mutually exclusive
--! output signal (greater than, equal to, or less than) is activated.

entity four_bit_comparator is
  port (
    a_i    : in    std_logic_vector(3 downto 0); --! First operand
    b_i    : in    std_logic_vector(3 downto 0); --! Second operand
    agtb_o : out   std_logic;                    --! '1' when a > b
    aeqb_o : out   std_logic;                    --! '1' when a = b
    altb_o : out   std_logic);                   --! '1' when a < b
end entity four_bit_comparator;

--! @brief Structural architecture of the 4-bit comparator
--! @details The architecture is implemented in a structural style using two instances
--! of a 2-bit comparator. One instance compares the higher bits (3 and 2), while the
--! other compares the lower bits (1 and 0). The final output is formed by logically
--! combining their results.

architecture arch of four_bit_comparator is

  -- signals for the results of the high and low 2-bit comparators
  signal gt_high : std_logic;
  signal eq_high : std_logic;
  signal lt_high : std_logic;
  signal gt_low  : std_logic;
  signal eq_low  : std_logic;
  signal lt_low  : std_logic;

  component two_bit_comparator is
    port (
      a_i    : in    std_logic_vector(1 downto 0);
      b_i    : in    std_logic_vector(1 downto 0);
      agtb_o : out   std_logic;
      aeqb_o : out   std_logic;
      altb_o : out   std_logic);
  end component two_bit_comparator;

begin

  -- two instances of two_bit_comparator
  comp_high : component two_bit_comparator
    port map (
      a_i    => a_i(3 downto 2),
      b_i    => b_i(3 downto 2),
      agtb_o => gt_high,
      aeqb_o => eq_high,
      altb_o => lt_high);

  comp_low : component two_bit_comparator
    port map (
      a_i    => a_i(1 downto 0),
      b_i    => b_i(1 downto 0),
      agtb_o => gt_low,
      aeqb_o => eq_low,
      altb_o => lt_low);

  -- final outputs
  aeqb_o <= eq_high and eq_low;
  agtb_o <= gt_high or (eq_high and gt_low);
  altb_o <= lt_high or (eq_high and lt_low);

end architecture arch;
