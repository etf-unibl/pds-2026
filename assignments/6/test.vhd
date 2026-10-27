-----------------------------------------------------------------------------
--
-- unit name:     test
--
-- description:
--
--   This file implements a simple XOR2 logic.
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

--! @file test.vhd
--! @brief Two-input XOR gate

--! Use standard library

library ieee;
--! Use logic elements
use ieee.std_logic_1164.all;

--! @brief Two-input XOR gate
--! @details Output y_o is the logical XOR of inputs a_i and b_i.

entity test is
  port (
    a_i : in    std_logic;  --! First input
    b_i : in    std_logic;  --! Second input
    y_o : out   std_logic); --! XOR output
end entity test;

--! @brief Dataflow architecture of the XOR gate
--! @details The XOR function is implemented with a single concurrent
--! signal assignment that uses the VHDL xor operator on both inputs.

architecture arch of test is

begin

  y_o <= a_i xor b_i;

end architecture arch;
