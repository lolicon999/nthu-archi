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

/**** IF stage ****/
//control signal...
wire [31:0] pc_mux_out;
wire [31:0] pc_out;
wire [31:0] instr_out;
wire [31:0] pc_add4;
/**** ID stage ****/
//control signal...
wire [31:0] IF_ID_Instr_out;
wire [31:0] IF_ID_Address_out;
wire [31:0] imm_extend;
wire [31:0] RF_read_data1;
wire [31:0] RF_read_data2;
wire [2:0] Control_ALU_op;
wire Control_ALUSrc;
wire Control_RegWrite;
wire Control_RegDst;
wire Control_Branch;
wire Control_MemWrite;
wire Control_MemRead;
wire Control_MemtoReg;

/**** EX stage ****/
//control signal...
wire [2:0] ID_EX_ALU_op;
wire ID_EX_ALUSrc;
wire ID_EX_RegWrite;
wire ID_EX_RegDst;
wire ID_EX_Branch;
wire ID_EX_MemWrite;
wire ID_EX_MemRead;
wire ID_EX_MemtoReg;
wire[31:0] ID_EX_PC_Address;
wire[31:0] ID_EX_ReadData1;
wire[31:0] ID_EX_ReadData2;
wire[31:0] ID_EX_Imm;
wire[4:0] ID_EX_Rs;
wire[4:0] ID_EX_Rt;
wire[4:0] ID_EX_Rd;
wire [1:0] ForwardA;
wire [1:0] ForwardB;
wire [31:0] ALU_Input1;
wire [31:0] ALU_Input2;
wire [3:0] ALUCtrl_output;
wire [31:0] ALU_Result;
wire ALU_Zero;
wire [4:0] RT_RD_MUX_Output;
wire [31:0] ALU_input_Mux_output;
wire [31:0] PC_ADDER2_SOURSE2;
wire [31:0] PC_ADDER2_Result;
/**** MEM stage ****/
//control signal...
wire EX_MEM_RegWrite;
wire EX_MEM_MemtoReg;
wire EX_MEM_Branch;
wire EX_MEM_MemRead;
wire EX_MEM_MemWrite;
wire [31:0] EX_MEM_PCAddress;
wire EX_MEM_Zero;
wire [31:0] EX_MEM_ALU_Result;
wire [31:0] EX_MEM_ALU_Input2;
wire [4:0]EX_MEM_rt_rd;

/**** WB stage ****/
//control signal...
wire [31:0] DM_Output;
wire MEM_WB_RegWrite;
wire MEM_WB__MemtoReg;
wire [31:0] MEM_WB_ReadData;
wire [31:0] MEM_WB_ALU_Result;
wire [4:0] MEM_WB_rt_rd;
wire [31:0] WB_MUX_Output;
/**** Data hazard ****/
//control signal...


