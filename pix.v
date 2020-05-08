`timescale 1ns / 1ps
`include "Parameters.v"


module pixels(
    input clk_in,
    input clk_out,
    input rst,
    input enable,
    input [`bit_depth_pix - 1:0] pix,
    input [`width_of_data_pix - 1:0] input_pix,  //параметр
    output [`width_of_data_pix * 2 - 1:0] output_pix
);

//////////////////////////////////////////////////////////
localparam width_SR_input = `up_coef * `low_coef - 1;

reg [`width_of_data_pix - 1:0] SR_for_input [width_SR_input:0]; //Сдвиговые регистр для входящих пикселей
reg [`width_of_data_pix - 1:0] SR_delta [`up_coef:0]; //Сдвиговый регистр для средних арефметических
wire [`width_of_data_pix - 1:0] data_from_multiplicator_0_5; 

reg [2*`width_of_data_pix - 1:0] data_out, data_to_multiplicator_0_33, data_to_multiplicator_0_5; 
integer i, j = 0;
wire [`width_of_data_pix - 1:0] coef_for_mult_0_5;
reg newdata_to_line = 0;

//////////////////////////////////////////////////////////
assign output_pix               = data_out;
assign coef_for_mult_0_5        = 8'b10000000;
assign coef_for_mult_0_33       = 8'b01010100;
//! ////////////////////////////////////////////////////////
//Сдвиговый регистр для входных значений
always @(posedge clk_in) begin
    if (enable) begin
        for (i = 0; i < width_SR_input + 1; i = i + 1) begin
            SR_for_input[0] <= input_pix;
            if (i != 0) begin
                SR_for_input[i] <= SR_for_input[i - 1];
            end
        end
       // SR_for_input[width_SR_input:0] <= {input_pix, SR_for_input[width_SR_input - 1:0]};
    end
end
//! ////////////////////////////////////////////////////////
//TODO SIGHTED ЗНАЧЕНИЕ!!!!
//Сдвиговый регистр для разности значений
always @(posedge clk_in) begin
    if (enable) begin
        for (j = 0; j < `up_coef + 1; j = j + 1) begin
            SR_delta[0] <= (SR_for_input[0] - SR_for_input[1]);
            if (j != 0) begin
                SR_delta[j] <= SR_delta[j - 1];
            end
        end
        //SR_delta[`up_coef - 1 : 0] = {SR_delta[0], SR_delta[`up_coef - 2 : 0]};
    end
end 
//! ////////////////////////////////////////////////////////
multiplication mult_for_out_shift_register(
    .clock          (clk_in),
    .dataa          (SR_delta[`up_coef]),
    .datab          (coef_for_mult_0_5),
    .result         (data_from_multiplicator_0_5)
);

// multiplication mult_for_out_pix(
//     .clock          (clk_in),
//     .dataa          (data_to_multiplicator_0_33),
//     .datab          (coef_for_mult_0_33),
//     .result         (data_out)
// );
//! ////////////////////////////////////////////////////////
// TODO знаковая разность между вторым и первым пикселем
//счетчик для определения кратности пикселей
// always @(posedge clk_out) begin
//     if (enable) begin











//         if (newdata_to_line) begin


//             if (SR_for_input[width_SR_input] < SR_for_input[width_SR_input - 1]) begin
//                 data_to_multiplicator_0_33 <= (SR_for_input[width_SR_input] + SR_for_input[width_SR_input]
//                                         + data_from_multiplicator_0_5 + SR_for_input[width_SR_input - 1]);
//             end else begin
//                 data_to_multiplicator_0_33 <= (SR_for_input[width_SR_input] + SR_for_input[width_SR_input - 1]
//                                         + data_from_multiplicator_0_5 + SR_for_input[width_SR_input - 1]);
//             end
//             newdata_to_line <= !newdata_to_line;

//         end else begin

//             if (SR_for_input[width_SR_input] < SR_for_input[width_SR_input - 1]) begin
//                 data_to_multiplicator_0_33 <= ( + + SR_for_input[width_SR_input - 2]);
//             end else begin

//             end
//             newdata_to_line <= !newdata_to_line;

//         end
//     end                                                                
// end

endmodule