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

    // DUT Instantiation
    RISC_V_MultiCycle_Control_Unit dut (.*);

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    // State Display Helper
    string state_name;
    always_comb begin
        case (dut.current_state)
            4'd0: state_name = "S0 (Fetch)";
            4'd1: state_name = "S1 (Decode)";
            4'd2: state_name = "S2 (Exec R-Type)";
            4'd3: state_name = "S3 (WB R-Type)";
            4'd4: state_name = "S4 (Mem Addr)";
            4'd5: state_name = "S5 (LW Read)";
            4'd6: state_name = "S6 (LW WB)";
            4'd7: state_name = "S7 (SW Write)";
            4'd8: state_name = "S8 (BEQ)";
            4'd9: state_name = "S9 (JAL)";
            default: state_name = "UNKNOWN";
        endcase
    end

    // Display Output on every clock cycle
    always @(posedge clk) begin
        if (!rst) begin
            $display("Time=%0tns | State=%-16s | PCWrite=%b PCWriteCond=%b IorD=%b MemRead=%b MemWrite=%b IRWrite=%b SrcReg=%b ALUOp=%b ALUSrcB=%b ALUSrcA=%b PCSource=%b RegWrite=%b",
                     $time, state_name, PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite, SrcReg, ALUOp, ALUSrcB, ALUSrcA, PCSource, RegWrite);
        end
    end

    initial begin
        // Reset Setup
        rst = 1;
        Opcode = 7'b0;
        #15 rst = 0;

        // 1. R-Type Instruction
        $display("\n--- Testing R-Type ---");
        Opcode = 7'b0110011;
        #40;

        // 2. Load Word (LW)
        $display("\n--- Testing LW ---");
        Opcode = 7'b0000011;
        #50;

        // 3. Store Word (SW)
        $display("\n--- Testing SW ---");
        Opcode = 7'b0100011;
        #40;

        // 4. Branch Equal (BEQ)
        $display("\n--- Testing BEQ ---");
        Opcode = 7'b1100011;
        #30;

        // 5. Jump and Link (JAL)
        $display("\n--- Testing JAL ---");
        Opcode = 7'b1101111;
        #30;

        $finish;
    end

endmodule