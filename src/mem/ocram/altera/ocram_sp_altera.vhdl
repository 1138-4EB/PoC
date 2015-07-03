-- EMACS settings: -*-  tab-width: 2; indent-tabs-mode: t -*-
-- vim: tabstop=2:shiftwidth=2:noexpandtab
-- kate: tab-width 2; replace-tabs off; indent-width 2;
-- 
-- ============================================================================
-- Authors:					Martin Zabel
--									Patrick Lehmann
--
-- Module:				 	Instantiate single-port memory on Altera FPGAs.
-- 
-- Description:
-- ------------------------------------
-- Quartus synthesis does not infer this RAM type correctly.
-- Instead, altsyncram is instantiated directly.
--
-- For further documentation see module "ocram_sp" 
-- (src/mem/ocram/ocram_sp.vhdl).
--
-- License:
-- ============================================================================
-- Copyright 2008-2015 Technische Universitaet Dresden - Germany
--										 Chair for VLSI-Design, Diagnostics and Architecture
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--		http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- ============================================================================

library	IEEE;
use			IEEE.std_logic_1164.all;
use			IEEE.numeric_std.all;

library	altera_mf;
use			altera_mf.all;


entity ocram_sp_altera is
	generic (
		A_BITS		: positive;
		D_BITS		: positive;
		FILENAME	: STRING		:= ""
	);
	port (
		clk : in	std_logic;
		ce	: in	std_logic;
		we	: in	std_logic;
		a		: in	unsigned(A_BITS-1 downto 0);
		d		: in	std_logic_vector(D_BITS-1 downto 0);
		q		: out std_logic_vector(D_BITS-1 downto 0)
	);
end ocram_sp_altera;


architecture rtl of ocram_sp_altera is
	component altsyncram
		generic (
			address_aclr_a					: STRING;
			indata_aclr_a						: STRING;
			init_file								: STRING;
			intended_device_family	: STRING;
			lpm_hint								: STRING;
			lpm_type								: STRING;
			numwords_a							: NATURAL;
			operation_mode					: STRING;
			outdata_aclr_a					: STRING;
			outdata_reg_a						: STRING;
			power_up_uninitialized	: STRING;
			widthad_a								: NATURAL;
			width_a									: NATURAL;
			width_byteena_a					: NATURAL;
			wrcontrol_aclr_a				: STRING
			);
		port (
			clocken0	: in	STD_LOGIC;
			wren_a		: in	STD_LOGIC;
			clock0		: in	STD_LOGIC;
			address_a : in	STD_LOGIC_VECTOR(widthad_a-1 downto 0);
			q_a				: out STD_LOGIC_VECTOR(width_a-1 downto 0);
			data_a		: in	STD_LOGIC_VECTOR(width_a-1 downto 0)
			);
	end component;

	constant DEPTH			: positive	:= 2**A_BITS;
	constant INIT_FILE	: STRING		:= ite((str_length(FILENAME) = 0), "UNUSED", FILENAME);
	
	signal a_sl : std_logic_vector(A_BITS-1 downto 0);

begin
	a_sl <= std_logic_vector(a);

	mem : altsyncram
		generic map (
			address_aclr_a					=> "NONE",
			indata_aclr_a						=> "NONE",
			init_file								=> INIT_FILE,
			intended_device_family	=> "Stratix",
			lpm_hint								=> "ENABLE_RUNTIME_MOD = NO",
			lpm_type								=> "altsyncram",
			numwords_a							=> DEPTH,
			operation_mode					=> "SINGLE_PORT",
			outdata_aclr_a					=> "NONE",
			outdata_reg_a						=> "UNREGISTERED",
			power_up_uninitialized	=> "FALSE",
			widthad_a								=> A_BITS,
			width_a									=> D_BITS,
			width_byteena_a					=> 1,
			wrcontrol_aclr_a				=> "NONE"
		)
		port map (
			clocken0								=> ce,
			wren_a									=> we,
			clock0									=> clk,
			address_a								=> a_sl,
			data_a									=> d,
			q_a											=> q
		);
end rtl;