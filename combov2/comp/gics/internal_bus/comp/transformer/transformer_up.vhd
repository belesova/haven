--
-- transformer_up.vhd: Internal Bus Transformer Up
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

-- ----------------------------------------------------------------------------
--                  ENTITY DECLARATION -- IB Transformer Up                  --
-- ---------------------------------------------------------------------------- 

entity IB_TRANSFORMER_UP is
   generic(
      -- Input Data Width (1-64)
      IN_DATA_WIDTH   : integer :=  8;       
      -- Output Data Width (2-128)
      OUT_DATA_WIDTH  : integer := 64;
      -- The length of input buffer (>=0)
      IN_BUFFER_ITEMS : integer :=  0;
      -- Output pipe enable
      OUT_PIPE        : boolean := false
   );   
   port(
      -- Common interface -----------------------------------------------------
      CLK             : in std_logic;
      RESET           : in std_logic;
      
      -- Input interface ------------------------------------------------------
      IN_DATA         : in  std_logic_vector(IN_DATA_WIDTH-1 downto 0);
      IN_SOF_N        : in  std_logic;
      IN_EOF_N        : in  std_logic;
      IN_SRC_RDY_N    : in  std_logic;
      IN_DST_RDY_N    : out std_logic;
 
      -- Output interface -----------------------------------------------------
      OUT_DATA        : out std_logic_vector(OUT_DATA_WIDTH-1 downto 0);
      OUT_SOF_N       : out std_logic;
      OUT_EOF_N       : out std_logic;
      OUT_SRC_RDY_N   : out std_logic;
      OUT_DST_RDY_N   : in  std_logic
   );
end entity IB_TRANSFORMER_UP;



