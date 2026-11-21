-----------------------------------------------------------------------------
--
-- unit name:     DUAL_MODE_LEADING_COUNTER_BASIC
--
-- description:
--
--   This file implements a counter of leading zeros or leading ones of a
--   16-bit input word using two independent counters and a multiplexer.
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

--! @file dual_mode_leading_counter_basic.vhd
--! @brief dual-mode leading zero/one counter (basic implementation)

--! Use standard library

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--! @brief dual-mode leading zero/one counter (basic implementation)
--! @details Counts the consecutive leading zeros (mode_i = '0') or the
--! consecutive leading ones (mode_i = '1') of the 16-bit input data_i,
--! starting from the most significant bit. The result count_o is in the
--! range from 0 to 16.

entity dual_mode_leading_counter_basic is
  port (
    data_i  : in    std_logic_vector(15 downto 0); --! 16-bit input data
    mode_i  : in    std_logic;                     --! mode select ('0' - zeros, '1' - ones)
    count_o : out   std_logic_vector(4 downto 0)); --! number of leading zeros/ones
end entity dual_mode_leading_counter_basic;

--! @brief Architecture with two independent counters and a multiplexer
--! @details A leading zero counter and a leading one counter work in parallel
--! on the same input data. A 5-bit 2-to-1 multiplexer controlled by mode_i
--! selects one of the two results.
--!
--! @image html 39_basic_rtl.png "RTL view of the basic implementation"

architecture arch of dual_mode_leading_counter_basic is

  signal zeros_count_s : unsigned(4 downto 0); --! Number of leading zeros
  signal ones_count_s  : unsigned(4 downto 0); --! Number of leading ones

begin

  --! Leading zero counter. Counts from the MSB down and stops at the first one.
  leading_zeros : process(data_i) is

    variable count_v : unsigned(4 downto 0);

  begin

    count_v := (others => '0');

    for i in 15 downto 0 loop

      exit when data_i(i) = '1';
      count_v := count_v + 1;

    end loop;

    zeros_count_s <= count_v;

  end process leading_zeros;

  --! Leading one counter. Counts from the MSB down and stops at the first zero.
  leading_ones : process(data_i) is

    variable count_v : unsigned(4 downto 0);

  begin

    count_v := (others => '0');

    for i in 15 downto 0 loop

      exit when data_i(i) = '0';
      count_v := count_v + 1;

    end loop;

    ones_count_s <= count_v;

  end process leading_ones;

  --! Output multiplexer
  count_o <= std_logic_vector(ones_count_s) when mode_i = '1' else
             std_logic_vector(zeros_count_s);

end architecture arch;
