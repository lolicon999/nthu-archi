`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/03
 * Design Name: 	Pipeline CPU
 * Module Name:		ForwardinUnit 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 
 * Please DO NOT change the module name, or your'll get ZERO point.
 * You should add your code here to complete the project 3 (bonus.)
 ******************************************************************/
module ForwardinUnit(EX_MEMRegWrite,MEM_WBRegWrite,EX_MEMRegisterRd,MEM_WBRegisterRd,ID_EXRegisterRs,ID_EXRegisterRt,ForwardA,ForwardB);
input EX_MEMRegWrite,MEM_WBRegWrite;
input [4:0] EX_MEMRegisterRd,MEM_WBRegisterRd,ID_EXRegisterRs,ID_EXRegisterRt;
output reg [1:0] ForwardA,ForwardB;

always@(*)begin
	
	if(((EX_MEMRegWrite == 1'b1)==1'b1)&&(MEM_WBRegisterRd!=5'd0)&&(EX_MEMRegisterRd==ID_EXRegisterRs))begin
		ForwardA = 2'b10;
	end else if((MEM_WBRegWrite == 1'b1)&&(MEM_WBRegisterRd!=5'd0)&&(MEM_WBRegisterRd==ID_EXRegisterRs))begin
		ForwardA = 2'b01;
	end else begin
		ForwardA = 2'b00;
	end
	
	if((EX_MEMRegWrite == 1'b1)&&(MEM_WBRegisterRd!=5'd0)&&(EX_MEMRegisterRd==ID_EXRegisterRt))begin
		ForwardB = 2'b10;
	end else if((MEM_WBRegWrite == 1'b1)&&(MEM_WBRegisterRd!=5'd0)&&(MEM_WBRegisterRd==ID_EXRegisterRt))begin
		ForwardB = 2'b01;
	end else begin
		ForwardB = 2'b00;
	end

end


endmodule
