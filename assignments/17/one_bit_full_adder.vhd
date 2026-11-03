-----------------------------------------------------------------------------
--
-- unit name:     ONE_BIT_FULL_ADDER
--
-- description:
--
--   This file implements a one-bit full adder using basic logic operations.
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

--! @file one_bit_full_adder.vhd
--! @brief one-bit full adder

--! Use standard library

library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief one-bit full adder
--! @details Adds two input bits a_i and b_i together with the input carry
--! c_i, producing the sum bit s_o and the output carry c_o.

entity one_bit_full_adder is
  port (
    a_i : in    std_logic;  --! first input bit
    b_i : in    std_logic;  --! second input bit
    c_i : in    std_logic;  --! input carry
    s_o : out   std_logic;  --! sum output
    c_o : out   std_logic); --! output carry
end entity one_bit_full_adder;

--! @brief Dataflow architecture of the one-bit full adder
--! @details The adder is implemented with two concurrent signal assignments
--! derived from the truth table:
--!   s_o = a_i xor b_i xor c_i
--!   c_o = (a_i and b_i) or (a_i and c_i) or (b_i and c_i)

architecture arch of one_bit_full_adder is

begin

  s_o <= a_i xor b_i xor c_i;
  c_o <= (a_i and b_i) or (a_i and c_i) or (b_i and c_i);

end architecture arch;
