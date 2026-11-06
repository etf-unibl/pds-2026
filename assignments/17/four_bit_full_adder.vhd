-----------------------------------------------------------------------------
--
-- unit name:     FOUR_BIT_FULL_ADDER
--
-- description:
--
--   This file implements a four-bit full adder in structural style using four
--   cascaded one-bit full adders.
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

--! @file four_bit_full_adder.vhd
--! @brief four-bit full adder

--! Use standard library

library ieee;
use ieee.std_logic_1164.all;

--! @brief four-bit full adder
--! @details Adds two four-bit numbers a_i and b_i together with the input
--! carry c_i, producing the four-bit sum sum_o and the output carry c_o.

entity four_bit_full_adder is
  port (
    a_i   : in    std_logic_vector(3 downto 0); --! first four-bit input
    b_i   : in    std_logic_vector(3 downto 0); --! second four-bit input
    c_i   : in    std_logic;                    --! input carry
    sum_o : out   std_logic_vector(3 downto 0); --! four-bit sum output
    c_o   : out   std_logic);                   --! output carry
end entity four_bit_full_adder;

--! @brief Structural architecture of the four-bit full adder
--! @details Four one-bit full adders are connected in a chain. The output
--! carry of each stage is the input carry of the next stage.

architecture arch of four_bit_full_adder is

  --! one-bit full adder component
  component one_bit_full_adder is
    port (
      a_i : in    std_logic;
      b_i : in    std_logic;
      c_i : in    std_logic;
      s_o : out   std_logic;
      c_o : out   std_logic);
  end component one_bit_full_adder;

  signal c1_s : std_logic; --! Carry from bit 0 to bit 1
  signal c2_s : std_logic; --! Carry from bit 1 to bit 2
  signal c3_s : std_logic; --! Carry from bit 2 to bit 3

begin

  --! Full adder for bit 0
  fa0 : component one_bit_full_adder
    port map (
      a_i => a_i(0),
      b_i => b_i(0),
      c_i => c_i,
      s_o => sum_o(0),
      c_o => c1_s);

  --! Full adder for bit 1
  fa1 : component one_bit_full_adder
    port map (
      a_i => a_i(1),
      b_i => b_i(1),
      c_i => c1_s,
      s_o => sum_o(1),
      c_o => c2_s);

  --! Full adder for bit 2
  fa2 : component one_bit_full_adder
    port map (
      a_i => a_i(2),
      b_i => b_i(2),
      c_i => c2_s,
      s_o => sum_o(2),
      c_o => c3_s);

  --! Full adder for bit 3
  fa3 : component one_bit_full_adder
    port map (
      a_i => a_i(3),
      b_i => b_i(3),
      c_i => c3_s,
      s_o => sum_o(3),
      c_o => c_o);

end architecture arch;
