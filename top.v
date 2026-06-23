module top(
    input clk,
    input btn,
    input [3:0] sw,
    output reg led0,
    output reg led1,
    output reg [6:0] seg,
    output [3:0] an
);

assign an = 4'b1110;

wire trap;

wire        mem_valid;
wire        mem_instr;
reg         mem_ready;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0]  mem_wstrb;
reg  [31:0] mem_rdata;

reg [31:0] rom [0:255];
reg [3:0] error_count = 0;

// button debounce
reg [19:0] btn_cnt = 0;
reg btn_sync = 0;
reg btn_debounced = 0;

initial begin
    rom[0]  = 32'h100000b7; // lui x1, 0x10000
    rom[1]  = 32'h0040a103; // lw x2, 4(x1)
    rom[2]  = 32'hfe010ee3; // beq x2, x0, -4

    rom[3]  = 32'h0000a183; // lw x3, 0(x1)
    rom[4]  = 32'h00a00213; // addi x4, x0, 10
    rom[5]  = 32'h00418663; // beq x3, x4, +12
    rom[6]  = 32'h00200293; // wrong: x5 = 2
    rom[7]  = 32'h0080006f; // jump write_led
    rom[8]  = 32'h00100293; // correct: x5 = 1

    rom[9]  = 32'h0050a423; // sw x5, 8(x1)

    rom[10] = 32'h0007a337;
    rom[11] = 32'h12030313;
    rom[12] = 32'hfff30313;
    rom[13] = 32'hfe031ee3;

    rom[14] = 32'h0040a103;
    rom[15] = 32'hfe011ee3;

    rom[16] = 32'hfc1ff06f;
end

reg [7:0] reset_cnt = 0;
wire resetn = (reset_cnt == 8'hff);

always @(posedge clk) begin
    if (reset_cnt != 8'hff)
        reset_cnt <= reset_cnt + 1;
end

always @(posedge clk) begin
    btn_sync <= btn;
    btn_cnt <= btn_cnt + 1;

    if (btn_cnt == 0)
        btn_debounced <= btn_sync;
end

always @(posedge clk) begin
    mem_ready <= mem_valid;

    if (mem_addr == 32'h10000000)
        mem_rdata <= {28'b0, sw};
    else if (mem_addr == 32'h10000004)
        mem_rdata <= {31'b0, btn_debounced};
    else
        mem_rdata <= rom[mem_addr[9:2]];
end

wire io_write_fire;

assign io_write_fire =
    mem_valid &&
    mem_ready &&
    (mem_wstrb != 0) &&
    (mem_addr == 32'h10000008);

always @(posedge clk) begin
    if (!resetn) begin
        led0 <= 1'b0;
        led1 <= 1'b0;
        error_count <= 4'd0;
    end
    else if (io_write_fire) begin
        led0 <= mem_wdata[0];
        led1 <= mem_wdata[1];

        if (mem_wdata[0]) begin
            error_count <= 4'd0;
        end
        else if (mem_wdata[1]) begin
            if (error_count < 4'd9)
                error_count <= error_count + 1'b1;
            else
                error_count <= 4'd9;
        end
    end
end

always @(*) begin
    case (error_count)
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        default: seg = 7'b0010000;
    endcase
end

picorv32 #(
    .ENABLE_COUNTERS(0),
    .ENABLE_COUNTERS64(0),
    .ENABLE_MUL(0),
    .ENABLE_DIV(0),
    .ENABLE_IRQ(0),
    .ENABLE_TRACE(0),
    .REGS_INIT_ZERO(1)
) cpu (
    .clk(clk),
    .resetn(resetn),
    .trap(trap),

    .mem_valid(mem_valid),
    .mem_instr(mem_instr),
    .mem_ready(mem_ready),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata),
    .mem_wstrb(mem_wstrb),
    .mem_rdata(mem_rdata),

    .pcpi_wr(1'b0),
    .pcpi_rd(32'b0),
    .pcpi_wait(1'b0),
    .pcpi_ready(1'b0),

    .irq(32'b0),
    .eoi()
);

endmodule