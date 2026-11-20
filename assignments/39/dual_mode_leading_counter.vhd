-----------------------------------------------------------------------------
--
-- unit name:     DUAL_MODE_LEADING_COUNTER
--
-- description:
--
--   This file implements a counter of leading zeros or leading ones of a
--   16-bit input word using a single shared leading zero counter.
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

--! @file dual_mode_leading_counter.vhd
--! @brief dual-mode leading zero/one counter (optimized implementation)

--! Use standard library

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief dual-mode leading zero/one counter (optimized implementation)
--! @details Counts the consecutive leading zeros (mode_i = '0') or the
--! consecutive leading ones (mode_i = '1') of the 16-bit input data_i,
--! starting from the most significant bit. The result count_o is in the
--! range from 0 to 16.

entity dual_mode_leading_counter is
  port (
    data_i  : in    std_logic_vector(15 downto 0); --! 16-bit input data
    mode_i  : in    std_logic;                     --! mode select ('0' - zeros, '1' - ones)
    count_o : out   std_logic_vector(4 downto 0)); --! number of leading zeros/ones
end entity dual_mode_leading_counter;

--! @brief Architecture with a single shared leading zero counter
--! @details The number of leading ones of a word equals the number of leading
--! zeros of its complement. The input data is therefore conditionally
--! inverted (each bit is xor-ed with mode_i) and a single leading zero
--! counter is used for both modes. Instead of two counters and an output
--! multiplexer, the design needs one counter and 16 xor gates at the input.
--! This is functionality sharing: the leading zero counter is reused for
--! the second function based on the relation between the two functions.
--! The xor with mode_i is equivalent to the multiplexer
--! (data_i when mode_i = '0' else not data_i).
--!
--! @image html 39_rtl.png "RTL view of the optimized implementation"
--!
--! Resource usage (Flow Summary, Cyclone V 5CSEMA5F31C6, DE1-SoC):
--!
--! | Implementation                    | ALMs |
--! |-----------------------------------|------|
--! | dual_mode_leading_counter_basic   | 25   |
--! | dual_mode_leading_counter         | 15   |
--!
--! The optimized implementation uses 10 ALMs less than the basic one
--! (40 % savings). It has one leading zero counter instead of two and no
--! output multiplexer, while the 16 xor gates at the input are merged into
--! the LUTs of the first counter stage.
--!
--! @image html 39_waveform.png "Simulation: both implementations give the same, expected results"

architecture arch of dual_mode_leading_counter is

  signal mode_mask_s : std_logic_vector(15 downto 0); --! mode_i extended to 16 bits
  signal data_x_s    : std_logic_vector(15 downto 0); --! Conditionally inverted input data
  signal count_s     : unsigned(4 downto 0);          --! Number of leading zeros of data_x_s

begin

  --! Input processing: for mode_i = '1' the data is inverted, so the
  --! leading ones become leading zeros
  mode_mask_s <= (others => mode_i);
  data_x_s    <= data_i xor mode_mask_s;

  --! Shared leading zero counter. Counts from the MSB down and stops at the first one.
  leading_zeros : process(data_x_s) is

    variable count_v : unsigned(4 downto 0);

  begin

    count_v := (others => '0');

    for i in 15 downto 0 loop

      exit when data_x_s(i) = '1';
      count_v := count_v + 1;

    end loop;

    count_s <= count_v;

  end process leading_zeros;

  --! Output
  count_o <= std_logic_vector(count_s);

end architecture arch;
