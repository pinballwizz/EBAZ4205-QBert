---------------------------------------------------------------------------------
--                       	  QBert - EBAZ4205
--                            Code from Mister
--
--                          Modified for EBAZ4205 
--                            by pinballwiz.org 
--                               21/03/2026
---------------------------------------------------------------------------------
-- Keyboard inputs :
--   5            : Add coin
--   2            : Start 2 players
--   1            : Start 1 player
--   UP arrow     : UP
--   DOWN arrow   : DOWN
--   RIGHT arrow  : Right
--   LEFT arrow   : Left
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------
entity qbert_ebaz4205 is
port(
	clock_50    : in std_logic;
   	I_RESET     : in std_logic;
	O_VIDEO_R	: out std_logic_vector(2 downto 0); 
	O_VIDEO_G	: out std_logic_vector(2 downto 0);
	O_VIDEO_B	: out std_logic_vector(1 downto 0);
	O_HSYNC	    : out std_logic;
	O_VSYNC	    : out std_logic;
	O_AUDIO_L 	: out std_logic;
	O_AUDIO_R 	: out std_logic;
	greenLED 	: out std_logic;
	redLED 	    : out std_logic;
    ps2_clk     : in std_logic;
	ps2_dat     : inout std_logic;
	joy         : in std_logic_vector(8 downto 0);
	dipsw       : in std_logic_vector(4 downto 0);
	led         : out std_logic_vector(7 downto 0)
 );
end qbert_ebaz4205;
------------------------------------------------------------------------------
architecture struct of qbert_ebaz4205 is

 signal clock_100       : std_logic;
 signal clk_sys         : std_logic;
 signal cpu_clk         : std_logic;
 signal sound_clk       : std_logic;
 signal clock_25        : std_logic;
 signal clock_40        : std_logic;
 signal clock_10        : std_logic;
 signal clock_5         : std_logic;
 signal pll_lock        : std_logic;
 --
 signal reset           : std_logic;
 --
 signal OP2720          : std_logic_vector(5 downto 0);
 signal audio           : std_logic_vector(7 downto 0);
 signal audio_pwm       : std_logic;
 --
 signal red             : std_logic_vector(7 downto 0);
 signal green           : std_logic_vector(7 downto 0); 
 signal blue            : std_logic_vector(7 downto 0);
 --
 signal video_r_i       : std_logic_vector(5 downto 0);
 signal video_g_i       : std_logic_vector(5 downto 0); 
 signal video_b_i       : std_logic_vector(5 downto 0);
 --
 signal video_r         : std_logic_vector(5 downto 0);
 signal video_g         : std_logic_vector(5 downto 0); 
 signal video_b         : std_logic_vector(5 downto 0);
 --
 signal iRGB            : std_logic_vector(23 downto 0);
 signal oRGB            : std_logic_vector(23 downto 0);
 --
 signal h_sync          : std_logic;
 signal v_sync	        : std_logic;
 signal hblank          : std_logic;
 signal vblank	        : std_logic;
 --
 signal IP1710          : std_logic_vector(7 downto 0);
 signal IP4740          : std_logic_vector(7 downto 0);
 --
 signal kbd_intr        : std_logic;
 signal kbd_scancode    : std_logic_vector(7 downto 0);
 signal joy_BBBBFRLDU   : std_logic_vector(8 downto 0);
 --
 signal SW_LEFT         : std_logic;
 signal SW_RIGHT        : std_logic;
 signal SW_UP           : std_logic;
 signal SW_DOWN         : std_logic;
 signal SW_FIRE         : std_logic;
 signal SW_BOMB         : std_logic;
 signal SW_COIN         : std_logic;
 signal P1_START        : std_logic;
 signal P2_START        : std_logic;
 --
 constant CLOCK_FREQ    : integer := 27E6;
 signal counter_clk     : std_logic_vector(25 downto 0);
 signal clock_4hz       : std_logic;
 signal AD              : std_logic_vector(15 downto 0);
 signal S_AD            : std_logic_vector(15 downto 0);
-------------------------------------------------------------------------
component m_clocks
port(
  clk_out1          : out    std_logic;
  clk_out2          : out    std_logic;
  clk_in1           : in     std_logic
 );
end component;
--------------------------------------------------------------------------

begin

 reset       <= not I_RESET; -- reset active low
 greenLED    <= '1'; -- turn off leds
 redLED      <= '1';
--------------------------------------------------------------------------
Clocks: m_clocks
    port map (
        clk_in1   => clock_50,
        clk_out1  => clock_100,
        clk_out2  => clock_40
      );
---------------------------------------------------------------------------
-- clocks divide

process (Clock_100)
begin
 if rising_edge(Clock_100) then
	clk_sys  <= not clk_sys;
 end if;
end process;
--------------------------------------------------------------------------
qbert_clocks : entity work.qbert_clocks
  port map (
  clk_sys       => clk_sys,  -- 50 Mhz In
  clock_40      => clock_40, -- 40 Mhz In
  clock_25      => clock_25, -- 25 Mhz Out
  clock_10      => clock_10, -- 10 Mhz Out
  clock_5       => clock_5,  --  5 Mhz Out
  cpu_clk       => cpu_clk,
  sound_clk     => sound_clk -- 1.44 Mhz Out
  );
