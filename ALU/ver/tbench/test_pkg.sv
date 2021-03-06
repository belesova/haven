/* *****************************************************************************
 * Project Name: ALU Functional Verification
 * File Name:    test_pkg.sv - test package
 * Description:  Definition of constants and parameters 
 * Author:       Marcela Simkova <isimkova@fit.vutbr.cz> 
 * Date:         22.3.2012 
 * ************************************************************************** */ 

package test_pkg;
   
   // VERIFICATION FRAMEWORK
   int FRAMEWORK  = 0;             // 0 = software framework
                                   // 1 = sw/hw framework     
   // DUT GENERICS
   parameter DATA_WIDTH     = 8; // data width
   
   // CLOCKS AND RESETS
   parameter CLK_PERIOD     = 10ns;
   parameter RESET_TIME     = 10*CLK_PERIOD;
   parameter ACTIVE_TIME    = CLK_PERIOD;
   parameter SIM_DELAY      = 100;
   
   // GENERATOR PARAMETERS
   parameter GEN_TRANS      = 3;   // 0 = simulation with generated transactions
                                   // 1 = generation of transactions and their
                                   //     storage to external file  
                                   // 2 = reading transactions from external
                                   //     file without generation
                                   // 3 = simulation with generated transactions
                                   //     and their storage to external file   
   // TRANSACTION FORMAT 
   
   // DRIVER PARAMETERS 
   // Enable/Disable weights of "delay between transactions" 
   parameter byte DRIVER_BT_DELAY_EN_WT  = 1;       
   parameter byte DRIVER_BT_DELAY_DI_WT  = 3;
   // Low/High limit of "delay between transactions" value
   parameter byte DRIVER_BT_DELAY_LOW    = 0;
   parameter byte DRIVER_BT_DELAY_HIGH   = 5;
   
   // TEST PARAMETERS
   parameter TRANSACTION_COUT = 1;   // Count of transactions
   parameter SEED1            = 0;    // Seed for PRNG
   parameter SEED2            = 2;    // Seed for PRNG
endpackage
