#include <cstdio>
#include <cstring>
#include <string>
#include <map>

int correct_count = 0;
int count = 0;

void mark_incorrect(const std::string& actual, const std::string& expected)
{
	fprintf(stdout, "Incorrect sequence detected:\n");
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
	fprintf(stdout, "---\n");

	// Set reference assembly.
	num_to_output[0] = "08860032";
	num_to_output[1] = "00443000";
	num_to_output[2] = "11047000";
	num_to_output[3] = "19444000";
	num_to_output[4] = "2184006F";
	num_to_output[5] = "29CC5000";
	num_to_output[6] = "320C1F77";
	num_to_output[7] = "3AE48000";
	num_to_output[8] = "42822000";
	num_to_output[9] = "4AC23000";
	num_to_output[10] = "53025000";
	num_to_output[11] = "5B40FFFF";
	num_to_output[12] = "";
	num_to_output[13] = "";
	num_to_output[14] = "";
	num_to_output[15] = "";
	num_to_output[16] = "";
	num_to_output[17] = "";
	num_to_output[18] = "";
	num_to_output[19] = "";
	num_to_output[20] = "";

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
			mark_incorrect(actual, num_to_output[i]);
		}
		else correct_count++;
		i++;
	}

	fprintf(stdout, "%d correct lines detected.\n", correct_count);
	fprintf(stdout, "%d incorrect lines detected.\n", count);
	return count;
}
