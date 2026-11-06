-----------------------------------------------------------------------------
--
-- unit name:     four_bit_full_subtractor
--
-- description:
--
--   This file implements a simple full subtractor circuit.
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
--! @details Inputs are four bit numbers A, B and one bit carry in. Outputs are difference (sub_o) and carry out bit.

entity four_bit_full_subtractor is
  port (
    a_i   : in    std_logic_vector(3 downto 0);
    b_i   : in    std_logic_vector(3 downto 0);
    c_i   : in    std_logic;
    sub_o : out   std_logic_vector(3 downto 0);
    c_o   : out   std_logic);
end entity four_bit_full_subtractor;

--! @brief Dataflow architecture of four bit full subtractor
--! @details four bit full subtroctor is made using four one_bit_full_subtractror components
--! and carry_s signal for conecting carry in and carry out ports.

architecture arch of four_bit_full_subtractor is

  component one_bit_full_subtractor is
    port (
      x_i        : in    std_logic;
      y_i        : in    std_logic;
      carry_i    : in    std_logic;
      subtract_o : out   std_logic;
      carry_o    : out   std_logic);
  end component one_bit_full_subtractor;

  signal carry_s : std_logic_vector(2 downto 0);

begin

  fs0 : component one_bit_full_subtractor
    port map (
      x_i        => a_i(0),
      y_i        => b_i(0),
      carry_i    => c_i,
      subtract_o => sub_o(0),
      carry_o    => carry_s(0));

  fs1 : component one_bit_full_subtractor
    port map (
      x_i        => a_i(1),
      y_i        => b_i(1),
      carry_i    => carry_s(0),
      subtract_o => sub_o(1),
      carry_o    => carry_s(1));

  fs2 : component one_bit_full_subtractor
    port map (
      x_i        => a_i(2),
      y_i        => b_i(2),
      carry_i    => carry_s(1),
      subtract_o => sub_o(2),
      carry_o    => carry_s(2));

  fs3 : component one_bit_full_subtractor
    port map (
      x_i        => a_i(3),
      y_i        => b_i(3),
      carry_i    => carry_s(2),
      subtract_o => sub_o(3),
      carry_o    => c_o);

end architecture arch;
