
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2019 02:57:24 PM
// Design Name: 
// Module Name: HazardUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module HazardUnit (IF_write , PC_write , bubble , addrSel , Jump , Branch , ALUZero ,
memReadEX, currRs , currRt , prevRt , UseShamt , UseImmed , Clk , Rst ) ;
output reg IF_write, PC_write, bubble;
output reg [1:0] addrSel ;
input Jump , Branch , ALUZero , memReadEX, Clk , Rst ;
input UseShamt , UseImmed ;
input [4:0] currRs , currRt , prevRt ;


//parameter for states
parameter normal=2'b00;
parameter jump_state=2'b01;
parameter branch_nottaken=2'b10;
parameter branch_taken=2'b11;
reg LdHazard;
reg [1:0] state, next_state;


//load hazard detection
always @ (*)
begin
if (prevRt!=0 && memReadEX ==1)
	begin
	if(currRs==prevRt)
		LdHazard<=1;

		else 
		begin
		if ((UseShamt==0) && (UseImmed==0))
		begin
		if (currRt==prevRt)
			LdHazard<=1;
			else
			LdHazard<=0;
		end	
		else
		LdHazard<=0;
	end	
	end
else 
	LdHazard<=0;

	end
//sequential loop to print next state
always @(negedge Clk)
	begin
	if(Rst==0)
		state<=2'b00;
	else
		state<=next_state;
	end
//mealy machine is to be created

always @(*)
begin
case(state)
normal: begin
			if (Jump==1'b1)
			begin
			IF_write=1'b0;
			PC_write=1'b1;
			bubble=1'b0;
			addrSel=2'b01;
			next_state=jump_state;
			end
			else if (LdHazard==1'b1)
				begin
				IF_write=1'b0;
				PC_write=1'b0;
				bubble=1'b1;
				addrSel=2'b00;
				next_state=normal;
				end
			else if(Branch==1'b1)
				begin
				IF_write=1'b0;
				PC_write=1'b0;
				bubble=1'b0;
				addrSel=2'b00;
				next_state=branch_nottaken;
				end
			else
				begin
				IF_write=1'b1;
				PC_write=1'b1;
				bubble=1'b0;
				addrSel=2'b00;
				next_state=normal;
				end		
		end
jump_state: begin
		IF_write=1'b1;
		PC_write=1'b1;
		bubble=1'b1;
		addrSel=2'b00;
		next_state=normal;
		end
branch_nottaken:
begin
		if(ALUZero==1'b0)
		begin
		IF_write=1'b1;
		PC_write=1'b1;
		bubble=1'b1;
		addrSel=2'b00;
		next_state=normal;
		end
		else
		begin
		IF_write=1'b0;
		PC_write=1'b1;
		bubble=1'b1;
		addrSel=2'b10;
		next_state=branch_taken;
		end
end
branch_taken:
begin
		IF_write=1'b1;
		PC_write=1'b1;
		bubble=1'b1;
		addrSel=2'b00;
		next_state=normal;
end
default: next_state=normal;
endcase
end

endmodule
