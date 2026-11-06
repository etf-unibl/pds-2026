-----------------------------------------------------------------------------
--
-- unit name:     four_bit_full_subtractor_tb
--
-- description:
--
--   This file implements a testbench for simple full subtractor circuit.
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
--! @brief four bit full subtractor testbench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_bit_full_subtractor_tb is
-- Testbench entitet nema portove
end entity four_bit_full_subtractor_tb;

architecture arch of four_bit_full_subtractor_tb is

  -- 1. Deklaracija komponente koja se testira (UUT)
  component four_bit_full_subtractor is
    port (
      a_i   : in    std_logic_vector(3 downto 0);
      b_i   : in    std_logic_vector(3 downto 0);
      c_i   : in    std_logic;
      sub_o : out   std_logic_vector(3 downto 0);
      c_o   : out   std_logic);
  end component four_bit_full_subtractor;

  -- 2. Interni signali za povezivanje sa UUT
  signal a_i_tb   : std_logic_vector(3 downto 0);
  signal b_i_tb   : std_logic_vector(3 downto 0);
  signal c_i_tb   : std_logic;
  signal sub_o_tb : std_logic_vector(3 downto 0);
  signal c_o_tb   : std_logic;

begin

  -- 3. Instanciranje jedinice koja se testira (Port Map)
  uut : component four_bit_full_subtractor
    port map (
      a_i   => a_i_tb,
      b_i   => b_i_tb,
      c_i   => c_i_tb,
      sub_o => sub_o_tb,
      c_o   => c_o_tb);

  -- 4. Proces za generisanje stimulusa (Testni scenariji)
  stim_proc : process is
  begin

    -- Vrijeme stabilizacije na pocetku
    wait for 20 ns;

    -- Test 1: Standardno oduzimanje bez pozajmice (7 - 3 = 4)
    a_i_tb <= "0111"; -- 7
    b_i_tb <= "0011"; -- 3
    c_i_tb <= '0';
    wait for 20 ns;

    -- Test 2: Rezultat nula (12 - 12 = 0)
    a_i_tb <= "1100"; -- 12
    b_i_tb <= "1100"; -- 12
    c_i_tb <= '0';
    wait for 20 ns;

    -- Test 3: Maksimalne vrijednosti (15 - 1 = 14)
    a_i_tb <= "1111"; -- 15
    b_i_tb <= "0001"; -- 1
    c_i_tb <= '0';
    wait for 20 ns;

    -- Test 4: Negativan rezultat / Underflow (2 - 5 = -3)
    -- U 4-bitnom neoznacenom kodu ovo daje "1101" (13) uz izlaznu pozajmicu c_o = '1'
    a_i_tb <= "0010"; -- 2
    b_i_tb <= "0101"; -- 5
    c_i_tb <= '0';
    wait for 20 ns;

    -- Test 5: Oduzimanje uz prisustvo ulazne pozajmice c_i (10 - 4 - 1 = 5)
    a_i_tb <= "1010"; -- 10
    b_i_tb <= "0100"; -- 4
    c_i_tb <= '1';    -- c_i aktivno
    wait for 20 ns;

    -- Kraj simulacije
    wait;

  end process stim_proc;

end architecture arch;
