--if you want to modify channel
--just modify component of transceiver(xcvr)

--!! warning !!
--user need to see "DataStruct_param_def_header.vhd"
--most important of typedef and parameter in here
--!! warning !!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;

library work;
use work.DataStruct_param_def_header.all;--invoke our defined type and parameter

entity XCVR_8B10B_interconnect is
    port (
        RST_N                       : in  std_logic;

        TX_para_external_ch         : in  para_data_men;
        RX_para_external_ch         : out para_data_men;
        TX_para_external_clk_ch     : out ser_data_men;
        RX_para_external_clk_ch     : out ser_data_men;
        tx_traffic_ready_ext_ch     : out std_logic;
        rx_traffic_ready_ext_ch     : out std_logic;
        
        error_cnt_ch                : out para_data_men;

        XCVR_Ref_Clock              : in  std_logic;
        --init_clock                  : in  std_logic;

        RX_ser                      : in  ser_data_men;
        TX_ser                      : out ser_data_men
    );
end entity XCVR_8B10B_interconnect ;


architecture Top of XCVR_8B10B_interconnect is
    --clock
    signal tx_clk_buf_out               		    : ser_data_men := (others =>'0');
    signal rx_clk_buf_out               		    : ser_data_men := (others =>'0');
    signal XCVR_Tx_clk_out_ch                       : ser_data_men := (others =>'0');
    signal XCVR_Rx_clk_out_ch                       : ser_data_men := (others =>'0');
    signal tx_clk_buf_out_to_ext                    : ser_data_men := (others =>'0');
    signal rx_clk_buf_out_to_ext                    : ser_data_men := (others =>'0');
    signal Ref_Clock_buf_to_XCVR_module			    : std_logic;
    --==================--
    ----data gen/check----
    --==================--
    --loopback_en
    signal internal_loopback_en_ch       : ser_data_men := (others =>'0');

    --para data
    signal tx_Para_data_ch               : para_data_men;
    signal rx_Para_data_ch               : para_data_men;

    signal tx_Para_data_internal_ch      : para_data_men;
    signal rx_Para_data_internal_ch      : para_data_men;

    signal xcvr_tx_Para_data_ch          : para_data_men;
    signal xcvr_rx_Para_data_ch          : para_data_men;

    --ready
    signal lane_up       : std_logic;

    signal TX_traffic_ready_ch           : ser_data_men;
    signal RX_traffic_ready_ch           : ser_data_men;
    signal TX_traffic_ready_buf_ch       : std_logic := '0';
    signal RX_traffic_ready_buf_ch       : std_logic := '0';

    signal tx_traffic_ready_internal_ch  : std_logic;
    signal rx_traffic_ready_internal_ch  : std_logic;

    signal XCVR_TX_ready_ch      : ser_data_men := (others =>'0'); --arria10
    signal XCVR_RX_ready_ch      : ser_data_men := (others =>'0'); --arria10
    --===============--
    ----transceiver----
    --===============--
    --controlled data
    signal rx_disp_err_ch           : ctrl_code_8B10B;
    signal rx_err_detec_ch          : ctrl_code_8B10B;

    signal rx_data_k_ch             : ctrl_code_8B10B;
    signal tx_data_k_ch             : ctrl_code_8B10B;

    signal rx_patterndetect_ch      : ctrl_code_8B10B; --arria10
    signal rx_syncstatus_ch         : ctrl_code_8B10B; --arria10
    signal rx_runningdisp_ch        : ctrl_code_8B10B; --arria10

    signal rx_std_wa_patternalign   : std_logic;--arria10
    signal XCVR_TxRx_rst : std_logic;
    --for grouping
    signal rx_Para_data_from_sync_buf_ch    : para_data_men ;
    signal rx_Para_data_to_sync_buf_ch      : para_data_men ;
    signal elastic_buf_sync_done            : ser_data_men := (others =>'0');
    signal elastic_can_start_sync           : ser_data_men := (others =>'0');
    signal sync_buf_overflow_ch_01          : std_logic := '0';
    signal sync_buf_sync_done_ch_01         : std_logic := '0';
    signal sync_buf_overflow_ch_23          : std_logic := '0';
    signal sync_buf_sync_done_ch_23         : std_logic := '0';
    signal elastic_buf_overflow             : std_logic := '0';
    
	component xcvr_8B10B is
		port (
			clk_clk                                                             : in  std_logic                      := 'X';             -- clk
			reset_reset_n                                                       : in  std_logic                      := 'X';             -- reset_n
			xcvr_native_a10_0_rx_clkout_ch0_clk                                 : out std_logic;                                         -- clk
			xcvr_native_a10_0_rx_clkout_ch1_clk                                 : out std_logic;                                         -- clk
			xcvr_native_a10_0_rx_clkout_ch2_clk                                 : out std_logic;                                         -- clk
			xcvr_native_a10_0_rx_clkout_ch3_clk                                 : out std_logic;                                         -- clk
			xcvr_native_a10_0_rx_coreclkin_ch0_clk                              : in  std_logic                      := 'X';             -- clk
			xcvr_native_a10_0_rx_coreclkin_ch1_clk                              : in  std_logic                      := 'X';             -- clk
			xcvr_native_a10_0_rx_coreclkin_ch2_clk                              : in  std_logic                      := 'X';             -- clk
			xcvr_native_a10_0_rx_coreclkin_ch3_clk                              : in  std_logic                      := 'X';             -- clk
			xcvr_native_a10_0_rx_datak_ch0_rx_datak                             : out std_logic_vector(1 downto 0);                      -- rx_datak
			xcvr_native_a10_0_rx_datak_ch1_rx_datak                             : out std_logic_vector(1 downto 0);                      -- rx_datak
			xcvr_native_a10_0_rx_datak_ch2_rx_datak                             : out std_logic_vector(1 downto 0);                      -- rx_datak
			xcvr_native_a10_0_rx_datak_ch3_rx_datak                             : out std_logic_vector(1 downto 0);                      -- rx_datak
			xcvr_native_a10_0_rx_disperr_ch0_rx_disperr                         : out std_logic_vector(1 downto 0);                      -- rx_disperr
			xcvr_native_a10_0_rx_disperr_ch1_rx_disperr                         : out std_logic_vector(1 downto 0);                      -- rx_disperr
			xcvr_native_a10_0_rx_disperr_ch2_rx_disperr                         : out std_logic_vector(1 downto 0);                      -- rx_disperr
			xcvr_native_a10_0_rx_disperr_ch3_rx_disperr                         : out std_logic_vector(1 downto 0);                      -- rx_disperr
			xcvr_native_a10_0_rx_errdetect_ch0_rx_errdetect                     : out std_logic_vector(1 downto 0);                      -- rx_errdetect
			xcvr_native_a10_0_rx_errdetect_ch1_rx_errdetect                     : out std_logic_vector(1 downto 0);                      -- rx_errdetect
			xcvr_native_a10_0_rx_errdetect_ch2_rx_errdetect                     : out std_logic_vector(1 downto 0);                      -- rx_errdetect
			xcvr_native_a10_0_rx_errdetect_ch3_rx_errdetect                     : out std_logic_vector(1 downto 0);                      -- rx_errdetect
			xcvr_native_a10_0_rx_parallel_data_ch0_rx_parallel_data             : out std_logic_vector(15 downto 0);                     -- rx_parallel_data
			xcvr_native_a10_0_rx_parallel_data_ch1_rx_parallel_data             : out std_logic_vector(15 downto 0);                     -- rx_parallel_data
			xcvr_native_a10_0_rx_parallel_data_ch2_rx_parallel_data             : out std_logic_vector(15 downto 0);                     -- rx_parallel_data
			xcvr_native_a10_0_rx_parallel_data_ch3_rx_parallel_data             : out std_logic_vector(15 downto 0);                     -- rx_parallel_data
			xcvr_native_a10_0_rx_patterndetect_ch0_rx_patterndetect             : out std_logic_vector(1 downto 0);                      -- rx_patterndetect
			xcvr_native_a10_0_rx_patterndetect_ch1_rx_patterndetect             : out std_logic_vector(1 downto 0);                      -- rx_patterndetect
			xcvr_native_a10_0_rx_patterndetect_ch2_rx_patterndetect             : out std_logic_vector(1 downto 0);                      -- rx_patterndetect
			xcvr_native_a10_0_rx_patterndetect_ch3_rx_patterndetect             : out std_logic_vector(1 downto 0);                      -- rx_patterndetect
			xcvr_native_a10_0_rx_runningdisp_ch0_rx_runningdisp                 : out std_logic_vector(1 downto 0);                      -- rx_runningdisp
			xcvr_native_a10_0_rx_runningdisp_ch1_rx_runningdisp                 : out std_logic_vector(1 downto 0);                      -- rx_runningdisp
			xcvr_native_a10_0_rx_runningdisp_ch2_rx_runningdisp                 : out std_logic_vector(1 downto 0);                      -- rx_runningdisp
			xcvr_native_a10_0_rx_runningdisp_ch3_rx_runningdisp                 : out std_logic_vector(1 downto 0);                      -- rx_runningdisp
			xcvr_native_a10_0_rx_serial_data_ch0_rx_serial_data                 : in  std_logic                      := 'X';             -- rx_serial_data
			xcvr_native_a10_0_rx_serial_data_ch1_rx_serial_data                 : in  std_logic                      := 'X';             -- rx_serial_data
			xcvr_native_a10_0_rx_serial_data_ch2_rx_serial_data                 : in  std_logic                      := 'X';             -- rx_serial_data
			xcvr_native_a10_0_rx_serial_data_ch3_rx_serial_data                 : in  std_logic                      := 'X';             -- rx_serial_data
			xcvr_native_a10_0_rx_seriallpbken_ch0_rx_seriallpbken               : in  std_logic                      := 'X';             -- rx_seriallpbken
			xcvr_native_a10_0_rx_seriallpbken_ch1_rx_seriallpbken               : in  std_logic                      := 'X';             -- rx_seriallpbken
			xcvr_native_a10_0_rx_seriallpbken_ch2_rx_seriallpbken               : in  std_logic                      := 'X';             -- rx_seriallpbken
			xcvr_native_a10_0_rx_seriallpbken_ch3_rx_seriallpbken               : in  std_logic                      := 'X';             -- rx_seriallpbken
			xcvr_native_a10_0_rx_std_wa_patternalign_ch0_rx_std_wa_patternalign : in  std_logic                      := 'X';             -- rx_std_wa_patternalign
			xcvr_native_a10_0_rx_std_wa_patternalign_ch1_rx_std_wa_patternalign : in  std_logic                      := 'X';             -- rx_std_wa_patternalign
			xcvr_native_a10_0_rx_std_wa_patternalign_ch2_rx_std_wa_patternalign : in  std_logic                      := 'X';             -- rx_std_wa_patternalign
			xcvr_native_a10_0_rx_std_wa_patternalign_ch3_rx_std_wa_patternalign : in  std_logic                      := 'X';             -- rx_std_wa_patternalign
			xcvr_native_a10_0_rx_syncstatus_ch0_rx_syncstatus                   : out std_logic_vector(1 downto 0);                      -- rx_syncstatus
			xcvr_native_a10_0_rx_syncstatus_ch1_rx_syncstatus                   : out std_logic_vector(1 downto 0);                      -- rx_syncstatus
			xcvr_native_a10_0_rx_syncstatus_ch2_rx_syncstatus                   : out std_logic_vector(1 downto 0);                      -- rx_syncstatus
			xcvr_native_a10_0_rx_syncstatus_ch3_rx_syncstatus                   : out std_logic_vector(1 downto 0);                      -- rx_syncstatus
			xcvr_native_a10_0_tx_clkout_ch0_clk                                 : out std_logic;                                         -- clk
			xcvr_native_a10_0_tx_clkout_ch1_clk                                 : out std_logic;                                         -- clk
			xcvr_native_a10_0_tx_clkout_ch2_clk                                 : out std_logic;                                         -- clk
			xcvr_native_a10_0_tx_clkout_ch3_clk                                 : out std_logic;                                         -- clk
			xcvr_native_a10_0_tx_coreclkin_ch0_clk                              : in  std_logic                      := 'X';             -- clk
			xcvr_native_a10_0_tx_coreclkin_ch1_clk                              : in  std_logic                      := 'X';             -- clk
			xcvr_native_a10_0_tx_coreclkin_ch2_clk                              : in  std_logic                      := 'X';             -- clk
			xcvr_native_a10_0_tx_coreclkin_ch3_clk                              : in  std_logic                      := 'X';             -- clk
			xcvr_native_a10_0_tx_datak_ch0_tx_datak                             : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- tx_datak
			xcvr_native_a10_0_tx_datak_ch1_tx_datak                             : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- tx_datak
			xcvr_native_a10_0_tx_datak_ch2_tx_datak                             : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- tx_datak
			xcvr_native_a10_0_tx_datak_ch3_tx_datak                             : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- tx_datak
			xcvr_native_a10_0_tx_parallel_data_ch0_tx_parallel_data             : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- tx_parallel_data
			xcvr_native_a10_0_tx_parallel_data_ch1_tx_parallel_data             : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- tx_parallel_data
			xcvr_native_a10_0_tx_parallel_data_ch2_tx_parallel_data             : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- tx_parallel_data
			xcvr_native_a10_0_tx_parallel_data_ch3_tx_parallel_data             : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- tx_parallel_data
			xcvr_native_a10_0_tx_serial_data_ch0_tx_serial_data                 : out std_logic;                                         -- tx_serial_data
			xcvr_native_a10_0_tx_serial_data_ch1_tx_serial_data                 : out std_logic;                                         -- tx_serial_data
			xcvr_native_a10_0_tx_serial_data_ch2_tx_serial_data                 : out std_logic;                                         -- tx_serial_data
			xcvr_native_a10_0_tx_serial_data_ch3_tx_serial_data                 : out std_logic;                                         -- tx_serial_data
			xcvr_native_a10_0_unused_rx_parallel_data_unused_rx_parallel_data   : out std_logic_vector(399 downto 0);                    -- unused_rx_parallel_data
			xcvr_native_a10_0_unused_tx_parallel_data_unused_tx_parallel_data   : in  std_logic_vector(439 downto 0) := (others => 'X'); -- unused_tx_parallel_data
			xcvr_reset_control_0_pll_select_pll_select                          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- pll_select
			xcvr_reset_control_0_reset_reset                                    : in  std_logic                      := 'X';             -- reset
			xcvr_reset_control_0_rx_ready0_rx_ready                             : out std_logic;                                         -- rx_ready
			xcvr_reset_control_0_rx_ready1_rx_ready                             : out std_logic;                                         -- rx_ready
			xcvr_reset_control_0_rx_ready2_rx_ready                             : out std_logic;                                         -- rx_ready
			xcvr_reset_control_0_rx_ready3_rx_ready                             : out std_logic;                                         -- rx_ready
			xcvr_reset_control_0_tx_ready0_tx_ready                             : out std_logic;                                         -- tx_ready
			xcvr_reset_control_0_tx_ready1_tx_ready                             : out std_logic;                                         -- tx_ready
			xcvr_reset_control_0_tx_ready2_tx_ready                             : out std_logic;                                         -- tx_ready
			xcvr_reset_control_0_tx_ready3_tx_ready                             : out std_logic;                                         -- tx_ready
			xcvr_reset_control_0_clock_clk                                      : in  std_logic                      := 'X'              -- clk
		);
	end component xcvr_8B10B;
    
    --clk buffer
    component clk_buffer is
        port (
            inclk  : in  std_logic := 'X'; -- inclk
            outclk : out std_logic         -- outclk
        );
    end component clk_buffer;

