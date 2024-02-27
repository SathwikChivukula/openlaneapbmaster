module apb_mcp(
    input clk,
    input preset,
    input [7:0]address,
    input [7:0]wdata,
    input pready,
    input [7:0]pread,
    input write,
    output reg penable,
    output reg [7:0]paddress,
    output reg [7:0]pwdata,
    output reg psel,
    output reg pwrite
);
parameter idle=2'b00;
parameter setup=2'b01;
parameter access=2'b10;
reg [1:0]state,nxt_state;
reg [31:0]pread_data;
always@(posedge clk or negedge preset)begin
     if(~preset) begin
        state=idle;
end else begin
   state=nxt_state; end
end 
always @ (state) begin
    case(state)
     idle: begin
        psel=0;
        penable=0;
        nxt_state=setup;
         end
    setup: begin
        psel=1'b1;
        pwrite=wdata;
        paddress=address;
        penable=1'b0;
        nxt_state = access; end
     access: begin
        penable=1'b1;
        if(pready==1'b1) begin
           if(write==1'b1) begin
               pwrite=1;
               pwdata=wdata;
               nxt_state=idle;
               paddress=address;
            end
            else  begin
               pwrite=0; 
               pread_data=pread;
               nxt_state=idle;
               paddress=address;

            end 
         end
        else begin
            pwdata=0;
            pread_data=0;
            nxt_state=access; end
    end
    endcase 
end       
endmodule
module tb;
    reg clk=0;
    reg preset;
    reg [7:0]address;
    reg [7:0]wdata;
    reg pready;
    reg [7:0]pread;
    reg write;
    wire penable;
    wire [7:0]paddress;
    wire [7:0]pwdata;
    wire psel;
    wire pwrite;
    apb_mcp dut(clk,preset,address,wdata,pready,pread,write,penable,paddress,pwdata,psel,pwrite);
    always begin
        #10 clk=~clk; end
    initial begin
        $dumpfile("apb_mcp.vcd");
        $dumpvars(0,tb);
    preset=0;
    #10 preset=1;
    repeat(40) begin
    address=$random;
    wdata=$random;
    pready=0;
    #20 pready=1;
    pread=$random;
    write=$random;
    #10;
    end
    #100 preset=0;
     #400 $finish;
    end
endmodule
