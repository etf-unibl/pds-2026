-----------------------------------------------------------------------------
--
-- unit name:     one_bit_full_adder
--
-- description:
--
--   This file implements a one-bit full adder described with conditional
--   concurrent signal assignments derived from its truth table.
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
--! @brief One-bit full adder

library ieee;
use ieee.std_logic_1164.all;

--! @brief One-bit full adder
--! @details One-bit full adder that adds a bit of the first operand,
--! a bit of the second operand and the carry from the previous stage.
--! The outputs are the sum of these three bits and the carry
--! to the next stage. The circuit is purely combinational.

entity one_bit_full_adder is
  port (
    a_i   : in    std_logic;  --! Bit of the first operand
    b_i   : in    std_logic;  --! Bit of the second operand
    c_i   : in    std_logic;  --! Carry from the previous stage
    sum_o : out   std_logic;  --! Sum of the input bits
    c_o   : out   std_logic); --! Carry to the next stage
end entity one_bit_full_adder;

--! @brief Dataflow architecture of the one-bit full adder
--! @details The architecture is described in dataflow style.
--! The internal signal inputs is the concatenation of the inputs
--! a_i, b_i and c_i. The internal signal outputs holds both outputs:
--! bit 1 is the carry c_o and bit 0 is the sum sum_o.
--! The outputs are assigned by a single conditional concurrent
--! signal assignment (when ... else) written directly from the truth
--! table: seven when conditions cover the input combinations 000 to
--! 110, and the final else branch covers the combination 111.

architecture arch of one_bit_full_adder is

  --! Inputs a_i, b_i and c_i packed into a 3-bit vector
  signal inputs : std_logic_vector(2 downto 0);
  --! Outputs packed into a 2-bit vector (bit 1 = c_o, bit 0 = sum_o)
  signal outputs : std_logic_vector(1 downto 0);

begin

  inputs <= a_i & b_i & c_i; -- concatenation of the three input bits

  outputs <= "00" when inputs = "000" else
             "01" when inputs = "001" else
             "01" when inputs = "010" else
             "10" when inputs = "011" else
             "01" when inputs = "100" else
             "10" when inputs = "101" else
             "10" when inputs = "110" else
             "11";

  c_o   <= outputs(1);
  sum_o <= outputs(0);

end architecture arch;
