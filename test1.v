////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: Spencer Beery
// File: function_unit.v
// Created: December 1, 2020
// Description: Function unit used to output various operation results based on selected operations 
//
////////////////////////////////////////////////////////////////////////////////////////////////////

module function_unit(FS, A, B, result, V, C, N, Z);
	input   [3:0] FS;				// Function Unit select code.
   input  [15:0] A;				// Function Unit operand A
   input  [15:0] B;				// Function Unit operand B
   output [15:0] result;		// Function Unit result
   output        V;				// Overflow status bit
   output        C;				// Carry-out status bit
   output        N;				// Negative status bit
   output        Z;				// Zero status bit
	
	
////////////Begin Wire Initialization//////////
	
	//Wire for assigning status bits
	wire [3:0] status;
	
	//Wires for operation result and status bit outputs
	wire [15:0] add,subab,movA,notA,mult4,div16,nandAB,incA,inc2B,dec3A,xorAB,orAB,swapA;
	wire [3:0] s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12;
	
	//Wires for easily callable select inputs and nots
	wire sw0,sw1,sw2,sw3;
	wire n0,n1,n2,n3;
	
//////////////End Wire Initialization/////////////

	assign V = status[3];
	assign C = status[2];
	assign N = status[1];
	assign Z = status[0];

	
	
	
//////////Begin Operation and Status Bit Output Implementation///////////////

	add addop(add,A,B,s0);
	sub subop(subab,A,B,s1);
	movA movop(movA,A,s2);
	notA notop(notA,A,s3);
	mult4 multop(mult4,B,s4);
	div16 divop(div16,B,s5);
	nandAB nandop(nandAB,A,B,s6);
	incA inc1(incA,A,s7);
	inc2B inc2(inc2B,B,s8);
	dec3A dec(dec3A,A,s9);
	xorAB xorop(xorAB,A,B,s10);
	orAB orop(orAB,A,B,s11);
	swapA swapop(swapA,A,s12);
	
///////End Operation and Status Bit Implementation/////////////////////
	

	
	
//////////Begin Switch Enabler Intilization/////////
	not (n0,FS[0]);
	not (n1,FS[1]);
	not (n2,FS[2]);
	not (n3,FS[3]);
	
	not (sw0,n0);
	not (sw1,n1);
	not (sw2,n2);
	not (sw3,n3);
	
	//Add Operation
	wire add_en;
	and (add_en,n3,n1,n2,sw0);
	tsg_16bit(add,add_en,result);
	tsg_4bit(s0,add_en,status);
	
	
	//Sub Operation
	wire sub_en;
	and (sub_en,n3,n2,sw1,n0);
	tsg_16bit(subab,sub_en,result);
	tsg_4bit(s1,sub_en,status);
	
	
	//MovA Operation
	wire mov_en;
	and (mov_en,n3,sw2,n1,sw0);
	tsg_16bit(movA,mov_en,result);
	tsg_4bit(s2,mov_en,status);

	
	//Not Operation
	wire not_en;
	and (not_en,n3,n2,sw1,sw0);
	tsg_16bit(notA,not_en,result);
	tsg_4bit(s3,not_en,status);
	
	
	//Mult4 Operation
	wire mult_en;
	and (mult_en,n3,sw2,sw2,n0);
	tsg_16bit(mult4,mult_en,result);
	tsg_4bit(s4,mult_en,status);
	
	
	//Div16 Operation
	wire div_en;
	and (div_en,n3,sw2,n1,n0);
	tsg_16bit(div16,div_en,result);
	tsg_4bit(s5,div_en,status);
	
	
	
	//Nand Operation
	wire nand_en;
	and (nand_en,n3,sw2,sw1,sw0);
	tsg_16bit(nandAB,nand_en,result);
	tsg_4bit(s6,nand_en,status);
	
	
	//Inc1A Operation
	wire inc_en;
	and (inc_en,sw3,n2,n1,n0);
	tsg_16bit(incA,inc_en,result);
	tsg_4bit(s7,inc_en,status);
	
	//Dec3A Operation
	wire dec_en;
	and (dec_en,sw3,n2,n1,sw0);
	tsg_16bit(dec3A,dec_en,result);
	tsg_4bit(s8,dec_en,status);
	
	//Inc2B Operation
	wire incb_en;
	and (incb_en,sw3,n2,sw1,n0);
	tsg_16bit(inc2B,incb_en,result);
	tsg_4bit(s9,incb_en,status);
	
	//Or Operation
	wire or_en;
	and (or_en,sw3,n2,sw1,sw0);
	tsg_16bit(orAB,or_en,result);
	tsg_4bit(s10,or_en,status);
	

	//Xor Operation
	wire xor_en;
	and (xor_en,sw3,sw2,n1,n0);
	tsg_16bit(xorAB,xor_en,result);
	tsg_4bit(s11,xor_en,status);
	
	
	//Swap Operation 
	wire swap_en;
	and (swap_en,sw3,sw2,n1,sw0);
	tsg_16bit(swapA,swap_en,result);
	tsg_4bit(s12,swap_en,status);
	

