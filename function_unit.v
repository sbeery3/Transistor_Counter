////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: function_unit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020 (Last modified 11 December 2020)
// 	Description: 16 bit function block module. 
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module function_unit(FS, A, B, result, V, C, N, Z);
	input   [3:0] FS;				// Function Unit select FS.
   input  [15:0] A;				// Function Unit operand A
   input  [15:0] B;				// Function Unit operand B
   output [15:0] result;		// Function Unit result
   output        V;				// Overflow status bit
   output        C;				// Carry-out status bit
   output        N;				// Negative status bit
   output        Z;				// Zero status bit
	
   wire [3:0] status;			// Status bits
	assign V = status[3];
	assign C = status[2];
	assign N = status[1];
	assign Z = status[0];
	
	wire [3:0] notFS;
	assign notFS = ~FS;
	
	// 0000 add
	// 0010 subBA
	// 0011 subAB
	// 0001 movA
	// 0100 notA
	// 0101 notB
	// 0111 mult4
	// 1000 div16
	// 1001 comp2sA
	// 1010 comp2sB
	// 1011 or
	// 1100 nor
	// 1101 nand
	
	wire [15:0] add, subBA, subAB, movA, notA, notB,
	mult4, div16, comp2sA, comp2sB, AorB, AnorB, AnandB;
	
	wire [3:0] addStatus, subBAStatus, subABStatus,
	identityStatus, notAStatus, notBStatus,
	mult4Status, div16Status, comp2sAStatus,
	comp2sBStatus, AorBStatus, AnorBStatus, AnandBStatus;
	
	add_16bit(add, addStatus, A, B);
	sub_16bit(subBA, subBAStatus,  B,  A);
	sub_16bit(subAB, subABStatus,  A,  B);
	identity_16bit(movA, identityStatus,  A);
	not_16bit(notA, notAStatus,  A);
	not_16bit(notB, notBStatus,  B);
	mult4_16bit(mult4, mult4Status,  B);
	div16_16bit(div16, div16Status,  B);
	comp2s_16bit(comp2sA, comp2sAStatus,  A);
	comp2s_16bit(comp2sB, comp2sBStatus,  B);
	or_16bit(AorB, AorBStatus,  A,  B);
	nor_16bit(AnorB, AnorBStatus,  A,  B);
	nand_16bit(AnandB, AnandBStatus, A, B);
	
	
	//0000 - add
	
	wire addSignal;
	and(addSignal, notFS[3], notFS[2], notFS[1], notFS[0]);
	tsg_16bit(add, addSignal, result);
	tsg_4bit(addStatus, addSignal, status);
	
	//0010 - subBA
	
	wire subBASignal; 
	and(subBASignal, notFS[3], notFS[2], FS[1], notFS[0]);
	tsg_16bit(subBA, subBASignal, result);
	tsg_4bit(subBAStatus, subBASignal, status);
	
	
	//0011 - subAB
	
	wire subABSignal;
	and(subABSignal, notFS[3], notFS[2], FS[1], FS[0]);
	tsg_16bit(subAB, subABSignal, result);
	tsg_4bit(subABStatus, subABSignal, status);
	
	//0001 movA
	
	wire movSignal;
	and(movSignal, notFS[3], notFS[2], notFS[1], FS[0]);
	tsg_16bit(movA, movSignal, result);
	tsg_4bit(identityStatus, movSignal, status);

	
	//0100 notA
	
	wire notASignal;
	and(notASignal, notFS[3], FS[2], notFS[1], notFS[0]);
	tsg_16bit(notA, notASignal, result);
	tsg_4bit(notAStatus, notASignal, status);
	
	//0101 notB
	
	wire notBSignal;
	and(notBSignal, notFS[3], FS[2], notFS[1], FS[0]);
	tsg_16bit(notB, notBSignal, result);
	tsg_4bit(notBStatus, notBSignal, status);
	
	//0111 mult4
	
	wire multSignal;
	and(multSignal, notFS[3], FS[2], FS[1], FS[0]);
	tsg_16bit(mult4, multSignal, result);
	tsg_4bit(mult4Status, multSignal, status);
	
	//1000 div16
	
	wire divSignal;
	and(divSignal, FS[3], notFS[2], notFS[1], notFS[0]);
	tsg_16bit(div16, divSignal, result);
	tsg_4bit(div16Status, divSignal, status);
	
	//1001 comp2sA
	
	wire comp2sASignal;
	and(comp2sASignal, FS[3], notFS[2], notFS[1], FS[0]);
	tsg_16bit(comp2sA, comp2sASignal, result);
	tsg_4bit(comp2sAStatus, comp2sASignal, status);
	
	//1010 comp2sB
	
	wire comp2sBSignal;
	and(comp2sBSignal, FS[3], notFS[2], FS[1], notFS[0]);
	tsg_16bit(comp2sB, comp2sBSignal, result);
	tsg_4bit(comp2sBStatus, comp2sBSignal, status);

	//1011 or
	
	wire AorBSignal;
	and(AorBSignal, FS[3], notFS[2], FS[1], FS[0]);
	tsg_16bit(AorB, AorBSignal, result);
	tsg_4bit(AorBStatus, AorBSignal, status);

	//1100 nor
	
	wire AnorBSignal;
	and(AnorBSignal, FS[3], FS[2], notFS[1], notFS[0]);
	tsg_16bit(AnorB, AnorBSignal, result);
	tsg_4bit(AnorBStatus, AnorBSignal, status);
	
	//1101 nand
	
	wire AnandBSignal;
	and(AnandBSignal, FS[3], FS[2], notFS[1], FS[0]);
	tsg_16bit(AnandB, AnandBSignal, result);
	tsg_4bit(AnandBStatus, AnandBSignal, status);
