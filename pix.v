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
reg [2*`width_of_data_pix - 1:0] data_out, data_to_multiplicator; 
integer i, j = 0;
reg [`width_of_data_pix - 1:0] coef_for_mult_0_5, [`width_of_data_pix - 1:0] coef_for_mult_0_33;
reg newdata_to_line = 0;

//////////////////////////////////////////////////////////
assign output_pix = data_out;
assign coef_for_mult_0_5 = 8'b10000000;
assign coef_for_mult_0_33 = 8'b01010100;//////////////////////////////////////////////////////////
always @(posedge clk_in) begin
    if (enable) begin
        
        // if (i > 1) begin
        //     SR_for_input[i] <= SR_for_input[i + 1];
        //     i <= i - 1;
        //     SR_for_input[width_SR_input] <= input_pix;
        // end else begin
        //    i <= width_SR_input - 1;
        // end
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
//TODO Подсоединить модуль умножителя
multiplicator mult_for_out_pix(
    .clock          (clk_in),
    .dataa          (),
    .datab          (coef_for_mult_0_33),
    .result         (data_out)
);
//! ////////////////////////////////////////////////////////
//счетчик для определения кратности пикселей
always @(posedge clk_out) begin
    if (enable) begin
        if (newdata_to_line) begin
            data_out <= (SR_for_input[width_SR_input] + SR_delta[`up_coef] + SR_for_input[width_SR_input - 1]);
            newdata_to_line <= !newdata_to_line;
        end else begin
            data_out <= (SR_delta[`up_coef - 1] + SR_delta[`up_coef - 2] + SR_for_input[width_SR_input - 2]);
            newdata_to_line <= !newdata_to_line;
        end
    end                                                                
    //     case (pix % 'up_coef) 
    //         2'b00: newdata_to_line <= 0;
    //         2'b01: begin
    //             newdata_to_line <= 1;
    //             data_out[(2 * `width_of_data_pix - 1) : `width_of_data_pix] <= (SR_for_input[width_SR_input] + SR_delta[`up_coef] + SR_for_input[width_SR_input - 1]) 
    //                                                                                 / (`up_coef * `low_coef) * `low_coef;
    //             data_out[`width_of_data_pix - 1 : 0] <= (SR_delta[`up_coef - 1] + SR_delta[`up_coef - 2] + SR_for_input[width_SR_input - 2])
    //                                                                                 / (`up_coef * `low_coef) * `low_coef;
    //         end
    //         2'b10: newdata_to_line <= 1;  
    // end
end

endmodule