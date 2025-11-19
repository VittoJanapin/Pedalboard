module Project (
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
    LEDR
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

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;

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

wire [2:0] amplification;
assign amplification = SW[3:1];

assign left_channel_audio_out	= left_channel_audio_in << amplification;
assign right_channel_audio_out	= right_channel_audio_in << amplification;

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

