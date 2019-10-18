//////////////////////////////////////////////////////////////////////////////
//
//    PRISCAS - Computer architecture simulator
//    Copyright (C) 2019 Winor Chen
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
#ifndef __ENV_H__
#define __ENV_H__
#include <algorithm>
#include "aliases.h"

namespace asmrunner
{
	/* Env 
	 * -
	 * Describes the current status of various parts of the PRISCAS environment
	 */
	class Env
	{
		public:

			/* void get_Option_AsmOnly
			 * Return whether or not ASM Input option -i has been specified
			 */
			bool get_Option_AsmInput() { return this->has_Option_AsmInput; }

			/* void get_Option_AsmOnly
			 * Return whether or not ASM Input option -a has been specified
			 */
			bool get_Option_AsmMode() { return this->has_Option_AsmInput; }

			/* void get_Option_AsmInputSpecified
			 * Return whether or not ASM Input option -i had a value specified for it
			 */
			bool get_Option_AsmInputSpecified() { return this->has_AsmInput_Value; }

			/* void characterize_Env
			 * Sets the environment given a set of arguments.
			 */
			void characterize_Env(const Arg_Vec&);

			/* const Filename_Vec& get_asmFilenames()
			 * Get the list of filename inputs
			 */
			const Filename_Vec& get_asmFilenames() { return this->asmInputs; }

			Env() :
				mem_bitwidth(16),
				has_Option_AsmInput(false),
				has_AsmInput_Value(false),
				channel_count(1),
				cpu_count(1)
			{}

		private:

			Filename_Vec asmInputs;		// vector of asm input to assemble (-i)
			Arg_Vec cpuStrings;			// specified cpu strings (-c)

			bool has_Option_AsmInput;	// -i option specified
			bool has_AsmInput_Value;	// -i option has a value
			unsigned mem_bitwidth;		// memory bitwidth (default 16)
			unsigned channel_count;		// amount of memory channels (currently 1), future use
			unsigned cpu_count;			// amount of cpu sockets (currently 1), future use
	};
}

#endif