--
--      Project:  Aurora Module Generator version 2.4
--
--         Date:  $Date$
--          Tag:  $Name:  $
--         File:  $RCSfile: rx_ll.vhd,v $
--          Rev:  $Revision$
--
--      Company:  Xilinx
-- Contributors:  R. K. Awalt, B. L. Woodard, N. Gulstone
--
--   Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
--                INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
--                PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
--                PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
--                ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
--                APPLICATION OR STANDARD, XILINX IS MAKING NO
--                REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
--                FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
--                RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
--                REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
--                EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
--                RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
--                INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
--                REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
--                FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
--                OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
--                PURPOSE.
--
--                (c) Copyright 2004 Xilinx, Inc.
--                All rights reserved.
--

--
--  RX_LL
--
--  Author: Nigel Gulstone
--          Xilinx - Embedded Networking System Engineering Group
--
--  VHDL Translation: Brian Woodard
--                    Xilinx - Garden Valley Design Team
--
--  Description: The RX_LL module receives data from the Aurora Channel,
--               converts it to LocalLink and sends it to the user interface.
--               It also handles NFC and UFC messages.
--
--               This module supports 1 2-byte lane designs.
--
--               This module supports User Flow Control.
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity RX_LL is

    port (

    -- LocalLink PDU Interface

            RX_D             : out std_logic_vector(0 to 15);
            RX_REM           : out std_logic;
            RX_SRC_RDY_N     : out std_logic;
            RX_SOF_N         : out std_logic;
            RX_EOF_N         : out std_logic;

    -- UFC Interface

            UFC_RX_DATA      : out std_logic_vector(0 to 15);
            UFC_RX_REM       : out std_logic;
            UFC_RX_SRC_RDY_N : out std_logic;
            UFC_RX_SOF_N     : out std_logic;
            UFC_RX_EOF_N     : out std_logic;

    -- Global Logic Interface

            START_RX         : in std_logic;

    -- Aurora Lane Interface

            RX_PAD           : in std_logic;
            RX_PE_DATA       : in std_logic_vector(0 to 15);
            RX_PE_DATA_V     : in std_logic;
            RX_SCP           : in std_logic;
            RX_ECP           : in std_logic;
            RX_SUF           : in std_logic;
            RX_FC_NB         : in std_logic_vector(0 to 3);

    -- Error Interface

            FRAME_ERROR      : out std_logic;

    -- System Interface

            USER_CLK         : in std_logic

         );

end RX_LL;

architecture MAPPED of RX_LL is

-- External Register Declarations --

    signal RX_D_Buffer             : std_logic_vector(0 to 15);
    signal RX_REM_Buffer           : std_logic;
    signal RX_SRC_RDY_N_Buffer     : std_logic;
    signal RX_SOF_N_Buffer         : std_logic;
    signal RX_EOF_N_Buffer         : std_logic;
    signal UFC_RX_DATA_Buffer      : std_logic_vector(0 to 15);
    signal UFC_RX_REM_Buffer       : std_logic;
    signal UFC_RX_SRC_RDY_N_Buffer : std_logic;
    signal UFC_RX_SOF_N_Buffer     : std_logic;
    signal UFC_RX_EOF_N_Buffer     : std_logic;
    signal FRAME_ERROR_Buffer      : std_logic;

-- Wire Declarations --

    signal pdu_pad_i           : std_logic;
    signal pdu_data_i          : std_logic_vector(0 to 15);
    signal pdu_data_v_i        : std_logic;
    signal pdu_scp_i           : std_logic;
    signal pdu_ecp_i           : std_logic;
    signal ufc_message_start_i : std_logic;
    signal ufc_data_i          : std_logic_vector(0 to 15);
    signal ufc_data_v_i        : std_logic;
    signal ufc_start_i         : std_logic;

    signal start_rx_i          : std_logic;

-- Component Declarations --

    component UFC_FILTER

        port (

        -- Aurora Channel Interface

                RX_PAD            : in std_logic;
                RX_PE_DATA        : in std_logic_vector(0 to 15);
                RX_PE_DATA_V      : in std_logic;
                RX_SCP            : in std_logic;
                RX_ECP            : in std_logic;
                RX_SUF            : in std_logic;
                RX_FC_NB          : in std_logic_vector(0 to 3);

        -- PDU Datapath Interface

                PDU_DATA          : out std_logic_vector(0 to 15);
                PDU_DATA_V        : out std_logic;
                PDU_PAD           : out std_logic;
                PDU_SCP           : out std_logic;
                PDU_ECP           : out std_logic;

        -- UFC Datapath Interface

                UFC_DATA          : out std_logic_vector(0 to 15);
                UFC_DATA_V        : out std_logic;
                UFC_MESSAGE_START : out std_logic;
                UFC_START         : out std_logic;

        -- System Interface

                USER_CLK          : in std_logic;
                RESET             : in std_logic

             );

    end component;


    component RX_LL_PDU_DATAPATH

        port (

        -- Traffic Separator Interface

                PDU_DATA     : in std_logic_vector(0 to 15);
                PDU_DATA_V   : in std_logic;
                PDU_PAD      : in std_logic;
                PDU_SCP      : in std_logic;
                PDU_ECP      : in std_logic;

        -- LocalLink PDU Interface

                RX_D         : out std_logic_vector(0 to 15);
                RX_REM       : out std_logic;
                RX_SRC_RDY_N : out std_logic;
                RX_SOF_N     : out std_logic;
                RX_EOF_N     : out std_logic;

        -- Error Interface

                FRAME_ERROR  : out std_logic;

        -- System Interface

                USER_CLK     : in std_logic;
                RESET        : in std_logic

             );

    end component;


    component RX_LL_UFC_DATAPATH

        port (

        --Traffic Separator Interface

                UFC_DATA          : in std_logic_vector(0 to 15);
                UFC_DATA_V        : in std_logic;
                UFC_MESSAGE_START : in std_logic;
                UFC_START         : in std_logic;

        --LocalLink UFC Interface

                UFC_RX_DATA       : out std_logic_vector(0 to 15);
                UFC_RX_REM        : out std_logic;
                UFC_RX_SRC_RDY_N  : out std_logic;
                UFC_RX_SOF_N      : out std_logic;
                UFC_RX_EOF_N      : out std_logic;

        --System Interface

                USER_CLK          : in std_logic;
                RESET             : in std_logic

             );

    end component;


