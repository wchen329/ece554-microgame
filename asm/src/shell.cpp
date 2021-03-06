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
#include <csignal>
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <cstdarg>
#include <string>
#include <memory>
#include "microgame.h"
#include "mt_exception.h"
#include "mtsstream.h"
#include "shell.h"

namespace asmrunner
{

	/* Shell for MIPS Tools
	 *
	 * The shell has two modes: Interative Mode and Batch Mode
	 *
	 * Passing in a file as an argument allows for that instruction to be batched.
	 *
	 * wchen329
	 */
	int Shell::Run()
	{

		WriteToOutput("Microgame Binary Assembler 1.0\n");
		WriteToOutput("Author: wchen329@wisc.edu\n");

		std::string AsmOutputName = "a.";

		// Characterize my arguments
		shEnv.characterize_Env(this->args);

		// Then start assembling if possible
		if(shEnv.get_Option_AsmInput())
		{
			// Open the source file
			if(!shEnv.get_Option_AsmInputSpecified())
			{
				WriteToError("Error: An input file is required (specified through -i [input file] ) in order to run in batch mode.\n");
				return -1;
			}

			else
			{
				inst_file = fopen(shEnv.get_asmFilenames()[0].c_str(), "r");

				// Check output format specification
				if(shEnv.get_Option_FormatSpec())
				{
					std::string o = shEnv.get_OModeStr();

					// Set output mode depending on string
					if(o == "hexlist" || o == "hl")
					{
						this->outputMode = StreamMode::HEXLIST;
						AsmOutputName += "hl";
					}

					else if(o == "bin")
					{
						this->outputMode = StreamMode::BIN;
						AsmOutputName += "bin";
					}

					else if(o == "mif")
						AsmOutputName += "mif";

					else
					{
						WriteToError("Invalid value for output format (-f).\n");
						WriteToError("Supported formats:\n");
						WriteToError("\t- mif (default)\n");
						WriteToError("\t- hexlist / hl\n");
						WriteToError("\t- bin\n");
						return -2;
					}
				}
				else
				{
					AsmOutputName += "mif";
				}

				// Check output name as necessary
				if(shEnv.get_Option_AsmOutputSpecified())
				{
					AsmOutputName = shEnv.get_MIFName();
				}


				this->out_stream = std::unique_ptr<asmrunner::asm_ostream>(new asm_ostream(AsmOutputName, this->outputMode));
			}

			if(inst_file == NULL)
			{
				WriteToError("Error: The file specified cannot be opened or doesn't exist.\n");
				return -3;
			}

		}

		else
		{
			WriteToOutput("Usage: mgassemble -i [source filename] -o [binary output filename] -g [sprite table file] -f [format]\n");
			return -4;
		}

		/* First, if an input file was specified
		 * (1) collect file symbols
		 * (2) map it to memory assemble that file first
		 */
		if(shEnv.get_Option_AsmInputSpecified())
		{
			std::vector<std::string> lines;

			uint32_t equiv_pc = 0;
			char input_f_stream[255];
			memset(input_f_stream, 0, sizeof(input_f_stream));
			unsigned long line_number = 0;
			try
			{
				while(fgets(input_f_stream, 254, inst_file) != NULL)
				{
					line_number++;
					std::string current_line = std::string(input_f_stream);
					std::vector<std::string> parts = chop_string(current_line);
	
					// Remove strings that are just whitespace
					if(parts.empty())
						continue;

					// Symbol assignment: add the symbol to symbol table
					
					if(parts[0][parts[0].size() - 1] == ':')
					{
						this->jump_syms.insert(parts[0].substr(0, parts[0].size() - 1), equiv_pc);
						continue;
					}

					equiv_pc = equiv_pc + 4;
					lines.push_back(current_line);		
				}

				
				// Start lining up sprites at PCs +256 each after the initial, if sprite table was specified.
				if(shEnv.get_Option_SpriteTable())
				{
					// Build sprite table
					sprite_stream spin(shEnv.get_Option_SpriteTable_Value());
					std::shared_ptr<Sprite> sp;
					while((sp = spin.next()).get() != nullptr)
					{
						this->splist.push_back(sp);
						jump_syms.insert(sp->getName(), equiv_pc);
						equiv_pc += PACKED_SPRITE_SIZE;
					}
				}
			}
			catch(priscas::mt_exception& e)
			{
				WriteToOutput("An error has occurred when writing debugging symbols and assigning directives:\n\t");
				WriteToOutput(e.get_err().c_str());
				return -4;
			}

			priscas::BW_32 asm_pc = 0;

			// Now assemble the rest
			for(size_t itr = 0; itr < lines.size(); itr++)
			{
				std::vector<std::string> asm_args = chop_string(lines[itr]);
				std::shared_ptr<priscas::BW> inst;
				try
				{
					inst = assemble(asm_args, asm_pc, jump_syms);
				}

				catch(priscas::mt_exception& e)
				{
					WriteToError(("An error occurred while assembling the program.\n"));
					std::string msg_1 = 
						(std::string("Error information: ") + std::string(e.get_err()));
					WriteToError(msg_1);
					WriteToError(("Line of error:\n"));
					std::string msg_2 = 
						(std::string("\t") + lines[itr] + std::string("\n"));
					WriteToError(msg_2);
					return -5;
				}

				priscas::BW_32& thirty_two = dynamic_cast<priscas::BW_32&>(*inst);
				asm_pc.AsUInt32() += 4;
				this->out_stream->append(thirty_two);
			}

			// Finally, just dump all sprites out to the memory.
			for(size_t spno = 0; spno < this->splist.size(); spno++)
			{
				std::list<BW_32> sd = (*(splist[spno])).toBW32();
				for(std::list<BW_32>::iterator li = sd.begin(); li != sd.end(); li++)
				{
					this->out_stream->append(*li);
				}
				asm_pc.AsUInt32() += PACKED_SPRITE_SIZE;
			}
		}

		WriteToOutput(("Operation completed successfully.\n"));
		return 0;
	}