endmodule


//Initializes tri-state gate
module tsg_16bit(in, en, out);
   input  [15:0] in;		// 8-bit input
   input        en;		// Enable bit
   output [15:0] out;	// 8-bit output
	
	bufif1(out[0],in[0],en);
	bufif1(out[1],in[1],en);
	bufif1(out[2],in[2],en);
	bufif1(out[3],in[3],en);
	bufif1(out[4],in[4],en);
	bufif1(out[5],in[5],en);
	bufif1(out[6],in[6],en);
	bufif1(out[7],in[7],en);
	bufif1(out[8],in[8],en);
	bufif1(out[9],in[9],en);
	bufif1(out[10],in[10],en);
	bufif1(out[11],in[11],en);
	bufif1(out[12],in[12],en);
	bufif1(out[13],in[13],en);
	bufif1(out[14],in[14],en);
	bufif1(out[15],in[15],en);
 
endmodule 

module tsg_4bit(in,en,out);
	input [3:0] in;
	input en;
	output [3:0] out;
	
	bufif1(out[0],in[0],en);
	bufif1(out[1],in[1],en);
	bufif1(out[2],in[2],en);
	bufif1(out[3],in[3],en);
	
endmodule

//Initializes single-bit carry-lookahead adder 
module lookahead(result,A,B,gen,prop,carry_out,carry_in);
	input A,B,carry_in;
	output result,gen,prop,carry_out;
	
	and (gen,A,B);
	or (prop,A,B);
	
	wire w;
	and(w,prop,carry_in);
	or (carry_out,gen,w);
	
	xor(result,A,B,carry_in);
	
endmodule 

//Initializes 4 bit carry-lookahead adder to decreases propagation delay using 1-bit adder 
module lookahead_4b(result,A,B,carry_4b,gen_4b,prop_4b,carry_in,final_carry);
	input [3:0] A,B;
	input carry_in;
	output [3:0] result;
	output final_carry,carry_4b,gen_4b,prop_4b;
	assign carry[0] = carry_in;
	wire [3:0] gen,prop,carry;
	
	lookahead a1(result[0],A[0],B[0],gen[1],prop[1],carry[1],carry[0]);
	lookahead a2(result[1],A[1],B[1],gen[2],prop[2],carry[2],carry[1]);
	lookahead a3(result[2],A[2],B[2],gen[3],prop[3],carry[3],carry[2]);
	lookahead a4(result[3],A[3],B[3],gen_4b,prop_4b,carry_4b,carry[3]);
	
	assign final_carry = carry[3];
	
endmodule


