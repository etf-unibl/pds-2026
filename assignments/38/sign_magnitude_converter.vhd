-----------------------------------------------------------------------------
--
-- unit name:     sign_magnitude_converter
--
-- description:
--
--   This file implements the optimized realization of a bidirectional converter
--   between 8-bit two's complement and sign-magnitude format. It utilizes
--   resource sharing by employing only a single negation circuit, since the
--   lower seven bits of the negation are identical in both directions.
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

--! @file sign_magnitude_converter.vhd
--! @brief Optimized bidirectional 8-bit sign-magnitude converter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Optimized 8-bit two's complement <-> sign-magnitude converter
--! @details This entity implements the conversion in both directions using a
--! single negation logic block to save hardware resources.

entity sign_magnitude_converter is
  port (
    data_i : in    std_logic_vector(7 downto 0);  --! Input number
    mode_i : in    std_logic;                     --! Direction: '0' TC->SM, '1' SM->TC
    data_o : out   std_logic_vector(7 downto 0)); --! Converted number
end entity sign_magnitude_converter;

--! @brief Architecture using resource sharing (single negation circuit)
--! @details Both directions negate the same operand "0" & magnitude, because bit
--! 7 of the operand does not affect the lower seven bits of the result
--! (128 = 0 mod 128), so no input multiplexer is needed. Only the sign bit
--! depends on mode_i: TC->SM keeps the sign, while SM->TC converts "-0" into +0.
--! The condition "magnitude /= 0" is taken from neg(7), i.e. from the carry chain
--! of the incrementer, without an additional zero detector.
--! @image html 38_rtl.png "RTL view of the optimized realization" width=600
--! @image html 38_waveform.png "Simulation of both realizations for representative input values" width=100%
--!
--! Resource usage from the Quartus Flow Summary:
--!
--! | Resource   | Basic | Optimized |
--! |------------|------:|----------:|
--! | ALMs       |    12 |         9 |
--! | Registers  |     0 |         0 |
--! | DSP blocks |     0 |         0 |
--!
--! - difference: 3 ALMs (25 % less than the basic realization)
--! - removed: one 8-bit negation circuit (complementer + incrementer)
--! - reduced: three multiplexers of the basic realization (two selected by
--!   data_i(7) and one by mode_i) to a single 7-bit multiplexer for the magnitude
--! - added: two logic gates for the sign bit (signal sgn)
--! - the savings are in combinational logic, neither realization uses registers

architecture arch of sign_magnitude_converter is

  --! Operand of the shared negation: magnitude extended with zero
  signal src : unsigned(7 downto 0);

  --! Shared negation: (-magnitude) mod 256; neg(7) = '1' iff magnitude /= 0
  signal neg : unsigned(7 downto 0);

  --! Magnitude of the result (lower seven bits)
  signal mag : std_logic_vector(6 downto 0);

  --! Sign bit of the result
  signal sgn : std_logic;

begin

  -- Single negation circuit, shared by both conversion directions
  src <= '0' & unsigned(data_i(6 downto 0));
  neg <= (not src) + 1;

  -- Magnitude: pass through for a non-negative input, negated otherwise
  mag <= data_i(6 downto 0) when data_i(7) = '0' else
         std_logic_vector(neg(6 downto 0));

  -- Sign bit: the only place where mode_i enters the logic
  sgn <= data_i(7) and ((not mode_i) or neg(7));

  -- Output
  data_o <= sgn & mag;

end architecture arch;
