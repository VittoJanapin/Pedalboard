/*****************************************************************************
 *                          Bit Crusher                        *
 *****************************************************************************/

module BitCrusher(

clk,
enable, // will be controller by a switch if 1 then we apply effect if 0 do nothing
reset_n,
r_audio_in,
l_audio_in,
r_audio_out,
l_audio_out,
// new_audio_in // Says that we have a new audio signal to process

);

input wire clk, enable, reset_n;
input wire signed [31:0] r_audio_in, l_audio_in;
output reg signed [31:0] r_audio_out, l_audio_out;
reg signed [31:0] r_audio_crushed, l_audio_crushed;


always @(*)
begin
    l_audio_crushed = l_audio_in;
    l_audio_crushed [0] = 1'b0;
    l_audio_crushed [1] = 1'b0;
    l_audio_crushed [2] = 1'b0;
    l_audio_crushed [3] = 1'b0; 
    l_audio_crushed [4] = 1'b0; 
    l_audio_crushed [5] = 1'b0; 
    l_audio_crushed [6] = 1'b0; 
    l_audio_crushed [7] = 1'b0; // sets the 8 least significant bits to be zero

    r_audio_crushed = l_audio_in;
    r_audio_crushed [0] = 1'b0;
    r_audio_crushed [1] = 1'b0;
    r_audio_crushed [2] = 1'b0;
    r_audio_crushed [3] = 1'b0; 
    r_audio_crushed [4] = 1'b0; 
    r_audio_crushed [5] = 1'b0; 
    r_audio_crushed [6] = 1'b0; 
    r_audio_crushed [7] = 1'b0; // sets the 8 least significant bits to be zer

    if(enable) begin
        l_audio_out = l_audio_crushed; //if the switch is on then we crush the audio
        r_audio_out = r_audio_crushed; //if the switch is on then we crush the audio
        end
    else begin
    r_audio_out = r_audio_in; //if the switch is off do nothing
    l_audio_out = l_audio_in; //if the switch is off do nothing
    end
end
endmodule