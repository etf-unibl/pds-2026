-----------------------------------------------------------------------------
--
-- unit name:     three_mode_barrel_shifter_basic
--
-- description:
--
--   This file implements an 8-bit three-mode barrel shifter (rotate right,
--   logical shift right, arithmetic shift right) using three independent
--   shifters and a multiplexer.
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

--! @file three_mode_barrel_shifter_basic.vhd
--! @brief Three-mode barrel shifter, basic implementation

library ieee;
use ieee.std_logic_1164.all;

--! @brief Three-mode barrel shifter, basic implementation
--! @details The 8-bit input a_i holds the data on which the selected operation
--! is performed. The operation is selected by the 2-bit vector lar_i, and the
--! number of positions to shift right (or rotate) by the 3-bit vector amt_i.
--! The output y_o is the shifted a_i.

entity three_mode_barrel_shifter_basic is
  port (
    a_i   : in    std_logic_vector(7 downto 0);  --! Input vector
    lar_i : in    std_logic_vector(1 downto 0);  --! Shift mode select
    amt_i : in    std_logic_vector(2 downto 0);  --! Number of positions to shift
    y_o   : out   std_logic_vector(7 downto 0)); --! Output vector
end entity three_mode_barrel_shifter_basic;

--! @brief Basic architecture with three independent shifters
--! @details The architecture consists of three independent processes, each
--! implementing one type of shifter. Every process produces a shifted version
--! of the input vector a_i. Which of these results is forwarded to y_o is
--! decided by a 4:1 multiplexer controlled by lar_i.
--! If lar_i = "00", the input is rotated right, so y_o <= s_ror.
--! If lar_i = "01", a logical shift right is performed, inserting zeros on the
--! left (most significant) side, so y_o <= s_srl.
--! If lar_i = "10", an arithmetic shift right is performed, inserting copies of
--! the sign bit on the left, so y_o <= s_sra.
--! If lar_i = "11", the input is passed through unchanged, so y_o <= a_i.

architecture arch of three_mode_barrel_shifter_basic is

  --! Internal signal for rotation
  signal s_ror : std_logic_vector(7 downto 0);
  --! Internal signal for logical shift
  signal s_srl : std_logic_vector(7 downto 0);
  --! Internal signal for arithmetic shift
  signal s_sra : std_logic_vector(7 downto 0);

begin

  --! @brief Process implementing the rotate-right shifter
  --! @details This process rotates the vector a_i to the right. Bits that
  --! "fall off" the right side re-enter the vector at the most significant
  --! positions. It is implemented with a case statement, where each branch
  --! corresponds to a rotation amount given by amt_i (from 0 to 7).
  shift_rotate : process(a_i, amt_i) is
  begin

    s_ror <= a_i;

    case amt_i is

      when "000" =>

        s_ror <= (a_i(7 downto 0));

      when "001" =>

        s_ror <= (a_i(0) & a_i(7 downto 1));

      when "010" =>

        s_ror <= (a_i(1 downto 0) & a_i(7 downto 2));

      when "011" =>

        s_ror <= (a_i(2 downto 0) & a_i(7 downto 3));

      when "100" =>

        s_ror <= (a_i(3 downto 0) & a_i(7 downto 4));

      when "101" =>

        s_ror <= (a_i(4 downto 0) & a_i(7 downto 5));

      when "110" =>

        s_ror <= (a_i(5 downto 0) & a_i(7 downto 6));

      when "111" =>

        s_ror <= (a_i(6 downto 0) & a_i(7));

      when others =>

        null;

    end case;

  end process shift_rotate;

  --! @brief Process implementing the logical shift right
  --! @details This process performs a logical shift right, filling the most
  --! significant bit positions with zeros. It is implemented with a case
  --! statement, where each branch corresponds to a shift amount given by
  --! amt_i (from 0 to 7).
  shift_right_logical : process(a_i, amt_i) is
  begin

    s_srl <= a_i;

    case amt_i is

      when "000" =>

        s_srl <= (a_i(7 downto 0));

      when "001" =>

        s_srl <= ((7 downto 7 => '0') & a_i(7 downto 1));

      when "010" =>

        s_srl <= ((7 downto 6 => '0') & a_i(7 downto 2));

      when "011" =>

        s_srl <= ((7 downto 5 => '0') & a_i(7 downto 3));

      when "100" =>

        s_srl <= ((7 downto 4 => '0') & a_i(7 downto 4));

      when "101" =>

        s_srl <= ((7 downto 3 => '0') & a_i(7 downto 5));

      when "110" =>

        s_srl <= ((7 downto 2 => '0') & a_i(7 downto 6));

      when "111" =>

        s_srl <= ((7 downto 1 => '0') & a_i(7 downto 7));

      when others =>

        null;

    end case;

  end process shift_right_logical;

  --! @brief Process implementing the arithmetic shift right
  --! @details This process performs an arithmetic shift right, filling the most
  --! significant bit positions with the sign bit of a_i, i.e. a_i(7).
  --! It is implemented with a case statement, where each branch corresponds
  --! to a shift amount given by amt_i (from 0 to 7).
  shift_right_aritm : process(a_i, amt_i) is
  begin

    s_sra <= a_i;

    case amt_i is

      when "000" =>

        s_sra <= (a_i(7 downto 0));

      when "001" =>

        s_sra <= ((7 downto 7 => a_i(7)) & a_i(7 downto 1));

      when "010" =>

        s_sra <= ((7 downto 6 => a_i(7)) & a_i(7 downto 2));

      when "011" =>

        s_sra <= ((7 downto 5 => a_i(7)) & a_i(7 downto 3));

      when "100" =>

        s_sra <= ((7 downto 4 => a_i(7)) & a_i(7 downto 4));

      when "101" =>

        s_sra <= ((7 downto 3 => a_i(7)) & a_i(7 downto 5));

      when "110" =>

        s_sra <= ((7 downto 2 => a_i(7)) & a_i(7 downto 6));

      when "111" =>

        s_sra <= ((7 downto 1 => a_i(7)) & a_i(7 downto 7));

      when others =>

        null;

    end case;

  end process shift_right_aritm;

  --! @brief Output multiplexer
  --! @details Selects the output signal y_o based on lar_i.
  with lar_i select y_o <=
    s_ror when "00",
    s_sra when "10",
    s_srl when "01",
    a_i when others;

end architecture arch;
