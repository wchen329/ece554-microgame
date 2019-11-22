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
	std::vector<std::string> chop_string(std::string & input);

	void asm_ostream::append(asmrunner::BW_32 data)
	{
		// Just buffer it for now
		ind++;
		std::string hrep = data.toHexString();
		this->instl.push_back(hrep);

		if(this->om == StreamMode::BIN)
		{
			int32_t out = data.AsUInt32();
			fwrite(&out, sizeof(out), 1, this->f);
		}
	}

	asm_ostream::asm_ostream(const std::string& filename, StreamMode::OutputMode om)
	{
		ind = 0;
		this->f = fopen(filename.c_str(), "w");
		this->om = om;
		
		if(this->om == StreamMode::MIF)
		{
			fprintf(this->f, "-- Microgame Assembler generated .mif file\n");
			fprintf(this->f, "WIDTH=32;\n");
		}
		
	}

	asm_ostream::~asm_ostream()
	{
		
		if(this->om == StreamMode::MIF)
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
		}

		else if(this->om == StreamMode::HEXLIST)
		{
			for(std::list<std::string>::iterator itt = instl.begin(); itt != instl.end(); itt++)
			{
				fprintf(this->f, "%s\n", (*itt).c_str());
			}
		}

		fclose(this->f);
	}

	sprite_stream::sprite_stream(const std::string fname)
	{
		this->spstr = fopen(fname.c_str(), "r");

		// Find the "base path", i.e. context path
		std::string bp;
		std::string buf;

		for(size_t z = 0; z < fname.size(); z++)
		{
			buf += fname[z];

			// If we've reached a slash, add everything we've seen to the relative path
			if(fname[z] == '/')
			{
				bp += buf;
				buf.clear();
			}
			
		}

		this->stream_offset = bp;

		if(spstr == NULL)
		{
			// Change to file exception
			throw mt_exception();
		}
	}

	std::shared_ptr<Sprite> sprite_stream::next()
	{
		// Read sprite name and filename. If can't, the return nullptr
		const size_t BUF_SIZE = 2048;
		char buf[BUF_SIZE];
		memset(buf, 0,  BUF_SIZE);

		// Read into the buffer
		if((fgets(buf, BUF_SIZE - 1, spstr) == NULL))
		{
			return std::shared_ptr<Sprite>();
		}
		else
		{
			std::string input(buf);
			std::string sname;
			std::string fname;
		
			
			// Parse. Use : as delineator
			bool hasSeen_col = false;
			for(size_t s = 0; s < input.size(); s++)
			{
				if(input[s] == ':')
				{
					hasSeen_col = true; continue;
				}

				else if(input[s] != '\n')
				{
					if(!hasSeen_col)
					{
						sname += input[s];
					}
					else
					{
						fname += input[s];
					}
				}
			}

			// Check for illegal formatting and trim leading whitespaces...
			std::vector<std::string> sn_var = chop_string(sname);
			std::vector<std::string> fn_var = chop_string(fname);

			if(sn_var.size() != 1 || fn_var.size() != 1)
			{
				throw mt_exception();
			}

			// Construct a new sprite off of the filename. 
			// Return that sprite
			return std::shared_ptr<Sprite>(new Sprite(sn_var[0], this->stream_offset+ fn_var[0]));
		}
	}

	sprite_stream::~sprite_stream()
	{
		if(spstr != NULL)
			fclose(spstr);
	}
}
