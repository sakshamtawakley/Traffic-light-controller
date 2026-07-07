`timescale 1ns/1ps

module traffic_light_controller (
    input  clk,
    input  rst,
    input  X,
    output reg [1:0] hwy,
    output reg [1:0] cntry
);

    // light codes
    parameter R = 0, Y = 1, G = 2;
    // states
    parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
    // how many clock cycles to hold each yellow/all-red phase
    parameter Y2R = 2, R2G = 2;

    reg [2:0] state, next_state;
    reg [3:0] delay_cnt;

    // state register
    always @(posedge clk or posedge rst) begin
        if (rst) state <= S0;
        else     state <= next_state;
    end

    // delay counter: resets whenever we're about to move to a new state
    always @(posedge clk or posedge rst) begin
        if (rst)
            delay_cnt <= 0;
        else if (state != next_state)
            delay_cnt <= 0;
        else
            delay_cnt <= delay_cnt + 1;
    end

    // output decode (Moore outputs)
    always @(*) begin
        case (state)
            S0: begin hwy = G; cntry = R; end
            S1: begin hwy = Y; cntry = R; end
            S2: begin hwy = R; cntry = R; end
            S3: begin hwy = R; cntry = G; end
            S4: begin hwy = R; cntry = Y; end
            default: begin hwy = R; cntry = R; end
        endcase
    end

    // next-state logic (combinational)
    always @(*) begin
        if (rst) begin
            next_state = S0;
        end else begin
            case (state)
                S0: next_state = X ? S1 : S0;
                S1: next_state = (delay_cnt >= Y2R-1) ? S2 : S1;
                S2: next_state = (delay_cnt >= R2G-1) ? S3 : S2;
                S3: next_state = X ? S3 : S4;
                S4: next_state = (delay_cnt >= Y2R-1) ? S0 : S4;
                default: next_state = S0;
            endcase
        end
    end

endmodule


// Testbench
module tb;

    reg clk = 0, rst, X;
    wire [1:0] hwy, cntry;

    traffic_light_controller dut (
        .clk(clk), .rst(rst), .X(X),
        .hwy(hwy), .cntry(cntry)
    );

    // 10ns period clock
    always #5 clk = ~clk;

    // small helper so waveform/monitor prints are readable
    function [7:0] name;
        input [1:0] code;
        begin
            case (code)
                0: name = "R";
                1: name = "Y";
                2: name = "G";
                default: name = "?";
            endcase
        end
    endfunction

    initial begin
        $dumpfile("traffic.vcd");
        $dumpvars(0, tb);

        rst = 1; X = 0;
        #12 rst = 0;      // release reset after a couple clocks
        #20 X = 1;        // car arrives on country road
        #10 X = 0;
        #100 X = 1;       // car stays present for a while
        #40 X = 0;
        #200 $finish;
    end

    
    always @(dut.state or hwy or cntry or X) begin
        $display("t=%0t state=%0d hwy=%s cntry=%s X=%b",
                  $time, dut.state, name(hwy), name(cntry), X);
    end

endmodule
