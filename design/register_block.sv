module register_block
#(parameter N=8)  
(
    input  logic clk_i,    // Clock
    input  logic rstn_i,   // Reset asincron, activ jos
    input  logic acc_en_i, // Activare acces pentru tranzactii sincrone
    input  logic wr_en_i,  // 1 pentru scriere, 0 pentru citire 
    input  logic [$clog2(N+N/8)-1:0] addr_i,// de addr_size
    input  logic [7:0] wdata_i, // Date de 8 bi?i pentru scriere
    output logic [7:0] rdata_o, // Date de 8 bi?i pentru citire

    // Iesirile pentru configurarea filtrelor. Acestea provin din registrele de control.
    output logic [2*N-1:0] filter_type, // 2 bi?i per filtru, N filtre
    output logic [4*N-1:0] window_size, // 4 bi?i per filtru, N filtre
    output logic [N-1:0] int_en,        // 1 bit per filtru, N filtre
    output logic [N-1:0] wd_rst,        // 1 bit per filtru, N filtre (selector de reset al ferestrei)

    // Intrarea pentru starea intreruperilor de la filtre
    input  logic [N-1:0] interrupt_status // 1 bit per filtru, N filtre (starea intreruperilor individuale (un bit per filtru))
);

// Declararea registrelor interne: reg_c declar? un array de N registre (un registru de 8 bi?i per filtru)
//                                 reg_s bi?i pentru starea întreruperilor (fiecare registru de stare va împacheta 8 bi?i de stare de la interrupt_status)

logic [7:0] reg_c[0:N-1];       // registru de control (N registre) Fiecare filtru are un registru de control.
logic [7:0] reg_s[0:N/8-1];     // registru de stare (N/8 registre)

genvar i;
// registru de control  SCRIERE
generate
    for(i = 0; i < N; i = i + 1) begin
        always_ff@(posedge clk_i or negedge rstn_i) begin
            if(rstn_i == 0)                                   // reset
                reg_c[i] <= 0;
            else if(wr_en_i == 1 && acc_en_i == 1 && addr_i == i) // scriere, acces activ, adresa curenta 
                reg_c[i] <= wdata_i;
        end
    end
endgenerate

// registru de stare  SCRIERE
generate
    for(i = 0; i < N/8; i = i + 1) begin
        always_ff@(posedge clk_i or negedge rstn_i) begin
            if(rstn_i == 0)
                reg_s[i] <= 0; // la reset
            else if(wr_en_i == 0 && acc_en_i == 1 && addr_i == N + i) // Aici este logica pentru R/C
                reg_s[i] <= 0; // *clear*
            else
                reg_s[i] <= reg_s[i] | interrupt_status[8*i +: 8]; // aici am corectat
        end
    end
endgenerate

// CITIRE (WE==0)
always_comb begin
    if(wr_en_i == 0 && acc_en_i == 1) begin
        if(addr_i < N)
            rdata_o = reg_c[addr_i];
        else if(addr_i >= N)
            rdata_o = reg_s[addr_i - N];
        else
            rdata_o = 8'd0;
    end else begin
        rdata_o = 8'd0;
    end
end

// alocarea bi?ilor pt registrele de control
generate
    for(i = 0; i < N; i = i + 1) begin
        assign filter_type[2*i+1:2*i] = reg_c[i][1:0];
        assign window_size[4*i+3:4*i] = reg_c[i][5:2];
        assign int_en[i] = reg_c[i][6];
        assign wd_rst[i] = reg_c[i][7];
    end
endgenerate

endmodule
