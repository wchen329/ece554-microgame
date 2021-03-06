`include "../constants.sv"

module sprite_command_controller_tb();
// ctrl signals
logic clk, rst_n;
// CPU
logic write_cmd;
logic [2:0] sprite_op;
logic [2:0] sprite_reg;
logic [1:0] orientation;
logic [7:0] x, y;
logic [15:0] address;
logic [7:0] r, g, b;
// mem
logic [31:0] mem_in;
logic [15:0] mem_address, addr;
// frame buffer
logic fb_busy;
logic fb_wfb, fb_dfb;
logic [15:0] fb_px;
logic [7:0] fb_r, fb_g, fb_b;

// sprite mem
logic [31:0] sprite_mem[0:255];

always_ff @(posedge clk)
	addr <= mem_address;

assign mem_in = sprite_mem[addr];

// frame buffer
logic [23:0] frame_buffer[0:65535];
logic [15:0] fb_counter;

typedef enum logic { IDLE, DFB } fb_state_t;
fb_state_t fb_state, fb_next_state;

// write
always_ff @(posedge clk, negedge rst_n)
	if(fb_wfb)
		frame_buffer[fb_px] <= { fb_r, fb_g, fb_b };

// counter
always_ff @(posedge clk)
	if(fb_state == DFB)
		fb_counter <= fb_counter + 1;
	else
		fb_counter <= 0;

// frame buffer SM
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		fb_state <= IDLE;
	else
		fb_state <= fb_next_state;

always_comb begin
	fb_next_state = IDLE;
	fb_busy = 0;

	case(fb_state)
		IDLE:
			if(fb_dfb) begin
				fb_busy = 1;
				fb_next_state = DFB;
			end
		DFB: begin
			fb_busy = 1;
			if(&fb_counter)
				fb_next_state = IDLE;
		end
	endcase
end

sprite_command_controller sprite_command_controller(
	.clk(clk),
	.rst_n(rst_n),
	.write_cmd(write_cmd),
	.cmd({sprite_op, sprite_reg, orientation, r, g, b, x, y, 16'h0, address}),
	.mem_in(mem_in),
	.mem_address(mem_address),
	.fb_wfb(fb_wfb),
	.fb_dfb(fb_dfb),
	.fb_px(fb_px),
	.fb_r(fb_r),
	.fb_g(fb_g),
	.fb_b(fb_b),
	.border_en(0)
);

always #20ns clk = ~clk;

initial begin
	integer i;
	$readmemh("sprite/sprite_buffer_mem.hex", sprite_mem);
	// $readmemh("sprite/sprite_buffer_mem2.hex", sprite_mem);
	clk = 0;
	rst_n = 0;
	sprite_op = 0;
	sprite_reg = 0;
	orientation = 0;
	{ x, y } = 0;
	address = 0;
	{ r, g, b } = 0;

	@(posedge clk);
	@(negedge clk);
	rst_n = 1;

	// draw frame buffer
	$display("Drawing frame buffer...");
	dfb();
	wait_done();

	// write px
	$display("Writing one pixel...");
	wfb(0, 0, 'hFF, 'hFF, 'hFF);
	dfb();
	wait_done();

	// wait for cmd to propagate
	@(posedge clk);
	@(negedge clk);

	// verify
	assert(frame_buffer[0] == 'hFFFFFF)
	else begin
		$display("Expected frame_buffer[0] to be 'hFFFFFF, not %h", frame_buffer[0]);
		$stop();
	end

	// draw a sprite
	ls(1, 0, 0);
	wait_done();
	for(i = 0; i < 8; i++) begin
		$display("Drawing sprite at %d,%d", i, i);
		ds(1, i, i);

		wait_done();
		check_sprite_frame(0, i, i);
	end

	// draw a sprite
	$display("Drawing sprite a lot");
	ls(1, 1, 0);
	ls(0, 0, 0);
	for(i = 0; i < 8; i++) begin
		ds(0, 10, 10);
	end

	repeat(10) wait_done();
	check_sprite_frame(0, 10, 10);

	// draw a sprite
	$display("Drawing sprite a lot then clearing");
	ls(1, 1, 0);
	ls(0, 0, 0);
	for(i = 0; i < 8; i++) begin
		ds(0, 10, 10);
	end
	cs(10, 10);

	repeat(11) wait_done();
	check_frame_zero(10, 10);

	// draw a sprite
	$display("Drawing and clearing sprite a lot");
	ls(1, 1, 0);
	ls(0, 0, 0);
	for(i = 0; i < 8; i++) begin
		ds(0, 10, 10);
		cs(10, 10);
	end

	repeat(16) wait_done();
	check_frame_zero(10, 10);

	// reset
	rst_n = 0;
	@(posedge clk);
	@(negedge clk);
	rst_n = 1;

	// draw a sprite
	$display("Drawing sprite after reset...");
	ls(0, 0, 0);
	ds(0, 0, 0);

	repeat(2) wait_done();
	check_sprite_frame(0, 0, 0);

	// rotate sprite
	$display("Drawing rotated sprite...");
	rs(0, 1);
	ds(0, 0, 0);

	wait_done();
	check_sprite_frame(64, 0, 0);

	// draw a sprite
	$display("Drawing sprite 2...");
	rs(0, 2);
	ds(0, 250, 1);

	wait_done();
	check_sprite_frame(128, 250, 1);

	// draw a sprite
	$display("Clearing sprite...");
	cs(250, 1);

	wait_done();
	check_frame_zero(250, 1);

	$display("All tests passed.");
	$stop();
end

task wfb(input [7:0] ix, iy, ir, ig, ib);
	sprite_op = `SPRITE_WFB;
	write_cmd = 1;
	x = ix;
	y = iy;
	{ r, g, b } = { ir, ig, ib };

	@(posedge clk);
	@(negedge clk);
	write_cmd = 0;
