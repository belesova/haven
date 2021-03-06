--
-- ib_switch_slave_64.vhd : Internal Bus Slave Switch (data width : 64 bits)
-- Copyright (C) 2008 CESNET
-- Author(s): Tomas Malek <tomalek@liberouter.org>
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

use work.ib_ifc_pkg.all; 
use work.ib_fmt_pkg.all; 
use work.ib_switch_pkg.all; 

-- ----------------------------------------------------------------------------
--       ENTITY DECLARATION -- IB Slave Switch (data width : 64 bits)        -- 
-- ----------------------------------------------------------------------------

entity IB_SWITCH_SLAVE_SIM is
   generic(
      -- The number of headers to be stored
      HEADER_NUM   : integer:=  1
   );   
   port(
      -- Common interface -----------------------------------------------------   
      CLK   : in std_logic; -- FPGA clock
      RESET : in std_logic; -- Reset active high 
 
      -- Upstream Port #0 -----------------------------------------------------
      PORT0_DOWN_DATA        : in  std_logic_vector(63 downto 0);
      PORT0_DOWN_SOF_N       : in  std_logic;
      PORT0_DOWN_EOF_N       : in  std_logic;
      PORT0_DOWN_SRC_RDY_N   : in  std_logic;
      PORT0_DOWN_DST_RDY_N   : out std_logic;
      
      PORT0_UP_DATA          : out std_logic_vector(63 downto 0);
      PORT0_UP_SOF_N         : out std_logic;
      PORT0_UP_EOF_N         : out std_logic;
      PORT0_UP_SRC_RDY_N     : out std_logic;
      PORT0_UP_DST_RDY_N     : in  std_logic;

      -- Downstream Port #1 ---------------------------------------------------
      PORT1_DOWN_DATA        : out std_logic_vector(63 downto 0);
      PORT1_DOWN_SOF_N       : out std_logic;
      PORT1_DOWN_EOF_N       : out std_logic;
      PORT1_DOWN_SRC_RDY_N   : out std_logic;
      PORT1_DOWN_DST_RDY_N   : in  std_logic;
      
      PORT1_UP_DATA          : in  std_logic_vector(63 downto 0);
      PORT1_UP_SOF_N         : in  std_logic;
      PORT1_UP_EOF_N         : in  std_logic;
      PORT1_UP_SRC_RDY_N     : in  std_logic;
      PORT1_UP_DST_RDY_N     : out std_logic;

      -- Downstream Port #2 ---------------------------------------------------
      PORT2_DOWN_DATA        : out std_logic_vector(63 downto 0);
      PORT2_DOWN_SOF_N       : out std_logic;
      PORT2_DOWN_EOF_N       : out std_logic;
      PORT2_DOWN_SRC_RDY_N   : out std_logic;
      PORT2_DOWN_DST_RDY_N   : in  std_logic;
      
      PORT2_UP_DATA          : in  std_logic_vector(63 downto 0);
      PORT2_UP_SOF_N         : in  std_logic;
      PORT2_UP_EOF_N         : in  std_logic;
      PORT2_UP_SRC_RDY_N     : in  std_logic;
      PORT2_UP_DST_RDY_N     : out std_logic  
   );
end entity IB_SWITCH_SLAVE_SIM;

-- ----------------------------------------------------------------------------
--    ARCHITECTURE DECLARATION -- IB Slave Switch (data width : 64 bits)     --
-- ----------------------------------------------------------------------------

architecture ib_switch_slave_sim_arch of IB_SWITCH_SLAVE_SIM is

begin

   U_ib_switch_slave: entity work.IB_SWITCH_SLAVE
   generic map(
      -- Data Width (1-128)
      DATA_WIDTH   => 64,
      -- The number of headers to be stored
      HEADER_NUM   => HEADER_NUM
   )
   port map(
      -- Common interface -----------------------------------------------------
      CLK                  => CLK,   
      RESET                => RESET,
      
      -- Upstream Port #0 -----------------------------------------------------
      PORT0_DOWN_DATA      => PORT0_DOWN_DATA,     
      PORT0_DOWN_SOF_N     => PORT0_DOWN_SOF_N,     
      PORT0_DOWN_EOF_N     => PORT0_DOWN_EOF_N,      
      PORT0_DOWN_SRC_RDY_N => PORT0_DOWN_SRC_RDY_N,  
      PORT0_DOWN_DST_RDY_N => PORT0_DOWN_DST_RDY_N, 
                                    
      PORT0_UP_DATA        => PORT0_UP_DATA,      
      PORT0_UP_SOF_N       => PORT0_UP_SOF_N,      
      PORT0_UP_EOF_N       => PORT0_UP_EOF_N,      
      PORT0_UP_SRC_RDY_N   => PORT0_UP_SRC_RDY_N,  
      PORT0_UP_DST_RDY_N   => PORT0_UP_DST_RDY_N,  

      -- Downstream Port #1 ---------------------------------------------------
      PORT1_DOWN_DATA      => PORT1_DOWN_DATA,     
      PORT1_DOWN_SOF_N     => PORT1_DOWN_SOF_N,      
      PORT1_DOWN_EOF_N     => PORT1_DOWN_EOF_N,      
      PORT1_DOWN_SRC_RDY_N => PORT1_DOWN_SRC_RDY_N,  
      PORT1_DOWN_DST_RDY_N => PORT1_DOWN_DST_RDY_N,  
                                         
      PORT1_UP_DATA        => PORT1_UP_DATA,         
      PORT1_UP_SOF_N       => PORT1_UP_SOF_N,        
      PORT1_UP_EOF_N       => PORT1_UP_EOF_N,        
      PORT1_UP_SRC_RDY_N   => PORT1_UP_SRC_RDY_N,    
      PORT1_UP_DST_RDY_N   => PORT1_UP_DST_RDY_N,    

      -- Downstream Port #2 ---------------------------------------------------
      PORT2_DOWN_DATA      => PORT2_DOWN_DATA,     
      PORT2_DOWN_SOF_N     => PORT2_DOWN_SOF_N,      
      PORT2_DOWN_EOF_N     => PORT2_DOWN_EOF_N,      
      PORT2_DOWN_SRC_RDY_N => PORT2_DOWN_SRC_RDY_N,  
      PORT2_DOWN_DST_RDY_N => PORT2_DOWN_DST_RDY_N,  
                                    
      PORT2_UP_DATA        => PORT2_UP_DATA,         
      PORT2_UP_SOF_N       => PORT2_UP_SOF_N,        
      PORT2_UP_EOF_N       => PORT2_UP_EOF_N,        
      PORT2_UP_SRC_RDY_N   => PORT2_UP_SRC_RDY_N,    
      PORT2_UP_DST_RDY_N   => PORT2_UP_DST_RDY_N    
   );
            
end ib_switch_slave_sim_arch;

                     