begin
    --connect loopback_en
    internal_loopback_en_ch <= (others =>'1') when xcvr_ser_internal_loopback_en = '1' else (others =>'0');

    --connecte para data with internal/external selector
    tx_Para_data_ch <= tx_Para_data_internal_ch when scr_para_Data_gen_check_form_this_module = '1';
    tx_Para_data_ch <= TX_para_external_ch      when scr_para_Data_gen_check_form_this_module = '0';

    rx_Para_data_ch <= rx_Para_data_from_sync_buf_ch;

    rx_Para_data_internal_ch <= rx_Para_data_ch when scr_para_Data_gen_check_form_this_module = '1';
    RX_para_external_ch      <= rx_Para_data_ch when scr_para_Data_gen_check_form_this_module = '0';

    TX_para_external_clk_ch <= tx_clk_buf_out when scr_para_Data_gen_check_form_this_module = '0';
    RX_para_external_clk_ch <= rx_clk_buf_out when scr_para_Data_gen_check_form_this_module = '0';
    
    RX_traffic_ready_buf_ch <= and_reduce(RX_traffic_ready_ch);
    TX_traffic_ready_buf_ch <= and_reduce(TX_traffic_ready_ch);
    --ready-ext
    rx_traffic_ready_ext_ch <= RX_traffic_ready_buf_ch when scr_para_Data_gen_check_form_this_module = '0';
    tx_traffic_ready_ext_ch <= TX_traffic_ready_buf_ch when scr_para_Data_gen_check_form_this_module = '0';
    --ready-int
    rx_traffic_ready_internal_ch <= RX_traffic_ready_buf_ch  when scr_para_Data_gen_check_form_this_module = '1';
    tx_traffic_ready_internal_ch <= TX_traffic_ready_buf_ch  when scr_para_Data_gen_check_form_this_module = '1';


    --XCVR module connect
    XCVR : xcvr_8B10B
    port map(
        clk_clk                                                   => XCVR_Ref_Clock,
        reset_reset_n                                             => RST_N,

        xcvr_reset_control_0_clock_clk                            => XCVR_Ref_Clock,

        xcvr_native_a10_0_rx_clkout_ch0_clk                       => XCVR_Rx_clk_out_ch(0),
        xcvr_native_a10_0_rx_clkout_ch1_clk                       => XCVR_Rx_clk_out_ch(1),
        xcvr_native_a10_0_rx_clkout_ch2_clk                       => XCVR_Rx_clk_out_ch(2),
        xcvr_native_a10_0_rx_clkout_ch3_clk                       => XCVR_Rx_clk_out_ch(3),

        xcvr_native_a10_0_rx_coreclkin_ch0_clk                    => rx_clk_buf_out(0),
        xcvr_native_a10_0_rx_coreclkin_ch1_clk                    => rx_clk_buf_out(1),
        xcvr_native_a10_0_rx_coreclkin_ch2_clk                    => rx_clk_buf_out(2),
        xcvr_native_a10_0_rx_coreclkin_ch3_clk                    => rx_clk_buf_out(3),

        xcvr_native_a10_0_rx_datak_ch0_rx_datak                   => rx_data_k_ch(0),
        xcvr_native_a10_0_rx_datak_ch1_rx_datak                   => rx_data_k_ch(1),
        xcvr_native_a10_0_rx_datak_ch2_rx_datak                   => rx_data_k_ch(2),
        xcvr_native_a10_0_rx_datak_ch3_rx_datak                   => rx_data_k_ch(3),

        xcvr_native_a10_0_rx_disperr_ch0_rx_disperr               => rx_disp_err_ch(0),
        xcvr_native_a10_0_rx_disperr_ch1_rx_disperr               => rx_disp_err_ch(1),
        xcvr_native_a10_0_rx_disperr_ch2_rx_disperr               => rx_disp_err_ch(2),
        xcvr_native_a10_0_rx_disperr_ch3_rx_disperr               => rx_disp_err_ch(3),

        xcvr_native_a10_0_rx_errdetect_ch0_rx_errdetect           => rx_err_detec_ch(0),
        xcvr_native_a10_0_rx_errdetect_ch1_rx_errdetect           => rx_err_detec_ch(1),
        xcvr_native_a10_0_rx_errdetect_ch2_rx_errdetect           => rx_err_detec_ch(2),
        xcvr_native_a10_0_rx_errdetect_ch3_rx_errdetect           => rx_err_detec_ch(3),

        xcvr_native_a10_0_rx_parallel_data_ch0_rx_parallel_data   => xcvr_rx_Para_data_ch(0),
        xcvr_native_a10_0_rx_parallel_data_ch1_rx_parallel_data   => xcvr_rx_Para_data_ch(1),
        xcvr_native_a10_0_rx_parallel_data_ch2_rx_parallel_data   => xcvr_rx_Para_data_ch(2),
        xcvr_native_a10_0_rx_parallel_data_ch3_rx_parallel_data   => xcvr_rx_Para_data_ch(3),

        xcvr_native_a10_0_rx_patterndetect_ch0_rx_patterndetect   => rx_patterndetect_ch(0),
        xcvr_native_a10_0_rx_patterndetect_ch1_rx_patterndetect   => rx_patterndetect_ch(1),
        xcvr_native_a10_0_rx_patterndetect_ch2_rx_patterndetect   => rx_patterndetect_ch(2),
        xcvr_native_a10_0_rx_patterndetect_ch3_rx_patterndetect   => rx_patterndetect_ch(3),

        xcvr_native_a10_0_rx_runningdisp_ch0_rx_runningdisp       => rx_runningdisp_ch(0),
        xcvr_native_a10_0_rx_runningdisp_ch1_rx_runningdisp       => rx_runningdisp_ch(1),
        xcvr_native_a10_0_rx_runningdisp_ch2_rx_runningdisp       => rx_runningdisp_ch(2),
        xcvr_native_a10_0_rx_runningdisp_ch3_rx_runningdisp       => rx_runningdisp_ch(3),

        xcvr_native_a10_0_rx_serial_data_ch0_rx_serial_data       => RX_ser(0),
        xcvr_native_a10_0_rx_serial_data_ch1_rx_serial_data       => RX_ser(1),
        xcvr_native_a10_0_rx_serial_data_ch2_rx_serial_data       => RX_ser(2),
        xcvr_native_a10_0_rx_serial_data_ch3_rx_serial_data       => RX_ser(3),

        xcvr_native_a10_0_rx_seriallpbken_ch0_rx_seriallpbken     => internal_loopback_en_ch(0),
        xcvr_native_a10_0_rx_seriallpbken_ch1_rx_seriallpbken     => internal_loopback_en_ch(1),
        xcvr_native_a10_0_rx_seriallpbken_ch2_rx_seriallpbken     => internal_loopback_en_ch(2),
        xcvr_native_a10_0_rx_seriallpbken_ch3_rx_seriallpbken     => internal_loopback_en_ch(3),

		xcvr_native_a10_0_rx_std_wa_patternalign_ch0_rx_std_wa_patternalign    => rx_std_wa_patternalign,
		xcvr_native_a10_0_rx_std_wa_patternalign_ch1_rx_std_wa_patternalign    => rx_std_wa_patternalign,
		xcvr_native_a10_0_rx_std_wa_patternalign_ch2_rx_std_wa_patternalign    => rx_std_wa_patternalign,
		xcvr_native_a10_0_rx_std_wa_patternalign_ch3_rx_std_wa_patternalign    => rx_std_wa_patternalign,

        xcvr_native_a10_0_rx_syncstatus_ch0_rx_syncstatus         => rx_syncstatus_ch(0),
        xcvr_native_a10_0_rx_syncstatus_ch1_rx_syncstatus         => rx_syncstatus_ch(1),
        xcvr_native_a10_0_rx_syncstatus_ch2_rx_syncstatus         => rx_syncstatus_ch(2),
        xcvr_native_a10_0_rx_syncstatus_ch3_rx_syncstatus         => rx_syncstatus_ch(3),

        xcvr_native_a10_0_tx_clkout_ch0_clk                       => XCVR_Tx_clk_out_ch(0),
        xcvr_native_a10_0_tx_clkout_ch1_clk                       => XCVR_Tx_clk_out_ch(1),
        xcvr_native_a10_0_tx_clkout_ch2_clk                       => XCVR_Tx_clk_out_ch(2),
        xcvr_native_a10_0_tx_clkout_ch3_clk                       => XCVR_Tx_clk_out_ch(3),

        xcvr_native_a10_0_tx_coreclkin_ch0_clk                    => tx_clk_buf_out(0),
        xcvr_native_a10_0_tx_coreclkin_ch1_clk                    => tx_clk_buf_out(1),
        xcvr_native_a10_0_tx_coreclkin_ch2_clk                    => tx_clk_buf_out(2),
        xcvr_native_a10_0_tx_coreclkin_ch3_clk                    => tx_clk_buf_out(3),

        xcvr_native_a10_0_tx_datak_ch0_tx_datak                   => tx_data_k_ch(0),
        xcvr_native_a10_0_tx_datak_ch1_tx_datak                   => tx_data_k_ch(1),
        xcvr_native_a10_0_tx_datak_ch2_tx_datak                   => tx_data_k_ch(2),
        xcvr_native_a10_0_tx_datak_ch3_tx_datak                   => tx_data_k_ch(3),

        xcvr_native_a10_0_tx_parallel_data_ch0_tx_parallel_data   => xcvr_tx_Para_data_ch(0),
        xcvr_native_a10_0_tx_parallel_data_ch1_tx_parallel_data   => xcvr_tx_Para_data_ch(1),
        xcvr_native_a10_0_tx_parallel_data_ch2_tx_parallel_data   => xcvr_tx_Para_data_ch(2),
        xcvr_native_a10_0_tx_parallel_data_ch3_tx_parallel_data   => xcvr_tx_Para_data_ch(3),

        xcvr_native_a10_0_tx_serial_data_ch0_tx_serial_data       => Tx_ser(0),
        xcvr_native_a10_0_tx_serial_data_ch1_tx_serial_data       => Tx_ser(1),
        xcvr_native_a10_0_tx_serial_data_ch2_tx_serial_data       => Tx_ser(2),
        xcvr_native_a10_0_tx_serial_data_ch3_tx_serial_data       => Tx_ser(3),

        xcvr_reset_control_0_pll_select_pll_select                => (others => '0'),

        xcvr_reset_control_0_reset_reset                          => (XCVR_TxRx_rst or (not RST_N)),

        xcvr_reset_control_0_rx_ready0_rx_ready                   => XCVR_RX_ready_ch(0),
        xcvr_reset_control_0_rx_ready1_rx_ready                   => XCVR_RX_ready_ch(1),
        xcvr_reset_control_0_rx_ready2_rx_ready                   => XCVR_RX_ready_ch(2),
        xcvr_reset_control_0_rx_ready3_rx_ready                   => XCVR_RX_ready_ch(3),

        xcvr_reset_control_0_tx_ready0_tx_ready                   => XCVR_TX_ready_ch(0),
        xcvr_reset_control_0_tx_ready1_tx_ready                   => XCVR_TX_ready_ch(1),
        xcvr_reset_control_0_tx_ready2_tx_ready                   => XCVR_TX_ready_ch(2),
        xcvr_reset_control_0_tx_ready3_tx_ready                   => XCVR_TX_ready_ch(3)

        --xcvr_atx_pll_a10_0_mcgb_rst_mcgb_rst                      => '0'
    );

    --others connect
    Data_gen_loop : for i in 0 to (num_of_xcvr_ch - 1) generate
        judg_if_data_is_internal : if scr_para_Data_gen_check_form_this_module = '1' generate
			  Data_gen : entity work.frame_gen
					port map(
						 TX_D             => tx_Para_data_internal_ch(i),

						 TX_traffic_ready => tx_traffic_ready_internal_ch,

						 USER_CLK         => tx_clk_buf_out(i) ,
						 SYSTEM_RESET_N   => RST_N
					);
        end generate judg_if_data_is_internal;
    end generate Data_gen_loop;

    Data_check_loop : for i in 0 to (num_of_xcvr_ch - 1) generate
        judg_if_data_is_internal : if scr_para_Data_gen_check_form_this_module = '1' generate
			  Data_check : entity work.frame_check
					port map(
						 RX_D              => rx_Para_data_internal_ch(i),

						 RX_traffic_ready  => rx_traffic_ready_internal_ch,

						 RX_errdetect      => rx_err_detec_ch(i),
						 RX_disperr        => rx_disp_err_ch(i),

						 ERROR_COUNT       => error_cnt_ch(i),

						 USER_CLK          => rx_clk_buf_out(i),
						 SYSTEM_RESET_N    => RST_N
					);
        end generate judg_if_data_is_internal;
    end generate Data_check_loop;

    generate_traffic_loop : for i in 0 to (num_of_xcvr_ch - 1) generate
        traffic : entity work.traffic
            port map(
                Reset_n                  => RST_N,
                lane_up                  => lane_up,

                tx_traffic_ready         => TX_traffic_ready_ch(i),
                rx_traffic_ready         => RX_traffic_ready_ch(i),

                rx_elastic_buf_sync_done => elastic_buf_sync_done(i),
                gp_sync_can_start        => elastic_can_start_sync(i),

                Tx_K                     => tx_data_k_ch(i),
                Rx_K                     => rx_data_k_ch(i),
                TX_DATA_Xcvr             => xcvr_tx_Para_data_ch(i),
                RX_DATA_Xcvr             => xcvr_rx_Para_data_ch(i),
                Tx_DATA_client           => tx_Para_data_ch(i),
                Rx_DATA_client           => rx_Para_data_to_sync_buf_ch(i),

                Tx_Clk                   => tx_clk_buf_out(i),
                Rx_Clk                   => rx_clk_buf_out(i)
            );
    end generate generate_traffic_loop;

    ch_sync_buf_2ch_01 : entity work.ch_sync_buffer_2ch
    port map(
        ch_sync_buffer_data_In_ch0          => rx_Para_data_to_sync_buf_ch(0),
        ch_sync_buffer_data_In_ch1          => rx_Para_data_to_sync_buf_ch(1),

        ch_sync_buffer_data_Out_ch0         => rx_Para_data_from_sync_buf_ch(0),
        ch_sync_buffer_data_Out_ch1         => rx_Para_data_from_sync_buf_ch(1),

        ch_sync_buffer_sync_done            => sync_buf_sync_done_ch_01,
        ch_sync_buffer_overflow             => sync_buf_overflow_ch_01,

        sync_en                             => elastic_can_start_sync(0) and elastic_can_start_sync(1),

        ch_sync_buffer_directly_pass        => not(grouping_enable),
        
        CLK                                 => rx_clk_buf_out(0),
        Reset_n                             => RST_N
    );    
    ch_sync_buf_2ch_23 : entity work.ch_sync_buffer_2ch
    port map(
        ch_sync_buffer_data_In_ch0          => rx_Para_data_to_sync_buf_ch(2),
        ch_sync_buffer_data_In_ch1          => rx_Para_data_to_sync_buf_ch(3),

        ch_sync_buffer_data_Out_ch0         => rx_Para_data_from_sync_buf_ch(2),
        ch_sync_buffer_data_Out_ch1         => rx_Para_data_from_sync_buf_ch(3),

        ch_sync_buffer_sync_done            => sync_buf_sync_done_ch_23,
        ch_sync_buffer_overflow             => sync_buf_overflow_ch_23,

        sync_en                             => elastic_can_start_sync(2) and elastic_can_start_sync(3),

        ch_sync_buffer_directly_pass        => not(grouping_enable),
        
        CLK                                 => rx_clk_buf_out(2),
        Reset_n                             => RST_N
    );

    rst_ctrl : entity work.reset_ctrl 
    port map(
        Reset_n                  => RST_N,
        INIT_CLK                 => XCVR_Ref_Clock,

        
        XCVR_rst_out             => XCVR_TxRx_rst,
        align_en                 => rx_std_wa_patternalign,
        lane_up                  => lane_up,

        Tx_xcvrRstIp_is_Ready    => XCVR_TX_ready_ch,
        Rx_xcvrRstIp_is_Ready    => XCVR_RX_ready_ch,

        RX_elastic_buf_overflow  => elastic_buf_overflow,
        rx_sync_status           => rx_syncstatus_ch,
        rx_pattern_detected      => rx_patterndetect_ch,
        RX_errdetect             => rx_err_detec_ch,
        RX_disperr               => rx_disp_err_ch
    );

    elastic_buf_sync_done(0) <= sync_buf_sync_done_ch_01;
    elastic_buf_sync_done(1) <= sync_buf_sync_done_ch_01;
    elastic_buf_sync_done(2) <= sync_buf_sync_done_ch_23;
    elastic_buf_sync_done(3) <= sync_buf_sync_done_ch_23;
    elastic_buf_overflow <= sync_buf_overflow_ch_01 or sync_buf_overflow_ch_23;

    generate_TX_BUFG_loop : for i in 0 to (num_of_xcvr_ch - 1) generate
       xcvr_tx_data_clk_buf_used_assert : if xcvr_tx_data_clk_buf_used = '1' generate
           gen_TX_BUFG : clk_buffer
               port map
               (
                   inclk                               =>      XCVR_Tx_clk_out_ch(i),
                   outclk                              =>      tx_clk_buf_out(i)
               );
       end generate xcvr_tx_data_clk_buf_used_assert;
       xcvr_tx_data_clk_buf_not_used_assert : if xcvr_tx_data_clk_buf_used = '0' generate
           tx_clk_buf_out(i) <= XCVR_Tx_clk_out_ch(i);
       end generate xcvr_tx_data_clk_buf_not_used_assert;
   end generate  generate_TX_BUFG_loop;

   generate_RX_BUFG_loop : for i in 0 to (num_of_xcvr_ch - 1) generate
       xcvr_rx_data_clk_buf_used_assert : if xcvr_rx_data_clk_buf_used = '1' generate
             gen_RX_BUFG : clk_buffer
                   port map
                   (
                        inclk                                =>      XCVR_Rx_clk_out_ch(i),
                        outclk                               =>      rx_clk_buf_out(i)
                   );
       end generate xcvr_rx_data_clk_buf_used_assert;
       xcvr_rx_data_clk_buf_not_used_assert : if xcvr_rx_data_clk_buf_used = '0' generate
           rx_clk_buf_out(i) <= XCVR_Rx_clk_out_ch(i);
       end generate xcvr_rx_data_clk_buf_not_used_assert;
   end generate generate_RX_BUFG_loop;

end architecture Top;
