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
#ifndef __PRIMITIVES_H__
#define __PRIMITIVES_H__
#include <cstdint>
#include <string>
/* Various byte long
 * primitives such as a 32-bitlong word
 * or a 64-bitlong one.
 *
 * wchen329
 */

namespace priscas
{
	typedef unsigned char byte_8b;

	template<class ConvType, int bitlength> std::string genericHexBuilder(ConvType c)
	{
		std::string ret = "0x";
		int tbl = bitlength;
		
		std::string interm = "";

		while(tbl > 0)
		{
			char val = c & 0x0F;

			switch(val)
			{
				case 0:
					interm = "0" + interm;
					break;
				case 1:
					interm = "1" + interm;
					break;
				case 2:
					interm = "2" + interm;
					break;
				case 3:
					interm = "3" + interm;
					break;
				case 4:
					interm = "4" + interm;
					break;
				case 5:
					interm = "5" + interm;
					break;
				case 6:
					interm = "6" + interm;
					break;
				case 7:
					interm = "7" + interm;
					break;
				case 8:
					interm = "8" + interm;
					break;
				case 9:
					interm = "9" + interm;
					break;
				case 10:
					interm = "a" + interm;
					break;
				case 11:
					interm = "b" + interm;
					break;
				case 12:
					interm = "c" + interm;
					break;
				case 13:
					interm = "d" + interm;
					break;
				case 14:
					interm = "e" + interm;
					break;
				case 15:
					interm = "f" + interm;
					break;
			};


			c = (c >> 4);
			tbl -= 4;
		}

		return ret + interm;
	}

	// general "bit word class"
	class BW
	{
		public:
			virtual std::string toHexString() = 0;
			virtual int16_t& AsInt16() = 0;
			virtual uint16_t& AsUInt16() = 0;
			virtual int32_t& AsInt32() = 0;
			virtual uint32_t& AsUInt32() = 0;
			virtual float& AsSPFloat() = 0;
			virtual bool operator==(BW& bw2) = 0;
			virtual bool operator!=(BW& bw2) = 0;

	};

	class BW_16 : public BW
	{
		public:
			char b_0() { return *(w_addr());}
			char b_1() { return *(w_addr() + 1);}
			BW_16() { w.i16 = 0; }
			BW_16(int16_t data){ w.i16 = data; }
			BW_16(uint16_t data) { w.ui16 = data; }
			BW_16(char b_0, char b_1);

			std::string toHexString() { return genericHexBuilder<int16_t, 16>(this->w.i16); }
			int16_t& AsInt16() { return w.i16; }
			uint16_t& AsUInt16() { return w.ui16; }
			int32_t& AsInt32() { signedTrunc(); return w.i32; } // Always truncate first (by sign extending), and return
			uint32_t& AsUInt32() { signedTrunc(); return w.ui32; }
			float& AsSPFloat() { signedTrunc(); return w.fp32; }

			bool operator==(BW& bw2) { return (this->AsInt16() == bw2.AsInt16()); }
			bool operator!=(BW& bw2) { return (this->AsInt16() != bw2.AsInt16()); }

		private:
			char * w_addr() { return (char*)&w.i16; }

			union BW_16_internal
			{
				int16_t i16;
				uint16_t ui16;
				int32_t i32;
				uint32_t ui32;
				float fp32;
			};

			
			BW_16_internal w;

			void signedTrunc()
			{
				w.i32 = ((w.i32 << 15) >> 15);
			}

	};

	class BW_32 : public BW
	{
		public:
			char b_0() { return *(w_addr());}
			char b_1() { return *(w_addr() + 1);}
			char b_2() { return *(w_addr() + 2);}
			char b_3() { return *(w_addr() + 3);}

			BW_32() { w.i32 = 0; }
			BW_32(int32_t data){ w.i32 = data; }
			BW_32(uint32_t data) { w.ui32 = data; }
			BW_32(float data) { w.fp32 = data; }
			BW_32(char b_0, char b_1, char b_2, char b_3);


			std::string toHexString() { return genericHexBuilder<int32_t, 32>(this->w.i32); }
			int16_t& AsInt16() { return w.i16; }
			uint16_t& AsUInt16() { return w.ui16; }
			int32_t& AsInt32() { return w.i32; }
			uint32_t& AsUInt32() { return w.ui32; }
			float& AsSPFloat() { return w.fp32; }

			bool operator==(BW& bw2) { return (this->AsInt32() == bw2.AsInt32()); }
			bool operator!=(BW& bw2) { return (this->AsInt32() != bw2.AsInt32()); }

		private:
			char * w_addr() { return (char*)&w.i32; }
			
			union BW_32_internal
			{
				int16_t i16;
				uint16_t ui16;
				int32_t i32;
				uint32_t ui32;
				float fp32;
			};

			BW_32_internal w;
	};

	/* Just a collection of two strings
	 * Name - the name of this object
	 * Description - description of this object
	 */
	class NameDescPair
	{
		public:
			std::string& getName() { return this->name; }
			std::string& getDescription() { return this->desc; }
			const std::string& getName() const { return this->name; }
			const std::string& getDescription() const { return this->desc; }
			NameDescPair(std::string name_of, std::string desc_of) : name(name_of), desc(desc_of) {}
		private:
			std::string name;
			std::string desc;
	};

	/* Just a collection of two strings
	 * Name - the name of this object
	 * Value - the string value of this object
	 */
	class NameValueStringPair
	{
		public:
			std::string& getName() { return this->name; }
			std::string& getValue() { return this->value; }
			NameValueStringPair(std::string name_of, std::string value_of) : name(name_of), value(value_of) {}
		private:
			std::string name;
			std::string value;
	};
}

#endif
