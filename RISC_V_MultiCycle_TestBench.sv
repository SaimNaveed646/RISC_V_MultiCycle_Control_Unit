`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/12/2026 06:32:49 PM
// Design Name: 
// Module Name: RISC_V_MultiCycle_TestBench
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

module RISC_V_MultiCycle_TestBench;


    logic clk = 0;
    logic rst;
    logic [6:0] Opcode;

    // Control Outputs
    logic PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite;
    logic [1:0] SrcReg, ALUOp, ALUSrcB;
    logic ALUSrcA, PCSource, RegWrite;

    
    RISC_V_MultiCycle_Control_Unit  dut (.*);

    
    always #5 clk = ~clk;

    initial begin
        
        rst = 1;
        Opcode = 7'b0;
        #15 rst = 0;

        //  R-Type 
        Opcode = 7'b0110011;
        #40;

        //  Load Word (LW) 
        Opcode = 7'b0000011;
        #50;

        //  Store Word (SW) 
        Opcode = 7'b0100011;
        #40;

        //  Branch Equal (BEQ) 
        Opcode = 7'b1100011;
        #30;

        //  Jump and Link (JAL) 
        Opcode = 7'b1101111;
        #30;

        $finish;
    end

endmodule


        
