-----------------------------------------------------------------------------
--
-- unit name:     three_mode_barrel_shifter
--
-- description:
--
--   This file implements an 8-bit three-mode barrel shifter (rotate right,
--   logical shift right, arithmetic shift right) using a single shifter.
--   The functions differ only in the bits that enter from the left side.
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

--! @file three_mode_barrel_shifter.vhd
--! @brief Three-mode barrel shifter, optimized implementation

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Three-mode barrel shifter, optimized implementation
--! @details The input a_i is the 8-bit data. The input lar_i selects the mode
--! (rotate, logical shift or arithmetic shift). The input amt_i says how many
--! positions to shift. The result is on the output y_o.

entity three_mode_barrel_shifter is
  port (
    a_i   : in    std_logic_vector(7 downto 0);  --! Input vector
    lar_i : in    std_logic_vector(1 downto 0);  --! Shift mode select
    amt_i : in    std_logic_vector(2 downto 0);  --! Number of positions to shift
    y_o   : out   std_logic_vector(7 downto 0)); --! Output vector
end entity three_mode_barrel_shifter;

--! @brief Optimized architecture with a single shifter
--! @details The basic version uses three separate shifters and a multiplexer.
--! This version uses only one shifter. All three modes shift to the right,
--! so they differ only in the bits that enter from the left side.
--! These bits are called fill. The architecture works in three steps:
--!
--! 1. The mode lar_i selects the value of fill.
--! 2. The vector extend = fill & a_i (16 bits) is created.
--! 3. The output is an 8-bit part (window) of extend. Its start position is
--!    given by amt_i.
--!
--! In the mode "11" the output is simply a_i, so a last multiplexer
--! selects between the shifted result and a_i.
--! The resource usage of both implementations on the DE1-SoC chip
--! (5CSEMA5F31C6, Optimization mode: Balanced) is given in the table:
--!
--! | Implementation | ALMs |
--! | -------------- | ---- |
--! | Basic          | 29   |
--! | Optimized      | 22   |
--!
--! The optimized version uses 22 ALMs instead of 29, which is about 24% less.
--! The saving comes from using one shifter instead of three. Only a small
--! multiplexer for the fill bits is added.
--!
--! @image html 35_waveform.png "Simulation of the testbench: both implementations give the same results" width=100%
--!
--! @image html 35_rtl.png "RTL view of the optimized implementation" width=600

architecture arch of three_mode_barrel_shifter is

  --! Bits that enter from the left side
  signal fill : std_logic_vector(7 downto 0);
  --! Extended input vector (fill & a_i)
  signal extend : std_logic_vector(15 downto 0);

begin

  --! @brief Selecting the fill bits
  --! @details The mode lar_i selects the value of fill:
  --! a_i for rotation, zeros for logical shift, and the sign bit a_i(7)
  --! for arithmetic shift.
  with lar_i select fill <=
    (a_i(7 downto 0)) when "00",
    (7 downto 0 => '0') when "01",
    (7 downto 0 => a_i(7)) when "10",
    (7 downto 0 => '0') when others;

  --! @brief Creating the extended vector
  --! @details The vector fill is placed in front of a_i.
  extend <= fill & a_i;

  --! @brief Selecting the output
  --! @details In the mode "11" the output is a_i. In all other modes the
  --! output is an 8-bit window of extend, which starts at position amt_i.
  y_o <= a_i when lar_i = "11" else
         extend(7 + to_integer(unsigned(amt_i)) downto to_integer(unsigned(amt_i)));

end architecture arch;
