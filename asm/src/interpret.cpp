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
#include "format_chk.h"
#include "microgame.h"
#include "primitives.h"
#include <memory>

namespace asmrunner
{

	// Main interpretation routine
	std::shared_ptr<BW> assemble(std::vector<std::string>& args, BW& baseAddress, syms_table& jump_syms)
	{
		if(args.size() < 1)
			return std::shared_ptr<BW>(new BW_32());

		priscas::opcode current_op = NOP;

		int rs = 0;
		int rt = 0;
		int rd = 0;
		int imm = 0;
		int cc = 0;
		int rsprite = 0;
		int x = 0;
		int y = 0;

		// Mnemonic resolution
		
		if("add" == args[0]) { current_op = ADD; }
		else if("addi" == args[0]) { current_op = ADDI; }
		else if("sub" == args[0]) { current_op = SUB; }
		else if("and" == args[0]) { current_op = AND; }
		else if("andi" == args[0]) { current_op = ANDI; }
		else if("or" == args[0]) { current_op = OR; }
		else if("ori" == args[0]) { current_op = ORI; }
		else if("xor" ==  args[0]) { current_op = XOR; }
		else if("sll" == args[0]) { current_op = SLL; }
		else if("srl" == args[0]) { current_op = SRL; }
		else if("sra" == args[0]) { current_op = SRA; }
		else if("lli" == args[0]) { current_op = LLI; }
		else if("lui" == args[0]) { current_op = LUI; }
		else if("lk" == args[0]) { current_op = LK; }
		else if("lw" == args[0]) { current_op = LW; }
		else if("sw" == args[0]) { current_op = SW; }
		else if("lwo" == args[0]) { current_op = LWO; }
		else if("swo" == args[0]) { current_op = SWO; }
		else if("bne" == args[0]) { current_op = B; cc = CCNE; }
		else if("beq" == args[0]) { current_op = B; cc = CCEQ; }
		else if("bgt" == args[0]) { current_op = B; cc = CCGT; }
		else if("blt" == args[0]) { current_op = B; cc = CCLT; }
		else if("bgte" == args[0]) { current_op = B; cc = CCGTE; }
		else if("blte" == args[0]) { current_op = B; cc = CCLTE; }
		else if("bov" == args[0]) { current_op = B; cc = CCOFLOW; }
		else if("b" == args[0]) { current_op = B; cc = CCUNCOND; }
		else if("blne" == args[0]) { current_op = JL; cc = CCNE; }
		else if("bleq" == args[0]) { current_op = JL; cc = CCEQ; }
		else if("blgt" == args[0]) { current_op = JL; cc = CCGT; }
		else if("bllt" == args[0]) { current_op = JL; cc = CCLT; }
		else if("bgte" == args[0]) { current_op = JL; cc = CCGTE; }
		else if("blte" == args[0]) { current_op = JL; cc = CCLTE; }
		else if("blov" == args[0]) { current_op = JL; cc = CCOFLOW; }
		else if("bl" == args[0]) { current_op = JL; cc = CCUNCOND; }
		else if("ret" == args[0]) { current_op = RET; }
		else if("wfb" == args[0]) { current_op = WFB; }
		else if("dfb" == args[0]) { current_op = DFB; }
		else if("ls" == args[0]) { current_op = LS; }
		else if("cs" == args[0]) { current_op = CS; }
		else if("ds" == args[0]) { current_op = DS; }
		else if("rs" == args[0]) { current_op = RS; }
		else if("sat" == args[0]) { current_op = SAT; }
		else if("dc" == args[0]) { current_op = DC; }
		else if("tim" == args[0]) { current_op = TIM; }
		else if("r" == args[0]) { current_op = R; }
		else if("sr" == args[0]) { current_op = SR; }
		else if("nop" == args[0]) { current_op = NOP; }
		else
		{
			throw mt_bad_mnemonic();
		}

		// Check for insufficient arguments TODO: simplify
		if(args.size() >= 1)
		{
			if	(
					(r_inst(current_op) && args.size() != 4 && current_op != DC) ||
					(i_inst(current_op) && args.size() != 4 && !mem_inst(current_op)) ||
					(i_inst(current_op) && args.size() != 3 && mem_inst(current_op)) ||
					(j_inst(current_op) && args.size() != 2) ||
					(m_inst(current_op) && args.size() != 3 && !(current_op == R || current_op == LK || current_op == SR || current_op == SAT)) ||
					(m_inst(current_op) && args.size() != 2 && (current_op == R || current_op == LK || current_op == SR || current_op == SAT)) ||
					(n_inst(current_op) && args.size() != 1) ||
					((current_op == WFB || current_op == CS || current_op == LS || current_op == RS) && args.size() != 2) ||
					((current_op == DS) && args.size() != 3) 
					
				)
			{
				throw priscas::mt_asm_bad_arg_count();
			}

			// Now first argument parsing
			if(r_inst(current_op) || (m_inst(current_op)))
			{
					if((rd = priscas::friendly_to_numerical(args[1].c_str())) <= priscas::INVALID)
						rd = priscas::get_reg_num(args[1].c_str());
			}

			else if(i_inst(current_op))
			{
				// later, check for branches
				if((rt = priscas::friendly_to_numerical(args[1].c_str())) <= priscas::INVALID)
				rt = priscas::get_reg_num(args[1].c_str());
			}

			else if(j_inst(current_op))
			{
				if(jump_syms.has(args[1]))
				{
					priscas::BW_32 label_PC = static_cast<int32_t>(jump_syms.lookup_from_sym(std::string(args[1].c_str())));
					imm = offset_to_address_br(baseAddress.AsInt32(), label_PC).AsInt32();
				}

				else
				{
					imm = priscas::get_imm(args[1].c_str());
				}
			}
	
			else if(s_inst(current_op))
			{
				if(current_op == WFB || current_op == CS || current_op == DS)
				{
					rt = get_reg_num(args[1].c_str());
				}

				if(current_op == RS || current_op == LS)
				{
					rsprite = get_reg_num_sprite(args[2].c_str());
				}
			}

			else
			{
				priscas::mt_bad_mnemonic();
			} 
		}

		// Second Argument Parsing
		
		if(args.size() > 2)
		{
			if(r_inst(current_op))
			{
				if((rs = priscas::friendly_to_numerical(args[2].c_str())) <= priscas::INVALID)
					rs = priscas::get_reg_num(args[2].c_str());
			}
						
			else if(i_inst(current_op))
			{
				if(mem_inst(current_op))
				{
					bool left_parenth = false; bool right_parenth = false;
					std::string wc = args[2];
					std::string imm_s = std::string();
					std::string reg = std::string();

					for(size_t i = 0; i < wc.length(); i++)
					{
						if(wc[i] == '(') { left_parenth = true; continue; }
						if(wc[i] == ')') { right_parenth = true; continue; }

						if(left_parenth)
						{
							reg.push_back(wc[i]);
						}

						else
						{
							imm_s.push_back(wc[i]);
						}
					}

					if(!right_parenth || !left_parenth) throw mt_unmatched_parenthesis();
					if((rs = priscas::friendly_to_numerical(reg.c_str())) <= priscas::INVALID) rs = priscas::get_reg_num(reg.c_str());
					imm = priscas::get_imm(imm_s.c_str());
								
				}

				else
				{
					// later, MUST check for branches
					if((rs = priscas::friendly_to_numerical(args[2].c_str())) <= priscas::INVALID)
					rs = priscas::get_reg_num(args[2].c_str());
				}
			}

			else if(m_inst(current_op))
			{
				imm = get_imm(args[2].c_str());
			}

			else if(j_inst(current_op)){}

			else if(s_inst(current_op))
			{
				if(current_op == WFB || current_op == CS || current_op == DS)
				{
					rs = get_reg_num(args[2].c_str());
				}

				else if(current_op == LS)
				{
					imm = priscas::get_imm(args[1].c_str());
				}

				else if(current_op == RS)
				{
					cc = priscas::get_imm(args[1].c_str());
				}
			}
		}

		if(args.size() > 3)
		{
			// Third Argument Parsing
			if(r_inst(current_op))
			{
				if((rt = priscas::friendly_to_numerical(args[3].c_str())) <= priscas::INVALID)
					rt = priscas::get_reg_num(args[3].c_str());
			}
						
			else if(i_inst(current_op))
			{

				if(jump_syms.has(args[3]))
				{
					priscas::BW_32 addr = baseAddress.AsInt32();
					priscas::BW_32 label_PC = static_cast<uint32_t>(jump_syms.lookup_from_sym(std::string(args[3].c_str())));
					imm = priscas::offset_to_address_br(addr, label_PC).AsInt32();
				}

				else
				{
					imm = priscas::get_imm(args[3].c_str());
				}
			}

			else if(current_op == DS)
			{
				rsprite = get_reg_num_sprite(args[3].c_str());
			}

			else if(j_inst(current_op)){}
		}

		// Pass the values of rs, rt, rd to the processor's encoding function
		BW_32 inst = generic_mips32_encode(rs, rt, rd, imm, cc, rsprite, current_op, x, y);

		return std::shared_ptr<BW>(new BW_32(inst));
	}
}
