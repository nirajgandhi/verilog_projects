

//MODULE DECLARATION
module apb(ahb_write_add,ahb_write_data,transfer,ahb_read_add,ahb_read_data_out,PCLK,PRESETn,PREADY,PADDR,PWRITE,PWDATA,PRDATA,PSEL,PENABLE,READ_WRITE_DATA);

//-------------------------------------------------------------------------------------------------------------------------------------------//

// INPUT PORT DECLARATIONS

 input PCLK,PRESETn,PREADY,transfer,READ_WRITE_DATA;
 input [31:0] ahb_write_add,ahb_write_data,ahb_read_add,PRDATA;

//-------------------------------------------------------------------------------------------------------------------------------------------//

// OUTPUT DECLARATIONS

output reg[31:0] PWDATA,ahb_read_data_out;
  output reg[31:0] PADDR;
output reg PWRITE,PSEL,PENABLE;
reg [31:0] mem [7:0];

//-----------------------------------------------------------------------------------------------------------------------------------------------//

// FSM STATE DECLARATIONS
reg [1:0] NEXT_STATE;
reg [1:0] PRES_STATE;

//----------------------------------------------------------------------------------------------------------------------------------------------//
 
//STATES ENCODING
parameter IDLE = 2'b00;
parameter SETUP = 2'b01;
parameter ACCESS = 2'b10;

  
//-------------------------------------------------------------------------------------------------------------------------------------------------//  


//FSM MODELLING

always @(*)
begin
  
  if(READ_WRITE_DATA)
   begin

//--------------------------------------WRITING THE DATA-----------------------------------------------------------------------------//

     case(PRES_STATE)
     IDLE: 
      begin 
        if(PREADY == 1'b0 && transfer == 1'b0)
         begin
         PWRITE = 1'b0;
         PSEL = 1'b0;
         PENABLE = 1'b0;
       
         NEXT_STATE = IDLE;
         end
      
        else if (PREADY == 1'b0 && transfer == 1'b1)
         begin
         NEXT_STATE = SETUP; 
         end
      end
     
    SETUP: 
      begin
        if (PREADY == 1'b0 && transfer == 1'b1)
         begin
         PADDR = ahb_write_add;
         //PADDR = 0;
         PWDATA = ahb_write_data;
         PWRITE = 1'b1;
         PSEL = 1'b1;
         PENABLE = 1'b0;
         NEXT_STATE = ACCESS;
         end
      
        else if (PREADY == 1'b0 && transfer == 1'b0)
         begin
         NEXT_STATE = IDLE;
         end
      end

    ACCESS:
     begin
       if(PREADY == 1'b0 && transfer == 1'b1)
        begin
        //PADDR = ahb_write_add;
         // PADDR = mem[0]
          //PWDATA = ahb_write_data;
          //PADDR = PWDATA; 
          //mem[PADDR] = PWDATA;
        PWRITE = 1'b1;
        PSEL = 1'b1;
        PENABLE = 1'b1;
        mem[PADDR] = PWDATA;
        //PENABLE = 1'b0;
        NEXT_STATE = ACCESS;
        end
 
       else if(PREADY == 1'b1 && transfer == 1'b1)
        begin
        NEXT_STATE = SETUP;
        end

       else if(PREADY == 1'b1 && transfer == 1'b0)
        begin
        NEXT_STATE = IDLE;
        end
     end

    default:NEXT_STATE = IDLE;
   endcase
  
  end 
  
//------------------------------------------------------READING THE DATA----------------------------------------------------------------//

  else if(!READ_WRITE_DATA)
  begin
    
    case(PRES_STATE)
      IDLE: 
      begin 
        if(PREADY == 1'b0 && transfer == 1'b0)
         begin
         PWRITE = 1'b0;
         PSEL = 1'b0;
         PENABLE = 1'b0;
         NEXT_STATE = IDLE;
         end
      
        else if (PREADY == 1'b0 && transfer == 1'b1)
         begin
         NEXT_STATE = SETUP; 
         end
      end 

      SETUP:
      begin
        if(PREADY == 1'b0 && transfer == 1'b1)
         begin
          PADDR = ahb_read_add;
          // PADDR = 0;
          PSEL = 1'b1;
          PENABLE = 1'b0;
          NEXT_STATE = ACCESS;
          end
         
        else if(PREADY == 1'b0 && transfer == 1'b0)
          begin
          NEXT_STATE = IDLE;
          end
        
      end
       
       ACCESS:
       begin
         if(PREADY == 1'b0 && transfer == 1'b1)
         begin
          //PRDATA = mem[0];
           
          PSEL = 1'b1;
          PENABLE = 1'b1;
          ahb_read_data_out = mem[PADDR];
          //PENABLE = 1'b0;
           NEXT_STATE = ACCESS;
          
         end
         
         else if(PREADY == 1'b1 && transfer == 1'b1)
        begin
        NEXT_STATE = SETUP;
        end

       else if(PREADY == 1'b1 && transfer == 1'b0)
        begin
        NEXT_STATE = IDLE;
      end
     end
      default : NEXT_STATE = IDLE;
     endcase

  end
end
         

//CLOCKING THE STATE FLIPFLOPS

always@(posedge PCLK)
begin
  if (PRESETn ==1'b0)
     PRES_STATE <= IDLE;
  else
     PRES_STATE <= NEXT_STATE;
end

endmodule




           
    
