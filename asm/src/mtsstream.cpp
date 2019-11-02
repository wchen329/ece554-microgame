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
#include "mtsstream.h"

namespace asmrunner
{

	void asm_ostream::append(asmrunner::BW_32 data)
	{
		uint32_t out = data.AsUInt32();
		fwrite(&out, sizeof(out), 1, this->f);
	}

	asm_ostream::asm_ostream(char * filename)
	{
		this->f = fopen(filename, "w");
	}

	asm_ostream::~asm_ostream()
	{
		fclose(this->f);
	}
}
