-- shortener_fsm.vhd: FrameLink Shortener finite state machine
-- Copyright (C) 2008 CESNET
-- Author(s): Michal Kajan <xkajan01@stud.fit.vutbr.cz>
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions
-- are met:
-- 1. Redistributions of source code must retain the above copyright
--    notice, this list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in
--    the documentation and/or other materials provided with the
--    distribution.
-- 3. Neither the name of the Company nor the names of its contributors
--    may be used to endorse or promote products derived from this
--    software without specific prior written permission.
--
-- This software is provided ``as is'', and any express or implied
-- warranties, including, but not limited to, the implied warranties of
-- merchantability and fitness for a particular purpose are disclaimed.
-- In no event shall the company or contributors be liable for any
-- direct, indirect, incidental, special, exemplary, or consequential
-- damages (including, but not limited to, procurement of substitute
-- goods or services; loss of use, data, or profits; or business
-- interruption) however caused and on any theory of liability, whether
-- in contract, strict liability, or tort (including negligence or
-- otherwise) arising in any way out of the use of this software, even
-- if advised of the possibility of such damage.
--
-- $Id$
--
-- TODO:
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.math_pack.all;


-- ----------------------------------------------------------------------------
--  Entity declaration: FL_SHORTENER_FSM
-- ----------------------------------------------------------------------------

entity FL_SHORTENER_FSM is

   generic(
      -- data width
      DATA_WIDTH : integer;

      -- order number of FrameLink part that will be truncated
      PART_NUM   : integer;

      -- number of words that will be kept in certain FrameLink part
      -- part given by generic constant PART_NUM
      WORDS_KEPT : integer;

      -- number of parts in frame
      PARTS      : integer;

      -- default value of REM computed from number of bytes left unchanged
      -- and data width
      REM_CONST  : integer
 
   );
   port(
      -- Commnon signals
      -- global FPGA clock
      CLK           : in  std_logic;

      -- synchronous reset
      RESET         : in  std_logic;

      -- FSM input signals
      -- information from source component about readiness to transfer data
      SRC_RDY       : in  std_logic;

      -- information from destination component about readiness to transfer
      -- data
      DST_RDY       : in  std_logic;

      -- rem signal from source component
      DREM          : in std_logic_vector(log2(DATA_WIDTH/8)-1 downto 0);

      -- EOP signal from RX interface
      EOP           : in  std_logic;

      -- EOF signal from RX interface
      EOF           : in  std_logic;

      -- information about number parts that have been received from input
      -- during FrameLink frame transfer
      CNT_EOP         : in std_logic_vector(log2(PARTS) downto 0);

      -- information about number of processed words in FrameLink part
      -- that is being truncated
      CNT_WORD      : in  std_logic_vector(log2(WORDS_KEPT) downto 0);

      -- FSM output signals

      -- EOP and EOF generated by FSM - this is important when all required
      -- bytes have been processed but the data transfer in FrameLink parts
      -- still continues. FSM will generate EOP for processed data
      -- and disables TX_SRC_RDY with FSM_SRC_RDY. EOF wil be generated
      -- when last part of processed frame is being sent.
      FSM_EOP       : out std_logic;
      FSM_EOF       : out std_logic;
      FSM_SRC_RDY   : out std_logic;

      -- this signal will be used when last part of frame is being processed
      -- but data transfer from source component continues. Apart from
      -- current status of signal TX_DST_RDY, packet shortener will process
      -- remaining bytes from source component
      FSM_DST_RDY   : out std_logic;

		-- REM signal - value of transmitted REM depends on which word
      -- of kept words from given part of frame is being processed
      FSM_REM       : out std_logic_vector(log2(DATA_WIDTH/8)-1 downto 0)
   );
end entity FL_SHORTENER_FSM;


-- ----------------------------------------------------------------------------
--  Architecture declaration: PACKET_SHORTENER_FSM_ARCH
-- ----------------------------------------------------------------------------
architecture FL_SHORTENER_FSM_ARCH of FL_SHORTENER_FSM is
   -- signal declaration
   -- control FSM declaration
   type t_states is (st_idle, st_processing, st_transmission);
   signal present_state, next_state : t_states;

   ----------------------------------------------------------------------------
