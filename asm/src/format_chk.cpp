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


namespace asmrunner
{

	// Returns register number corresponding with argument if any
	// Returns -1 if invalid or out of range
	int get_reg_num(const char * reg_str)
	{
		std::vector<char> numbers;
		int len = strlen(reg_str);
		if(len <= 1) throw priscas::mt_bad_imm();
		if(reg_str[0] != '$') throw priscas::mt_parse_unexpected("$", reg_str);
		for(int i = 1; i < len; i++)
		{
			if(reg_str[i] >= '0' && reg_str[i] <= '9')
			{
				numbers.push_back(reg_str[i]);
			}

			else throw priscas::mt_bad_reg_format();
		}

		int num = -1;

		if(numbers.empty()) throw priscas::mt_bad_reg_format();
		else
		{
			char * num_str = new char[numbers.size()];

			int k = 0;
			for(std::vector<char>::iterator itr = numbers.begin(); itr < numbers.end(); itr++)
			{
				num_str[k] = *itr;
				k++;
			}
			num = atoi(num_str);
			delete[] num_str;
		}

		return num;
	}

	// Returns register number corresponding with argument if any
	// Returns -1 if invalid or out of range, uses the sprite (#) TODO: combine with other register get-num above
	int get_reg_num_sprite(const char * reg_str)
	{
		std::vector<char> numbers;
		int len = strlen(reg_str);
		if(len <= 1) throw priscas::mt_bad_imm();
		if(reg_str[0] != '%') throw priscas::mt_parse_unexpected("%", reg_str);
		for(int i = 1; i < len; i++)
		{
			if(reg_str[i] >= '0' && reg_str[i] <= '9')
			{
				numbers.push_back(reg_str[i]);
			}

			else throw priscas::mt_bad_reg_format();
		}

		int num = -1;

		if(numbers.empty()) throw priscas::mt_bad_reg_format();
		else
		{
			char * num_str = new char[numbers.size()];

			int k = 0;
			for(std::vector<char>::iterator itr = numbers.begin(); itr < numbers.end(); itr++)
			{
				num_str[k] = *itr;
				k++;
			}
			num = atoi(num_str);
			delete[] num_str;
		}

		return num;
	}

	// Returns immediate value if valid
	int get_imm(const char * str)
	{
		int len = strlen(str);
		int base = 10;

		// Change base if possible
		if(len > 0)
		{
			if(str[0] == 'o')
			{
				base = 8;
				str = str + 1;
				len = len - 1;
			}

			else if(str[0] == 'h')
			{
				base = 16;
				str = str + 1;
				len = len - 1;
			}

			else if(str[0] == 'b')
			{
				base = 2;
				str = str + 1;
				len = len - 1;
			}

		}


		for(int i = 0; i < len; i++)
		{

			if(
					(base == 10 && (str[i] < '0' || str[i] > '9')) ||
					(base == 2 && (str[i] < '0' || str[i] > '1')) ||
					(base == 16 && !((str[i] >= '0' && str[i] <= '9') || (str[i] >= 'a' && str[i] <= 'f') || (str[i] >= 'A' && str[i] <= 'F'))) ||
					(base == 8 && (str[i] < '0' || str[i] > '7'))
				)
			{
				if(!(i == 0 && str[i] == '-'))
				{
					throw priscas::mt_bad_imm();
				}
			}
		}

		if(len == 0)
		{
			throw mt_bad_imm();
		}

		return strtol(str, NULL, base);
	}
}
