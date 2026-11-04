-----------------------------------------------------------------------------
--
-- unit name:     FULL_SUBTRACTOR
--
-- description:
--
--   This file implements a 1-bit full subtractor using a conditional
--   concurrent statement (when-else).
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
--! @brief 1-bit full subtractor

library ieee;
use ieee.std_logic_1164.all;

--! @brief 1-bit full subtractor
--! @details Computes the difference and borrow out of three input bits:
--!          minuend (x_i), subtrahend (y_i) and borrow in (bin_i).
--!          Implemented using a conditional concurrent statement (when-else).

entity full_subtractor is
  port (
    x_i    : in    std_logic;  --! Minuend input
    y_i    : in    std_logic;  --! Subtrahend input
    bin_i  : in    std_logic;  --! Borrow in input
    d_o    : out   std_logic;  --! Difference output
    bout_o : out   std_logic); --! Borrow out output
end entity full_subtractor;

--! @brief Dataflow architecture of the 1-bit full subtractor
--! @details Uses conditional concurrent assignments (when-else)
--!          based on the truth table of the full subtractor.

architecture arch of full_subtractor is

begin

  d_o <= '1' when std_logic_vector'(x_i & y_i & bin_i) = "001" else
         '1' when std_logic_vector'(x_i & y_i & bin_i) = "010" else
         '1' when std_logic_vector'(x_i & y_i & bin_i) = "100" else
         '1' when std_logic_vector'(x_i & y_i & bin_i) = "111" else
         '0';

  bout_o <= '1' when std_logic_vector'(x_i & y_i & bin_i) = "001" else
            '1' when std_logic_vector'(x_i & y_i & bin_i) = "010" else
            '1' when std_logic_vector'(x_i & y_i & bin_i) = "011" else
            '1' when std_logic_vector'(x_i & y_i & bin_i) = "111" else
            '0';

end architecture arch;
