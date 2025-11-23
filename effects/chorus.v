module chorus(
    CLOCK_50,
    sample_clk,
    resetn,
    enable,
    left_channel_audio_in,
    right_channel_audio_in,
    left_channel_audio_out,
    right_channel_audio_out
);
/*************************************
PORTS
**************************************/
input CLOCK_50, enable, resetn, sample_clk;
input [31:0] left_channel_audio_in, right_channel_audio_in;
output [31:0] right_channel_audio_in, left_channel_audio_in;

/**********************************************************************
    specifications: 
    10 ms, depth of 4 ms, lfo of 0.8hz, wet = 0.4

    10ms delay = 480 samples (480 pointers behind)
    4ms depth = 192 (this is how much it varies) 
***********************************************************************/

//circular buffer for 32 ms approx -> 32 bits * 32ms/48k
reg [31:0] delay_buffer[0:2047]; //0.42 ms of samples //11 bit requirement
reg [10:0] write_ptr;
reg [10:0] read_ptr1, read_ptr2, read_ptr3; //+one voice

/***********************************************************************************************
Writing logic, the pointer iterates at 48k sync with aud then I will write to a certain address
The address will loop back to 0, exactly like a circular buffer
***********************************************************************************************/
always @ (posedge sample_clk) begin
    if(~resetn) begin
        write_ptr <= 0;
    end
    else begin
        delay_buffer[write_ptr] <= left_channel_audio_in; 
        write_ptr <= (write_ptr+1) & 11'b11111111111; //pointer mask, basically always limited to the and of 1111111
    end
end
/***********************************************************************************************
Reading logic, will compare with the write ptr then subtract a certain index according to a 
a low frequency oscillator like 
***********************************************************************************************/

/***********************************************************************************************
LFO - LOW FREQUENCY OSCILLATOR WITH LUT FOR SIN
***********************************************************************************************/
parameter PHASE_STEP = 32'd74565;//calculated the right frequency
reg [31:0] phase_acc1; //0 degree offest voice 1
reg [31:0] phase_acc2; //120
reg [31:0] phase_acc3; //240

initial begin
    phase_acc1 = 32'd0;
    phase_acc2 = 32'd1431655765; //one third of the way
    phase_acc3 = 32'd2863311530; //two thirds
end

always @ (posedge sample_clk) begin
        phase_acc1 <= (phase_acc1 + PHASE_STEP); //ptr mask so it never exceeds that
        phase_acc2 <= (phase_acc2 + PHASE_STEP);
        phase_acc3 <= (phase_acc3 + PHASE_STEP);
end

//so now phase_acc can be used as inputs for sin!!!!
//use lookup table here

//delay_ptr calculator
reg [11:0] delay1, delay2, delay3;

//these lines generate what index were on (what theta)
wire [7:0] lut_index1, lut_index2, lut_index3;
assign lut_index1 = phase_acc1[31:24];
assign lut_index2 = phase_acc2[31:24];
assign lut_index3 = phase_acc3[31:24];

//output of sin theta in floating point
wire signed [15:0] sin1, sin2, sin3;
assign signed [15:0] sin1 = LUT[lut_index1];
assign signed [15:0] sin2 = LUT[lut_index2];
assign signed [15:0] sin3 = LUT[lut_index3];

//how deep
localparam signed [15:0] depth = 192;


always @ (posedge sample_clk) begin
    delay1 <= 480 + ((sin1 * depth) >>> 15); //we multiply using floating pointmath then we divide back down to integer level (set this in the lut generator)
    delay2 <= 480 + ((sin2 * depth) >>> 15); //we multiply using floating pointmath then we divide back down to integer level (set this in the lut generator)
    delay3 <= 480 + ((sin3 * depth) >>> 15); //we multiply using floating pointmath then we divide back down to integer level (set this in the lut generator)
end

//now we know delay we must set the ptr to be behind the writer
always @ (posedge sample_clk) begin
    read_ptr1 <= (write_ptr - delay1) & 11'h7FF;
    read_ptr2 <= (write_ptr - delay2) & 11'h7FF;
    read_ptr3 <= (write_ptr - delay3) & 11'h7FF;
end


/***********************************************************************************************
MIXING TIME!!!
dry: 50
v1, v2 ,v3 = 25 25 25 
***********************************************************************************************/
// combinational mixer
wire signed [35:0] mix_acc =
      (left_channel_audio_in        >>> 1)  // 0.5 * dry
    + (delay_buffer[read_ptr1]      >>> 2)  // 0.25 * v1
    + (delay_buffer[read_ptr2]      >>> 2)  // 0.25 * v2
    + (delay_buffer[read_ptr3]      >>> 2); // 0.25 * v3

reg signed [31:0] chorus_out;

always @(posedge sample_clk or negedge resetn) begin
    if (!resetn)
        chorus_out <= 0;
    else
        chorus_out <= mix_acc[31:0];
end

assign left_channel_audio_out  = chorus_out;
assign right_channel_audio_out = chorus_out;

assign left_channel_audio_out = chorus_out;
assign right_channel_audio_out = chorus_out;


reg [15:0] LUT[0:255];