/****************************************
*       Instantiate modules             *
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32))pc_mux(
			.data0_i(pc_add4),
            .data1_i(PC_ADDER2_Result),
            .select_i(EX_MEM_Branch&EX_MEM_Zero),
            .data_o(pc_mux_out)
		);


ProgramCounter PC(
			.clk_i(clk_i),
			.rst_i(rst_i),
			.pc_in_i(pc_mux_out),
			.pc_out_o(pc_out)
        );

Instr_Memory IM(
			.pc_addr_i(pc_out),
			.instr_o(instr_out)
	    );
			
Adder Add_pc(
			.src1_i(pc_out),
			.src2_i(32'd4),
			.sum_o(pc_add4)
		);

		
Pipe_Reg #(.size(32)) IF_ID_Instr( 	      
			.rst_i(rst_i),
			.clk_i(clk_i),
			.data_i(instr_out),
			.data_o(IF_ID_Instr_out)
		);
		
Pipe_Reg #(.size(32)) IF_ID_PCaddress(       
			.rst_i(rst_i),
			.clk_i(clk_i),
			.data_i(pc_out),
			.data_o(IF_ID_Address_out)
		);
		
//Instantiate the components in ID stage
Reg_File RF(
			.clk_i(clk_i),
			.rst_i(rst_i),
			.RSaddr_i(IF_ID_Instr_out[25:21]),
			.RTaddr_i(IF_ID_Instr_out[20:16]),
			.RDaddr_i(MEM_WB_rt_rd),
			.RDdata_i(WB_MUX_Output),
			.RegWrite_i(MEM_WB_RegWrite),
			.RSdata_o(RF_read_data1),
			.RTdata_o(RF_read_data2)
		);

Decoder Control(
			.instr_op_i(IF_ID_Instr_out[31:26]),
			.RegWrite_o(Control_RegWrite),
			.ALU_op_o(Control_ALU_op),
			.ALUSrc_o(Control_ALUSrc),
			.RegDst_o(Control_RegDst),
			.Branch_o(Control_Branch),
			.MemWrite_o(Control_MemWrite),
			.MemRead_o(Control_MemRead),
			.MemtoReg_o(Control_MemtoReg)
		);

Sign_Extend Sign_Extend(
		    .data_i(IF_ID_Instr_out[15:0]),
			.data_o(imm_extend)
		);	
//WB
Pipe_Reg #(.size(1)) ID_EX_REGWRITE(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(Control_RegWrite),
			.data_o(ID_EX_RegWrite)
		);
Pipe_Reg #(.size(1)) ID_EX_MEMtoREG(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(Control_MemtoReg),
			.data_o(ID_EX_MemtoReg)
		);
//M
Pipe_Reg #(.size(1)) ID_EX_BRANCH(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(Control_Branch),
			.data_o(ID_EX_Branch)
		);
Pipe_Reg #(.size(1)) ID_EX_MEMREAD(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(Control_MemRead),
			.data_o(ID_EX_MemRead)
		);
Pipe_Reg #(.size(1)) ID_EX_MEMWRITE(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(Control_MemWrite),
			.data_o(ID_EX_MemWrite)
		);
//EX
Pipe_Reg #(.size(1)) ID_EX_REGDST(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(Control_RegDst),
			.data_o(ID_EX_RegDst)
		);
Pipe_Reg #(.size(3)) ID_EX_ALUOP(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(Control_ALU_op),
			.data_o(ID_EX_ALU_op)
		);
Pipe_Reg #(.size(1)) ID_EX_ALUSRC(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(Control_ALUSrc),
			.data_o(ID_EX_ALUSrc)
		);
		
		
Pipe_Reg #(.size(32)) ID_EX_PC_ADDRESS(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(IF_ID_Address_out),
			.data_o(ID_EX_PC_Address)
		);
Pipe_Reg #(.size(32)) ID_EX_READDATA1(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(RF_read_data1),
			.data_o(ID_EX_ReadData1)
		);
Pipe_Reg #(.size(32)) ID_EX_READDATA2(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(RF_read_data2),
			.data_o(ID_EX_ReadData2)
		);
Pipe_Reg #(.size(32)) ID_EX_IMM(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(imm_extend),
			.data_o(ID_EX_Imm)
		);
Pipe_Reg #(.size(5)) ID_EX_RS(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(IF_ID_Instr_out[25:21]),
			.data_o(ID_EX_Rs)
		);	
Pipe_Reg #(.size(5)) ID_EX_RT(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(IF_ID_Instr_out[20:16]),
			.data_o(ID_EX_Rt)
		);  
Pipe_Reg #(.size(5)) ID_EX_RD(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(IF_ID_Instr_out[15:11]),
			.data_o(ID_EX_Rd)
		);  
//Instantiate the components in EX stage	   
ALU ALU(
			.src1_i(ALU_Input1),
			.src2_i(ALU_Input2),
			.ctrl_i(ALUCtrl_output),
			.result_o(ALU_Result),
			.zero_o(ALU_Zero)
		);
		
ALU_Ctrl ALU_Control(
			.funct_i(ID_EX_Imm[5:0]),
			.ALUOp_i(ID_EX_ALU_op),
			.ALUCtrl_o(ALUCtrl_output)
		);

MUX_2to1 #(.size(5)) RT_RD_MUX(
			.data0_i(ID_EX_Rt),
            .data1_i(ID_EX_Rd),
            .select_i(ID_EX_RegDst),
            .data_o(RT_RD_MUX_Output)
        );
		
MUX_2to1 #(.size(32)) ALU_input_Mux(
			.data0_i(ID_EX_ReadData2),
            .data1_i(ID_EX_Imm),
            .select_i(ID_EX_ALUSrc),
            .data_o(ALU_input_Mux_output)
        );
MUX_3to1#(.size(32)) ALU_INPUT1(
			.data0_i(ID_EX_ReadData1),
            .data1_i(WB_MUX_Output),
		    .data2_i(EX_MEM_ALU_Result),
            .select_i(ForwardA),
            .data_o(ALU_Input1)

		);
MUX_3to1#(.size(32)) ALU_INPUT2(
			.data0_i(ALU_input_Mux_output),
            .data1_i(WB_MUX_Output),
		    .data2_i(EX_MEM_ALU_Result),
            .select_i(ForwardB),
            .data_o(ALU_Input2)

		);
ForwardinUnit frowardingUnit(
			.EX_MEMRegWrite(EX_MEM_RegWrite),
			.MEM_WBRegWrite(MEM_WB_RegWrite),
			.EX_MEMRegisterRd(EX_MEM_rt_rd),
			.MEM_WBRegisterRd(MEM_WB_rt_rd),
			.ID_EXRegisterRs(ID_EX_Rs),
			.ID_EXRegisterRt(ID_EX_Rt),
			.ForwardA(ForwardA),
			.ForwardB(ForwardB)
		);
Shift_Left_Two_32 IMM_SHIFT(
			    .data_i(ID_EX_Imm),
				.data_o(PC_ADDER2_SOURSE2)
		);
Adder Add_pc2(
			.src1_i(ID_EX_PC_Address),
			.src2_i(PC_ADDER2_SOURSE2),
			.sum_o(PC_ADDER2_Result)
		);
//WB
Pipe_Reg #(.size(1)) EX_MEM_REGWRITE(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ID_EX_MemWrite),
			.data_o(EX_MEM_RegWrite)
		);
Pipe_Reg #(.size(1)) EX_MEM_MEMtoREG(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ID_EX_MemtoReg),
			.data_o(EX_MEM_MemtoReg)
		);
//M
Pipe_Reg #(.size(1)) EX_MEM_BRANCH(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ID_EX_Branch),
			.data_o(EX_MEM_Branch)
		);
Pipe_Reg #(.size(1)) EX_MEM_MEMREAD(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ID_EX_MemRead),
			.data_o(EX_MEM_MemRead)
		);
Pipe_Reg #(.size(1)) EX_MEM_MEMWRITE(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ID_EX_MemWrite),
			.data_o(EX_MEM_MemWrite)
		);

Pipe_Reg #(.size(32)) EX_MEM_PCADDRESS(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ID_EX_PC_Address),
			.data_o(EX_MEM_PCAddress)
		);
Pipe_Reg #(.size(1)) EX_MEM_ALUZERO(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ALU_Zero),
			.data_o(EX_MEM_Zero)
		);
Pipe_Reg #(.size(32)) EX_MEM_ALURESULT(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ALU_Result),
			.data_o(EX_MEM_ALU_Result)
		);
Pipe_Reg #(.size(32)) EX_MEM_ALU_INPUT2(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(ALU_Input2),
			.data_o(EX_MEM_ALU_Input2)
		);
Pipe_Reg #(.size(5)) EX_MEM_RT_RD(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(RT_RD_MUX_Output),
			.data_o(EX_MEM_rt_rd)
		);

	
//Instantiate the components in MEM stage
Data_Memory DM(
			.clk_i(clk_i),
			.rst_i(rst_i),
			.addr_i(EX_MEM_ALU_Result),
			.data_i(EX_MEM_ALU_Input2),
			.MemRead_i(EX_MEM_MemRead),
			.MemWrite_i(EX_MEM_MemWrite),
			.data_o(DM_Output)
	    );
//WB
Pipe_Reg #(.size(1)) MEM_WB_REGWRITE(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(EX_MEM_RegWrite),
			.data_o(MEM_WB_RegWrite)
		);
Pipe_Reg #(.size(1)) MEM_WB_MEMtoREG(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(EX_MEM_MemtoReg),
			.data_o(MEM_WB__MemtoReg)
		);
		
Pipe_Reg #(.size(32)) MEM_WB_DM_READDATA(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(DM_Output),
			.data_o(MEM_WB_ReadData)
		);
Pipe_Reg #(.size(32)) MEM_WB_ALU_RESULT(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(EX_MEM_ALU_Result),
			.data_o(MEM_WB_ALU_Result)
		);		
Pipe_Reg #(.size(5)) MEM_WB_RT_RD(
			.rst_i(rst_i),
			.clk_i(clk_i),   
			.data_i(EX_MEM_rt_rd),
			.data_o(MEM_WB_rt_rd)
		);		

		
//Instantiate the components in WB stage
MUX_2to1 #(.size(32))WB_mux(
			.data0_i(MEM_WB_ALU_Result),
            .data1_i(MEM_WB_ReadData),
            .select_i(MEM_WB__MemtoReg),
            .data_o(WB_MUX_Output)
		);

/****************************************
*         Signal assignment             *
****************************************/
	
endmodule