---------------------------------------------------------------------------
-- input map

SW_LEFT    <= joy_BBBBFRLDU(2) when dipsw(0) = '0' else not joy(0);
SW_RIGHT   <= joy_BBBBFRLDU(3) when dipsw(0) = '0' else not joy(1);
SW_UP      <= joy_BBBBFRLDU(0) when dipsw(0) = '0' else not joy(2);
SW_DOWN    <= joy_BBBBFRLDU(1) when dipsw(0) = '0' else not joy(3);
SW_FIRE    <= joy_BBBBFRLDU(4) when dipsw(0) = '0' else not joy(4);
SW_BOMB    <= joy_BBBBFRLDU(8) when dipsw(0) = '0' else not joy(5);
SW_COIN    <= joy_BBBBFRLDU(7) when dipsw(0) = '0' else not joy(6);
P1_START   <= joy_BBBBFRLDU(5) when dipsw(0) = '0' else not joy(7);
P2_START   <= joy_BBBBFRLDU(6) when dipsw(0) = '0' else not joy(8);
--------------------------------------------------------------------------
 IP1710    <= SW_FIRE & '1' & "00" & SW_COIN & '0' & P2_START & P1_START;
 IP4740    <= "0000" & SW_LEFT & SW_RIGHT & SW_UP & SW_DOWN;
--------------------------------------------------------------------------
mylstar_board : entity work.mylstar_board
  port map (
  clk_sys       => clk_sys, -- 50 Mhz
  reset         => reset,
  CLK           => clock_10,
  CLK5          => clock_5,
  CPU_CORE_CLK  => clock_100,
  CPU_CLK       => cpu_clk,
  red           => red,
  green         => green,
  blue          => blue,
  IP1710        => IP1710,
  IP4740        => IP4740,
  IPA1J2        => "00000000",
  OP2720        => OP2720,
  OP3337        => open,
  dip_switch    => "00000100",
  AD            => AD
);
------------------------------------------------------------------------------
-- Sync

iRGB <= red & green & blue;

HVGEN : entity work.hvgen
port map(
	vclk   => clock_5,
	hb     => hblank,
	vb     => vblank,
	hs     => h_sync,
	vs     => v_sync,
	colfix => '0'
);
------------------------------------------------------------------------------
video_r_i <= iRGB(23 downto 18) when hblank = '0' and vblank = '0' else "000000";
video_g_i <= iRGB(15 downto 10) when hblank = '0' and vblank = '0' else "000000";
video_b_i <= iRGB(7 downto 2) when hblank = '0' and vblank = '0' else "000000";
-----------------------------------------------------------------------------
-- vga output

 O_VIDEO_R  <= video_r_i(5 downto 3);
 O_VIDEO_G  <= video_g_i(5 downto 3);
 O_VIDEO_B  <= video_b_i(5 downto 4);
 O_HSYNC    <= h_sync;
 O_VSYNC    <= v_sync;
------------------------------------------------------------------------------
ma216_board : entity work.ma216_board
port map (
  clk 	    => sound_clk, -- 1.44 Mhz
  clk_sys   => clk_sys, -- 50 Mhz
  reset	    => reset,
  IP2720	=> OP2720,
  audio	    => audio
 );
------------------------------------------------------------------------------
  u_dac : entity work.dac
    generic map(
      msbi_g => 7
    )
    port  map(
      clk_i   => clock_25,
      res_n_i => I_RESET,
      dac_i   => audio,
      dac_o   => audio_pwm
    );

  O_AUDIO_L <= audio_pwm;
  O_AUDIO_R <= audio_pwm;
------------------------------------------------------------------------------
-- get scancode from keyboard

keyboard : entity work.io_ps2_keyboard
port map (
  clk       => clock_10,
  kbd_clk   => ps2_clk,
  kbd_dat   => ps2_dat,
  interrupt => kbd_intr,
  scancode  => kbd_scancode
);
------------------------------------------------------------------------------
-- translate scancode to joystick

joystick : entity work.kbd_joystick
port map (
  clk            => clock_10,
  kbdint         => kbd_intr,
  kbdscancode    => std_logic_vector(kbd_scancode), 
  joy_BBBBFRLDU  => joy_BBBBFRLDU 
);
------------------------------------------------------------------------------
-- debug

process(reset, clock_25)
begin
  if reset = '1' then -- reset active high
   clock_4hz <= '0';
   counter_clk <= (others => '0');
  else
    if rising_edge(clock_25) then
      if counter_clk = CLOCK_FREQ/8 then
        counter_clk <= (others => '0');
        clock_4hz <= not clock_4hz;
      led(7 downto 0) <= not AD(14 downto 7);
      else
        counter_clk <= counter_clk + 1;
      end if;
    end if;
  end if;
end process;
------------------------------------------------------------------------
end struct;