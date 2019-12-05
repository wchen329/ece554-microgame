/* Buffers input to convolution filters. We need to capture data from multiple
 * greyscale pixel rows and hold onto it until we have everything we need
 * for convolution. This module accomplishes this as well as pixel
 * assignment for the convolution modules including edge normalization.
 *
 * Note that there are 3 possible output modes from this module. Greyscale,
 * vertical edge detection, and horizontal edge detection.
 */

module convolution_buffer(
	input [11:0] ired,
	input [11:0] igreen,
	input [11:0] iblue,
	input idval, // input data valid
	
	input [1:0] mode, // 00 is raw RGB, 01 is vertical edge, 10 is horizontal edge, 11 is greyscale

	output logic [11:0] ored,
	output logic [11:0] ogreen,
	output logic [11:0] oblue,
	output logic odval, // output data valid

	input clk, rst_n
);

///////////////////////////////////////////////////////////////////////////////
// pixel buffers

logic [0:1282] [11:0] red_buffer;
logic [0:1282] [11:0] green_buffer;
logic [0:1282] [11:0] blue_buffer;
logic [0:1282] [11:0] grey_buffer;
logic [11:0] igrey;

Greyscale g(
		.r(ired),
		.g(igreen),
		.b(iblue),
		.grey(igrey)
	);

always_ff @(posedge clk) begin
	if (idval) begin
		red_buffer[0:1282]    <= {ired, red_buffer[0:1281]};
		green_buffer[0:1282]  <= {igreen, green_buffer[0:1281]};
		blue_buffer[0:1282]   <= {iblue, blue_buffer[0:1281]};
		grey_buffer[0:1282]   <= {igrey, grey_buffer[0:1281]};
	end
end

logic [10:0] received;
logic [8:0] con_row;
logic [9:0] con_col;

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		received <= 11'b0;
		odval <= 0;
	end else if (idval) begin
		if (received == 642) begin
			odval <= 1;
		end else begin
			received <= received + 1;
		end
	end else begin
		received <= received;
		odval <= 0;
	end
end

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		con_row <= 0;
		con_col <= 0;
	end else if (odval) begin
		if (con_col == 639) begin
			con_col <= 0;
			if (con_row == 479) begin
				con_row <= 0;
			end else begin
				con_row <= con_row + 1;
			end
		end else begin
			con_col <= con_col + 1;
		end
	end
end

logic signed [10:0] neg_col;
logic signed [10:0] pos_col;
logic signed [10:0] neg_row;
logic signed [10:0] pos_row;
logic [11:0] convolute_in [8:0];

always_comb begin
	// convolution assignments
	// We need to do some special math here to account for edges of the image

	neg_row = 640;
	pos_row = -640;
	neg_col = 1;
	pos_col = -1;

	// row edge cases
	if (con_row == 0) begin
		// top
		neg_row = 0;
	end else
	if (con_row == 479) begin
		// bottom
		pos_row = 0;
	end

	// column edge cases
	if (con_col == 0) begin
		// left
		neg_col = 0;
	end else
	if (con_col == 639) begin
		// right
		pos_col = 0;
	end

	convolute_in[0] = grey_buffer[641 + neg_row + neg_col];
	convolute_in[1] = grey_buffer[641 + neg_row];
	convolute_in[2] = grey_buffer[641 + neg_row + pos_col];
	convolute_in[3] = grey_buffer[641 + neg_col];
	convolute_in[4] = grey_buffer[641];
	convolute_in[5] = grey_buffer[641 + pos_col];
	convolute_in[6] = grey_buffer[641 + pos_row + neg_col];
	convolute_in[7] = grey_buffer[641 + pos_row];
	convolute_in[8] = grey_buffer[641 + pos_row + pos_col];
end

///////////////////////////////////////////////////////////////////////////////
// vertical convolution module

logic [11:0] vertical_data;

vertical_convolution vertical_edge(
	.data_0(convolute_in[0]),
	.data_1(convolute_in[1]),
	.data_2(convolute_in[2]),
	.data_3(convolute_in[3]),
	.data_4(convolute_in[4]),
	.data_5(convolute_in[5]),
	.data_6(convolute_in[6]),
	.data_7(convolute_in[7]),
	.data_8(convolute_in[8]),
	.convolution(vertical_data)
);

///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////
// horizontal convolution module

logic [11:0] horizontal_data;

horizontal_convolution horizontal_edge(
	.data_0(convolute_in[0]),
	.data_1(convolute_in[1]),
	.data_2(convolute_in[2]),
	.data_3(convolute_in[3]),
	.data_4(convolute_in[4]),
	.data_5(convolute_in[5]),
	.data_6(convolute_in[6]),
	.data_7(convolute_in[7]),
	.data_8(convolute_in[8]),
	.convolution(horizontal_data)
);

///////////////////////////////////////////////////////////////////////////////



// 00 is raw RGB, 01 is vertical edge, 10 is horizontal edge, 11 is greyscale
always_comb begin
	case(mode)
		2'b00: begin
			ored = red_buffer[641];
			ogreen = green_buffer[641];
			oblue = blue_buffer[641];
		end
		2'b01: begin
			ored = vertical_data;
			ogreen = vertical_data;
			oblue = vertical_data;
		end
		2'b10: begin
			ored = horizontal_data;
			ogreen = horizontal_data;
			oblue = horizontal_data;
		end
		2'b11: begin
			ored = grey_buffer[641];
			ogreen = grey_buffer[641];
			oblue = grey_buffer[641];
		end
	endcase
end

endmodule
