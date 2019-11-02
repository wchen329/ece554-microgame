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
#include "microgame.h"

namespace asmrunner
{
	int friendly_to_numerical(const char * fr_name)
	{
		int len = strlen(fr_name);
		if(len < 2) return INVALID;

		REGISTERS reg_val
			=
			// Can optimize based off of 
			fr_name[1] == 'a' ?
				!strcmp("$a0", fr_name) ? $a0 :
				!strcmp("$a1", fr_name) ? $a1 :
				!strcmp("$a2", fr_name) ? $a2 :
				!strcmp("$a3", fr_name) ? $a3 :
				!strcmp("$at", fr_name) ? $at : INVALID
			:

			fr_name[1] == 'f' ?
				!strcmp("$fp", fr_name) ? $fp : INVALID
			:

			fr_name[1] == 'g' ?
				!strcmp("$gp", fr_name) ? $gp : INVALID
			:

			fr_name[1] == 'k' ?
				!strcmp("$k0", fr_name) ? $k0 :
				!strcmp("$k1", fr_name) ? $k1 : INVALID
			:

			fr_name[1] == 'r' ?
				!strcmp("$ra", fr_name) ? $ra : INVALID
			:

			fr_name[1] == 's' ?
				!strcmp("$s0", fr_name) ? $s0 :
				!strcmp("$s1", fr_name) ? $s1 :
				!strcmp("$s2", fr_name) ? $s2 :
				!strcmp("$s3", fr_name) ? $s3 :
				!strcmp("$s4", fr_name) ? $s4 :
				!strcmp("$s5", fr_name) ? $s5 :
				!strcmp("$s6", fr_name) ? $s6 :
				!strcmp("$s7", fr_name) ? $s7 :
				!strcmp("$sp", fr_name) ? $sp : INVALID
			:

			fr_name[1] == 't' ?
				!strcmp("$t0", fr_name) ? $t0 :
				!strcmp("$t1", fr_name) ? $t1 :
				!strcmp("$t2", fr_name) ? $t2 :
				!strcmp("$t3", fr_name) ? $t3 :
				!strcmp("$t4", fr_name) ? $t4 :
				!strcmp("$t5", fr_name) ? $t5 :
				!strcmp("$t6", fr_name) ? $t6 :
				!strcmp("$t7", fr_name) ? $t7 :
				!strcmp("$t8", fr_name) ? $t8 :
				!strcmp("$t9", fr_name) ? $t9 : INVALID
			:

			fr_name[1] == 'v' ?
				!strcmp("$v0", fr_name) ? $v0 :
				!strcmp("$v1", fr_name) ? $v1 : INVALID
			:
			fr_name[1] == 'z' ?
				!strcmp("$zero", fr_name) ? $zero : INVALID
			: INVALID;

		return reg_val;
	}

	std::string get_reg_name(int id)
	{
		std::string name =
			id == 0 ? "$zero" :
			id == 1 ? "$at" :
			id == 2 ? "$v0" :
			id == 3 ? "$v1" :
			id == 4 ? "$a0" :
			id == 5 ? "$a1" :
			id == 6 ? "$a2" :
			id == 7 ? "$a3" :
			id == 8 ? "$t0" :
			id == 9 ? "$t1" :
			id == 10 ? "$t2" :
			id == 11 ? "$t3" :
			id == 12 ? "$t4" :
			id == 13 ? "$t5" :
			id == 14 ? "$t6" :
			id == 15 ? "$t7" :
			id == 16 ? "$s0" :
			id == 17 ? "$s1" :
			id == 18 ? "$s2" :
			id == 19 ? "$s3" :
			id == 20 ? "$s4" : id == 21 ? "$s5" :
			id == 22 ? "$s6" :
			id == 23 ? "$s7" :
			id == 24 ? "$t8" :
			id == 25 ? "$t9" :
			id == 26 ? "$k0" :
			id == 27 ? "$k1" :
			id == 28 ? "$gp" :
			id == 29 ? "$sp" :
			id == 30 ? "$fp" :
			id == 31 ? "$ra" : "";
		
		if(name == "")
		{
			throw reg_oob_exception();
		}
		
		return name;
	}

	bool r_inst(opcode operation)
	{
		return
		
			operation == ADD ? true :
			operation == SUB? true :
			operation == AND ? true :
			operation == OR ? true :
			operation == XOR ? true :
			operation == DC ? true :
			false ;
	}

	bool i_inst(opcode operation)
	{
		return
			operation == ADDI ? true :
			operation == ANDI ? true :
			operation == SLL ? true :
			operation == SRA ? true :
			operation == SRL ? true :
			operation == LWO ? true :
			operation == SWO ? true :
			false ;
	}

	bool m_inst(opcode operation)
	{
		return
			operation == LUI ? true :
			operation == LLI ? true :
			operation == LW ? true :
			operation == SW ? true :
			operation == LK ? true :
			operation == R ? true :
			operation == SAT ? true :
			operation == SR ? true :
			false;
	}

	bool b_inst(opcode operation)
	{
		return
			operation == B ? true :
			operation == JL ? true :
			false;
	}

	bool s_inst(opcode operation)
	{
		return
			operation == WFB ? true :
			operation == LS ? true :
			operation == DS ? true :
			operation == CS ? true :
			operation == RS ? true :
			false;
	}

	bool j_inst(opcode operation)
	{
		return b_inst(operation);
	}

	bool n_inst(opcode operation)
	{
		return
			operation == RET ? true :
			operation == DFB ? true :
			false;
	}

	bool mem_inst(opcode operation)
	{
		return operation == LWO || operation == SWO;
	}

	BW_32 generic_mips32_encode(int rs, int rt, int rd, int imm, int cc, int rsprite, opcode op, int x, int y)
	{
		BW_32 w = 0;

		if(r_inst(op))
		{
			w = (w.AsInt32() | ((rd & ((1 << 5) - 1) ) << 11 ));
			w = (w.AsInt32() | ((rt & ((1 << 5) - 1) ) << 16 ));
			w = (w.AsInt32() | ((rs & ((1 << 5) - 1) ) << 21 ));
			w = (w.AsInt32() | ((op & ((1 << 6) - 1) ) << 26 ));
		}

		if(i_inst(op))
		{
			w = (w.AsInt32() | (imm & ((1 << 16) - 1)));
			w = (w.AsInt32() | ((rt & ((1 << 5) - 1) ) << 16 ));
			w = (w.AsInt32() | ((rs & ((1 << 5) - 1) ) << 21 ));
			w = (w.AsInt32() | ((op & ((1 << 6) - 1) ) << 26 ));
		}

		if(b_inst(op))
		{
			w = (w.AsInt32() | (imm & ((1 << 16) - 1)));
			w = (w.AsInt32() | ((cc & ((1 << 3) - 1) ) << 23 ));
			w = (w.AsInt32() | ((op & ((1 << 6) - 1) ) << 26 ));
		}

		if(m_inst(op))
		{
			w = (w.AsInt32() | (imm & ((1 << 16) - 1)));
			w = (w.AsInt32() | ((rd & ((1 << 5) - 1) ) << 21 ));
			w = (w.AsInt32() | ((op & ((1 << 6) - 1) ) << 26 ));
		}

		if(n_inst(op))
		{
			w = (w.AsInt32() | ((op & ((1 << 6) - 1) ) << 26 ));
		}

		return w;
	}

	BW_32 offset_to_address_br(BW_32 current, BW_32 target)
	{
		BW_32 ret = target.AsInt32() - current.AsInt32();
		ret = ret.AsInt32() - 4;
		ret = (ret.AsInt32() >> 2);
		return ret;
	}
}
