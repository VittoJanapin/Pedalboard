module distortion (
    CLOCK_50,
    enable,
    left_channel_audio_in,
    right_channel_audio_in,
    left_channel_audio_out,
    right_channel_audio_out,
);

/****************************************************************

                        PORTS                                   
    
*****************************************************************/

input CLOCK_50, enable;
input [31:0] left_channel_audio_in, right_channel_audio_in;
output [31:0] left_channel_audio_out, left_channel_audio_out;

/****************************************************************

                    COMBINATIONAL CIRCUITS                      
    
************************************_*****************************/
localparam threshold = 31'd1_000_000_000;
always @ (*) 
    begin   
        if(~enable) 
        begin
            left_channel_audio_out = left_channel_audio_in;
            right_channel_audio_out = right_channel_audio_in;
        end

        else
        begin
            /***** APPLY DISTORTION LOGIC ******/
            if(left_channel_audio_in[30:0] > threshold)
                left_channel_audio_out = {left_channel_audio_in[31], threshold[30:0]}
            else 
                left_channel_audio_out = left_channel_audio_in;
            if(right_channel_audio_in[30:0] > threshold)
                right_channel_audio_out = {right_channel_audio_in[31], threshold[30:0]}
            else 
                right_channel_audio_out = right_channel_audio_in;
        end
    end

//easy!


endmodule