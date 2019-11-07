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
#ifndef __SHELL_H__
#define __SHELL_H__

#include <set>
#include <queue>
#include <map>
#include <string>
#include <vector>
#include <memory>
#include "mtsstream.h"
#include "primitives.h"
#include "syms_table.h"
#include "env.h"

namespace asmrunner
{
	/* Divides a string based on whitespace, tabs, commas and newlines
	 * Acknowledges escaping \ and quotes
	 */
	std::vector<std::string> chop_string(std::string & input);

	/* A single instance of a Shell
	 * -
	 * The shell allows easy and direct access to utilizing a processor.
	 */
	class Shell
	{

		public:
			void Run();
			void SetArgs(std::vector<std::string> & args) { this->args = args; }
			Shell();
		private:
			std::vector<std::string> args;
			std::list<std::string> sfilelist; // sprite file list
			void WriteToError(std::string& e);
			void WriteToError(const char* e);
			void WriteToOutput(std::string& o);
			void WriteToOutput(const char* o);
			FILE* inst_file;
			std::unique_ptr<asm_ostream> out_stream;
			Env shEnv;
			priscas::syms_table jump_syms;
	};
}

#endif
