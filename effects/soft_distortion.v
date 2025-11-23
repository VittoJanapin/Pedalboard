module soft_distortion (
    CLOCK_50,
    enable,
    left_channel_audio_in,
    right_channel_audio_in,
    left_channel_audio_out,
    right_channel_audio_out
);

/****************************************************************

                        PORTS                                   
    
*****************************************************************/

input CLOCK_50, enable;
input [31:0] left_channel_audio_in, right_channel_audio_in;
output reg [31:0] left_channel_audio_out, left_channel_audio_out;

/****************************************************************

                    COMBINATIONAL CIRCUITS                      
    
*****************************************************************/



reg[7:0] LUT[0:255];
initial begin
    LUT[0] = 8'h00;
    LUT[1] = 8'h06;
    LUT[2] = 8'h0D;
    LUT[3] = 8'h13;
    LUT[4] = 8'h19;
    LUT[5] = 8'h20;
    LUT[6] = 8'h26;
    LUT[7] = 8'h2C;
    LUT[8] = 8'h32;
    LUT[9] = 8'h38;
    LUT[10] = 8'h3E;
    LUT[11] = 8'h44;
    LUT[12] = 8'h4A;
    LUT[13] = 8'h50;
    LUT[14] = 8'h56;
    LUT[15] = 8'h5B;
    LUT[16] = 8'h61;
    LUT[17] = 8'h66;
    LUT[18] = 8'h6C;
    LUT[19] = 8'h71;
    LUT[20] = 8'h76;
    LUT[21] = 8'h7B;
    LUT[22] = 8'h80;
    LUT[23] = 8'h84;
    LUT[24] = 8'h89;
    LUT[25] = 8'h8D;
    LUT[26] = 8'h92;
    LUT[27] = 8'h96;
    LUT[28] = 8'h9A;
    LUT[29] = 8'h9E;
    LUT[30] = 8'hA2;
    LUT[31] = 8'hA6;
    LUT[32] = 8'hA9;
    LUT[33] = 8'hAD;
    LUT[34] = 8'hB0;
    LUT[35] = 8'hB3;
    LUT[36] = 8'hB7;
    LUT[37] = 8'hBA;
    LUT[38] = 8'hBD;
    LUT[39] = 8'hBF;
    LUT[40] = 8'hC2;
    LUT[41] = 8'hC5;
    LUT[42] = 8'hC7;
    LUT[43] = 8'hCA;
    LUT[44] = 8'hCC;
    LUT[45] = 8'hCE;
    LUT[46] = 8'hD1;
    LUT[47] = 8'hD3;
    LUT[48] = 8'hD5;
    LUT[49] = 8'hD6;
    LUT[50] = 8'hD8;
    LUT[51] = 8'hDA;
    LUT[52] = 8'hDC;
    LUT[53] = 8'hDD;
    LUT[54] = 8'hDF;
    LUT[55] = 8'hE0;
    LUT[56] = 8'hE2;
    LUT[57] = 8'hE3;
    LUT[58] = 8'hE4;
    LUT[59] = 8'hE6;
    LUT[60] = 8'hE7;
    LUT[61] = 8'hE8;
    LUT[62] = 8'hE9;
    LUT[63] = 8'hEA;
    LUT[64] = 8'hEB;
    LUT[65] = 8'hEC;
    LUT[66] = 8'hED;
    LUT[67] = 8'hEE;
    LUT[68] = 8'hEF;
    LUT[69] = 8'hEF;
    LUT[70] = 8'hF0;
    LUT[71] = 8'hF1;
    LUT[72] = 8'hF1;
    LUT[73] = 8'hF2;
    LUT[74] = 8'hF3;
    LUT[75] = 8'hF3;
    LUT[76] = 8'hF4;
    LUT[77] = 8'hF4;
    LUT[78] = 8'hF5;
    LUT[79] = 8'hF5;
    LUT[80] = 8'hF6;
    LUT[81] = 8'hF6;
    LUT[82] = 8'hF7;
    LUT[83] = 8'hF7;
    LUT[84] = 8'hF7;
    LUT[85] = 8'hF8;
    LUT[86] = 8'hF8;
    LUT[87] = 8'hF9;
    LUT[88] = 8'hF9;
    LUT[89] = 8'hF9;
    LUT[90] = 8'hF9;
    LUT[91] = 8'hFA;
    LUT[92] = 8'hFA;
    LUT[93] = 8'hFA;
    LUT[94] = 8'hFA;
    LUT[95] = 8'hFB;
    LUT[96] = 8'hFB;
    LUT[97] = 8'hFB;
    LUT[98] = 8'hFB;
    LUT[99] = 8'hFB;
    LUT[100] = 8'hFC;
    LUT[101] = 8'hFC;
    LUT[102] = 8'hFC;
    LUT[103] = 8'hFC;
    LUT[104] = 8'hFC;
    LUT[105] = 8'hFC;
    LUT[106] = 8'hFC;
    LUT[107] = 8'hFD;
    LUT[108] = 8'hFD;
    LUT[109] = 8'hFD;
    LUT[110] = 8'hFD;
    LUT[111] = 8'hFD;
    LUT[112] = 8'hFD;
    LUT[113] = 8'hFD;
    LUT[114] = 8'hFD;
    LUT[115] = 8'hFD;
    LUT[116] = 8'hFD;
    LUT[117] = 8'hFE;
    LUT[118] = 8'hFE;
    LUT[119] = 8'hFE;
    LUT[120] = 8'hFE;
    LUT[121] = 8'hFE;
    LUT[122] = 8'hFE;
    LUT[123] = 8'hFE;
    LUT[124] = 8'hFE;
    LUT[125] = 8'hFE;
    LUT[126] = 8'hFE;
    LUT[127] = 8'hFE;
    LUT[128] = 8'hFE;
    LUT[129] = 8'hFE;
    LUT[130] = 8'hFE;
    LUT[131] = 8'hFE;
    LUT[132] = 8'hFE;
    LUT[133] = 8'hFE;
    LUT[134] = 8'hFE;
    LUT[135] = 8'hFE;
    LUT[136] = 8'hFE;
    LUT[137] = 8'hFE;
    LUT[138] = 8'hFE;
    LUT[139] = 8'hFF;
    LUT[140] = 8'hFF;
    LUT[141] = 8'hFF;
    LUT[142] = 8'hFF;
    LUT[143] = 8'hFF;
    LUT[144] = 8'hFF;
    LUT[145] = 8'hFF;
    LUT[146] = 8'hFF;
    LUT[147] = 8'hFF;
    LUT[148] = 8'hFF;
    LUT[149] = 8'hFF;
    LUT[150] = 8'hFF;
    LUT[151] = 8'hFF;
    LUT[152] = 8'hFF;
    LUT[153] = 8'hFF;
    LUT[154] = 8'hFF;
    LUT[155] = 8'hFF;
    LUT[156] = 8'hFF;
    LUT[157] = 8'hFF;
    LUT[158] = 8'hFF;
    LUT[159] = 8'hFF;
    LUT[160] = 8'hFF;
    LUT[161] = 8'hFF;
    LUT[162] = 8'hFF;
    LUT[163] = 8'hFF;
    LUT[164] = 8'hFF;
    LUT[165] = 8'hFF;
    LUT[166] = 8'hFF;
    LUT[167] = 8'hFF;
    LUT[168] = 8'hFF;
    LUT[169] = 8'hFF;
    LUT[170] = 8'hFF;
    LUT[171] = 8'hFF;
    LUT[172] = 8'hFF;
    LUT[173] = 8'hFF;
    LUT[174] = 8'hFF;
    LUT[175] = 8'hFF;
    LUT[176] = 8'hFF;
    LUT[177] = 8'hFF;
    LUT[178] = 8'hFF;
    LUT[179] = 8'hFF;
    LUT[180] = 8'hFF;
    LUT[181] = 8'hFF;
    LUT[182] = 8'hFF;
    LUT[183] = 8'hFF;
    LUT[184] = 8'hFF;
    LUT[185] = 8'hFF;
    LUT[186] = 8'hFF;
    LUT[187] = 8'hFF;
    LUT[188] = 8'hFF;
    LUT[189] = 8'hFF;
    LUT[190] = 8'hFF;
    LUT[191] = 8'hFF;
    LUT[192] = 8'hFF;
    LUT[193] = 8'hFF;
    LUT[194] = 8'hFF;
    LUT[195] = 8'hFF;
    LUT[196] = 8'hFF;
    LUT[197] = 8'hFF;
    LUT[198] = 8'hFF;
    LUT[199] = 8'hFF;
    LUT[200] = 8'hFF;
    LUT[201] = 8'hFF;
    LUT[202] = 8'hFF;
    LUT[203] = 8'hFF;
    LUT[204] = 8'hFF;
    LUT[205] = 8'hFF;
    LUT[206] = 8'hFF;
    LUT[207] = 8'hFF;
    LUT[208] = 8'hFF;
    LUT[209] = 8'hFF;
    LUT[210] = 8'hFF;
    LUT[211] = 8'hFF;
    LUT[212] = 8'hFF;
    LUT[213] = 8'hFF;
    LUT[214] = 8'hFF;
    LUT[215] = 8'hFF;
    LUT[216] = 8'hFF;
    LUT[217] = 8'hFF;
    LUT[218] = 8'hFF;
    LUT[219] = 8'hFF;
    LUT[220] = 8'hFF;
    LUT[221] = 8'hFF;
    LUT[222] = 8'hFF;
    LUT[223] = 8'hFF;
    LUT[224] = 8'hFF;
    LUT[225] = 8'hFF;
    LUT[226] = 8'hFF;
    LUT[227] = 8'hFF;
    LUT[228] = 8'hFF;
    LUT[229] = 8'hFF;
    LUT[230] = 8'hFF;
    LUT[231] = 8'hFF;
    LUT[232] = 8'hFF;
    LUT[233] = 8'hFF;
    LUT[234] = 8'hFF;
    LUT[235] = 8'hFF;
    LUT[236] = 8'hFF;
    LUT[237] = 8'hFF;
    LUT[238] = 8'hFF;
    LUT[239] = 8'hFF;
    LUT[240] = 8'hFF;
    LUT[241] = 8'hFF;
    LUT[242] = 8'hFF;
    LUT[243] = 8'hFF;
    LUT[244] = 8'hFF;
    LUT[245] = 8'hFF;
    LUT[246] = 8'hFF;
    LUT[247] = 8'hFF;
    LUT[248] = 8'hFF;
    LUT[249] = 8'hFF;
    LUT[250] = 8'hFF;
    LUT[251] = 8'hFF;
    LUT[252] = 8'hFF;
    LUT[253] = 8'hFF;
    LUT[254] = 8'hFF;
    LUT[255] = 8'hFF;
end

/************************************
    NOISE GATE
************************************/
wire [31:0] gated_input;
wire [31:0] abs_value;

assign abs_value = left_channel_audio_in[31] ? -left_channel_audio_in : left_channel_audio_in;
parameter THRESH = 31'd5_000_000; 

assign gated_input = abs_value < THRESH ? 32'b0 : left_channel_audio_in;

/************************************
    LUT INDEXER
    *find magnitude take upper 8;
*************************************/
wire [7:0] mag_index;
wire [7:0] lut_mag;
wire signed [8:0] lut_signed;

assign mag_index = abs_value [31:24];
assign lut_mag = LUT[mag_index];
lut_signed = left_channel_audio_in[31] ? -lut_mag : lut_mag;

wire signed [31:0] distorted = lut_signed << 23;
always @ (*) 
    begin   
        if(~enable) 
        begin
            left_channel_audio_out = gated_input;
            right_channel_audio_out = gated_input;
        end

        else
        begin
            /***** APPLY DISTORTION LOGIC ******/
            //evaluate the amplitude at different thresholds
            //use lut for with the top 8 bits as index, 
            //use gated input
            left_channel_audio_out = distorted;
            right_channel_audio_out = distorted;
        end
    end
endmodule