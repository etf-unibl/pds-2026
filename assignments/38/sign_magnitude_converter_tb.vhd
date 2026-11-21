-----------------------------------------------------------------------------
--
-- unit name:     sign_magnitude_converter_tb
--
-- description:
--
--   This file implements a self-checking testbench for the bidirectional 8-bit
--   sign-magnitude converter. It instantiates both basic and optimized versions,
--   applies identical stimuli, and compares their outputs with a reference model.
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

--! @file sign_magnitude_converter_tb.vhd
--! @brief Self-checking testbench for the sign-magnitude converter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--! @brief Testbench entity

entity sign_magnitude_converter_tb is
end entity sign_magnitude_converter_tb;

--! @brief Architecture of the testbench
--! @details Instantiates both converters, applies all 256 input values in both
--! directions (512 cases) and checks them against a reference model. Six
--! characteristic values are then repeated to give a short waveform segment.

architecture arch of sign_magnitude_converter_tb is

  -- Basic component declaration
  component sign_magnitude_converter_basic is
    port (
      data_i : in    std_logic_vector(7 downto 0);
      mode_i : in    std_logic;
      data_o : out   std_logic_vector(7 downto 0));
  end component sign_magnitude_converter_basic;

  -- Optimized component declaration
  component sign_magnitude_converter is
    port (
      data_i : in    std_logic_vector(7 downto 0);
      mode_i : in    std_logic;
      data_o : out   std_logic_vector(7 downto 0));
  end component sign_magnitude_converter;

  -- Testbench signals
  signal data_i       : std_logic_vector(7 downto 0);
  signal mode_i       : std_logic;
  signal data_basic_o : std_logic_vector(7 downto 0);
  signal data_opt_o   : std_logic_vector(7 downto 0);
  signal data_exp_o   : std_logic_vector(7 downto 0);
  -- Duration of one test case
  constant c_STEP : time := 10 ns;
  -- Conversion directions used in the test loops

  type t_mode_array is array (0 to 1) of std_logic;

  constant c_MODES : t_mode_array := ('0', '1');
  -- Definition of an array of characteristic values (edge and asymmetric cases)

  type t_vector_array is array (natural range <>) of std_logic_vector(7 downto 0);

  constant c_DEMO : t_vector_array :=
  (
    "00000000",
    "00000101",
    "01111111",
    "10000000",
    "10000101",
    "11111111"
  );
  -- Reference model: conversion described with integer arithmetic, independent
  -- of the designs under test

  function golden (
    constant d : in std_logic_vector(7 downto 0);
    constant m : in std_logic
  ) return std_logic_vector
  is

    variable v : integer;
    variable a : integer;
    variable r : std_logic_vector(7 downto 0);

  begin

    if m = '0' then
      -- two's complement -> sign-magnitude
      v := to_integer(signed(d));
      if v >= 0 then
        r := d;
      elsif v = -128 then
        r := "10000000"; -- no representation in sign-magnitude
      else
        r := std_logic_vector(to_unsigned(128 - v, 8));
      end if;
    else
      -- sign-magnitude -> two's complement
      a := to_integer(unsigned(d(6 downto 0)));
      if d(7) = '0' then
        r := d;
      elsif a = 0 then
        r := "00000000"; -- "-0" is converted to +0
      else
        r := std_logic_vector(to_unsigned(256 - a, 8));
      end if;
    end if;

    return r;

  end function golden;

begin

  -- Instantiate basic converter
  dut_basic : component sign_magnitude_converter_basic
    port map (
      data_i => data_i,
      mode_i => mode_i,
      data_o => data_basic_o);

  -- Instantiate optimized converter
  dut_opt : component sign_magnitude_converter
    port map (
      data_i => data_i,
      mode_i => mode_i,
      data_o => data_opt_o);

  -- Stimulus and checking process
  stim_proc : process is

    variable errors : natural;
    variable exp    : std_logic_vector(7 downto 0);
    -- Applies one input combination and checks both realizations

    procedure apply (
      constant d : in std_logic_vector(7 downto 0);
      constant m : in std_logic
    ) is
    begin

      data_i     <= d;
      mode_i     <= m;
      exp        := golden(d, m);
      data_exp_o <= exp;
      -- Wait for signals to propagate
      wait for c_STEP;
      -- Check basic realization and print inputs on error
      assert data_basic_o = exp
        report "BASIC: mode=" & std_logic'image(m) &
               " input=" & integer'image(to_integer(unsigned(d))) &
               " expected=" & integer'image(to_integer(unsigned(exp))) &
               " got=" & integer'image(to_integer(unsigned(data_basic_o)))
        severity error;
      -- Check optimized realization and print inputs on error
      assert data_opt_o = exp
        report "OPT: mode=" & std_logic'image(m) &
               " input=" & integer'image(to_integer(unsigned(d))) &
               " expected=" & integer'image(to_integer(unsigned(exp))) &
               " got=" & integer'image(to_integer(unsigned(data_opt_o)))
        severity error;

      if data_basic_o /= exp or data_opt_o /= exp then
        errors := errors + 1;
      end if;

    end procedure apply;

  begin

    errors := 0;
    -- Phase 1: all 256 input values in both directions (512 cases)
    for mi in c_MODES'range loop

      for di in 0 to 255 loop

        apply(std_logic_vector(to_unsigned(di, 8)), c_MODES(mi));

      end loop;

    end loop;

    -- Phase 2: representative segment used for the waveform image
    for mi in c_MODES'range loop

      for k in c_DEMO'range loop

        apply(c_DEMO(k), c_MODES(mi));

      end loop;

    end loop;

    -- Final result of the self-checking test
    if errors = 0 then
      report "PASS: both realizations correct for all 512 cases."
        severity note;
    else
      report "FAIL: " & integer'image(errors) & " incorrect outputs."
        severity failure;
    end if;

    wait;

  end process stim_proc;

end architecture arch;
