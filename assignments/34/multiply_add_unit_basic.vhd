-----------------------------------------------------------------------------
--
-- unit name:     MULTIPLY_ADD_UNIT_BASIC
--
-- description:
--
--   Basic implementation of the multiply-add unit using separate multipliers
--   for each product.
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
--! @brief Basic multiply-add unit

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Basic multiply-add unit entity
--! @details Computes a*b, a*c, a*b+c, or b*c based on ctrl_i.

entity multiply_add_unit_basic is
  port (
    a_i    : in    std_logic_vector(7 downto 0);   --! Operand A
    b_i    : in    std_logic_vector(7 downto 0);   --! Operand B
    c_i    : in    std_logic_vector(7 downto 0);   --! Operand C
    ctrl_i : in    std_logic_vector(1 downto 0);   --! Control input
    res_o  : out   std_logic_vector(15 downto 0)); --! Result
end entity multiply_add_unit_basic;

--! @brief Basic architecture with separate multipliers
--! @details Uses three multipliers and an adder, selecting the result at the end.
--!          Resource usage for DE1-SoC (5CSEMA5F31C6):
--!
--!          | Realizacija    | ALMs | DSP Blocks |
--!          |----------------|------|------------|
--!          | Osnovna        | 26   | 3          |
--!          | Optimizovana   | 25   | 1          |
--!
--!          Savings: Optimized version uses 67% fewer DSP blocks (1 vs 3)
--!          by using operator sharing (one multiplier instead of three).
--!          ALM count is nearly identical because multiplexers are cheaper
--!          than multipliers on Cyclone V.
--! @image html 34_basic_rtl.png "RTL Viewer - basic implementation (3 multipliers)" width=600

architecture arch of multiply_add_unit_basic is

  --! @brief Product a * b
  signal p_ab : unsigned(15 downto 0);
  --! @brief Product a * c
  signal p_ac : unsigned(15 downto 0);
  --! @brief Product b * c
  signal p_bc : unsigned(15 downto 0);
  --! @brief Sum a * b + c
  signal s_abc : unsigned(15 downto 0);

begin

  p_ab  <= unsigned(a_i) * unsigned(b_i);
  p_ac  <= unsigned(a_i) * unsigned(c_i);
  p_bc  <= unsigned(b_i) * unsigned(c_i);
  s_abc <= p_ab + resize(unsigned(c_i), 16);

  --! @brief Output multiplexer
  with ctrl_i select res_o <=
    std_logic_vector(p_ab) when "00",
    std_logic_vector(p_ac) when "01",
    std_logic_vector(s_abc) when "10",
    std_logic_vector(p_bc) when others;

end architecture arch;
