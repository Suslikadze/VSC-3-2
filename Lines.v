`timescale 1ns / 1ps
`include "Parameters.v"


module compression_video(
    input clk_in,
    input clk_out,
    input rst,
    input enable,
    input newline,
    input [`bit_depth_lines - 1:0] lines,
    input [`width_of_data_pix - 1:0] input_pix,  //параметр
    output [`width_of_data_pix * 2 - 1:0] output_pix
);
//////////////////////////////////////////////////////////
localparam width_SR_input = `up_coef * `low_coef - 1;
//reg [`width_of_data_pix - 1:0] RAM [`number_of_lines * width_SR_input:0];
reg [`width_of_data_pix - 1:0] SR_for_measure [width_SR_input - 1:0];
wire [`width_of_data_pix - 1:0] data_in_RAM;
wire [`width_of_data_pix - 1:0] data_from_RAM1, data_from_RAM2, data_from_RAM3, data_from_RAM4, data_from_RAM5;
reg [`width_of_data_pix - 1:0] data_out;
reg [`width_of_data_pix - 1:0] average1, average2;
integer i = 0,
        j = 0;
reg [4:0] wr_enable, rd_enable;
//////////////////////////////////////////////////////////
assign data_in_RAM = input_pix;
assign output_pix = data_out; 
//////////////////////////////////////////////////////////
// always @(posedge clk_in) begin
//     if (type_data_from_pix) begin
//             data_in_RAM = input_pix [(2 * `width_of_data_pix - 1) : `width_of_data_pix];
//         end else begin
//             data_in_RAM = input_pix [`width_of_data_pix - 1 : 0];
//             // for (j = 0; j < `width_of_data_pix - 1; j = j + 1) begin
//             //     data_in_RAM[7 - j] <= input_pix[7 - j];
//             // end
//             i <= 0;
//         end
//     end
// end
//////////////////////////////////////////////////////////
//пять RAM для хранения пяти строк
RAM_2_ports RAM_1(
    .data(data_in_RAM),
    .rdaddress(lines),
    .rdclock(clk_out),
    .rden(rd_enable[0]),
    .wraddress(lines),
    .wrclock(clk_in),
    .wren(wr_enable[0]),
    .q(data_from_RAM1)
);
RAM_2_ports RAM_2(
    .data(data_in_RAM),
    .rdaddress(lines),
    .rdclock(clk_out),
    .rden(rd_enable[1]),
    .wraddress(lines),
    .wrclock(clk_in),
    .wren(wr_enable[1]),
    .q(data_from_RAM2)
);
RAM_2_ports RAM_3(
    .data(data_in_RAM),
    .rdaddress(lines),
    .rdclock(clk_out),
    .rden(rd_enable[2]),
    .wraddress(lines),
    .wrclock(clk_in),
    .wren(wr_enable[2]),
    .q(data_from_RAM3)
);
RAM_2_ports RAM_4(
    .data(data_in_RAM),
    .rdaddress(lines),
    .rdclock(clk_out),
    .rden(rd_enable[3]),
    .wraddress(lines),
    .wrclock(clk_in),
    .wren(wr_enable[3]),
    .q(data_from_RAM4)
);
RAM_2_ports RAM_5(
    .data(data_in_RAM),
    .rdaddress(lines),
    .rdclock(clk_out),
    .rden(rd_enable[4]),
    .wraddress(lines),
    .wrclock(clk_in),
    .wren(wr_enable[4]),
    .q(data_from_RAM5)
);
//////////////////////////////////////////////////////////
multiplication mult_1(
    clock(clk_in),
    dataa()
);

//////////////////////////////////////////////////////////
//Логика объявления enable разным RAM
always @(posedge newline) begin
    if (enable) begin
        if (j < 4) begin
            j <= j + 1;
        end else begin
            j <= 0;
        end
    end
end
//////////////////////////////////////////////////////////
always @(posedge clk_in) begin
    if (enable) begin
        case (j) 
            3'd0: begin
                    wr_enable <= 5'b00001;
                    rd_enable <= ~wr_enable;

                    average1 <= (data_from_RAM2 + data_from_RAM3) / `low_coef;
                    average2 <= (data_from_RAM3 + data_from_RAM4) / `low_coef;
                end
            3'd1: begin
                    wr_enable <= 5'b00010;
                    rd_enable <= ~wr_enable;
                    average1 <= (data_from_RAM4 + data_from_RAM5) / `low_coef;
                end
            3'd2: begin
                    wr_enable <= 5'b00100;
                    rd_enable <= ~wr_enable;

                    average1 <= (data_from_RAM5 + data_from_RAM1) / 2;
                    average2 <= (data_from_RAM1 + data_from_RAM2) / 2;
                end
            3'd3: begin
                    wr_enable <= 5'b01000;
                    rd_enable <= ~wr_enable;

                end
            3'd4: begin
                    wr_enable <= 5'b10000;
                    rd_enable <= ~wr_enable;

                    average1 <= (data_from_RAM1 + data_from_RAM2) / 2;
                end
        endcase
    end
end
//////////////////////////////////////////////////////////
always @(posedge clk_out) begin
    if (enable) begin
        case (j)
            3'd0: begin
                    data_out <= (data_from_RAM3 + average1 + average2) / (`up_coef * `low_coef) * `low_coef;
                end
            3'd1: begin
                    data_out <= (average1 + data_from_RAM3 + data_from_RAM4) /  (`up_coef * `low_coef) * `low_coef;
                end
            3'd2: begin
                    data_out <= (average1 + average2) / (`up_coef * `low_coef) * `low_coef;
                end
            3'd3: begin
                    data_out <= (data_from_RAM1 + data_from_RAM2 + average1) / (`up_coef * `low_coef) * `low_coef;
                end
        endcase
    end
end

endmodule