`timescale 1ns / 1ps

module top_tb;

    // Parametru local pentru num?rul de canale
    localparam N = 8;

    // Declara?ii de semnale pentru conectarea la DUT
    logic clk_i_tb;
    logic rstn_i_tb;
    logic acc_en_i_tb;
    logic wr_en_i_tb;
    logic [$clog2(N + N/8)-1:0] addr_i_tb; // adres? pentru acces registru
    logic [7:0] wdata_i_tb;                // date de scris
    logic [7:0] rdata_o_tb;                // date citite
    logic [N-1:0] data_in_tb;              // intr?ri de la senzori
    logic [N-1:0] data_out_tb;             // ie?iri de la filtre
    logic int_pulse_out_tb;               // semnal de întrerupere global

    // Instan?ierea modulului de testat (DUT - Device Under Test)
    top #(.N(N)) DUT (
        .clk_i(clk_i_tb),
        .rstn_i(rstn_i_tb),
        .acc_en_i(acc_en_i_tb),
        .wr_en_i(wr_en_i_tb),
        .addr_i(addr_i_tb),
        .wdata_i(wdata_i_tb),
        .rdata_o(rdata_o_tb),
        .data_in(data_in_tb),
        .data_out(data_out_tb),
        .int_pulse_out(int_pulse_out_tb)
    );

    // Generator de ceas (clock) - cu perioad? de 2ns
    initial begin
        clk_i_tb = 0;
        forever #1 clk_i_tb = ~clk_i_tb; // toggling la fiecare 1ns
    end

    // Ini?ializare ?i secven?? de test
    initial begin
        // Resetare ini?ial? ?i configurare semnale
        rstn_i_tb     = 0;
        acc_en_i_tb   = 0;
        wr_en_i_tb    = 0;
        addr_i_tb     = 0;
        wdata_i_tb    = 0;
        data_in_tb    = 0;

        #10 rstn_i_tb = 1; // scoatere din reset dup? 10ns

        // Activare acces ?i scriere în registrele de configurare
        acc_en_i_tb = 1;
        wr_en_i_tb  = 1;

        // Scrierea filtrelor pentru fiecare canal (0-7)
        addr_i_tb = 0; wdata_i_tb = 8'h03; #3;
        addr_i_tb = 1; wdata_i_tb = 8'h05; #3;
        addr_i_tb = 2; wdata_i_tb = 8'h07; #3;
        addr_i_tb = 3; wdata_i_tb = 8'h09; #3;
        addr_i_tb = 4; wdata_i_tb = 8'h03; #3;
        addr_i_tb = 5; wdata_i_tb = 8'h05; #3;
        addr_i_tb = 6; wdata_i_tb = 8'h02; #3;
        addr_i_tb = 7; wdata_i_tb = 8'h01; #3;

        // Scriere în registrul de stare (dac? este R/C, va fi ignorat?)
        addr_i_tb = 8; wdata_i_tb = 8'hAA; #3;

        // Oprire scriere
        wr_en_i_tb = 0;
        addr_i_tb  = 0;
        #3;

        // Aplicare date pe intrare - simul?m un senzor care variaz?
        data_in_tb = 8'b0000_0001; #10;  // semnal pe canalul 0
        data_in_tb = 8'b0000_0000; #10;  // totul la 0
        data_in_tb = 8'b0000_0010; #15;  // semnal pe canalul 1
        data_in_tb = 8'b0000_0000; #10;  // revenire
        data_in_tb = 8'b0000_0100; #20;  // canal 2 activ
        data_in_tb = 8'b0000_0000; #20;

        // Finalizare simulare
        $display("Simularea s-a încheiat.");
        $stop;
    end

endmodule

/*`timescale 1ns / 1ps

module testbench_extins();

    localparam N = 8;

    logic clk_i_tb;
    logic rstn_i_tb;
    logic acc_en_i_tb;
    logic wr_en_i_tb;
    logic [$clog2(N + N/8)-1 : 0] addr_i_tb;
    logic [7:0] wdata_i_tb;
    logic [N-1:0] data_in_tb;
    logic [7:0] rdata_o_tb;
    logic [N-1:0] data_out_tb;
    logic int_pulse_out_tb;

    // Instan?iem modulul de top
    top #(.N(N)) DUT (
        .clk_i(clk_i_tb),
        .rstn_i(rstn_i_tb),
        .acc_en_i(acc_en_i_tb),
        .wr_en_i(wr_en_i_tb),
        .addr_i(addr_i_tb),
        .wdata_i(wdata_i_tb),
        .data_in(data_in_tb),
        .rdata_o(rdata_o_tb),
        .data_out(data_out_tb),
        .int_pulse_out(int_pulse_out_tb)
    );

    // Generare ceas (clock)
    initial begin
        clk_i_tb = 0;
        forever #1 clk_i_tb = ~clk_i_tb;
    end

    // Ini?ializare ?i scriere în registre (configurare filtre)
    initial begin
        rstn_i_tb = 0;
        acc_en_i_tb = 0;
        wr_en_i_tb = 0;
        addr_i_tb = 0;
        wdata_i_tb = 0;
        data_in_tb = 0;
        #10;

        rstn_i_tb = 1;
        acc_en_i_tb = 1;
        wr_en_i_tb = 1;

        // Configur?m filtrele pentru toate cele 8 canale
        // Exemplu: filtrul tip 01 ?i fereastr? de 3 cicluri
        for (int i = 0; i < N; i++) begin
            addr_i_tb = i;
            wdata_i_tb = 8'b00000001; // filter_type = 01
            #2;
        end

        for (int i = 0; i < N; i++) begin
            addr_i_tb = i + N; // adresele 8-15 pentru window_size
            wdata_i_tb = 8'b00000011; // fereastr? = 3
            #2;
        end

        wr_en_i_tb = 0;
        #10;
    end

    // Simulare zgomot + activ?ri multiple
    initial begin
        #40;

        // ? Simul?m semnal de zgomot pe canalul 0 ?i 1
        data_in_tb = 8'b00000001; #2; // scurt impuls
        data_in_tb = 8'b00000000; #2;
        data_in_tb = 8'b00000010; #2; // scurt impuls pe canalul 1
        data_in_tb = 8'b00000000; #2;

        // ? Semnal valid (durat? mai lung?) pe canalul 2 ?i 3
        data_in_tb = 8'b00001100; #10; // 2 ?i 3
        data_in_tb = 8'b00000000; #4;

        // ? Rapid toggling (zgomot) pe canalul 4
        repeat (4) begin
            data_in_tb = 8'b00010000; #1;
            data_in_tb = 8'b00000000; #1;
        end

        // ? Semnal valid pe toate canalele
        data_in_tb = 8'b11111111; #12;
        data_in_tb = 8'b00000000; #5;

        $stop();
    end

endmodule
*/