	/* Takes an input string and breaks that string into a vector of several
	 * based off of whitespace and tab delineators
	 * Also removes comments
	 * "Also acknowledges " " and ' ' and \ all used for escaping
	 */
	std::vector<std::string> chop_string(std::string & input)
	{
		std::string commentless_input;
		size_t real_end = input.size();
		for(size_t cind = 0; cind < input.size(); cind++)
		{
			if(input[cind] == '#')
			{
				real_end = cind;
				break;
			}
		}

		commentless_input = input.substr(0, real_end);

		std::vector<std::string> str_vec;
		
		std::string built_string = "";

		bool has_escaped = false;
		bool in_quotes = false;

		// Use a linear search
		for(size_t ind = 0; ind < commentless_input.size(); ind++)
		{
			// If no escaping, then perform syntactical checks
			if(!has_escaped)
			{
				// First acknowledge escaping
				if(commentless_input[ind] == '\\')
				{
					has_escaped = true;
					continue;
				}

				// Detect quotations
				if(commentless_input[ind] == '\"' || commentless_input[ind] == '\'')
				{
					in_quotes = !in_quotes;
					continue;
				}

				// Now if not quoted as well, then a comma, whitespace, tab, or newline delineates that argument is done parsing
				if(!in_quotes)
				{
					if(commentless_input[ind] == ',' ||  commentless_input[ind] == ' ' || commentless_input[ind] == '\t' || commentless_input[ind] == '\n' || commentless_input[ind] == '\r')
					{
						// Check: do not add empty strings
						if(built_string != "")
						{
							str_vec.push_back(built_string);
							built_string = "";
						}

						continue;
					}
				}
			}

			built_string += commentless_input[ind];
			has_escaped = false; // no matter what, escaping only escapes one...
		}

		if(has_escaped || in_quotes)
		{
			throw priscas::mt_bad_escape();
		}

		if(built_string != "")
			str_vec.push_back(built_string);

		return str_vec;
	}

	// Set up list of runtime directives
	Shell::Shell() : inst_file(nullptr)
	{
	}

	void Shell::WriteToError(std::string& e)
	{
		fprintf(stderr, e.c_str());
	}

	void Shell::WriteToError(const char* e)
	{
		fprintf(stderr, e);
	}

	void Shell::WriteToOutput(std::string& o)
	{
		fprintf(stdout, o.c_str());
	}

	void Shell::WriteToOutput(const char* o)
	{
		std::string o_str(o);
		WriteToOutput(o_str);
	}
}
