-----------------------------------------------------------------------------
--
-- unit name:     FOUR_BIT_SIGNED_COMPARATOR
--
-- description:
--
--   This file implements a 4-bit comparator of signed numbers
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
--! @brief 4-bit signed comparator, dataflow description

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief 4-bit comparator of signed numbers
--! @details The entity implements a 4-bit comparator that compares two signed numbers.
--! The output signal agtb_o is set to '1' when a_i > b_i
--! For any a_i <= b_i the output signal agtb_o is set to '0'

entity four_bit_signed_comparator is
  port (
    a_i    : in    std_logic_vector(3 downto 0);
    b_i    : in    std_logic_vector(3 downto 0);
    agtb_o : out   std_logic);
end entity four_bit_signed_comparator;

--! @brief Dataflow architecture of the 4-bit signed comparator
--! @details Dataflow description using a concurrent when-else assignment.
--! Inputs are interpreted as signed (two's complement) via numeric_std casting.
--! Output is '1' if a_i > b_i, else '0'.

architecture arch of four_bit_signed_comparator is

begin

  agtb_o <= '1' when signed(a_i) > signed(b_i) else
            '0';

end architecture arch;
