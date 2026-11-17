-----------------------------------------------------------------------------
--
-- unit name:     dual_mode_barrel_rotator
--
-- description:
--
--   This file implements the optimized realization of a 16-bit dual-mode
--   barrel rotator. It utilizes resource sharing by employing only a single
--   left-rotation circuit and adjusting the shift amount for right rotations.
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

--! @file dual_mode_barrel_rotator.vhd
--! @brief Optimized 16-bit dual-mode barrel rotator

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Optimized 16-bit barrel rotator
--! @details This entity implements a 16-bit barrel rotator using a single
--! rotation logic block to save hardware resources.

entity dual_mode_barrel_rotator is
  port (
    a_i    : in    std_logic_vector(15 downto 0);  --! Input data
    amt_i  : in    std_logic_vector(3 downto 0);   --! Rotation amount (0-15)
    mode_i : in    std_logic;                      --! Direction: '0' for left, '1' for right
    y_o    : out   std_logic_vector(15 downto 0)); --! Output data
end entity dual_mode_barrel_rotator;

--! @brief Architecture using resource sharing (single rotator)
--! @details A right rotation by N is mathematically equivalent to a left
--! rotation by (16 - N). We compute the adjusted shift amount and perform
--! only a single left rotation, saving logic elements.
--! @image html 37_rtl.png "RTL view of the optimized realization" width=100%
--! @image html 37_waveform.png "Simulation of both realizations for a_i = ABCD" width=100%
--!
--! Resource usage from the Quartus Flow Summary:
--!
--! | Resource   | Basic | Optimized |
--! |------------|------:|----------:|
--! | ALMs       |    66 |        34 |
--! | Registers  |     0 |         0 |
--! | DSP blocks |     0 |         0 |
--!
--! - difference: 32 ALMs (48.5 % less than the basic realization)
--! - removed: one 16-bit rotator and one 16-bit multiplexor
--! - added: a 4-bit negation of the amount (two's complement) and a 4-bit
--!   multiplexer that selects the amount (signal amt_adj)
--! -the savings are in combinational logic, neither realization uses Registers

architecture arch of dual_mode_barrel_rotator is

  signal amt_adj : unsigned(3 downto 0);

begin

  -- Calculate adjusted shift amount for a unified left rotation
  -- (16 - amt) mod 16 is equivalent to the 2's complement of the 4-bit amount
  amt_adj <= unsigned(amt_i) when mode_i = '0' else
             (not unsigned(amt_i)) + 1;

  -- Single left rotation
  y_o <= std_logic_vector(rotate_left(unsigned(a_i), to_integer(amt_adj)));

end architecture arch;
