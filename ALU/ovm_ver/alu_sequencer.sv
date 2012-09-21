/* *****************************************************************************
 * Project Name: HAVEN
 * File Name:    alu_sequencer.sv
 * Description:  OVM Sequencer Class for ALU
 * Authors:      Michaela Belesova <xbeles00@stud.fit.vutbr.cz>,
 *               Marcela Simkova <isimkova@fit.vutbr.cz> 
 * Date:         17.8.2012
 * ************************************************************************** */

`include "ovm_macros.svh"
package alu_sequencer_pkg;
 import ovm_pkg::*;
 import sv_basic_comp_pkg::*;
 import alu_transaction_result_pkg::*; 
 
/*!
 * \brief AluSequencer
 * 
 * This class creates random inputs for DUT and sends them to driver
 */

 class AluSequencer extends BasicSequencer #(AluTransaction);
    
   //registration of component tools
   `ovm_component_utils(AluSequencer)

  /*! 
   * Constructor - creates AluSequencer object  
   *
   * \param name     - sequencer instance name
   * \param parent   - parent class identification
   */ 
   function new(string name, ovm_component parent);
     super.new(name, parent, SV_GEN, SV_SIM);
   endfunction: new

 endclass: AluSequencer
 
endpackage: alu_sequencer_pkg 