begin

   -- FSM control process
   fsm_ctrlp : process(CLK, RESET)
   begin
      if (CLK'event and CLK = '1') then
         if (RESET = '1') then
            present_state <= st_processing;
         else
            present_state <= next_state;
         end if;
      end if;
   end process fsm_ctrlp;

   -- FSM next state logic process
   fsm_nslp : process(present_state, EOP, EOF, CNT_EOP, CNT_WORD, SRC_RDY,
                      DST_RDY)
   begin
      next_state <= present_state;

      case present_state is
         -- ST_PROCESSING
         when st_processing =>
            next_state <= st_processing;
            -- source and destination component must be ready for transfer
            if ((SRC_RDY or DST_RDY) = '0') then
               -- change to another state is allowed only when given part
               -- is being processed
               if (CNT_EOP = PART_NUM) then
                  -- checking if EOF is at input must precede checking for EOP!
                  if (EOF = '0') then
                     next_state <= st_processing;
                  -- end of payload
                  elsif (EOP = '0') then
                     next_state <= st_transmission;
                  -- all bytes have been processed, but data transfer from
                  -- source component continues
                  elsif (CNT_WORD = (WORDS_KEPT-1)) then
                     next_state <= st_idle;
                  end if;
               end if;
            end if;

         -- ST_IDLE
         when st_idle =>
            next_state <= st_idle;
            -- source component must be ready
            if (SRC_RDY = '0') then
               -- if EOF from RX interface is active then next state
               -- must be st_processing, checking for EOF must precede
               -- checking for EOP!
               if (EOF = '0') then
                  next_state <= st_processing;
               -- if EOP from RX interface is active then  next state
               -- must be st_transmission
               elsif (EOP = '0') then
                  next_state <= st_transmission;
               end if;
            end if;

         -- ST_TRANSMISSION
         when st_transmission =>
            next_state <= st_transmission;
            -- source and destination component must be ready for transfer
            if ((SRC_RDY or DST_RDY) = '0') then
               -- if EOF from RX interface is active then next state
               -- must be st_processing
               if (EOF = '0') then
                  next_state <= st_processing;
               end if;
            end if;

         when others =>
            null;
      end case;
   end process fsm_nslp;

   -- FSM output logic process
   fsm_olp : process(present_state, CNT_WORD, CNT_EOP, SRC_RDY, DST_RDY, EOP, EOF, DREM)
   begin
      -- default values for output signals
      FSM_EOP       <= EOP;
      FSM_EOF       <= EOF;
      FSM_SRC_RDY   <= SRC_RDY;
      FSM_DST_RDY   <= DST_RDY;
      FSM_REM       <= DREM;

      case present_state is
         -- ST_PROCESS
         when st_processing =>
            -- source and destination component must be ready for transfer
            -- for FSM to control it
            if ((SRC_RDY or DST_RDY) = '0') then
               -- current order number of part of FrameLink frame
               -- is lower than given one, no processing
               -- (independent on EOF or EOP signals)
               if (CNT_EOP < PART_NUM) then
                  null;
               -- current order number of part of FrameLink frame is equal
               -- to the given one (higher value not needed - when
               -- truncation of this part will be finished then state change
               -- will occur)
               else
                  if (CNT_WORD = (WORDS_KEPT-1)) then
                     -- value of REM will be lower from REM computed
                     -- as constant from given number of kept bytes and data
                     -- width and current REM value on input interface if RX_EOP_N
                     -- is active. Else REM is simply REM_CONST.
                     if (EOP = '0') then
                        FSM_REM <= conv_std_logic_vector(min(REM_CONST,
                                                 conv_integer(unsigned(DREM))),
                                                 log2(DATA_WIDTH/8));
                     else
                        FSM_REM <= conv_std_logic_vector(REM_CONST, log2(DATA_WIDTH/8));
                     end if;
                     FSM_EOP <= '0';
                     -- current part being processed is last part in frame
                     -- it is necessary to generate EOF for destination
                     -- component
                     if (CNT_EOP = (PARTS-1)) then
                        FSM_EOF <= '0';
                     end if;
                  end if;
               end if;
            end if;

         -- ST_IDLE
         when st_idle =>
            -- inactive FSM_SRC_RDY will be connected to the TX_SRC_RDY
            FSM_DST_RDY <= '0';
            FSM_SRC_RDY <= '1';

            -- ST_TRANSMISSION
         when st_transmission =>
            -- default FSM command output signals will be used
            null;

         when others =>
            null;
      end case;
   end process fsm_olp;
end architecture FL_SHORTENER_FSM_ARCH;