//Applies 4-bit carry-lookahead adder to 4bit operand inputs to output proper results
module add(result,A,B,status);
	input [15:0] A,B;
	output [15:0] result;
	output [3:0] status;
	wire [3:0] carry_4b,gen_4b,prop_4b;
	wire w0,w1,w2,w3,w4,w5,w6;
	
	assign carry_4b[0] = 1'b0;
	
	lookahead_4b a1(result[3:0],A[3:0],B[3:0],carry_4b[1],gen_4b[1],prop_4b[1],carry_4b[0],w3);
	lookahead_4b a2(result[7:4],A[7:4],B[7:4],carry_4b[2],gen_4b[2],prop_4b[2],carry_4b[1],w4);
	lookahead_4b a3(result[11:8],A[11:8],B[11:8],carry_4b[3],gen_4b[3],prop_4b[3],carry_4b[2],w5);
	lookahead_4b a4(result[15:12],A[15:12],B[15:12],w0,w1,w2,carry_4b[3],w6);
	
	
	xor(status[3],w6,w0);
	
	assign status[2] = w0;
	
	assign status[1] = result[15];
	
	assign status[0] = (result == 16'b0000000000000000) ? 1'b1 : 1'b0;
	
endmodule 
	


module sub(result,A,B,status);
	input [15:0] A,B;
	output [3:0] status;
	output [15:0] result;
	
	//Creates 2s complement for B
	wire [15:0] nB,cB;
	wire [3:0] s0,s1;
	
	notA notB(nB,B,s0);
	incA incB(cB,nB,s1);
	
	//Add 2s complement and input A
	add op(result,A,cB,status);
	
endmodule
	

//Initializes notA operation
module notA(notresult,A,status);
	input [15:0] A;
	output [3:0] status;
	output [15:0] notresult;
	
	not (notresult[0],A[0]);
	not (notresult[1],A[1]);
	not (notresult[2],A[2]);
	not (notresult[3],A[3]);
	not (notresult[4],A[4]);
	not (notresult[5],A[5]);
	not (notresult[6],A[6]);
	not (notresult[7],A[7]);
	not (notresult[8],A[8]);
	not (notresult[9],A[9]);
	not (notresult[10],A[10]);
	not (notresult[11],A[11]);
	not (notresult[12],A[12]);
	not (notresult[13],A[13]);
	not (notresult[14],A[14]);
	not (notresult[15],A[15]);

	
	assign status[3] = 1'b0;
	
	assign status[2] = 1'b0;
	
	assign status[1] = notresult[15];
	
	assign status[0] = (notresult == 16'b0000000000000000) ? 1'b1 : 1'b0;
		
endmodule

//Initializes A+1 using add operation 
module incA(result,A,status);
	input [15:0] A;
	output [3:0] status;
	output [15:0] result;
	
	
	add Aone(result,A,1,status);
	
	
endmodule 

//Initializes movA operation 
module movA(result,A,status);
	input [15:0] A;
	output [3:0] status;
	output [15:0] result;
	
	wire [15:0] nA;
	
	wire [3:0] dw1,dw2;
	
	notA not0(nA,A,dw1);
	notA not1(result,nA,dw2);
	
	
	assign status[3] = 1'b0;
	
	assign status[2] = 1'b0;
	
	assign status[1] = result[15];
	
	assign status[0] = (result == 16'b0000000000000000) ? 1'b1 : 1'b0;
	
endmodule 

//Initializes divison operator
module div16(result,B,status);
	input [15:0] B;
	output [3:0] status;
	output [15:0] result;
	
	wire [15:0] nB;
	wire [3:0] dw1;
	
	notA notB(nB,B,dw1);
	
	//Shifts bits [11:5] right four bits 
	not (result[0],nB[4]);
	not (result[1],nB[5]);
	not (result[2],nB[6]);
	not (result[3],nB[7]);
	not (result[4],nB[8]);
	not (result[5],nB[9]);
	not (result[6],nB[10]);
	not (result[7],nB[11]);
	not (result[8],nB[12]);
	not (result[9],nB[13]);
	not (result[10],nB[14]);
	not (result[11],nB[15]);
	not (result[12],nB[15]);
	
	
	//Assigns bits[15:12] to 0
	not (result[13],1);
	not (result[14],1);
	not (result[15],1);
	
	
	assign status[3] = 1'b0;
	
	assign status[2] = 1'b0;
	
	assign status[1] = result[15];
	
	assign status[0] = (result == 16'b0000000000000000) ? 1'b1 : 1'b0;

endmodule

module mult4(result,B,status);
	input [15:0] B;
	output [3:0] status;
	output [15:0] result; 
	
	wire [15:0] nB;
	
	notA notB(nB,B);
	
	not (result[2],nB[0]);
	not (result[3],nB[1]);
	not (result[4],nB[2]);
	not (result[5],nB[3]);
	not (result[6],nB[4]);
	not (result[7],nB[5]);
	not (result[8],nB[6]);
	not (result[9],nB[7]);
	not (result[10],nB[8]);
	not (result[11],nB[9]);
	not (result[12],nB[10]);
	not (result[13],nB[11]);
	
	
	//Assigns result [1:0] & [14:15] to 0
	not (result[15],1);
	not (result[14],1);
	not (result[1],1);
	not (result[0],1);
	
	assign status[3] = 1'b0;
	
	assign status[2] = 1'b0;
	
	assign status[1] = result[15];
	
	assign status[0] = (result == 16'b0000000000000000) ? 1'b1 : 1'b0;
	
endmodule 


//Intializes B+2 using add operation
module inc2B(result,B,status);
	input [15:0] B;
	output [3:0] status;
	output [15:0] result;
	
	add Btwo(result,2,B,status);
	
endmodule

//Initializes A-3 using subtraction operation
module dec3A(result,A,status);
	input [15:0] A;
	output [3:0] status;
	output [15:0] result;
	
	sub Aneg3(result,A,3,status);
endmodule 


//Initializes nand operation
module nandAB(result,A,B,status);
	input [15:0] A,B;
	output [3:0] status;
	output [15:0] result;
	
	nand (result[0],A[0],B[0]);
	nand (result[1],A[1],B[1]);
	nand (result[2],A[2],B[2]);
	nand (result[3],A[3],B[3]);
	nand (result[4],A[4],B[4]);
	nand (result[5],A[5],B[5]);
	nand (result[6],A[6],B[6]);
	nand (result[7],A[7],B[7]);
	nand (result[8],A[8],B[8]);
	nand (result[9],A[9],B[9]);
	nand (result[10],A[10],B[10]);
	nand (result[11],A[11],B[11]);
	nand (result[12],A[12],B[12]);
	nand (result[13],A[13],B[13]);
	nand (result[14],A[14],B[14]);
	nand (result[15],A[15],B[15]);
	
	assign status[3] = 1'b0;
	
	assign status[2] = 1'b0;
	
	assign status[1] = result[15];
	
	assign status[0] = (result == 16'b0000000000000000) ? 1'b1 : 1'b0;
	
endmodule 
	

//Initializes xor operator
module xorAB(result,A,B,status);
	input [15:0] A,B;
	output [3:0] status;
	output [15:0] result;
	
	xor (result[0],A[0],B[0]);
	xor (result[1],A[1],B[1]);
	xor (result[2],A[2],B[2]);
	xor (result[3],A[3],B[3]);
	xor (result[4],A[4],B[4]);
	xor (result[5],A[5],B[5]);
	xor (result[6],A[6],B[6]);
	xor (result[7],A[7],B[7]);
	xor (result[8],A[8],B[8]);
	xor (result[9],A[9],B[9]);
	xor (result[10],A[10],B[10]);
	xor (result[11],A[11],B[11]);
	xor (result[12],A[12],B[12]);
	xor (result[13],A[13],B[13]);
	xor (result[14],A[14],B[14]);
	xor (result[15],A[15],B[15]);
	
	
	assign status[3] = 1'b0;
	
	assign status[2] = 1'b0;
	
	assign status[1] = result[15];
	
	assign status[0] = (result == 16'b0000000000000000) ? 1'b1 : 1'b0;
	
endmodule 


//Initializes or operator
module orAB(result,A,B,status);
	input [15:0] A,B;
	output [3:0] status;
	output [15:0] result;
	
	or (result[0],A[0],B[0]);
	or (result[1],A[1],B[1]);
	or (result[2],A[2],B[2]);
	or (result[3],A[3],B[3]);
	or (result[4],A[4],B[4]);
	or (result[5],A[5],B[5]);
	or (result[6],A[6],B[6]);
	or (result[7],A[7],B[7]);
	or (result[8],A[8],B[8]);
	or (result[9],A[9],B[9]);
	or (result[10],A[10],B[10]);
	or (result[11],A[11],B[11]);
	or (result[12],A[12],B[12]);
	or (result[13],A[13],B[13]);
	or (result[14],A[14],B[14]);
	or (result[15],A[15],B[15]);
	
	
	assign status[3] = 1'b0;
	
	assign status[2] = 1'b0;
	
	assign status[1] = result[15];
	
	assign status[0] = (result == 16'b0000000000000000) ? 1'b1 : 1'b0;
	
endmodule 

//Initializes swap operation
module swapA(result,A,status);
	input [15:0] A;
	output [3:0] status;
	output [15:0] result;
	
	wire [15:0] w;
	
	notA notop(w,A);
	
	not (result[0],w[8]);
	not (result[1],w[9]);
	not (result[2],w[10]);
	not (result[3],w[11]);
	not (result[4],w[12]);
	not (result[5],w[13]);
	not (result[6],w[14]);
	not (result[7],w[15]);
	not (result[8],w[0]);
	not (result[9],w[1]);
	not (result[10],w[2]);
	not (result[11],w[3]);
	not (result[12],w[4]);
	not (result[13],w[5]);
	not (result[14],w[6]);
	not (result[15],w[7]);
	
	assign status[3] = 1'b0;
	
	assign status[2] = 1'b0;
	
	assign status[1] = 1'b0;
	
	assign status[0] = 1'b0;
	
endmodule 

	
	
	

