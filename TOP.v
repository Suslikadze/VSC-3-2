`timescale 1ns / 1ps
`include "Parameters.v"


module compression_video(
    input clk_in,
    input rst,
    input enable,
    input [`bit_depth_pix - 1:0] pix,
    input [`bit_depth_lines - 1:0] lines,
    input [`width_of_data_pix - 1:0] input_pix,  //параметр
    output [`width_of_data_pix * 2 - 1:0] output_pix
);

//////////////////////////////////////////////////////////




//////////////////////////////////////////////////////////
pixels pixels(
    .clk_in(clk_in),
    .rst(rst),
    .enable(enable),
    .[`bit_depth_pix - 1:0] pix([`bit_depth_pix - 1:0] pix),
    .[`width_of_data_pix - 1:0] input_pix([`width_of_data_pix - 1:0] input_pix),
    .[`width_of_data_pix * 2 - 1:0] output_pix(from_pix_output)
)