`timescale 1ns / 1ps

module main(
    input wire CLK,
    output [3:0] TMDS,
    output [3:0] TMDSB
);


// clock pixel
wire pixclk;

// datas
wire [11:0] hdata;
wire [11:0] vdata;
wire hsync;
wire vsync;
wire de;

// vga
wire [26:0] _v;
vga1920x1080x60 v_inst (.clk(pixclk), .hdata(_v[26:15]), .vdata(_v[14:3]), .hsync(_v[2]), .vsync(_v[1]), .de(_v[0]));
buffer #(27) v_buffer (.clk(pixclk), .in(_v), .out({hdata, vdata, hsync, vsync, de})); 

// TMDS

////////////////////////////////////////////////////////////////
// DVI Encoder
////////////////////////////////////////////////////////////////

// clock 148.5
wire clk_tmp;
wire clk_tmp2;
wire clk2; // was 20 10
dcm #(.M(27),.D(20)) c0 (.in(CLK), .fx_out(clk_tmp)); 
dcm #(.M(11),.D(10)) c1 (.in(clk_tmp), .fx_out(clk2));

wire [26:0] _v2;
buffer #(27) v_buffer2 (.clk(pixclk), .in({
  (de == 1'b0) ? 8'h00 : hdata[7:0],
  (de == 1'b0) ? 8'h00 : vdata[7:0],
  (de == 1'b0) ? 8'h00 : 8'h5A,
  hsync, vsync, de}), .out(_v2)); 

dvi_out DVI (
  .reset(1'b0), 
  .clkfx(clk2), 
  .clk_out(pixclk), 
  
  .red_data(_v2[26:19]), 
  .green_data(_v2[18:11]), 
  .blue_data(_v2[10:3]),
   
  .hsync(_v2[2]), 
  .vsync(_v2[1]), 
  .de(_v2[0]),
   
  .TMDS(TMDS), 
  .TMDSB(TMDSB)
);
  
endmodule
