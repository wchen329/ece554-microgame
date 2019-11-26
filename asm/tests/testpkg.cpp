#include <cstdio>
#include <cstring>
#include <string>
#include <map>

int correct_count = 0;
int count = 0;

void mark_incorrect(int where, const std::string& actual, const std::string& expected)
{
	fprintf(stdout, "Incorrect sequence detected at line %d:\n", where);
	fprintf(stdout, "\tExpected:%s\n\tActual:%s\n", expected.c_str(), actual.c_str());
	count++;
}

/* This program simply tests by using 
 * direct string compare
 * wchen329
 */
int main(int argc, char** argv)
{
	std::map<int, std::string> num_to_output;
	fprintf(stdout, "ASSEMBLER GENERAL INSTRUCTION TEST\n");

	// Set reference hex values.
	num_to_output[0] = "08860032";
	num_to_output[1] = "00443000";
	num_to_output[2] = "11047000";
	num_to_output[3] = "19444000";
	num_to_output[4] = "2184006F";
	num_to_output[5] = "29CC5000";
	num_to_output[6] = "320C1F77";
	num_to_output[7] = "3A4E8000";
	num_to_output[8] = "42822000";
	num_to_output[9] = "4AC23000";
	num_to_output[10] = "53025000";
	num_to_output[11] = "5B40FFFF";
	num_to_output[12] = "6380FFFF";
	num_to_output[13] = "73C00064";
	num_to_output[14] = "6C000064";
	num_to_output[15] = "7C5E0014";
	num_to_output[16] = "84A00019";
	num_to_output[17] = "8900FFEE";
	num_to_output[18] = "8D00FFED";
	num_to_output[19] = "8C00FFEC";
	num_to_output[20] = "8800FFEB";
	num_to_output[21] = "8A00000B";
	num_to_output[22] = "8B00000A";
	num_to_output[23] = "8E000009";
	num_to_output[24] = "8F00FFE7";
	num_to_output[25] = "9100FFE6";
	num_to_output[26] = "9500FFE5";
	num_to_output[27] = "94000005";
	num_to_output[28] = "90000004";
	num_to_output[29] = "92000003";
	num_to_output[30] = "93000002";
	num_to_output[31] = "9600FFE0";
	num_to_output[32] = "9700FFDF";
	num_to_output[33] = "98000000";
	num_to_output[34] = "A5000000";
	num_to_output[35] = "A82B6000";
	num_to_output[36] = "B0000000";
	num_to_output[37] = "BB80FFFF";
	num_to_output[38] = "C12B6000";
	num_to_output[39] = "C82F8000";
	num_to_output[40] = "D2C00000";
	num_to_output[41] = "DE800000";
	num_to_output[42] = "E6F80000";
	num_to_output[43] = "EF400000";
	num_to_output[44] = "F7800000";
	num_to_output[45] = "FFC00000";

	// Open reference test file
	FILE* f = fopen("test.hl", "r");
	if(f == NULL)
	{
		fprintf(stdout, "Test output not found, aborting test.\n");
		return -1;
	}

	int i = 0;
	const size_t BUF_SIZE = 256;
	char buf[BUF_SIZE];

	// Compare each output accordingly
	while(fgets(buf, BUF_SIZE - 1, f) != NULL)
	{
		// Remove trailing newline
		int len = strlen(buf);
		if(buf[len - 1] == '\n')
		{
			buf[len - 1] = '\0';	
		}

		std::string actual = std::string(buf);
		if(actual != num_to_output[i])
		{
			mark_incorrect(i, actual, num_to_output[i]);
		}
		else correct_count++;
		i++;
	}

	fprintf(stdout, "%d correct lines detected.\n", correct_count);
	fprintf(stdout, "%d incorrect lines detected.\n", count);
	return count;
}