endtask

task wait_done();
	@(posedge sprite_command_controller.fifo_read);
	@(negedge sprite_command_controller.fifo_read);
	@(negedge clk);
endtask

task dfb();
	sprite_op = `SPRITE_DFB;
	write_cmd = 1;

	@(posedge clk);
	@(negedge clk);
	write_cmd = 0;
endtask

task ls(input [2:0] ireg, [1:0] iori, [15:0] iaddr);
	sprite_op = `SPRITE_LS;
	write_cmd = 1;
	sprite_reg = ireg;
	orientation = iori;
	address = iaddr;

	@(posedge clk);
	@(negedge clk);
	write_cmd = 0;
endtask

task ds(input [2:0] ireg, [7:0] ix, iy);
	sprite_op = `SPRITE_DS;
	write_cmd = 1;
	sprite_reg = ireg;
	x = ix;
	y = iy;

	@(posedge clk);
	@(negedge clk);
	write_cmd = 0;
endtask

task cs(input [7:0] ix, iy);
	sprite_op = `SPRITE_CS;
	write_cmd = 1;
	x = ix;
	y = iy;

	@(posedge clk);
	@(negedge clk);
	write_cmd = 0;
endtask

task rs(input [2:0] ireg, [1:0] iori);
	sprite_op = `SPRITE_RS;
	write_cmd = 1;
	sprite_reg = ireg;
	orientation = iori;

	@(posedge clk);
	@(negedge clk);
	write_cmd = 0;
endtask

task check_sprite_frame(input integer isprite_addr, [7:0] ix, iy);
	integer i;

	for(i = 0; i < 64; i++) begin
		// assert (frame_buffer[{iy+i[5:3], ix+i[2:0]}] == (ix < 8 || iy < 8 || ix > 248 || iy > 248) ? 0 : sprite_mem[isprite_addr+i][23:0])
		assert (sprite_mem[isprite_addr+i][23:0] ? frame_buffer[{iy+i[5:3], ix+i[2:0]}] == sprite_mem[isprite_addr+i][23:0] : 1)
		else begin
			$display(
				"Expected frame_buffer[%d (%d)] to be %d,%d,%d not %d,%d,%d",
				i, {iy+i[5:3], ix+i[2:0]},
				sprite_mem[isprite_addr+i][23:16], sprite_mem[isprite_addr+i][15:8], sprite_mem[isprite_addr+i][7:0],
				frame_buffer[{iy+i[5:3], ix+i[2:0]}][23:16], frame_buffer[{iy+i[5:3], ix+i[2:0]}][15:8], frame_buffer[{iy+i[5:3], ix+i[2:0]}][7:0]
			);
			$stop();
		end
	end
endtask

task check_frame_zero(input [7:0] ix, iy);
	integer i;

	for(i = 0; i < 64; i++) begin
		assert (frame_buffer[{iy+i[5:3], ix+i[2:0]}] == 0)
		else begin
			$display(
				"Expected frame_buffer[%d (%d)] to be 0 not %d,%d,%d",
				i, {iy+i[5:3], ix+i[2:0]},
				frame_buffer[{iy+i[5:3], ix+i[2:0]}][23:16], frame_buffer[{iy+i[5:3], ix+i[2:0]}][15:8], frame_buffer[{iy+i[5:3], ix+i[2:0]}][7:0]
			);
			$stop();
		end
	end
endtask

endmodule