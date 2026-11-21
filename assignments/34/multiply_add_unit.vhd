-----------------------------------------------------------------------------
--
-- unit name:     MULTIPLY_ADD_UNIT
--
-- description:
--
--   Optimized implementation of the multiply-add unit using operator sharing
--   (one multiplier with multiplexers for operands).
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
--! @brief Optimized multiply-add unit with operator sharing

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Optimized multiply-add unit entity
--! @details Computes a*b, a*c, a*b+c, or b*c using a single shared multiplier.

entity multiply_add_unit is
  port (
    a_i    : in    std_logic_vector(7 downto 0);   --! Operand A
    b_i    : in    std_logic_vector(7 downto 0);   --! Operand B
    c_i    : in    std_logic_vector(7 downto 0);   --! Operand C
    ctrl_i : in    std_logic_vector(1 downto 0);   --! Control input
    res_o  : out   std_logic_vector(15 downto 0)); --! Result
end entity multiply_add_unit;

--! @brief Optimized architecture using operator sharing
--! @details Uses multiplexers to select operands for a single multiplier.
--!          Resource usage for DE1-SoC (5CSEMA5F31C6):
--!
--!          | Realizacija    | ALMs | DSP Blocks |
--!          |----------------|------|------------|
--!          | Osnovna        | 26   | 3          |
--!          | Optimizovana   | 25   | 1          |
--!
--!          Savings: Optimized version uses 67% fewer DSP blocks (1 vs 3)
--!          by using operator sharing (one multiplier instead of three).
--!          ALM count is nearly identical because Quartus maps multipliers
--!          into dedicated DSP blocks, so they do not consume ALMs.
--!          ALMs are used by multiplexers and the adder: the basic version
--!          has a 16-bit 4:1 output multiplexer, while the optimized version
--!          has two 8-bit 2:1 input multiplexers and a 16-bit 2:1 output
--!          multiplexer.
--! @image html 34_rtl.png "RTL Viewer - optimized implementation (1 multiplier)" width=600
--! @image html 34_waveform.png "Simulation waveform - both units produce identical results" width=100%

architecture arch of multiply_add_unit is

  --! @brief First operand for the shared multiplier
  signal src0 : std_logic_vector(7 downto 0);
  --! @brief Second operand for the shared multiplier
  signal src1 : std_logic_vector(7 downto 0);
  --! @brief Result of the shared multiplication
  signal product : unsigned(15 downto 0);
  --! @brief Result of addition (product + c)
  signal sum : unsigned(15 downto 0);

begin

  --! @brief Multiplexer for the first operand (a for 00,01,10; b for 11)
  src0 <= a_i when ctrl_i /= "11" else
          b_i;

  --! @brief Multiplexer for the second operand (b for 00,10; c for 01,11)
  src1 <= b_i when ctrl_i(0) = '0' else
          c_i;

  --! @brief Shared multiplier
  product <= unsigned(src0) * unsigned(src1);

  --! @brief Adder for the "a*b + c" case
  sum <= product + resize(unsigned(c_i), 16);

  --! @brief Output multiplexer (selects sum only for ctrl="10")
  res_o <= std_logic_vector(sum) when ctrl_i = "10" else
           std_logic_vector(product);

end architecture arch;
