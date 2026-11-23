-----------------------------------------------------------------------------
--
-- unit name:     sign_magnitude_converter_basic
--
-- description:
--
--   This file implements the basic realization of a bidirectional converter
--   between 8-bit two's complement and sign-magnitude format. It uses two
--   independent converters, each with its own negation circuit, and an output
--   multiplexer controlled by the mode_i signal.
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

--! @file sign_magnitude_converter_basic.vhd
--! @brief Basic bidirectional 8-bit sign-magnitude converter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief Basic 8-bit two's complement <-> sign-magnitude converter
--! @details This entity converts a two's complement number into sign-magnitude
--! (mode_i = '0') or vice versa (mode_i = '1'), with separate logic for each
--! direction, multiplexed to the output based on the mode.

entity sign_magnitude_converter_basic is
  port (
    data_i : in    std_logic_vector(7 downto 0);  --! Input number
    mode_i : in    std_logic;                     --! Direction: '0' TC->SM, '1' SM->TC
    data_o : out   std_logic_vector(7 downto 0)); --! Converted number
end entity sign_magnitude_converter_basic;

--! @brief Architecture using two separate converters and a multiplexer
--! @details Contains distinct data paths for TC->SM and SM->TC conversion, each
--! with its own complementer and incrementer. Non-negative numbers have the same
--! representation in both formats and are passed through, while the special
--! cases -128 and "-0" follow directly from the modular arithmetic.
--! @image html 38_basic_rtl.png "RTL view of the basic realization" width=600

architecture arch of sign_magnitude_converter_basic is

  --! Negation of the input word: (-data_i) mod 256
  signal neg_tc : unsigned(7 downto 0);

  --! Magnitude extended with zero to eight bits
  signal mag : unsigned(7 downto 0);

  --! Negation of the magnitude: (-(0 & magnitude)) mod 256
  signal neg_sm : unsigned(7 downto 0);

  --! Output of the TC->SM converter
  signal tc2sm : std_logic_vector(7 downto 0);

  --! Output of the SM->TC converter
  signal sm2tc : std_logic_vector(7 downto 0);

begin

  -- TC -> SM: bit 7 of the negation is discarded and the sign is forced to '1',
  -- so -128 is converted into "10000000"
  neg_tc <= (not unsigned(data_i)) + 1;
  tc2sm  <= data_i when data_i(7) = '0' else
            '1' & std_logic_vector(neg_tc(6 downto 0));

  -- SM -> TC: the magnitude is extended with zero before negation, so the sign
  -- bit does not enter the arithmetic and "-0" is converted into "00000000"
  mag    <= '0' & unsigned(data_i(6 downto 0));
  neg_sm <= (not mag) + 1;
  sm2tc  <= data_i when data_i(7) = '0' else
            std_logic_vector(neg_sm);

  -- Multiplexer
  data_o <= tc2sm when mode_i = '0' else
            sm2tc;

end architecture arch;
