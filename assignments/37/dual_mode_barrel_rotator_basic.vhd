-----------------------------------------------------------------------------
--
-- unit name:     dual_mode_barrel_rotator_basic
--
-- description:
--
--   This file implements the basic realization of a 16-bit barrel; rotator
--   capable of rotating data left or right based on the mode_i signal.
--   It uses two independent rotation circuits and a multiplexer.
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

--! @file dual_mode_barrel_rotator_basic.vhd
--! @brief Basic 16-bit dual-mode barrel rotator

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Basic 16-bit barrel rotator
--! @details This entity implements a 16-bit barrel rotator with separate logic
--! for left and right rotations, multiplexed to te output based on the mode.

entity dual_mode_barrel_rotator_basic is
  port (
    a_i    : in    std_logic_vector(15 downto 0);  --! Input data
    amt_i  : in    std_logic_vector(3 downto 0);   --! Rotation amount (0-15)
    mode_i : in    std_logic;                      --! Direction: '0' for left, '1' for right
    y_o    : out   std_logic_vector(15 downto 0)); --! Output data
end entity dual_mode_barrel_rotator_basic;

--! @brief Architecture using two separate rotators and a multiplexer
--! @details Contains distinct data paths for left and right rotation

architecture arch of dual_mode_barrel_rotator_basic is

  signal y_left  : std_logic_vector(15 downto 0);
  signal y_right : std_logic_vector(15 downto 0);

begin

  -- Independent rotators
  y_left  <= std_logic_vector(rotate_left(unsigned(a_i), to_integer(unsigned(amt_i))));
  y_right <= std_logic_vector(rotate_right(unsigned(a_i), to_integer(unsigned(amt_i))));

  -- Multiplexer
  y_o <= y_left when mode_i = '0' else
         y_right;

end architecture arch;
