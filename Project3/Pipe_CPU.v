`timescale 1ns / 1ps
/*******************************************************************
 * Create Date: 	2016/05/03
 * Design Name: 	Pipeline CPU
 * Module Name:		Pipe_CPU 
 * Project Name: 	Architecture Project_3 Pipeline CPU
 
 * Please DO NOT change the module name, or your'll get ZERO point.
 * You should add your code here to complete the project 3.
 ******************************************************************/
module Pipe_CPU(
        clk_i,
		rst_i
		);
    
/****************************************
*            I/O ports                  *
****************************************/
input clk_i;
input rst_i;
/****************************************
*          Internal signal              *
****************************************/

//IF
wire [31:0] PC_in;
wire [31:0] PC_out;
wire [31:0] PC_add4;
wire [31:0] PC_branch;
wire [31:0] Instr_output;
wire [31:0] IF_ID_pc;
wire [31:0] IF_ID_instr;
//ID
wire [31:0] RF_readdata1;
wire [31:0] RF_readdata2;
wire [31:0] extended_imm;
wire [2:0] Control_ALUop;
wire Control_RegWrite;
wire Control_ALUSrc;
wire Control_RegDst;
wire Control_Branch;
wire Control_MemWrite;
wire Control_MemRead;
wire Control_MemtoReg;
//EX
wire ID_EX_Reg_Write;
wire ID_EX_MemtoReg;
wire ID_EX_Branch;
wire ID_EX_MemRead;
wire ID_EX_MemWrite;
wire ID_EX_RegDst;
wire [2:0] ID_EX_ALUOp;
wire ID_EX_ALUSrc;
wire [31:0] ID_EX_PC;
wire [31:0] ID_EX_ReadData1;
wire [31:0] ID_EX_ReadData2;
wire [31:0] ID_EX_Imm;

wire [4:0] ID_EX_RS;
wire [4:0] ID_EX_RT;
wire [4:0] ID_EX_RT_Forward;
wire [4:0] ID_EX_RD;


wire [31:0] ALU_Input1;
wire [31:0] ALU_Input2;
wire [31:0] ALU_Result;
wire ALU_Zero;
wire [31:0] shifted_imm;
wire [31:0] pc_Bracch_adder_result;
wire [3:0] ALUCTRL;
wire [4:0] RT_RD;
wire [1:0] ForwardA;
wire [1:0] ForwardB;
wire [31:0] read2_imm;
wire [31:0] ALU_mux2_output;
//MEM
wire EX_MEM_RegWrite;
wire EX_MEM_MemtoReg;
wire EX_MEM_Branch;
wire EX_MEM_MemRead;
wire EX_MEM_MemWrite;
wire [31:0] EX_MEM_PC;
wire zero;
wire [31:0] EX_MEM_ALUResult;
wire [31:0] EX_MEM_ALUInput2;
wire [4:0] EX_MEM_RT_RD;
wire [31:0] DM_OUT;
//WB
wire MEM_WB_RegWrite;
wire MEM_WB_MemtoReg;
wire [31:0] MEM_WB_MemReadData;
wire [31:0] MEM_WB_ALUresult;
wire [4:0] MEM_WB_RT_RD;
wire [31:0] WB_MUX_Output;

MUX_2to1 #(.size(32))PC_MUX(
		.data0_i(PC_add4),
        .data1_i(PC_branch),
        .select_i(EX_MEM_Branch&zero),
		.data_o(PC_in)

);

ProgramCounter PC(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.pc_in_i(PC_in),
		.pc_out_o(PC_out)
);
Adder PC_ADD4_Adder(
		.src1_i(PC_out),
		.src2_i(32'd4),
		.sum_o(PC_add4)
);
Instr_Memory IM(
	    .pc_addr_i(PC_out),
		.instr_o(Instr_output)
);
//template
//Pipe_Reg #(.size()) (.rst_i(rst_i),.clk_i(clk_i),.data_i(),.data_o());
Pipe_Reg #(.size(32)) IF_ID_PCADDRESS(.rst_i(rst_i),.clk_i(clk_i),.data_i(PC_add4),.data_o(IF_ID_pc));
Pipe_Reg #(.size(32)) IF_ID_INSTR(.rst_i(rst_i),.clk_i(clk_i),.data_i(Instr_output),.data_o(IF_ID_instr));
//ID
//////////////////////////////////////////////////////////////////////////////////////////////////////////
Reg_File RF(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.RSaddr_i(IF_ID_instr[25:21]),
		.RTaddr_i(IF_ID_instr[20:16]),
		.RDaddr_i(MEM_WB_RT_RD),
		.RDdata_i(WB_MUX_Output),
		.RegWrite_i(MEM_WB_RegWrite),
		.RSdata_o(RF_readdata1),
		.RTdata_o(RF_readdata2)
);

Decoder Control(
		.instr_op_i(IF_ID_instr[31:26]),
		.RegWrite_o(Control_RegWrite),
		.ALU_op_o(Control_ALUop),
		.ALUSrc_o(Control_ALUSrc),
		.RegDst_o(Control_RegDst),
		.Branch_o(Control_Branch),
		.MemWrite_o(Control_MemWrite),
		.MemRead_o(Control_MemRead),
		.MemtoReg_o(Control_MemtoReg)
);
Sign_Extend imm_extender(
	    .data_i(IF_ID_instr[15:0]),
		.data_o(extended_imm)
);
//WB
Pipe_Reg #(.size(1)) ID_EX_regwrite(.rst_i(rst_i),.clk_i(clk_i),.data_i(Control_RegWrite),.data_o(ID_EX_Reg_Write));
Pipe_Reg #(.size(1)) ID_EX_memtoreg(.rst_i(rst_i),.clk_i(clk_i),.data_i(Control_MemtoReg),.data_o(ID_EX_MemtoReg));
//M
Pipe_Reg #(.size(1)) ID_EX_branch(.rst_i(rst_i),.clk_i(clk_i),.data_i(Control_Branch),.data_o(ID_EX_Branch));
Pipe_Reg #(.size(1)) ID_EX_memread(.rst_i(rst_i),.clk_i(clk_i),.data_i(Control_MemRead),.data_o(ID_EX_MemRead));
Pipe_Reg #(.size(1)) ID_EX_memwrite(.rst_i(rst_i),.clk_i(clk_i),.data_i(Control_MemWrite),.data_o(ID_EX_MemWrite));
//EX
Pipe_Reg #(.size(1)) ID_EX_regdst(.rst_i(rst_i),.clk_i(clk_i),.data_i(Control_RegDst),.data_o(ID_EX_RegDst));
Pipe_Reg #(.size(3)) ID_EX_aluop(.rst_i(rst_i),.clk_i(clk_i),.data_i(Control_ALUop),.data_o(ID_EX_ALUOp));
Pipe_Reg #(.size(1)) ID_EX_alusrc(.rst_i(rst_i),.clk_i(clk_i),.data_i(Control_ALUSrc),.data_o(ID_EX_ALUSrc));

Pipe_Reg #(.size(32)) ID_EX_pc(.rst_i(rst_i),.clk_i(clk_i),.data_i(IF_ID_pc),.data_o(ID_EX_PC));
Pipe_Reg #(.size(32)) ID_EX_readdata1(.rst_i(rst_i),.clk_i(clk_i),.data_i(RF_readdata1),.data_o(ID_EX_ReadData1));
Pipe_Reg #(.size(32)) ID_EX_readdata2(.rst_i(rst_i),.clk_i(clk_i),.data_i(RF_readdata2),.data_o(ID_EX_ReadData2));
Pipe_Reg #(.size(32)) ID_EX_imm(.rst_i(rst_i),.clk_i(clk_i),.data_i(extended_imm),.data_o(ID_EX_Imm));

Pipe_Reg #(.size(5)) ID_EX_rs(.rst_i(rst_i),.clk_i(clk_i),.data_i(IF_ID_instr[25:21]),.data_o(ID_EX_RS));
Pipe_Reg #(.size(5)) ID_EX_rt(.rst_i(rst_i),.clk_i(clk_i),.data_i(IF_ID_instr[20:16]),.data_o(ID_EX_RT));
Pipe_Reg #(.size(5)) ID_EX_rt_forward(.rst_i(rst_i),.clk_i(clk_i),.data_i(IF_ID_instr[20:16]),.data_o(ID_EX_RT_Forward));
Pipe_Reg #(.size(5)) ID_EX_rd(.rst_i(rst_i),.clk_i(clk_i),.data_i(IF_ID_instr[15:11]),.data_o(ID_EX_RD));
/////////////////////////////////////////////////////////////////////////////////////////////
//EX
ALU ALU(
		.src1_i(ALU_Input1),
		.src2_i(ALU_Input2),
		.ctrl_i(ALUCTRL),
		.result_o(ALU_Result),
		.zero_o(ALU_Zero)
);

ALU_Ctrl ALU_Ctrl(
        .funct_i(ID_EX_Imm[5:0]),
        .ALUOp_i(ID_EX_ALUOp),
        .ALUCtrl_o(ALUCTRL)	
);
Adder PCbranch_Adder(
		.src1_i(ID_EX_PC),
		.src2_i(shifted_imm),
		.sum_o(pc_Bracch_adder_result)
);
Shift_Left_Two_32 SL(
	    .data_i(ID_EX_Imm),
		.data_o(shifted_imm)
);


MUX_2to1 #(.size(5)) RT_RD_Mux(
        .data0_i(ID_EX_RT),	
	    .data1_i(ID_EX_RD),
        .select_i(ID_EX_RegDst),
        .data_o(RT_RD)
);

MUX_2to1 #(.size(32)) READ2_IMM_MUX(
        .data0_i(ALU_mux2_output),
        .data1_i(ID_EX_Imm),
        .select_i(ID_EX_ALUSrc),
        .data_o(ALU_Input2)

);
MUX_3to1 #(.size(32)) ALU_Input_Mux1(
		.data0_i(ID_EX_ReadData1),
        .data1_i(WB_MUX_Output),
 	    .data2_i(EX_MEM_ALUResult),
        .select_i(ForwardA),
        .data_o(ALU_Input1)
);
MUX_3to1 #(.size(32)) ALU_Input_Mux2(
		.data0_i(ID_EX_ReadData2),
        .data1_i(WB_MUX_Output),
        .data2_i(EX_MEM_ALUResult),
        .select_i(ForwardB),
        .data_o(ALU_mux2_output)
);


ForwardinUnit forwardinUnit(
		.EX_MEMRegWrite(EX_MEM_RegWrite),
		.MEM_WBRegWrite(MEM_WB_RegWrite),
		.EX_MEMRegisterRd(EX_MEM_RT_RD),
		.MEM_WBRegisterRd(MEM_WB_RT_RD),
		.ID_EXRegisterRs(ID_EX_RS),
		.ID_EXRegisterRt(ID_EX_RT_Forward),
		.ForwardA(ForwardA),
		.ForwardB(ForwardB)
);
//WB
Pipe_Reg #(.size(1)) EX_MEM_regwrite(.rst_i(rst_i),.clk_i(clk_i),.data_i(ID_EX_Reg_Write),.data_o(EX_MEM_RegWrite));
Pipe_Reg #(.size(1)) EX_MEM_memtoreg(.rst_i(rst_i),.clk_i(clk_i),.data_i(ID_EX_MemtoReg),.data_o(EX_MEM_MemtoReg));
//M
Pipe_Reg #(.size(1)) EX_MEM_branch(.rst_i(rst_i),.clk_i(clk_i),.data_i(ID_EX_Branch),.data_o(EX_MEM_Branch));
Pipe_Reg #(.size(1)) EX_MEM_memread(.rst_i(rst_i),.clk_i(clk_i),.data_i(ID_EX_MemRead),.data_o(EX_MEM_MemRead));
Pipe_Reg #(.size(1)) EX_MEM_memwrite(.rst_i(rst_i),.clk_i(clk_i),.data_i(ID_EX_MemWrite),.data_o(EX_MEM_MemWrite));

Pipe_Reg #(.size(32)) EX_MEM_pc(.rst_i(rst_i),.clk_i(clk_i),.data_i(pc_Bracch_adder_result),.data_o(EX_MEM_PC));
Pipe_Reg #(.size(1)) EX_MEM_zero(.rst_i(rst_i),.clk_i(clk_i),.data_i(ALU_Zero),.data_o(zero));
Pipe_Reg #(.size(32)) EX_MEM_aluresult(.rst_i(rst_i),.clk_i(clk_i),.data_i(ALU_Result),.data_o(EX_MEM_ALUResult));
Pipe_Reg #(.size(32)) EX_MEM_aluinput2(.rst_i(rst_i),.clk_i(clk_i),.data_i(ALU_mux2_output),.data_o(EX_MEM_ALUInput2));
Pipe_Reg #(.size(5)) EX_MEM_rt_ed(.rst_i(rst_i),.clk_i(clk_i),.data_i(RT_RD),.data_o(EX_MEM_RT_RD));



/////////////////////////////////////////////////////////////////////////////////////////////
//MEM


Data_Memory DM(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.addr_i(EX_MEM_ALUResult),
		.data_i(EX_MEM_ALUInput2),
		.MemRead_i(EX_MEM_MemRead),
		.MemWrite_i(EX_MEM_MemWrite),
		.data_o(DM_OUT)
);


//WB
Pipe_Reg #(.size(1))MEM_WB_regwrite (.rst_i(rst_i),.clk_i(clk_i),.data_i(EX_MEM_RegWrite),.data_o(MEM_WB_RegWrite));
Pipe_Reg #(.size(1))MEM_WB_memtoreg (.rst_i(rst_i),.clk_i(clk_i),.data_i(EX_MEM_MemtoReg),.data_o(MEM_WB_MemtoReg));

Pipe_Reg #(.size(32))MEM_WB_memreaddata (.rst_i(rst_i),.clk_i(clk_i),.data_i(DM_OUT),.data_o(MEM_WB_MemReadData));
Pipe_Reg #(.size(32))MEM_WB_aluresult (.rst_i(rst_i),.clk_i(clk_i),.data_i(EX_MEM_ALUResult),.data_o(MEM_WB_ALUresult));
Pipe_Reg #(.size(5))MEM_WB_rt_rd (.rst_i(rst_i),.clk_i(clk_i),.data_i(EX_MEM_RT_RD),.data_o(MEM_WB_RT_RD));




/////////////////////////////////////////////////////////////////////////////////////////////
//WB

MUX_2to1 #(.size(32)) WB_MUX(
        .data0_i(MEM_WB_ALUresult),
        .data1_i(MEM_WB_MemReadData	),
        .select_i(MEM_WB_MemtoReg),
        .data_o(WB_MUX_Output)
);














endmodule