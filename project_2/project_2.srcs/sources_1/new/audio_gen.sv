`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 6.111 Final Project Fall 2019
// Engineer: Alejandro Diaz 
// 
// Create Date: 11/01/2019 02:44:53 PM
// Module Name: audio_gen
// Project Name: FPGuitarHero
// Description: Takes the notes to be played and uses sine generators to create the 
// notes. Audio mixing is done by scaling the signals and then adding them together. 
//////////////////////////////////////////////////////////////////////////////////


module audio_gen(   input clk,
                    input [1:0] volume,
                    input reset,
                    input [60:0] notes,
                    output logic aud_pwm,
                    output logic aud_sd
    );  
    parameter SAMPLE_COUNT = 677;   // approximately (will generate audio at approx 48 kHz sample rate.
                                    // 1354 = 65000000 clock/48000KHz for a 64 sine table
                                    // 677 = 65000000 clock/96000KHz for a 128 sine table
    logic [15:0] sample_counter;
    logic sample_trigger;
    logic adc_ready;
    logic enable;
    logic [11:0] recorder_data;     // data passed from play_notes to volume_control (sum of note signals)        
    logic [7:0] vol_out;
    logic pwm_val;                  // pwm signal (HI/LO)
    
    assign aud_sd = 1;
    assign sample_trigger = (sample_counter == SAMPLE_COUNT);   // rate at which the sine wave advances

    always_ff @(posedge clk)begin
        if (sample_counter == SAMPLE_COUNT)begin                // resets counter
            sample_counter <= 16'b0;
        end else begin
            sample_counter <= sample_counter + 16'b1;
        end
    end
 
    play_notes myrec( .clk_in(clk),.rst_in(reset),.ready_in(sample_trigger), // notes and a trigger for advancing are passed
                         .data_out(recorder_data), .notes(notes));                                                                
    volume_control vc (.vol_in(volume),.signal_in(recorder_data), .signal_out(vol_out));            // scales signal
    pwm (.clk_in(clk), .rst_in(reset), .level_in({~vol_out[7],vol_out[6:0]}), .pwm_out(pwm_val));   // creates pwm
    assign aud_pwm = pwm_val?1'bZ:1'b0; 
    
endmodule

// Playing Notes
module play_notes(
  input logic clk_in,              // 100MHz system clock
  input logic rst_in,               // 1 to reset to initial state
  input logic ready_in,             // 1 when data is available
  input [60:0] notes,
  output logic signed [11:0] data_out       // 8-bit PCM data to headphone
); 
    // all note signals
    logic [7:0] t55, t58, t61, t65, t69, t73, t77, t82, t87, t92, t98, t103, t110, t116, 
    t123, t130, t138, t146, t155, t164, t174, t185, t196, t207, t220, t233, t246, t261, 
    t277, t293, t311, t329, t349, t369, t392, t415, t440, t466, t493, t523, t554, t587, 
    t622, t659, t698, t739, t783, t830, t880, t932, t987, t1046, t1108, t1174, t1244, 
    t1318, t1396, t1479, t1567, t1661, t1760;
    // SINE GENERATORS for each note
    sine_generator #(.PHASE_INCR(32'd4921316))   tonet55(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t55));
    sine_generator #(.PHASE_INCR(32'd5213911))   tonet58(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t58));
    sine_generator #(.PHASE_INCR(32'd5524401))   tonet61(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t61));
    sine_generator #(.PHASE_INCR(32'd5852787))   tonet65(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t65));
    sine_generator #(.PHASE_INCR(32'd6200859))   tonet69(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t69));
    sine_generator #(.PHASE_INCR(32'd6569510))   tonet73(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t73));
    sine_generator #(.PHASE_INCR(32'd6959636))   tonet77(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t77));
    sine_generator #(.PHASE_INCR(32'd7373921))   tonet82(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t82));
    sine_generator #(.PHASE_INCR(32'd7812366))   tonet87(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t87));
    sine_generator #(.PHASE_INCR(32'd8276759))   tonet92(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t92));
    sine_generator #(.PHASE_INCR(32'd8768891))   tonet98(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t98));
    sine_generator #(.PHASE_INCR(32'd9290551))   tonet103(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t103));
    sine_generator #(.PHASE_INCR(32'd9842633))   tonet110(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t110));
    sine_generator #(.PHASE_INCR(32'd10427822))   tonet116(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t116));
    sine_generator #(.PHASE_INCR(32'd11047908))   tonet123(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t123));
    sine_generator #(.PHASE_INCR(32'd11704680))   tonet130(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t130));
    sine_generator #(.PHASE_INCR(32'd12400823))   tonet138(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t138));
    sine_generator #(.PHASE_INCR(32'd13138126))   tonet146(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t146));
    sine_generator #(.PHASE_INCR(32'd13919273))   tonet155(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t155));
    sine_generator #(.PHASE_INCR(32'd14746949))   tonet164(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t164));
    sine_generator #(.PHASE_INCR(32'd15623838))   tonet174(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t174));
    sine_generator #(.PHASE_INCR(32'd16553519))   tonet185(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t185));
    sine_generator #(.PHASE_INCR(32'd17537783))   tonet196(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t196));
    sine_generator #(.PHASE_INCR(32'd18580207))   tonet207(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t207));
    sine_generator #(.PHASE_INCR(32'd19685266))   tonet220(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t220));
    sine_generator #(.PHASE_INCR(32'd20855645))   tonet233(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t233));
    sine_generator #(.PHASE_INCR(32'd22095817))   tonet246(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t246));
    sine_generator #(.PHASE_INCR(32'd23410256))   tonet261(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t261));
    sine_generator #(.PHASE_INCR(32'd24801646))   tonet277(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t277));
    sine_generator #(.PHASE_INCR(32'd26276252))   tonet293(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t293));
    sine_generator #(.PHASE_INCR(32'd27839441))   tonet311(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t311));
    sine_generator #(.PHASE_INCR(32'd29494793))   tonet329(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t329));
    sine_generator #(.PHASE_INCR(32'd31248571))   tonet349(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t349));
    sine_generator #(.PHASE_INCR(32'd33106144))   tonet369(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t369));
    sine_generator #(.PHASE_INCR(32'd35075566))   tonet392(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t392));
    sine_generator #(.PHASE_INCR(32'd37160414))   tonet415(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t415));
    sine_generator #(.PHASE_INCR(32'd39370533))   tonet440(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t440));
    sine_generator #(.PHASE_INCR(32'd41711290))   tonet466(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t466));
    sine_generator #(.PHASE_INCR(32'd44191634))   tonet493(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t493));
    sine_generator #(.PHASE_INCR(32'd46819617))   tonet523(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t523));
    sine_generator #(.PHASE_INCR(32'd49604187))   tonet554(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t554));
    sine_generator #(.PHASE_INCR(32'd52553398))   tonet587(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t587));
    sine_generator #(.PHASE_INCR(32'd55677987))   tonet622(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t622));
    sine_generator #(.PHASE_INCR(32'd58988691))   tonet659(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t659));
    sine_generator #(.PHASE_INCR(32'd62497142))   tonet698(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t698));
    sine_generator #(.PHASE_INCR(32'd66213184))   tonet739(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t739));
    sine_generator #(.PHASE_INCR(32'd70150237))   tonet783(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t783));
    sine_generator #(.PHASE_INCR(32'd74321724))   tonet830(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t830));
    sine_generator #(.PHASE_INCR(32'd78741067))   tonet880(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t880));
    sine_generator #(.PHASE_INCR(32'd83423476))   tonet932(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t932));
    sine_generator #(.PHASE_INCR(32'd88384163))   tonet987(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t987));
    sine_generator #(.PHASE_INCR(32'd93639234))   tonet1046(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1046));
    sine_generator #(.PHASE_INCR(32'd99207481))   tonet1108(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1108));
    sine_generator #(.PHASE_INCR(32'd105106797))   tonet1174(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1174));
    sine_generator #(.PHASE_INCR(32'd111356869))   tonet1244(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1244));
    sine_generator #(.PHASE_INCR(32'd117978277))   tonet1318(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1318));
    sine_generator #(.PHASE_INCR(32'd124993390))   tonet1396(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1396));
    sine_generator #(.PHASE_INCR(32'd132426368))   tonet1479(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1479));
    sine_generator #(.PHASE_INCR(32'd140300475))   tonet1567(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1567));
    sine_generator #(.PHASE_INCR(32'd148643449))   tonet1661(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1661));
    sine_generator #(.PHASE_INCR(32'd157482134))   tonet1760(.clk_in(clk_in), .rst_in(rst_in),.step_in(ready_in), .amp_out(t1760));                            
    
    // either contain note signal or nothing                               
    logic [7:0] d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, 
        d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, 
        d24, d25, d26, d27, d28, d29, d30, d31, d32, d33, d34, d35, 
        d36, d37, d38, d39, d40, d41, d42, d43, d44, d45, d46, d47, 
        d48, d49, d50, d51, d52, d53, d54, d55, d56, d57, d58, d59, d60;
    
    always_ff @(posedge clk_in)begin
        d0 <= notes[60]?    t55:8'b0; // send tone
        d1 <= notes[59]?    t58:8'b0; // send tone
        d2 <= notes[58]?    t61:8'b0; // send tone
        d3 <= notes[57]?    t65:8'b0; // send tone
        d4 <= notes[56]?    t69:8'b0; // send tone
        d5 <= notes[55]?    t73:8'b0; // send tone
        d6 <= notes[54]?    t77:8'b0; // send tone
        d7 <= notes[53]?    t82:8'b0; // send tone
        d8 <= notes[52]?    t87:8'b0; // send tone
        d9 <= notes[51]?    t92:8'b0; // send tone
        d10 <= notes[50]?   t98:8'b0; // send tone
        d11 <= notes[49]?   t103:8'b0; // send tone
        d12 <= notes[48]?   t110:8'b0; // send tone
        d13 <= notes[47]?   t116:8'b0; // send tone
        d14 <= notes[46]?   t123:8'b0; // send tone
        d15 <= notes[45]?   t130:8'b0; // send tone
        d16 <= notes[44]?   t138:8'b0; // send tone
        d17 <= notes[43]?   t146:8'b0; // send tone
        d18 <= notes[42]?   t155:8'b0; // send tone
        d19 <= notes[41]?   t164:8'b0; // send tone
        d20 <= notes[40]?   t174:8'b0; // send tone
        d21 <= notes[39]?   t185:8'b0; // send tone
        d22 <= notes[38]?   t196:8'b0; // send tone
        d23 <= notes[37]?   t207:8'b0; // send tone
        d24 <= notes[36]?   t220:8'b0; // send tone
        d25 <= notes[35]?   t233:8'b0; // send tone
        d26 <= notes[34]?   t246:8'b0; // send tone
        d27 <= notes[33]?   t261:8'b0; // send tone
        d28 <= notes[32]?   t277:8'b0; // send tone
        d29 <= notes[31]?   t293:8'b0; // send tone
        d30 <= notes[30]?   t311:8'b0; // send tone
        d31 <= notes[29]?   t329:8'b0; // send tone
        d32 <= notes[28]?   t349:8'b0; // send tone
        d33 <= notes[27]?   t369:8'b0; // send tone
        d34 <= notes[26]?   t392:8'b0; // send tone
        d35 <= notes[25]?   t415:8'b0; // send tone
        d36 <= notes[24]?   t440:8'b0; // send tone
        d37 <= notes[23]?   t466:8'b0; // send tone
        d38 <= notes[22]?   t493:8'b0; // send tone
        d39 <= notes[21]?   t523:8'b0; // send tone
        d40 <= notes[20]?   t554:8'b0; // send tone
        d41 <= notes[19]?   t587:8'b0; // send tone
        d42 <= notes[18]?   t622:8'b0; // send tone
        d43 <= notes[17]?   t659:8'b0; // send tone
        d44 <= notes[16]?   t698:8'b0; // send tone
        d45 <= notes[15]?   t739:8'b0; // send tone
        d46 <= notes[14]?   t783:8'b0; // send tone
        d47 <= notes[13]?   t830:8'b0; // send tone
        d48 <= notes[12]?   t880:8'b0; // send tone
        d49 <= notes[11]?   t932:8'b0; // send tone
        d50 <= notes[10]?   t987:8'b0; // send tone
        d51 <= notes[9]?    t1046:8'b0; // send tone
        d52 <= notes[8]?    t1108:8'b0; // send tone
        d53 <= notes[7]?    t1174:8'b0; // send tone
        d54 <= notes[6]?    t1244:8'b0; // send tone
        d55 <= notes[5]?    t1318:8'b0; // send tone
        d56 <= notes[4]?    t1396:8'b0; // send tone
        d57 <= notes[3]?    t1479:8'b0; // send tone
        d58 <= notes[2]?    t1567:8'b0; // send tone
        d59 <= notes[1]?    t1661:8'b0; // send tone
        d60 <= notes[0]?    t1760:8'b0; // send tone
        data_out <= (d0 + d1 + d2 + d3 + d4 + d5 + d6 + d7 +    // sum all note signals
            d8 + d9 + d10 + d11 + d12 + d13 + d14 + d15 + d16 + 
            d17 + d18 + d19 + d20 + d21 + d22 + d23 + d24 + d25 + 
            d26 + d27 + d28 + d29 + d30 + d31 + d32 + d33 + d34 + 
            d35 + d36 + d37 + d38 + d39 + d40 + d41 + d42 + d43 + 
            d44 + d45 + d46 + d47 + d48 + d49 + d50 + d51 + d52 + 
            d53 + d54 + d55 + d56 + d57 + d58 + d59 + d60);
    end                            
endmodule                              

//Volume Control
module volume_control (input [2:0] vol_in, input signed [11:0] signal_in, output logic signed[7:0] signal_out);
    logic [2:0] shift;
    assign shift = 3'd7 - vol_in;
    assign signal_out = signal_in>>>shift;
endmodule

//PWM generator for audio generation!
module pwm (input clk_in, input rst_in, input [7:0] level_in, output logic pwm_out);
    logic [7:0] count;
    assign pwm_out = count<level_in;
    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            count <= 8'b0;
        end else begin
            count <= count+8'b1;
        end
    end
endmodule

//Sine Wave Generator
module sine_generator ( input clk_in, input rst_in, //clock and reset
                        input step_in, //trigger a phase step (rate at which you run sine generator)
                        output logic [7:0] amp_out); //output phase   
    parameter PHASE_INCR = 32'b1000_0000_0000_0000_0000_0000_0000_0000>>5; //1/64th of 48 khz is 750 Hz
    logic [31:0] phase;                     // used to move through sine table
    logic [7:0] amp;
    assign amp_out = {~amp[7],amp[6:0]};    // output of this module
    sine_lut lut_1(.clk_in(clk_in), .phase_in(phase[31:25]), .amp_out(amp)); // selects correct sine value to display
    
    always_ff @(posedge clk_in)begin
        if (rst_in)begin
            phase <= 32'b0;
        end else if (step_in)begin
            phase <= phase+PHASE_INCR;      // used to move through the sine table
        end
    end
endmodule

// 7bit sine lookup for 128 values, 8bit depth (values are the addition of 3 sine functions
// flipped around a vertical axis)
module sine_lut(input[6:0] phase_in, input clk_in, output logic[7:0] amp_out);
  always_ff @(posedge clk_in)begin
    case(phase_in)
        7'd0: amp_out <= 8'd101;
        7'd1: amp_out <= 8'd75;
        7'd2: amp_out <= 8'd52;
        7'd3: amp_out <= 8'd32;
        7'd4: amp_out <= 8'd17;
        7'd5: amp_out <= 8'd6;
        7'd6: amp_out <= 8'd1;
        7'd7: amp_out <= 8'd1;
        7'd8: amp_out <= 8'd5;
        7'd9: amp_out <= 8'd14;
        7'd10: amp_out <= 8'd27;
        7'd11: amp_out <= 8'd42;
        7'd12: amp_out <= 8'd58;
        7'd13: amp_out <= 8'd76;
        7'd14: amp_out <= 8'd92;
        7'd15: amp_out <= 8'd107;
        7'd16: amp_out <= 8'd120;
        7'd17: amp_out <= 8'd130;
        7'd18: amp_out <= 8'd137;
        7'd19: amp_out <= 8'd140;
        7'd20: amp_out <= 8'd140;
        7'd21: amp_out <= 8'd137;
        7'd22: amp_out <= 8'd132;
        7'd23: amp_out <= 8'd126;
        7'd24: amp_out <= 8'd119;
        7'd25: amp_out <= 8'd111;
        7'd26: amp_out <= 8'd105;
        7'd27: amp_out <= 8'd100;
        7'd28: amp_out <= 8'd96;
        7'd29: amp_out <= 8'd95;
        7'd30: amp_out <= 8'd97;
        7'd31: amp_out <= 8'd101;
        7'd32: amp_out <= 8'd107;
        7'd33: amp_out <= 8'd114;
        7'd34: amp_out <= 8'd123;
        7'd35: amp_out <= 8'd132;
        7'd36: amp_out <= 8'd141;
        7'd37: amp_out <= 8'd148;
        7'd38: amp_out <= 8'd155;
        7'd39: amp_out <= 8'd159;
        7'd40: amp_out <= 8'd160;
        7'd41: amp_out <= 8'd160;
        7'd42: amp_out <= 8'd157;
        7'd43: amp_out <= 8'd152;
        7'd44: amp_out <= 8'd145;
        7'd45: amp_out <= 8'd138;
        7'd46: amp_out <= 8'd131;
        7'd47: amp_out <= 8'd124;
        7'd48: amp_out <= 8'd119;
        7'd49: amp_out <= 8'd116;
        7'd50: amp_out <= 8'd116;
        7'd51: amp_out <= 8'd119;
        7'd52: amp_out <= 8'd125;
        7'd53: amp_out <= 8'd135;
        7'd54: amp_out <= 8'd147;
        7'd55: amp_out <= 8'd162;
        7'd56: amp_out <= 8'd179;
        7'd57: amp_out <= 8'd196;
        7'd58: amp_out <= 8'd213;
        7'd59: amp_out <= 8'd228;
        7'd60: amp_out <= 8'd241;
        7'd61: amp_out <= 8'd250;
        7'd62: amp_out <= 8'd255;
        7'd63: amp_out <= 8'd255;
        7'd64: amp_out <= 8'd255;
        7'd65: amp_out <= 8'd255;
        7'd66: amp_out <= 8'd250;
        7'd67: amp_out <= 8'd241;
        7'd68: amp_out <= 8'd228;
        7'd69: amp_out <= 8'd213;
        7'd70: amp_out <= 8'd196;
        7'd71: amp_out <= 8'd179;
        7'd72: amp_out <= 8'd162;
        7'd73: amp_out <= 8'd147;
        7'd74: amp_out <= 8'd135;
        7'd75: amp_out <= 8'd125;
        7'd76: amp_out <= 8'd119;
        7'd77: amp_out <= 8'd116;
        7'd78: amp_out <= 8'd116;
        7'd79: amp_out <= 8'd119;
        7'd80: amp_out <= 8'd124;
        7'd81: amp_out <= 8'd131;
        7'd82: amp_out <= 8'd138;
        7'd83: amp_out <= 8'd145;
        7'd84: amp_out <= 8'd152;
        7'd85: amp_out <= 8'd157;
        7'd86: amp_out <= 8'd160;
        7'd87: amp_out <= 8'd160;
        7'd88: amp_out <= 8'd159;
        7'd89: amp_out <= 8'd155;
        7'd90: amp_out <= 8'd148;
        7'd91: amp_out <= 8'd141;
        7'd92: amp_out <= 8'd132;
        7'd93: amp_out <= 8'd123;
        7'd94: amp_out <= 8'd114;
        7'd95: amp_out <= 8'd107;
        7'd96: amp_out <= 8'd101;
        7'd97: amp_out <= 8'd97;
        7'd98: amp_out <= 8'd95;
        7'd99: amp_out <= 8'd96;
        7'd100: amp_out <= 8'd100;
        7'd101: amp_out <= 8'd105;
        7'd102: amp_out <= 8'd111;
        7'd103: amp_out <= 8'd119;
        7'd104: amp_out <= 8'd126;
        7'd105: amp_out <= 8'd132;
        7'd106: amp_out <= 8'd137;
        7'd107: amp_out <= 8'd140;
        7'd108: amp_out <= 8'd140;
        7'd109: amp_out <= 8'd137;
        7'd110: amp_out <= 8'd130;
        7'd111: amp_out <= 8'd120;
        7'd112: amp_out <= 8'd107;
        7'd113: amp_out <= 8'd92;
        7'd114: amp_out <= 8'd76;
        7'd115: amp_out <= 8'd58;
        7'd116: amp_out <= 8'd42;
        7'd117: amp_out <= 8'd27;
        7'd118: amp_out <= 8'd14;
        7'd119: amp_out <= 8'd5;
        7'd120: amp_out <= 8'd1;
        7'd121: amp_out <= 8'd1;
        7'd122: amp_out <= 8'd6;
        7'd123: amp_out <= 8'd17;
        7'd124: amp_out <= 8'd32;
        7'd125: amp_out <= 8'd52;
        7'd126: amp_out <= 8'd75;
        7'd127: amp_out <= 8'd101;
    endcase
  end
endmodule
