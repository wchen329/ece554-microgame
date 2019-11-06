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
		// Just buffer it for now
		ind++;
		std::string hrep = data.toHexString();
		this->instl.push_back(hrep);

//		fwrite(&out, sizeof(out), 1, this->f);
	}

	asm_ostream::asm_ostream(char * filename)
	{
		ind = 0;
		this->f = fopen(filename, "w");
		fprintf(this->f, "-- Microgame Assembler generated .mif file\n");
		fprintf(this->f, "WIDTH=32;\n");
	}

	asm_ostream::~asm_ostream()
	{
		
		fprintf(this->f, "DEPTH=%d;\n\n", ind);
		fprintf(this->f, "ADDRESS_RADIX=UNS;\n");
		fprintf(this->f, "DATA_RADIX=HEX;\n\n");
		fprintf(this->f, "CONTENT BEGIN\n");

		int where = 0;

		for(std::list<std::string>::iterator itt = instl.begin(); itt != instl.end(); itt++)
		{
			fprintf(this->f, "\t%d : %s;\n", where, (*itt).c_str());
			where++;
		}

		fprintf(this->f, "END;\n");
		fclose(this->f);
	}
}
