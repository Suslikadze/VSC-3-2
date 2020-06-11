`timescale 1ns / 1ps
`include "Parameters.v"


module pixels(
    input clk_in,
    input rst,
    input enable_main,
    input [`bit_depth_pix - 1:0] pix,
    input [`width_of_data_pix - 1:0] input_pix,  //параметр
    output [`width_of_data_pix * 2 - 1:0] output_pix
);
//////////////////////////////////////////////////////////
wire         clk_100, clk_150, locked;
integer      i, j, a; 
reg          enable_int;
reg          switch_bool = 0;

reg         [`width_of_data_pix - 1:0]          SR_for_input [4:0]; //Сдвиговые регистр для входящих пикселей
reg signed  [`width_of_data_pix:0]              SR_delta [`up_coef - 1:0]; //Сдвиговый регистр для средних арифметических
reg signed  [`width_of_data_pix:0]              SR_from_mult_0_5 [`up_coef - 2:0]; 

wire signed [17:0]                              data_from_multiplicator_all_0_5, data_from_multiplicator_all_0_33;
wire        [`width_of_data_pix:0]              coef_for_mult_0_5, coef_for_mult_0_33;
wire        [9:0]                               data_from_multiplicator_0_5; 

reg [10:0] Total_sum;



//////////////////////////////////////////////////////////
assign output_pix                       = data_from_multiplicator_all_0_33[17:8];
assign coef_for_mult_0_5                = 9'b010000000;
assign coef_for_mult_0_33               = 9'b001010100;
assign data_from_multiplicator_0_5      = data_from_multiplicator_all_0_5[17:8];

//! ////////////////////////////////////////////////////////
multiplication mult_for_out_shift_register(
    .clock          (clk_150),
    .dataa          (SR_delta[0]),
    .datab          (coef_for_mult_0_5),
    .result         (data_from_multiplicator_all_0_5)
);

multiplicator_unsigned mult_for_out_pix(
    .clock          (clk_100),
    .dataa          (Total_sum),
    .datab          (coef_for_mult_0_33),
    .result         (data_from_multiplicator_all_0_33)
);

PLL PLL(
    .inclk0         (clk_in),
    .c0             (clk_100),
    .c2             (clk_150),
    .locked         (locked)
);
//! ////////////////////////////////////////////////////////
always @(posedge clk_150) begin
        enable_int <= locked & enable_main;
end
//! ////////////////////////////////////////////////////////
//Сдвиговый регистр для входных значений
always @(posedge clk_150) begin
    if (enable_int) begin
        for (i = 0; i < 5; i = i + 1) begin
            SR_for_input[0] <= input_pix;
            if (i != 0) begin
                SR_for_input[i] <= SR_for_input[i - 1];
            end
        end
       // SR_for_input[width_SR_input:0] <= {input_pix, SR_for_input[width_SR_input - 1:0]};
    end
end
//! ////////////////////////////////////////////////////////
//TODO SIGHTED ЗНАЧЕНИЕ!!!! DONE
//Сдвиговый регистр для разности значений
always @(posedge clk_150) begin
    if (enable_int) begin
        for (j = 0; j < `up_coef; j = j + 1) begin
            SR_delta[0] <= (input_pix - SR_for_input[0]);
            if (j != 0) begin
                SR_delta[j] <= SR_delta[j - 1];
            end
        end
        //SR_delta[`up_coef - 1 : 0] = {SR_delta[0], SR_delta[`up_coef - 2 : 0]};
    end
end 

//! ////////////////////////////////////////////////////////
// TODO знаковая разность между вторым и первым пикселем DONE
//Сдвиговый регистр для промежуточных средних пикселей, которые выходят из mult_for_out_shift_register
always @(posedge clk_150) begin
    if (enable_int) begin
        for (a = 0; a < `up_coef - 1; a = a + 1) begin
            SR_from_mult_0_5[0] <= data_from_multiplicator_0_5 + SR_for_input[2];
            if (a != 0) begin
                SR_from_mult_0_5[a] <= SR_from_mult_0_5[a - 1];
            end
        end
    end
end

always @(posedge clk_100) begin
    if (enable_int) begin
        case (switch_bool)
            0: begin
                //Total_sum <= SR_from_mult_0_5[0];
                Total_sum <= SR_from_mult_0_5[1] + SR_for_input[4] + SR_for_input[3];
                switch_bool <= !switch_bool;
            end
            1:  begin
                //Total_sum <= SR_from_mult_0_5[0];
                Total_sum <= SR_for_input [3] + SR_from_mult_0_5[0] + SR_from_mult_0_5[1];
                switch_bool <= !switch_bool;
            end
        endcase
    end
end


        // for (b = 0; b < 1; b = b + 1) begin
        //     result[0] <= 
        //     if (b != 0) begin
        //         result[b] <= result [b - 1]
        //     end









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