begin

    RX_D             <= RX_D_Buffer;
    RX_REM           <= RX_REM_Buffer;
    RX_SRC_RDY_N     <= RX_SRC_RDY_N_Buffer;
    RX_SOF_N         <= RX_SOF_N_Buffer;
    RX_EOF_N         <= RX_EOF_N_Buffer;
    UFC_RX_DATA      <= UFC_RX_DATA_Buffer;
    UFC_RX_REM       <= UFC_RX_REM_Buffer;
    UFC_RX_SRC_RDY_N <= UFC_RX_SRC_RDY_N_Buffer;
    UFC_RX_SOF_N     <= UFC_RX_SOF_N_Buffer;
    UFC_RX_EOF_N     <= UFC_RX_EOF_N_Buffer;
    FRAME_ERROR      <= FRAME_ERROR_Buffer;

    start_rx_i       <= not START_RX;

-- Main Body of Code --

    -- Separate UFC traffic from regular data --

    ufc_filter_i : UFC_FILTER

        port map (

        -- Aurora Channel Interface

                    RX_PAD            => RX_PAD,
                    RX_PE_DATA        => RX_PE_DATA,
                    RX_PE_DATA_V      => RX_PE_DATA_V,
                    RX_SCP            => RX_SCP,
                    RX_ECP            => RX_ECP,
                    RX_SUF            => RX_SUF,
                    RX_FC_NB          => RX_FC_NB,

        -- PDU Datapath Interface

                    PDU_DATA          => pdu_data_i,
                    PDU_DATA_V        => pdu_data_v_i,
                    PDU_PAD           => pdu_pad_i,
                    PDU_SCP           => pdu_scp_i,
                    PDU_ECP           => pdu_ecp_i,

        -- UFC Datapath Interface

                    UFC_DATA          => ufc_data_i,
                    UFC_DATA_V        => ufc_data_v_i,
                    UFC_MESSAGE_START => ufc_message_start_i,
                    UFC_START         => ufc_start_i,

        -- System Interface

                    USER_CLK          => USER_CLK,
                    RESET             => start_rx_i

                 );


    -- Datapath for user PDUs --

    rx_ll_pdu_datapath_i : RX_LL_PDU_DATAPATH

        port map (

        -- Traffic Separator Interface

                    PDU_DATA     => pdu_data_i,
                    PDU_DATA_V   => pdu_data_v_i,
                    PDU_PAD      => pdu_pad_i,
                    PDU_SCP      => pdu_scp_i,
                    PDU_ECP      => pdu_ecp_i,

        -- LocalLink PDU Interface

                    RX_D         => RX_D_Buffer,
                    RX_REM       => RX_REM_Buffer,
                    RX_SRC_RDY_N => RX_SRC_RDY_N_Buffer,
                    RX_SOF_N     => RX_SOF_N_Buffer,
                    RX_EOF_N     => RX_EOF_N_Buffer,

        -- Error Interface

                    FRAME_ERROR  => FRAME_ERROR_Buffer,

        -- System Interface

                    USER_CLK     => USER_CLK,
                    RESET        => start_rx_i

                 );


    -- Datapath for UFC PDUs --

    rx_ll_ufc_datapath_i : RX_LL_UFC_DATAPATH

        port map (

        -- Traffic Separator Interface

                    UFC_DATA          => ufc_data_i,
                    UFC_DATA_V        => ufc_data_v_i,
                    UFC_MESSAGE_START => ufc_message_start_i,
                    UFC_START         => ufc_start_i,

        -- LocalLink PDU Interface

                    UFC_RX_DATA       => UFC_RX_DATA_Buffer,
                    UFC_RX_REM        => UFC_RX_REM_Buffer,
                    UFC_RX_SRC_RDY_N  => UFC_RX_SRC_RDY_N_Buffer,
                    UFC_RX_SOF_N      => UFC_RX_SOF_N_Buffer,
                    UFC_RX_EOF_N      => UFC_RX_EOF_N_Buffer,

        -- System Interface

                    USER_CLK          => USER_CLK,
                    RESET             => start_rx_i

                 );


end MAPPED;
