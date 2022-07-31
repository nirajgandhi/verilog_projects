//**********************************************************************************************************************************************************

//module : apb_slave_test();
//description :  Test bench for APB slave module. In this test bench, dummy APB master is generated, to generate input signal for APB slave in random manner.

//**********************************************************************************************************************************************************


module apb_slave_test();



 wire [31:0] pwdata_out;   // write data on slave devices
 wire [31:0] prdata_out;    //read data from device
 wire pready;
 
 //i/p declration
 reg psel;            // slave select signal from master
 reg penable;         // enable signal for transfer data
 reg [31:0] paddr;    // address of slave
 reg pwrite;          // write data in slave devices
 reg preset;          
 reg pclk;           // slave clk
 reg [31:0] prdata_in;    //read data from device
 reg [31:0] pwdata_in;    //read data from device

 integer rnd_num1;

apb_slave inst_main(psel,penable,paddr,pwrite,preset,pclk,pwdata_out,prdata_out,pready,prdata_in,pwdata_in);

initial
begin

  psel =0;
  penable = 0;
  paddr = 0;
  pwrite = 1'b0;
  preset = 1;
  pclk = 0;
  prdata_in = 0;
  pwdata_in = 0;
  rnd_num1 = {{10{1'b0}}, {5{2'b10}},{3{3'b011}},3'b101};

  #10 preset = 0;
  #15 preset = 1;

  #5 
     paddr  = {32{1'b1}}; 
  
  #200   paddr  = {32{1'b1}}; 

  #2000 $finish;



end

initial
begin
  $dumpvars(0,apb_slave_test);
  $dumpfile("acitivity.vcd");
  
end

always #10 pclk = ~pclk;

//*************************************************************************************************************************
//dummy APB master generator
//*************************************************************************************************************************

reg setup_mode;
reg enable_mode;
reg idle_mode;

initial		//initial condition for APB master
begin
  setup_mode = 1'b0;
  enable_mode = 1'b0;
  idle_mode = 1'b0;
end

always @(posedge pclk, negedge preset)		//generation of APB slave input signal in random manner, using dummy APB master
begin
  if(!preset | idle_mode)
  begin
    psel = 1'b0;
    penable = 1'b0;
    setup_mode = 1'b1;
    enable_mode = 1'b0;
    idle_mode = 1'b0;
  end  
  
  else if(setup_mode == 1'b1)
  begin
    psel = 1'b1;
    penable = 1'b0;
    setup_mode = 1'b0;
    enable_mode = 1'b1;
  end  
  
  else if(enable_mode == 1'b1)
  begin
    psel = 1'b1;
    penable = 1'b1;
    if(apb_slave_test.inst_main.pready == 1'b1)
    begin
      psel = 1'b0;
      penable = 1'b0;
      idle_mode = 1'b1;
    end    
  end  
  
  
  else 
  begin
    psel = 1'b0;
    penable = 1'b0;
    setup_mode = 1'b0;
    enable_mode = 1'b0;
  end  



end

always @(posedge psel)		//generation of random data, for data bus
begin

  rnd_num1 = {rnd_num1[30:0] , rnd_num1[31]^rnd_num1[27]};
  prdata_in[31:0] = rnd_num1;
  pwdata_in[31:0] = ~rnd_num1;
  pwrite = rnd_num1[0];

end


endmodule
