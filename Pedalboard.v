module Pedalboard (
	// Inputs
	CLOCK_50,
	SW,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
    LEDR,

	VGA_R,
	VGA_G,
	VGA_B,

	VGA_HS,
	VGA_VS,
	VGA_BLANK_N,
	VGA_SYNC_N,
	VGA_CLK

);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[3:0]	KEY;
input		[3:0]	SW;
output       [9:0]   LEDR;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs for audio
output				AUD_XCK;
output				AUD_DACDAT;
output				FPGA_I2C_SCLK;

//Outputs for video
output				VGA_R;
output				VGA_G;
output				VGA_B;
output				VGA_HS;
output				VGA_VS;
output				VGA_BLANK_N;
output				VGA_SYNC_N;
output				VGA_CLK;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

// Internal Registers


// State Machine Registers


/*******************************************************************************

Audio Controller Interfacing

********************************************************************************/

assign read_audio_in			= audio_in_available; //will set a flag for the audio module to read audio in if theres available signals
assign write_audio_out			= audio_in_available & audio_out_allowed & SW[0]; //set flag to allow outputting



assign left_channel_audio_out	= left_channel_audio_in;
assign right_channel_audio_out	= right_channel_audio_in;

/*******************************************************************************

Amplification uses 3-bit specifications, 
Bit shift left by n bits (each level is a power of 2 more)

********************************************************************************/

/*******************************************************************************

Signal Strength Detector, This will display how much amplitude there is
This follows the decibel scale
max is 2^31-1 and min is obviously 0
divide that into ten and account for the logarithmic pattern
each bin is calculated by 10^(18.66n/20)
We evaluate the highest amplitude first

********************************************************************************/
wire	[30:0] abs_sample;
assign abs_sample = left_channel_audio_out[31] ? -left_channel_audio_out[30:0] : left_channel_audio_out[30:0];
reg     [9:0]   amplitude;
always @ (*)
begin
	amplitude = 10'b0;
    if(abs_sample > 31'd2137962000) //MAX
        amplitude = 10'b1111111111;
    else if(abs_sample > 31'd249459500)
        amplitude = 10'b0111111111;
    else if(abs_sample > 31'd29107170)
        amplitude = 10'b0011111111;
    else if(abs_sample > 31'd3396253)
        amplitude = 10'b0001111111;
    else if(abs_sample > 31'd396278)
        amplitude = 10'b0000111111;
    else if(abs_sample > 31'd46238)
        amplitude = 10'b0000011111;
    else if(abs_sample > 31'd5395)
        amplitude = 10'b0000001111;
    else if(abs_sample > 31'd629)
        amplitude = 10'b0000000111;
    else if(abs_sample > 31'd73)
        amplitude = 10'b0000000011;
    else if(abs_sample > 31'd8)
        amplitude = 10'b0000000001;
    else
        amplitude = 10'b0000000000;
end

assign LEDR[9:0] = amplitude;
/*****************************************************************************
 *                              VGA CONTROLLER                             *
 *****************************************************************************/
parameter RESOLUTION = "160x120"; // "640x480" "320x240" "160x120"
parameter COLOR_DEPTH = 9; // 9 6 3

 
/* wires for VGA */

reg write;
reg [8:0] x; //160 bam
reg [7:0] y; //7 for height
reg [8:0] color;

defparam VGA.BACKGROUND_IMAGE = "./MIFs/background.mif";

//there are only 4 things we can draw
wire [3:0] enable;
assign enable = SW[3:0];

//next state logic
reg [1:0] state, nextState;
always @ (*)
    begin
        case(state)
            0: nextState = 1;
            1: nextState = 2'd2;
            2: nextState = 2'd3;
            3: nextState = 2'd0;
        endcase
    end

always @ (posedge CLOCK_50)
    begin
        if(~KEY[0]) state <= 0;
        else state <= nextState;
    end


//outputs
always @ (posedge CLOCK_50) begin
    case(state)
        0: begin x <= 42; y <= 47; color <= enable[0] ? 3'h1C1 : 9'h100; write<=1; end
        1: begin x <= 66; y <= 47; color <= enable[0] ? 3'h1C1 : 9'h100; write<=1; end
        2: begin x <= 90; y <= 47; color <= enable[0] ? 3'h1C1 : 9'h100; write<=1; end
        3: begin x <= 113; y <= 47; color <= enable[0] ? 3'h1C1 : 9'h100; write<=1; end
    endcase
end

wire [3:0] selector;
assign selector = SW[3:0];






/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(0)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);

vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .color(color),
        .x(X),
        .y(Y),
        .write(write),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
);




endmodule


/*
COLOR GUIDE
1D9 - ORANGE PEDAL
2F - BLUE
1B6 - WHITE
56 - PURPLE

1C1 - red
100 - MUTED RED
*/


/* VGA Adapter
 * ----------------
 *
 * This is an implementation of a VGA Adapter. The adapter uses VGA mode signalling to initiate
 * a 640x480 resolution mode on a computer monitor, with a refresh rate of approximately 60Hz.
 *
 * This implementation of the VGA adapter can display images of varying color depth at a 
 * resolution of 640x480 pixels. You can also select a resolution of 320x240 or 160x120. For 
 * these resolutions the adapter draws each "pixel" as a 2x2, or 4x4, block, respectively, on 
 * the 640x480 display. 
 *
 * The number of bits of on-chip memory used by the adapter for the video memory is given by:
 *
 *     memory bits = COLS x ROWS x COLOR_DEPTH
 *
 *     Examples for DE1-SoC with COLOR_DEPTH = 3, 6, 9 (total colors = 8, 64, 512): 
 *       640 x 480: x 3 = 921,600 bits, x 6 = 1,843,200 bit, x 9 = 2,764,800 bits
 *       320 x 240: x 3 = 230,400 bits, x 6 = 460,800 bits,  x 9 = 691,200 bits 
 *       160 x 120: x 3 = 57,600 bits,  x 6 = 115,200 bits,  x 9 = 172,800 bits
 *
 * The VGA resolution is set in the file resolution.v. The color-depth of the video memory is
 * set by the parameter COLOR_DEPTH.
 *
 * The video memory can be loaded with an image from a memory initialization file (MIF) during
 * FPGA programming. The MIF is specified by using the parameter BACKGROUND_IMAGE.
 *
 * To use this module connect the vga_adapter to your circuit. Your circuit should produce a 
 * value for inputs color, x, y and write. When write is high, at the next positive edge of the 
 * input clock the vga_adapter will change the contents of the video memory for the pixel at 
 * location (x,y). At the next redraw * cycle the VGA controller will update the external video
 * monitor. Since the monitor has no memory, the VGA controller copies the contents of the 
 * video memory to the screen once every 60th of a second, which keeps the image stable.
 *
 * Make sure to include the required VGA signal pin assignments for the DE1-SoC board. Connect
 * the clock input to 50 MHz CLOCK_50 pin.
 *
 * During compilation with Quartus Prime you may receive a number of warning messages related
 * to a phase-locked loop (PLL), and a message about VGA_SYNC_N being stuck at Vcc. You can 
 * safely ignore these warnings. 
 */