initial begin
LUT[0] = 16'h0000;
LUT[1] = 16'h0324;
LUT[2] = 16'h0648;
LUT[3] = 16'h096A;
LUT[4] = 16'h0C8C;
LUT[5] = 16'h0FAB;
LUT[6] = 16'h12C8;
LUT[7] = 16'h15E2;
LUT[8] = 16'h18F9;
LUT[9] = 16'h1C0B;
LUT[10] = 16'h1F1A;
LUT[11] = 16'h2223;
LUT[12] = 16'h2528;
LUT[13] = 16'h2826;
LUT[14] = 16'h2B1F;
LUT[15] = 16'h2E11;
LUT[16] = 16'h30FB;
LUT[17] = 16'h33DF;
LUT[18] = 16'h36BA;
LUT[19] = 16'h398C;
LUT[20] = 16'h3C56;
LUT[21] = 16'h3F17;
LUT[22] = 16'h41CE;
LUT[23] = 16'h447A;
LUT[24] = 16'h471C;
LUT[25] = 16'h49B4;
LUT[26] = 16'h4C3F;
LUT[27] = 16'h4EBF;
LUT[28] = 16'h5133;
LUT[29] = 16'h539B;
LUT[30] = 16'h55F5;
LUT[31] = 16'h5842;
LUT[32] = 16'h5A82;
LUT[33] = 16'h5CB3;
LUT[34] = 16'h5ED7;
LUT[35] = 16'h60EB;
LUT[36] = 16'h62F1;
LUT[37] = 16'h64E8;
LUT[38] = 16'h66CF;
LUT[39] = 16'h68A6;
LUT[40] = 16'h6A6D;
LUT[41] = 16'h6C23;
LUT[42] = 16'h6DC9;
LUT[43] = 16'h6F5E;
LUT[44] = 16'h70E2;
LUT[45] = 16'h7254;
LUT[46] = 16'h73B5;
LUT[47] = 16'h7504;
LUT[48] = 16'h7641;
LUT[49] = 16'h776B;
LUT[50] = 16'h7884;
LUT[51] = 16'h7989;
LUT[52] = 16'h7A7C;
LUT[53] = 16'h7B5C;
LUT[54] = 16'h7C29;
LUT[55] = 16'h7CE3;
LUT[56] = 16'h7D89;
LUT[57] = 16'h7E1D;
LUT[58] = 16'h7E9C;
LUT[59] = 16'h7F09;
LUT[60] = 16'h7F61;
LUT[61] = 16'h7FA6;
LUT[62] = 16'h7FD8;
LUT[63] = 16'h7FF5;
LUT[64] = 16'h7FFF;
LUT[65] = 16'h7FF5;
LUT[66] = 16'h7FD8;
LUT[67] = 16'h7FA6;
LUT[68] = 16'h7F61;
LUT[69] = 16'h7F09;
LUT[70] = 16'h7E9C;
LUT[71] = 16'h7E1D;
LUT[72] = 16'h7D89;
LUT[73] = 16'h7CE3;
LUT[74] = 16'h7C29;
LUT[75] = 16'h7B5C;
LUT[76] = 16'h7A7C;
LUT[77] = 16'h7989;
LUT[78] = 16'h7884;
LUT[79] = 16'h776B;
LUT[80] = 16'h7641;
LUT[81] = 16'h7504;
LUT[82] = 16'h73B5;
LUT[83] = 16'h7254;
LUT[84] = 16'h70E2;
LUT[85] = 16'h6F5E;
LUT[86] = 16'h6DC9;
LUT[87] = 16'h6C23;
LUT[88] = 16'h6A6D;
LUT[89] = 16'h68A6;
LUT[90] = 16'h66CF;
LUT[91] = 16'h64E8;
LUT[92] = 16'h62F1;
LUT[93] = 16'h60EB;
LUT[94] = 16'h5ED7;
LUT[95] = 16'h5CB3;
LUT[96] = 16'h5A82;
LUT[97] = 16'h5842;
LUT[98] = 16'h55F5;
LUT[99] = 16'h539B;
LUT[100] = 16'h5133;
LUT[101] = 16'h4EBF;
LUT[102] = 16'h4C3F;
LUT[103] = 16'h49B4;
LUT[104] = 16'h471C;
LUT[105] = 16'h447A;
LUT[106] = 16'h41CE;
LUT[107] = 16'h3F17;
LUT[108] = 16'h3C56;
LUT[109] = 16'h398C;
LUT[110] = 16'h36BA;
LUT[111] = 16'h33DF;
LUT[112] = 16'h30FB;
LUT[113] = 16'h2E11;
LUT[114] = 16'h2B1F;
LUT[115] = 16'h2826;
LUT[116] = 16'h2528;
LUT[117] = 16'h2223;
LUT[118] = 16'h1F1A;
LUT[119] = 16'h1C0B;
LUT[120] = 16'h18F9;
LUT[121] = 16'h15E2;
LUT[122] = 16'h12C8;
LUT[123] = 16'h0FAB;
LUT[124] = 16'h0C8C;
LUT[125] = 16'h096A;
LUT[126] = 16'h0648;
LUT[127] = 16'h0324;
LUT[128] = 16'h0000;
LUT[129] = 16'hFCDC;
LUT[130] = 16'hF9B8;
LUT[131] = 16'hF696;
LUT[132] = 16'hF374;
LUT[133] = 16'hF055;
LUT[134] = 16'hED38;
LUT[135] = 16'hEA1E;
LUT[136] = 16'hE707;
LUT[137] = 16'hE3F5;
LUT[138] = 16'hE0E6;
LUT[139] = 16'hDDDD;
LUT[140] = 16'hDAD8;
LUT[141] = 16'hD7DA;
LUT[142] = 16'hD4E1;
LUT[143] = 16'hD1EF;
LUT[144] = 16'hCF05;
LUT[145] = 16'hCC21;
LUT[146] = 16'hC946;
LUT[147] = 16'hC674;
LUT[148] = 16'hC3AA;
LUT[149] = 16'hC0E9;
LUT[150] = 16'hBE32;
LUT[151] = 16'hBB86;
LUT[152] = 16'hB8E4;
LUT[153] = 16'hB64C;
LUT[154] = 16'hB3C1;
LUT[155] = 16'hB141;
LUT[156] = 16'hAECD;
LUT[157] = 16'hAC65;
LUT[158] = 16'hAA0B;
LUT[159] = 16'hA7BE;
LUT[160] = 16'hA57E;
LUT[161] = 16'hA34D;
LUT[162] = 16'hA129;
LUT[163] = 16'h9F15;
LUT[164] = 16'h9D0F;
LUT[165] = 16'h9B18;
LUT[166] = 16'h9931;
LUT[167] = 16'h975A;
LUT[168] = 16'h9593;
LUT[169] = 16'h93DD;
LUT[170] = 16'h9237;
LUT[171] = 16'h90A2;
LUT[172] = 16'h8F1E;
LUT[173] = 16'h8DAC;
LUT[174] = 16'h8C4B;
LUT[175] = 16'h8AFC;
LUT[176] = 16'h89BF;
LUT[177] = 16'h8895;
LUT[178] = 16'h877C;
LUT[179] = 16'h8677;
LUT[180] = 16'h8584;
LUT[181] = 16'h84A4;
LUT[182] = 16'h83D7;
LUT[183] = 16'h831D;
LUT[184] = 16'h8277;
LUT[185] = 16'h81E3;
LUT[186] = 16'h8164;
LUT[187] = 16'h80F7;
LUT[188] = 16'h809F;
LUT[189] = 16'h805A;
LUT[190] = 16'h8028;
LUT[191] = 16'h800B;
LUT[192] = 16'h8001;
LUT[193] = 16'h800B;
LUT[194] = 16'h8028;
LUT[195] = 16'h805A;
LUT[196] = 16'h809F;
LUT[197] = 16'h80F7;
LUT[198] = 16'h8164;
LUT[199] = 16'h81E3;
LUT[200] = 16'h8277;
LUT[201] = 16'h831D;
LUT[202] = 16'h83D7;
LUT[203] = 16'h84A4;
LUT[204] = 16'h8584;
LUT[205] = 16'h8677;
LUT[206] = 16'h877C;
LUT[207] = 16'h8895;
LUT[208] = 16'h89BF;
LUT[209] = 16'h8AFC;
LUT[210] = 16'h8C4B;
LUT[211] = 16'h8DAC;
LUT[212] = 16'h8F1E;
LUT[213] = 16'h90A2;
LUT[214] = 16'h9237;
LUT[215] = 16'h93DD;
LUT[216] = 16'h9593;
LUT[217] = 16'h975A;
LUT[218] = 16'h9931;
LUT[219] = 16'h9B18;
LUT[220] = 16'h9D0F;
LUT[221] = 16'h9F15;
LUT[222] = 16'hA129;
LUT[223] = 16'hA34D;
LUT[224] = 16'hA57E;
LUT[225] = 16'hA7BE;
LUT[226] = 16'hAA0B;
LUT[227] = 16'hAC65;
LUT[228] = 16'hAECD;
LUT[229] = 16'hB141;
LUT[230] = 16'hB3C1;
LUT[231] = 16'hB64C;
LUT[232] = 16'hB8E4;
LUT[233] = 16'hBB86;
LUT[234] = 16'hBE32;
LUT[235] = 16'hC0E9;
LUT[236] = 16'hC3AA;
LUT[237] = 16'hC674;
LUT[238] = 16'hC946;
LUT[239] = 16'hCC21;
LUT[240] = 16'hCF05;
LUT[241] = 16'hD1EF;
LUT[242] = 16'hD4E1;
LUT[243] = 16'hD7DA;
LUT[244] = 16'hDAD8;
LUT[245] = 16'hDDDD;
LUT[246] = 16'hE0E6;
LUT[247] = 16'hE3F5;
LUT[248] = 16'hE707;
LUT[249] = 16'hEA1E;
LUT[250] = 16'hED38;
LUT[251] = 16'hF055;
LUT[252] = 16'hF374;
LUT[253] = 16'hF696;
LUT[254] = 16'hF9B8;
end

endmodule