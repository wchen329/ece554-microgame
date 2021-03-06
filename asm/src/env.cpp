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
#include "env.h"

namespace asmrunner
{
	void Env::characterize_Env(const Arg_Vec& args)
	{
		size_t argc = args.size();

		for(size_t argind = 0; argind < argc; argind++)
		{
			if(args[argind] == "-i")
			{
				// Declare -i was received
				this->has_Option_AsmInput = true;
				
				// Set file name
				if((argind + 1) < argc)
				{
					this->asmInputs.push_back(args[argind+1]);
					this->has_AsmInput_Value = true;
				}
			}

			if(args[argind] == "-o")
			{
				// Declare -o was received
				this->has_Option_AsmOutput = true;
				
				// Set file name
				if((argind + 1) < argc)
				{
					this->asmInputs.push_back(args[argind+1]);
					this->has_AsmOutput_Value = true;
					this->mifName = args[argind + 1];
				}
			}

			if(args[argind] == "-g")
			{
				// Declare -g was received
				this->has_Option_SpriteTable = true;

				// Set file name
				if((argind + 1) < argc)
				{
					this->stName = args[argind + 1];
				}
			}

			if(args[argind] == "-f")
			{
				// Declare -f was received
				this->has_Option_FormatSpec = true;

				// Set formatting type
				if((argind + 1) < argc)
				{
					this->oms = args[argind + 1];
				}
			}
		}
	}
}
