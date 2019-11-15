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
#include "primitives.h"

namespace asmrunner
{
	BW_32::BW_32(char b_0, char b_1, char b_2, char b_3)
	{
		char * w_ptr = (char*)&(w.i32);
		*w_ptr = b_0;
		*(w_ptr + 1) = b_1;
		*(w_ptr + 2) = b_2;
		*(w_ptr + 3) = b_3;
	}

	Sprite::Sprite(const std::string& spritename, const std::string& filename)
	{
		FILE * f = fopen(filename.c_str(), "r");	

		if(f == NULL)
		{
			throw mt_io_file_open_failure(filename);
			return;
		}

		this->name = spritename;

		// Read 192 bytes (one sprite) into the buffer
		fread(spBuf, 192, 1, f);
		fclose(f);
	}

	std::list<BW_32> Sprite::toBW32()
	{
		std::list<BW_32> l;
		int count = SPRITE_SIZE;

		for(int i = 0; i < count; i = (i + 3))
		{
			BW_32 n(spBuf[i], spBuf[i + 1], spBuf[i + 2], 0); // Zero extend the 8 top bits
			l.push_back(n);
		}

		return l;
	}
}
