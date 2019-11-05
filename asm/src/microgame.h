//////////////////////////////////////////////////////////////////////////////
//
//    Microgame Assembler
//    (derived from MIPS Tools) Copyright (C) 2019 Winor Chen
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License along
//    with this program; if not, write to the Free Software Foundation, Inc.,
//    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//////////////////////////////////////////////////////////////////////////////
#ifndef __MICROGAME_H__
#define __MICROGAME_H__


/* A header for mips specifc details
 * such as register name mappings
 * and a jump list for functional routines
 *
 * Instruction Formats:
 * R - 6 opcode, 5 rs, 5 rt, 5 rd (Register)
 * I - 6 opcode, 5 r1, 5 r1, 16 imm / addr (Immediate)
 * M - 6 opcode, 5 r1, 5 unused, 16 addr / imm / unused (Mono-Register)
 * B - 6 opcode, 3 cc, 8 unused, 16 addr (Branch)
 * S - 6 opcode, 3 rsprite / unused, 2 cc / unused, 8 unused, 8 axis_1 / unused, 8 axis_2 / unused (Special)
 * N - 6 opcode (SiNgleton Operand)
 * 
 *
 * wchen329
 */
#include <cstring>
#include <cstddef>
#include <memory>
#include "mt_exception.h"
#include "primitives.h"
#include "aliases.h"
#include "syms_table.h"

namespace asmrunner
{

	// Friendly Register Names -> Numerical Assignments
	enum REGISTERS
	{
		$zero = 0,
		$at = 1,
		$v0 = 2,
		$v1 = 3,
		$a0 = 4,
		$a1 = 5,
		$a2 = 6,
		$a3 = 7,
		$t0 = 8,
		$t1 = 9,
		$t2 = 10,
		$t3 = 11,
		$t4 = 12,
		$t5 = 13,
		$t6 = 14,
		$t7 = 15,
		$s0 = 16,
		$s1 = 17,
		$s2 = 18,
		$s3 = 19,
		$s4 = 20,
		$s5 = 21, $s6 = 22,
		$s7 = 23,
		$t8 = 24,
		$t9 = 25,
		$k0 = 26,
		$k1 = 27,
		$gp = 28,
		$sp = 29,
		$fp = 30,
		$ra = 31,
		INVALID = -1
	};

	// MIPS Processor Opcodes
	enum opcode
	{
		ADD = 0,
		ADDI = 1,
		SUB = 2,
		AND = 3,
		ANDI = 4,
		OR = 5,
		ORI = 99,
		XOR = 6,
		SLL = 7,
		SRL = 8,
		SRA = 9,
		LUI = 10,
		LLI = 11,
		LW = 12,
		SW = 13,
		LWO = 14,
		SWO = 15,
		B = 16,
		JL = 101,
		RET = 100,
		LK = 17,
		WFB = 18,
		DFB = 19,
		LS = 20,
		DS = 21,
		CS = 22,
		RS = 23,
		SAT = 24,
		DC = 25,
		TIM = 26,
		R = 27,
		SR = 28,
		NOP =  -1
	};

	int friendly_to_numerical(const char *);

	
	// Format check functions
	/* Checks if an instruction is I formatted.
	 */
	bool i_inst(opcode operation);

	/* Checks if an instruction is R formatted.
	 */
	bool r_inst(opcode operation);

	/* Checks if an instruction is M formatted.
	 */
	bool m_inst(opcode operation);

	/* Checks if an instruction is B formatted.
	 */
	bool b_inst(opcode operation);

	/* Checks if an instruction is S formatted.
	 */
	bool s_inst(opcode operation);

	/* Checks if an instruction is N formatted.
	 */
	bool n_inst(opcode operation);

	/* Alias for b inst.
	 *
	 */
	bool j_inst(opcode operation);

	/* Check if a MEMORY OFFSET instruction
	 */
	bool mem_inst(opcode operation);

	/* "Generic" MIPS-32 architecture
	 * encoding function asm -> binary
	 */
	BW_32 generic_mips32_encode(int rs, int rt, int rd, int imm, int cc, int rsprite, opcode op, int x, int y);

	/* For calculating a label offset in branches
	 */
	BW_32 offset_to_address_br(BW_32 current, BW_32 target);

	std::shared_ptr<BW> assemble(std::vector<std::string>& args, BW& baseAddress, syms_table& jump_syms);

	/* Microgame ISA
	 *
	 */
	class Microgame
	{
		
		public:
			unsigned get_reg_count() { return REG_COUNT; }
			virtual unsigned get_address_bit_width() { return PC_BIT_WIDTH; }
			virtual std::string get_reg_name(int id);
			virtual int get_reg_id(std::string& fr) { return friendly_to_numerical(fr.c_str()); }
			virtual int get_register_bit_width(int id) { return UNIVERSAL_REG_BW; }
			virtual std::shared_ptr<BW> assemble(std::vector<std::string>& args, BW& baseAddress, syms_table& jump_syms);
		private:
			static const unsigned REG_COUNT = 32;
			static const unsigned PC_BIT_WIDTH = 32;
			static const unsigned UNIVERSAL_REG_BW = 32;
	};

	enum CondCondes
	{
		CCNE = 0,
		CCEQ = 1,
		CCGT = 2,
		CCLT = 3,
		CCGTE = 4,
		CCLTE = 5,
		CCOFLOW = 6,
		CCUNCOND = 7
	};
}

#endif
