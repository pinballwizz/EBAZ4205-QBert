//----------------------------------
//       QBert Clocks
//----------------------------------
module qbert_clocks( 
  input         clk_sys,
  input         clock_40,
  output reg    clock_25,
  output        clock_10,
  output reg    clock_5,
  output reg    cpu_clk,
  output reg    sound_clk // 1.44 Mhz
);

reg [3:0] cnt1;
//reg cpu_clk; // clock enable

always @(posedge clk_sys) begin
  cnt1 <= cnt1 + 5'd1;
  if (cnt1 == 5'd9) begin
    cnt1 <= 5'd0;
    cpu_clk <= 1'b1;
  end
  else cpu_clk <= 1'b0;
end

//------------------------------------
// derive 1.44 Mhz sound clock from clk_sys

reg [5:0] cnt2;
//reg sound_clk;

always @(posedge clk_sys) begin
  cnt2 <= cnt2 + 6'd1;
  sound_clk <= 1'b0;
  if (cnt2 == 6'd55) begin
    cnt2 <= 6'd0;
    sound_clk <= 1'b1;
  end
end

reg [1:0] cnt3;
always @(posedge clock_40)
  cnt3 <= cnt3 + 2'd1;

assign clock_10 = cnt3[1];

//reg clock_5;
always @(posedge clock_10)
  clock_5 <= ~clock_5;
  
//reg clock_25;
always @(posedge clk_sys)
  clock_25 <= ~clock_25; 

endmodule