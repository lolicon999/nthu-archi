`timescale 1ns / 1ps
//Subject:     Architecture Project1 - Simulator
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simulator(
        clk_i,
		rst_i
		);

//Parameter
`define INSTR_NUM 256
`define DATA_NUM 256
//instuction define
//R-type
`define ADD 6'h20
`define SUB 6'h22
`define AND 6'h24
`define OR 6'h25
`define SLT 6'h2A
//I-type
`define ADDI 6'h08
`define LW 6'h23
`define SW 6'h2B
`define SLTI 6'h0A
`define BEQ 6'h04


//I/O ports
input clk_i;
input rst_i;  

//DO NOT CHANGE SIZE, NAME
reg [32-1:0] Instr_Mem [0:`INSTR_NUM-1];
reg [32-1:0] Data_Mem [0:`DATA_NUM-1];
reg signed [32-1:0] Reg_File [0:32-1];

//Register
reg [32-1:0] instr;
reg [32-1:0] pc_addr;
reg [6-1:0]op;
reg [5-1:0]rs;
reg [5-1:0]rt;
reg [5-1:0]rd;
reg [5-1:0]shamt;
reg [6-1:0]func;
reg [15:0]imm;
integer i;

//Task
task decode;
	begin
		op = instr[31:26];
		rs = instr[25:21];
		rt = instr[20:16];
		rd = instr[15:11];
		shamt = instr[10:6];
		func = instr[5:0];
		imm =instr[15:0];
	end
endtask

//Main function
//wire [31:0] neg_addi;
//assign neg_addi = {{16{~instr[15]}}, (!instr[15:0])+16'd1};

always @(posedge clk_i or negedge rst_i) begin
	if(rst_i == 0) begin
		for(i=0; i<32; i=i+1)
			Reg_File[i] = 32'd0;	
		
		for(i=0;i<256;i=i+1)
			Data_Mem[i] = 32'd0;
		pc_addr = 32'd0;
		
	end
	else begin
		instr = Instr_Mem[pc_addr/4];
		decode;
		if(op == 6'd0)begin //R-type
			case(func)
				`ADD: begin
					Reg_File[rd] = Reg_File[rs] + Reg_File[rt];
				end
				`SUB:begin
					Reg_File[rd] = Reg_File[rs] - Reg_File[rt];
				end
				`AND:begin
					Reg_File[rd] = Reg_File[rs] & Reg_File[rt];
				end
				`OR:begin
					Reg_File[rd] = Reg_File[rs] | Reg_File[rt];
				end
				`SLT:begin
					if(Reg_File[rs]<Reg_File[rt])begin
						Reg_File[rd] = 32'd1;
					end else begin
						Reg_File[rd] = 32'd0;
					end					
				end
			endcase
		end
		else begin //I-type
			case(op)
				`ADDI:begin
					Reg_File[rt] = Reg_File[rs] + {{16{imm[15]}},imm};
				end
				`LW:begin
					Reg_File[rt] = Data_Mem[Reg_File[rs]+{{16{imm[15]}},imm}];
				end
				`SW:begin
					Data_Mem[Reg_File[rs]+{{16{imm[15]}},imm}] = Reg_File[rt];
				end
				`SLTI:begin
					if(Reg_File[rs]<{{16{imm[15]}},imm})begin
						Reg_File[rt] = 32'd1;
					end else begin
						Reg_File[rt] = 32'd0;
					end		
				end
				`BEQ:begin
					if(Reg_File[rs]==Reg_File[rt])begin
						pc_addr = pc_addr + 4*{{16{imm[15]}},imm};
					end else begin
						pc_addr = pc_addr;
					end
				end
			endcase
		end
		pc_addr = pc_addr + 32'd4;
	end
end
endmodule