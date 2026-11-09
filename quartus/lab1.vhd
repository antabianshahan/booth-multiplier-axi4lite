LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

entity lab1 is
port(
		-- Clocks
		CLOCK_50: 				in std_logic;
		
		-- DDR3 SDRAM
		HPS_DDR3_ADDR:	out std_logic_vector(14 downto 0);
		HPS_DDR3_BA: 			out std_logic_vector(2 downto 0);
		HPS_DDR3_CAS_N: 		out std_logic;
		HPS_DDR3_CKE: 			out std_logic; 
		HPS_DDR3_CK_N:			out std_logic;
		HPS_DDR3_CK_P:			out std_logic;
		HPS_DDR3_CS_N:			out std_logic;
		HPS_DDR3_DM: 			out std_logic_vector(3 downto 0);
		HPS_DDR3_DQ:			inout std_logic_vector(31 downto 0);
		HPS_DDR3_DQS_N:		inout std_logic_vector(3 downto 0);
		HPS_DDR3_DQS_P:		inout std_logic_vector(3 downto 0);
		HPS_DDR3_ODT:			out std_logic;
		HPS_DDR3_RAS_N:		out std_logic;
		HPS_DDR3_RESET_N:		out std_logic;
		HPS_DDR3_RZQ:			in std_logic;
		HPS_DDR3_WE_N:			out std_logic;
		
		-- USB
		HPS_CONV_USB_N:		inout std_logic;
		HPS_USB_CLKOUT:		in std_logic;
		HPS_USB_DATA:			inout std_logic_vector(7 downto 0);
		HPS_USB_DIR:			in	std_logic;
		HPS_USB_NXT:			in std_logic;
		HPS_USB_STP:			out std_logic;
		
		-- UART
		HPS_UART_RX:			in std_logic;
		HPS_UART_TX:			out std_logic
		
		
);
end lab1;

architecture structural of lab1 is

	component lab1_system is
		port (
			hps_io_hps_io_usb1_inst_D0  : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1  : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2  : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3  : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4  : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5  : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6  : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7  : inout std_logic                     := 'X';             -- hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK : in    std_logic                     := 'X';             -- hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP : out   std_logic;                                        -- hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR : in    std_logic                     := 'X';             -- hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT : in    std_logic                     := 'X';             -- hps_io_usb1_inst_NXT
			hps_io_hps_io_uart0_inst_RX : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX : out   std_logic;                                        -- hps_io_uart0_inst_TX
			memory_mem_a                : out   std_logic_vector(14 downto 0);                    -- mem_a
			memory_mem_ba               : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck               : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n             : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke              : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n             : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n            : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n            : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n             : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n          : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq               : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
			memory_mem_dqs              : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
			memory_mem_dqs_n            : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
			memory_mem_odt              : out   std_logic;                                        -- mem_odt
			memory_mem_dm               : out   std_logic_vector(3 downto 0);                     -- mem_dm
			memory_oct_rzqin            : in    std_logic                     := 'X';             -- oct_rzqin
			system_pll_ref_clk_clk      : in    std_logic                     := 'X';             -- clk
			system_pll_ref_reset_reset  : in    std_logic                     := 'X'             -- reset
   
		);
	end component lab1_system;

begin

	u0 : component lab1_system
		port map (
			hps_io_hps_io_usb1_inst_D0  => HPS_USB_DATA(0),  	-- .hps_io.hps_io_usb1_inst_D0
			hps_io_hps_io_usb1_inst_D1  => HPS_USB_DATA(1),  	-- .hps_io_usb1_inst_D1
			hps_io_hps_io_usb1_inst_D2  => HPS_USB_DATA(2),  	-- .hps_io_usb1_inst_D2
			hps_io_hps_io_usb1_inst_D3  => HPS_USB_DATA(3),  	-- .hps_io_usb1_inst_D3
			hps_io_hps_io_usb1_inst_D4  => HPS_USB_DATA(4),  	-- .hps_io_usb1_inst_D4
			hps_io_hps_io_usb1_inst_D5  => HPS_USB_DATA(5),  	-- .hps_io_usb1_inst_D5
			hps_io_hps_io_usb1_inst_D6  => HPS_USB_DATA(6),  	-- .hps_io_usb1_inst_D6
			hps_io_hps_io_usb1_inst_D7  => HPS_USB_DATA(7),  	-- .hps_io_usb1_inst_D7
			hps_io_hps_io_usb1_inst_CLK => HPS_USB_CLKOUT, 		-- .hps_io_usb1_inst_CLK
			hps_io_hps_io_usb1_inst_STP => HPS_USB_STP, 			-- .hps_io_usb1_inst_STP
			hps_io_hps_io_usb1_inst_DIR => HPS_USB_DIR, 			-- .hps_io_usb1_inst_DIR
			hps_io_hps_io_usb1_inst_NXT => HPS_USB_NXT, 			-- .hps_io_usb1_inst_NXT
			hps_io_hps_io_uart0_inst_RX => HPS_UART_RX, 			-- .hps_io_uart0_inst_RX
			hps_io_hps_io_uart0_inst_TX => HPS_UART_TX, 			-- .hps_io_uart0_inst_TX
			memory_mem_a                => HPS_DDR3_ADDR,		-- memory.mem_a
			memory_mem_ba               => HPS_DDR3_BA,        -- .mem_ba
			memory_mem_ck               => HPS_DDR3_CK_P,   	-- .mem_ck
			memory_mem_ck_n             => HPS_DDR3_CK_N,    	-- .mem_ck_n
			memory_mem_cke              => HPS_DDR3_CKE,      	-- .mem_cke
			memory_mem_cs_n             => HPS_DDR3_CS_N,     	-- .mem_cs_n
			memory_mem_ras_n            => HPS_DDR3_RAS_N,    	-- .mem_ras_n
			memory_mem_cas_n            => HPS_DDR3_CAS_N,  	-- .mem_cas_n
			memory_mem_we_n             => HPS_DDR3_WE_N,    	-- .mem_we_n
			memory_mem_reset_n          => HPS_DDR3_RESET_N, 	-- .mem_reset_n
			memory_mem_dq               => HPS_DDR3_DQ,     	-- .mem_dq
			memory_mem_dqs              => HPS_DDR3_DQS_P, 		-- .mem_dqs
			memory_mem_dqs_n            => HPS_DDR3_DQS_N,  	-- .mem_dqs_n
			memory_mem_odt              => HPS_DDR3_ODT,     	-- .mem_odt
			memory_mem_dm               => HPS_DDR3_DM,      	-- .mem_dm
			memory_oct_rzqin            => HPS_DDR3_RZQ,     	-- .oct_rzqin
			system_pll_ref_clk_clk      => CLOCK_50,      		-- system_pll_ref_clk.clk
			system_pll_ref_reset_reset  => '0'					-- system_pll_ref_reset.reset
			
		);

end structural;	
		
