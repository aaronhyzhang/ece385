/***************************** Include Files *******************************/
#include "hdmi_text_controller.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "sleep.h"

/************************** Function Definitions ***************************/

void paletteTest()
{
	textHDMIColorClr();

	for (int i = 0; i < 8; i ++)
	{
		char color_string[80];
		sprintf(color_string, "Foreground: %d background %d", 2*i, 2*i+1);
		textHDMIDrawColorText (color_string, 0, 2*i, 2*i, 2*i+1);
		sprintf(color_string, "Foreground: %d background %d", 2*i+1, 2*i);
		textHDMIDrawColorText (color_string, 40, 2*i, 2*i+1, 2*i);
	}
	textHDMIDrawColorText ("The above text should cycle through random colors", 0, 25, 0, 1);


	for (int i = 0; i < 10; i++)
	{
		sleep_MB (1);
		for (int j = 0; j < 16; j++)
			setColorPalette(j, 	rand() % 16, rand() % 16,rand() % 16); //set color 0 to random color;

	}
}

void textHDMIColorClr()#ifndef HDMI_TEXT_CONTROLLER_H
#define HDMI_TEXT_CONTROLLER_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"
#include "xparameters.h"

#define COLUMNS 80
#define ROWS 30
#define PALETTE_START 0x2000

struct TEXT_HDMI_STRUCT {
	uint8_t		      	VRAM [ROWS*COLUMNS*2]; 									 //Week 2 - extended VRAM
	//modify this by adding const bytes to skip to palette, or manually compute palette
};

struct COLOR{
	char name [20];
	uint8_t red;
	uint8_t green;
	uint8_t blue;
};


//you may have to change this line depending on your platform designer
static volatile struct TEXT_HDMI_STRUCT* hdmi_ctrl = XPAR_HDMI_TEXT_CONTROLLER_0_AXI_BASEADDR;

//CGA colors with names
static struct COLOR colors[]={
    {"black",          0x0, 0x0, 0x0},
	{"blue",           0x0, 0x0, 0xa},
    {"green",          0x0, 0xa, 0x0},
	{"cyan",           0x0, 0xa, 0xa},
    {"red",            0xa, 0x0, 0x0},
	{"magenta",        0xa, 0x0, 0xa},
    {"brown",          0xa, 0x5, 0x0},
	{"light gray",     0xa, 0xa, 0xa},
    {"dark gray",      0x5, 0x5, 0x5},
	{"light blue",     0x5, 0x5, 0xf},
    {"light green",    0x5, 0xf, 0x5},
	{"light cyan",     0x5, 0xf, 0xf},
    {"light red",      0xf, 0x5, 0x5},
	{"light magenta",  0xf, 0x5, 0xf},
    {"yellow",         0xf, 0xf, 0x5},
	{"white",          0xf, 0xf, 0xf}
};

/**************************** Type Definitions *****************************/
/**
 *
 * Write a value to a HDMI_TEXT_CONTROLLER register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the HDMI_TEXT_CONTROLLERdevice.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void HDMI_TEXT_CONTROLLER_mWriteReg(u32 BaseAddress, unsigned RegOffset, u32 Data)
 *
 */
#define HDMI_TEXT_CONTROLLER_mWriteReg(BaseAddress, RegOffset, Data) \
  	Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

/**
 *
 * Read a value from a HDMI_TEXT_CONTROLLER register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the HDMI_TEXT_CONTROLLER device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	u32 HDMI_TEXT_CONTROLLER_mReadReg(u32 BaseAddress, unsigned RegOffset)
 *
 */
#define HDMI_TEXT_CONTROLLER_mReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the HDMI_TEXT_CONTROLLER instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */

void textHDMIColorClr();
void textHDMIDrawColorText(char* str, int x, int y, uint8_t background, uint8_t foreground);
void setColorPalette (uint8_t color, uint8_t red, uint8_t green, uint8_t blue); //Fill in this code
void paletteTest();
void textHDMIColorScreenSaver();
void hdmiTestWeek2(); //call this for your Week 2 demo 

#endif // HDMI_TEXT_CONTROLLER_H
{
	for (int i = 0; i<(ROWS*COLUMNS) * 2; i++)
	{
		hdmi_ctrl->VRAM[i] = 0x00;
	}
}

void textHDMIDrawColorText(char* str, int x, int y, uint8_t background, uint8_t foreground)
{
	int i = 0;
	while (str[i]!=0)
	{
		hdmi_ctrl->VRAM[(y*COLUMNS + x + i) * 2] = foreground << 4 | background;
		hdmi_ctrl->VRAM[(y*COLUMNS + x + i) * 2 + 1] = str[i];
		i++;
	}
}

void setColorPalette (uint8_t color, uint8_t red, uint8_t green, uint8_t blue)
{
	//fill in this function to set the color palette starting at offset 0x0000 2000 (from base)
	uint32_t packed_color = (red << 8) | (green << 4) | blue;

	volatile uint16_t* palette_addr = (uint16_t*)((uint8_t*)hdmi_ctrl + PALETTE_START + (color * 4));

	// printf("Palette address: %p  Data: 0x%04X\n", (void*)palette_addr, *palette_addr);

	*palette_addr = packed_color;
}


void textHDMIColorScreenSaver()
{
	paletteTest();
	char color_string[80];
    int fg, bg, x, y;
	textHDMIColorClr();
	//initialize palette
	for (int i = 0; i < 16; i++)
	{
		setColorPalette (i, colors[i].red, colors[i].green, colors[i].blue);
	}
	while (1)
	{
		fg = rand() % 16;
		bg = rand() % 16;
		while (fg == bg)
		{
			fg = rand() % 16;
			bg = rand() % 16;
		}
		sprintf(color_string, "Drawing %s text with %s background", colors[fg].name, colors[bg].name);
		x = rand() % (80-strlen(color_string));
		y = rand() % 30;
		textHDMIDrawColorText (color_string, x, y, bg, fg);
		sleep_MB (1);
	}
}

//Call this function for your Week 2 test
hdmiTestWeek2()
{
    //On-chip memory write and readback test
	uint32_t checksum[ROWS], readsum[ROWS];

	for (int j = 0; j < ROWS; j++)
	{
		checksum[j] = 0;
		for (int i = 0; i < COLUMNS * 2; i++)
		{
			hdmi_ctrl->VRAM[j*COLUMNS*2 + i] = i + j;
			checksum[j] += i + j;
		}
	}
	
	for (int j = 0; j < ROWS; j++)
	{
		readsum[j] = 0;
		for (int i = 0; i < COLUMNS * 2; i++)
		{
			readsum[j] += hdmi_ctrl->VRAM[j*COLUMNS*2 + i];
			//printf ("%x \n\r", hdmi_ctrl->VRAM[j*COLUMNS*2 + i]);
		}
		printf ("Row: %d, Checksum: %x, Read-back Checksum: %x\n\r", j, checksum[j], readsum[j]);
		if (checksum[j] != readsum[j])
		{
			printf ("Checksum mismatch!, check your AXI4 code or your on-chip memory\n\r");
			while (1){};
		}
	}
	printf ("Checksum passed, beginning palette test\n\r");
	
	paletteTest();
	printf ("Palette test passed, beginning screensaver loop\n\r");
    textHDMIColorScreenSaver();
}