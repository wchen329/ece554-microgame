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
#ifndef __MTSSTREAM_H__
#define __MTSSTREAM_H__
#include <cstdio>
#include <list>
#include "primitives.h"

namespace asmrunner
{

	class asm_ostream
	{
		public:	
			void append(asmrunner::BW_32);
			asm_ostream(const std::string& filename);
			~asm_ostream();
		private:
			FILE * f;
			std::list<std::string> instl;
			asm_ostream(asm_ostream &);
			asm_ostream& operator=(asm_ostream &);
			int ind;
	};
}

#endif