endmodule


////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: add_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
// 	Description: 16 bit adder module made up of 4 4 bit lookaheads
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module add_16bit(out, status, op1, op2);
   input  [15:0] op1, op2;		
   output [3:0] status; 		
	output [15:0] out;				
   wire [3:0] group_carry, group_gen, group_prop, temp1;
   wire [1:0] temp;
	wire carry_out, last_carry_in;
   
   assign group_carry[0] = 1'b0;
   
   lookahead_4bit(out[3:0], group_carry[1], group_gen[1], temp1[0], group_prop[1], op1[3:0], op2[3:0], group_carry[0]);
   lookahead_4bit(out[7:4], group_carry[2], group_gen[2], temp1[1], group_prop[2], op1[7:4], op2[7:4], group_carry[1]);
   lookahead_4bit(out[11:8], group_carry[3], group_gen[3], temp1[2], group_prop[3], op1[11:8], op2[11:8], group_carry[2]);
   lookahead_4bit(out[15:12], carry_out, temp[0], temp[1],  last_carry_in, op1[15:12], op2[15:12], group_carry[3]);
	
	xor(status[3], carry_out, last_carry_in);
	assign status[2] = carry_out;
	assign status[1] = out[15];
    assign status[0] = (out == 4'h0000) ? 1'b1: 1'b0;
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: sub_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//		Description: 16 bit subtraction module
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module sub_16bit(out, status, op1, op2);
   input  [15:0] op1, op2;
   output  [3:0] status;		
   output [15:0] out;			
	wire [15:0] temp;
	wire [3:0] tempStatus;
	comp2s_16bit(temp, tempStatus, op2);
	add_16bit(out, status, temp, op1);	
endmodule 



////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: lookahead_4bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
// 	Description: 4 bit lookahead adder module.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
module lookahead_4bit(out, group_carry, group_gen, group_prop, carry_in_last, op1, op2, carry_in);
   input [3:0] op1, op2;
   input carry_in;
   output [3:0] out;
   output group_carry, group_gen, group_prop, carry_in_last;
   wire   [3:0] carry, gen, prop;
   assign carry[0] = carry_in;

	assign carry_in_last = carry[3];
   lookahead_adder(out[0], carry[1], gen[1], prop[1], op1[0], op2[0], carry[0]);
   lookahead_adder(out[1], carry[2], gen[2], prop[2], op1[1], op2[1], carry[1]);
   lookahead_adder(out[2], carry[3], gen[3], prop[3], op1[2], op2[2], carry[2]);
   lookahead_adder(out[3], group_carry, group_gen, group_prop, op1[3], op2[3], carry[3]);
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: lookahead_adder
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//    Description: Single bit lookahead adder module.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module lookahead_adder(result, carry_out, generate_out, propagate_out, val1, val2, carry_in);
	output result, generate_out, propagate_out, carry_out;
	input val1, val2, carry_in;
	
    and(generate_out, val1, val2);
    or(propagate_out, val1, val2);
	
   wire temp; 
   and(temp, propagate_out, carry_in);
   or(carry_out, generate_out, temp);
	
   xor(result, carry_in, val1, val2);
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: not_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//		Description: 16 bit not module(1s complement)
//
////////////////////////////////////////////////////////////////////////////////////////////////////
module not_16bit(out, status, in);
   input  [15:0] in;			
   output [3:0] status;		
   output [15:0] out;		
	not(out[0], in[0]);
	not(out[1], in[1]);
	not(out[2], in[2]);
	not(out[3], in[3]);
	not(out[4], in[4]);
	not(out[5], in[5]);
	not(out[6], in[6]);
	not(out[7], in[7]);
	not(out[8], in[8]);
	not(out[9], in[9]);
	not(out[10], in[10]);
	not(out[11], in[11]);
	not(out[12], in[12]);
	not(out[13], in[13]);
	not(out[14], in[14]);
	not(out[15], in[15]);
	assign status[3:2] = 2'b00;
	assign status[1] = out[15];
	assign status[0] = (out == 4'h0000) ? 1'b1: 1'b0;
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: identity_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//		Description: Identity module	
//
////////////////////////////////////////////////////////////////////////////////////////////////////
module identity_16bit(out, status, in);
  	input  [15:0] in;			
  	output  [3:0] status;	
	output [15:0] out;
	
	identity(out[0], in[0]);
	identity(out[1], in[1]);
	identity(out[2], in[2]);
	identity(out[3], in[3]);
	identity(out[4], in[4]);
	identity(out[5], in[5]);
	identity(out[6], in[6]);
	identity(out[7], in[7]);
	identity(out[8], in[8]);
	identity(out[9], in[9]);
	identity(out[10], in[10]);
	identity(out[11], in[11]);
	identity(out[12], in[12]);
	identity(out[13], in[13]);
	identity(out[14], in[14]);
	identity(out[15], in[15]);
	
	assign status[3:2] = 2'b00;
	assign status[1] = out[15];
	assign status[0] = (out == 4'h0000) ? 1'b1: 1'b0;
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: mult4_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//		Description: A unit that can perform the following operations on two 16 bit inputs:				
//
////////////////////////////////////////////////////////////////////////////////////////////////////
module mult4_16bit(out, status, op1);
   input  [15:0] op1;		
   output [3:0]status;		
   output [15:0] out;		
		
	always0(out[0]);
	always0(out[1]);
	identity(out[2], op1[0]);
	identity(out[3], op1[1]);
	identity(out[4], op1[2]);
	identity(out[5], op1[3]);
	identity(out[6], op1[4]);
	identity(out[7], op1[5]);
	identity(out[8], op1[6]);
	identity(out[9], op1[7]);
	identity(out[10], op1[8]);
	identity(out[11], op1[9]);
	identity(out[12], op1[10]);
	identity(out[13], op1[11]);
	identity(out[14], op1[12]);
	identity(out[15], op1[13]);
	
	assign status[3:2] = 2'b00;
	assign status[1] = out[15];
	assign status[0] = (out == 4'h0000) ? 1'b1: 1'b0;
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: div16_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//		Description: A unit that can perform the following operations on two 16 bit inputs:			
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module div16_16bit(out, status, op1);
   input  [15:0] op1;		
   output [3:0] status; 	
   output [15:0] out;		
	
	identity(out[0], op1[4]);
	identity(out[1], op1[5]);
	identity(out[2], op1[6]);
	identity(out[3], op1[7]);
	identity(out[4], op1[8]);
	identity(out[5], op1[9]);
	identity(out[6], op1[10]);
	identity(out[7], op1[11]);
	identity(out[8], op1[12]);
	identity(out[9], op1[13]);
	identity(out[10], op1[14]);
	always0(out[11]);
	always0(out[12]);
	always0(out[13]);
	always0(out[14]);
	identity(out[15], op1[15]);

	assign status[3:2] = 2'b00;
	assign status[1] = out[15];
	assign status[0] = (out == 4'h0000) ? 1'b1: 1'b0;
endmodule 

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: nand_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//		Description: A unit that can perform the following operations on two 16 bit inputs:
//						
////////////////////////////////////////////////////////////////////////////////////////////////////

module nand_16bit(out, status, op1, op2);
   input  [15:0] op1, op2;	
   output [3:0] status;		
   output [15:0] out;		
	
	nand(out[0], op1[0], op2[0]);
	nand(out[1], op1[1], op2[1]);
	nand(out[2], op1[2], op2[2]);
	nand(out[3], op1[3], op2[3]); 
	nand(out[4], op1[4], op2[4]);
	nand(out[5], op1[5], op2[5]);
	nand(out[6], op1[6], op2[6]);
	nand(out[7], op1[7], op2[7]);
	nand(out[8], op1[8], op2[8]);
	nand(out[9], op1[9], op2[9]);
	nand(out[10], op1[10], op2[10]); 
	nand(out[11], op1[11], op2[11]);
	nand(out[12], op1[12], op2[12]);
	nand(out[13], op1[13], op2[13]);
	nand(out[14], op1[14], op2[14]);
	nand(out[15], op1[15], op2[15]);
	
	assign status[3:2] = 2'b00;
	assign status[1] = out[15];
	assign status[0] = (out == 4'h0000) ? 1'b1: 1'b0;
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: comp2s_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//		Description: 16 bit 2s complement module
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module comp2s_16bit(out, status, op1);
	input [15:0] op1;
	output [3:0] status;
	output [15:0] out;
	wire [15:0] temp;
	wire [3:0] temp_status;
	not_16bit(temp, temp_status, op1);
	add_16bit(out, status, temp, 16'b0000000000000001);
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: or_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//		Description: 16 bit bitwise or module						
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module or_16bit(out, status, op1, op2);
	input [15:0] op1, op2;
	output [3:0] status;
	output [15:0] out;
	
	or(out[0], op1[0], op2[0]);
	or(out[1], op1[1], op2[1]);
	or(out[2], op1[2], op2[2]);
	or(out[3], op1[3], op2[3]);
	or(out[4], op1[4], op2[4]);
	or(out[5], op1[5], op2[5]);
	or(out[6], op1[6], op2[6]);
	or(out[7], op1[7], op2[7]);
	or(out[8], op1[8], op2[8]);
	or(out[9], op1[9], op2[9]);
	or(out[10], op1[10], op2[10]);
	or(out[11], op1[11], op2[11]);
	or(out[12], op1[12], op2[12]);
	or(out[13], op1[13], op2[13]);
	or(out[14], op1[14], op2[14]);
	or(out[15], op1[15], op2[15]);
	
	assign status[3:2] = 2'b00;
	assign status[1] = out[15];
	assign status[0] = (out == 4'h0000) ? 1'b1: 1'b0;
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  	Module: nor_16bit
// 	Author: Tom Anders (tanders28)
//  	Created: 10 December 2020
//		Description: 16 bit bitwise nor module
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module nor_16bit(out, status, op1, op2);
	input [15:0] op1, op2;
	output [3:0] status;
	output [15:0] out;
	
	nor(out[0], op1[0], op2[0]);
	nor(out[1], op1[1], op2[1]);
	nor(out[2], op1[2], op2[2]);
	nor(out[3], op1[3], op2[3]);
	nor(out[4], op1[4], op2[4]);
	nor(out[5], op1[5], op2[5]);
	nor(out[6], op1[6], op2[6]);
	nor(out[7], op1[7], op2[7]);
	nor(out[8], op1[8], op2[8]);
	nor(out[9], op1[9], op2[9]);
	nor(out[10], op1[10], op2[10]);
	nor(out[11], op1[11], op2[11]);
	nor(out[12], op1[12], op2[12]);
	nor(out[13], op1[13], op2[13]);
	nor(out[14], op1[14], op2[14]);
	nor(out[15], op1[15], op2[15]);
	
	assign status[3:2] = 2'b00;
	assign status[1] = out[15];
	assign status[0] = (out == 4'h0000) ? 1'b1: 1'b0;
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: tsg_4bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//	   Description: An 4-bit wide tri-state gate module written using Verilog primitives
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module tsg_4bit(in, en, out);
   input  [3:0] in;		
   input        en;		
   output [3:0] out;		

	bufif1(out[0], in[0], en);
	bufif1(out[1], in[1], en);
	bufif1(out[2], in[2], en);
	bufif1(out[3], in[3], en);
endmodule 	

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//    Module: tsg_16bit
//    Author: Tom Anders (tanders28)
//    Created: 10 December 2020
//	   Description: A 16-bit wide tri-state gate module written using Verilog primitives
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module tsg_16bit(in, en, out);
   input  [15:0] in;		
   input        en;		
   output [15:0] out;  

	bufif1(out[0], in[0], en);
	bufif1(out[1], in[1], en);
	bufif1(out[2], in[2], en);
	bufif1(out[3], in[3], en);
	bufif1(out[4], in[4], en);
	bufif1(out[5], in[5], en);
	bufif1(out[6], in[6], en);
	bufif1(out[7], in[7], en);
	bufif1(out[8], in[8], en);
	bufif1(out[9], in[9], en);
	bufif1(out[10], in[10], en);
	bufif1(out[11], in[11], en);
	bufif1(out[12], in[12], en);
	bufif1(out[13], in[13], en);
	bufif1(out[14], in[14], en);
	bufif1(out[15], in[15], en);
endmodule 	

////////////////////////////////////////////////////////////////////////////////////////////////////
// SINGLE BIT UTILITY MODULES

module always0(result);
	output result;
	assign result = 0;
endmodule

module identity(result, in);
	input in;
	output result;
	assign result = in;
endmodule 
