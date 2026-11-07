-----------------------------------------------------------------------------
--
-- unit name:     one_bit_full_subtractor
--
-- description:
--
--   This file implements a simple full subtractor circuit using
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
--! @brief one bit full subtractor

library ieee;
use ieee.std_logic_1164.all;

--! @brief one bit full subtractor
--! @details Inputs are X, Y and carry in. Outputs are difference (subtract) and carry out. All ports are one bit.

entity one_bit_full_subtractor is
  port (
    x_i        : in    std_logic;  --! first term
    y_i        : in    std_logic;  --! second term
    carry_i    : in    std_logic;  --! carry in port
    subtract_o : out   std_logic;  --! difference of terms
    carry_o    : out   std_logic); --! '1' if x_i = 0 and y_i = 1 else '0'
end entity one_bit_full_subtractor;

--! @brief Dataflow architecture of one bit full subtractor
--! @details Full one bit subtractor is described using concurrent sequential logic.
--! @details Subtract port will be in high logic state if number of high logic states inputs is odd.
--! @details Carry out will be in high input state if X input port is in low logic state
--! while either Y input port or Carry in port are in high logic state
--! or when both terms and carry in ports are in high logic state

architecture arch of one_bit_full_subtractor is

  signal input : std_logic_vector(2 downto 0); --! signal for merging all inputs in vector

begin

  input <= x_i & y_i & carry_i;
  with input select subtract_o <=
    '1' when "001" | "010" | "100" | "111",
    '0' when others;
  with input select carry_o <=
    '1' when "001" | "010" | "011" | "111",
    '0' when others;

end architecture arch;
