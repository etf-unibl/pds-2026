-----------------------------------------------------------------------------
--
-- unit name:     TWO_BIT_COMPARATOR
--
-- description:
--
--   This file implements a 2-bit comparator of unsigned numbers.
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
--! @brief 2-bit comparator

library ieee;
use ieee.std_logic_1164.all;

--! @brief 2-bit comparator of unsigned numbers
--! @details Compares two 2-bit unsigned numbers a_i and b_i. Exactly one
--! of the outputs agtb_o, aeqb_o and altb_o is '1' at any time.

entity two_bit_comparator is
  port (
    a_i    : in    std_logic_vector(1 downto 0); --! First operand
    b_i    : in    std_logic_vector(1 downto 0); --! Second operand
    agtb_o : out   std_logic;                    --! '1' when a > b
    aeqb_o : out   std_logic;                    --! '1' when a = b
    altb_o : out   std_logic);                   --! '1' when a < b
end entity two_bit_comparator;

--! @brief Concurrent architecture of the comparator
--! @details Each output is driven by its own concurrent assignment.
--! Exactly one of the three outputs is '1' for any input combination.

architecture arch of two_bit_comparator is

begin

  -- a equal to b
  aeqb_o <= '1' when a_i = b_i else
            '0';

  -- a greater than b: the high bit decides, or the low bit if high bits are equal
  agtb_o <= '1' when (a_i(1) = '1' and b_i(1) = '0') or
                     (a_i(1) = b_i(1) and a_i(0) = '1' and b_i(0) = '0') else
            '0';

  -- a less than b: the high bit decides, or the low bit if high bits are equal
  altb_o <= '1' when (a_i(1) = '0' and b_i(1) = '1') or
                     (a_i(1) = b_i(1) and a_i(0) = '0' and b_i(0) = '1') else
            '0';

end architecture arch;
