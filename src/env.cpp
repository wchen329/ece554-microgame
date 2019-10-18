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
					this->asmInputs.push_back(args[argind+1]); // todo store this value
					this->has_AsmInput_Value = true;
				}
			}
		}
	}
}