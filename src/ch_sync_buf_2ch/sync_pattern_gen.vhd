library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

library work;
use work.DataStruct_param_def_header.all;--invoke our defined type and parameter

entity sync_pattern_gen is    
    port (
        sync_pattern            : out std_logic_vector ((MAX_CNT_COUNTED_power -1) downto 0 ):= (others => '0'); 
        pattern_over_mid_val    : out std_logic := '0';
        
        pattern_gen_en          : in  std_logic := '0';
        
        USER_CLK                : in  std_logic := '0';
        SYSTEM_RESET_N          : in  std_logic := '0'
    ); 
end sync_pattern_gen;


architecture RTL of sync_pattern_gen is
begin
    pattern_gen_cnt : process(USER_CLK,SYSTEM_RESET_N, pattern_gen_en)
        variable cnt                        : integer range 0 to  MAX_CNT_COUNTED := 0;
        variable pattern_counted_mid_val    : std_logic := '0';
    begin
        if (SYSTEM_RESET_N = '0' or pattern_gen_en = '0') then
            cnt := 0; 
            pattern_counted_mid_val := '0';
        elsif (rising_edge(USER_CLK)) then  
            if (cnt = MAX_CNT_COUNTED) then
                cnt := 0;
            else
                cnt := cnt + 1;
            end if;  
            if (cnt >= MID_CNT_COUNTED) then
                pattern_counted_mid_val := '1';
            else
                pattern_counted_mid_val := '0';
            end if;
        end if;
    sync_pattern            <= cnt;
    pattern_over_mid_val    <= pattern_counted_mid_val;
    end process pattern_gen_cnt;      
end RTL;