/*
 * scoreboard.sv: Frame Link Scoreboard
 * Copyright (C) 2009 CESNET
 * Author(s): Marek Santa <xsanta06@stud.fit.vutbr.cz>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 3. Neither the name of the Company nor the names of its contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * This software is provided ``as is'', and any express or implied
 * warranties, including, but not limited to, the implied warranties of
 * merchantability and fitness for a particular purpose are disclaimed.
 * In no event shall the company or contributors be liable for any
 * direct, indirect, incidental, special, exemplary, or consequential
 * damages (including, but not limited to, procurement of substitute
 * goods or services; loss of use, data, or profits; or business
 * interruption) however caused and on any theory of liability, whether
 * in contract, strict liability, or tort (including negligence or
 * otherwise) arising in any way out of the use of this software, even
 * if advised of the possibility of such damage.
 *
 *
 *
 * TODO:
 *
 */

import sv_common_pkg::*;
import sv_fl_pkg::*;
  
  // --------------------------------------------------------------------------
  // -- Frame Link Driver Callbacks
  // --------------------------------------------------------------------------
  class ScoreboardDriverCbs #(bit pInsert=0, int pMarkPart=0, int pOffset=2,  
                              int pMarkSize=1) extends DriverCbs;

    // ---------------------
    // -- Class Variables --
    // ---------------------
    TransactionTable #(0) sc_table;

    // -------------------
    // -- Class Methods --
    // -------------------

    // -- Constructor ---------------------------------------------------------
    // Create a class 
    function new (TransactionTable #(0) sc_table);
      this.sc_table = sc_table;
    endfunction
    
    // ------------------------------------------------------------------------
    // Function is called before is transaction sended 
    // Allow modify transaction before is sended
    virtual task pre_tx(ref Transaction transaction, string inst);
    //   FrameLinkTransaction tr;
    //   $cast(tr,transaction);
         $write("+++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
         $timeformat(-9, 3, " ns", 8);
         $write("Time: %t\n", $time);
    
    // Example - set first byte of first packet in each frame to zero   
    //   tr.data[0][0]=0;
    endtask
    
    // ------------------------------------------------------------------------
    // Function is called after is transaction sended 
    
    virtual task post_tx(Transaction transaction, string inst);
      FrameLinkTransaction tr;                  // FrameLink transaction      
      static bit[pMarkSize*8-1:0] mark = 0;     // Mark  
                   
      $cast(tr,transaction);

      if (pOffset <= tr.data[pMarkPart].size) begin
        if (pInsert) begin
          // enlarge packet to make space for mark
          tr.data[pMarkPart] = new[pMarkSize+tr.data[pMarkPart].size](tr.data[pMarkPart]);
                              
          // shift data
          for (int i=tr.data[pMarkPart].size-1; i>=pMarkSize+pOffset; i--)  
            tr.data[pMarkPart][i] = tr.data[pMarkPart][i-pMarkSize];
        end    
         
        // add mark
        for (int i=0; i<pMarkSize*8; i++)
          tr.data[pMarkPart][pOffset+i/8][i%8] = mark[i]; 
      end

      mark++; // increment mark

      transaction.display("PACKET WITH MARK");
      
      // add transaction to tr.table
      sc_table.add(transaction);
    endtask

   endclass : ScoreboardDriverCbs


  // --------------------------------------------------------------------------
  // -- Frame Link Monitor Callbacks
  // --------------------------------------------------------------------------
  class ScoreboardMonitorCbs extends MonitorCbs;
    
    // ---------------------
    // -- Class Variables --
    // ---------------------
    TransactionTable #(0) sc_table;
    
    // -- Constructor ---------------------------------------------------------
    // Create a class 
    function new (TransactionTable #(0) sc_table);
      this.sc_table = sc_table;
    endfunction
    
    // ------------------------------------------------------------------------
    // Function is called after is transaction received (scoreboard)

    virtual task post_rx(Transaction transaction, string inst);
      bit status=0;
      sc_table.remove(transaction, status);
      if (status==0)begin
         $write("Unknown transaction received from monitor %d\n", inst);
         $timeformat(-9, 3, " ns", 8);
         $write("Time: %t\n", $time);
         transaction.display(); 
         sc_table.display();
         $stop;
       end;
    endtask

 
  endclass : ScoreboardMonitorCbs

  // -- Constructor ---------------------------------------------------------
  // Create a class 
  // --------------------------------------------------------------------------
  // -- Scoreboard
  // --------------------------------------------------------------------------
  class Scoreboard #(bit pInsert=0, int pMarkPart=0, int pOffset=2,  
                     int pMarkSize=1);

    // ---------------------
    // -- Class Variables --
    // ---------------------
    TransactionTable #(0) scoreTable;
    ScoreboardMonitorCbs  monitorCbs;
    ScoreboardDriverCbs #(pInsert,pMarkPart,pOffset,pMarkSize)  driverCbs;

    // -- Constructor ---------------------------------------------------------
    // Create a class 
    function new ();
      this.scoreTable = new;
      this.monitorCbs = new(scoreTable);
      this.driverCbs  = new(scoreTable);
    endfunction

    // -- Display -------------------------------------------------------------
    // Create a class 
    task display();
      scoreTable.display();
    endtask
  
  endclass : Scoreboard

