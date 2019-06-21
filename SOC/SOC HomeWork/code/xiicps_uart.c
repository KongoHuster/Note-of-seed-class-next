
#include "xparameters.h"
#include "xiicps.h"
#include "xil_printf.h"
#include "xgpio.h"

#define PS_IIC_DEVICE_ID		XPAR_XIICPS_1_DEVICE_ID
#define PL_IIC_DEVICE_ID		XPAR_XIICPS_0_DEVICE_ID

#define IIC_SLAVE_ADDR		0b1001000
#define IIC_SCLK_RATE		100000

#define TEST_BUFFER_SIZE	2
#define FLAG_BIT 1
#define DELAY_TOP 6000

#define GPIO_0_ID XPAR_AXI_GPIO_0_DEVICE_ID
#define GPIO_1_ID XPAR_AXI_GPIO_1_DEVICE_ID

XGpio uart1;
XGpio uart_tx_full;

void Delay(int DelayTime);
int IicMasterPolled(u16 DeviceId);
XIicPs Iic;		/**< Instance of the IIC Device */

u8 TemperatureFlag = 0x00;

u8 RecvBuffer[TEST_BUFFER_SIZE];  /**< Buffer for Receiving Data */

int main(void)
{
	int Status;

	Status = XGpio_Initialize(&uart1, GPIO_0_ID);
	if(Status != XST_SUCCESS) return XST_FAILURE;

	Status = XGpio_Initialize(&uart_tx_full, GPIO_1_ID);
	if(Status != XST_SUCCESS) return XST_FAILURE;

	XGpio_SetDataDirection(&uart1, 1, 0x00000000);
	XGpio_SetDataDirection(&uart1, 2, 0x00000000);
	XGpio_SetDataDirection(&uart_tx_full, 1, 0xFFFFFFFF);


	xil_printf("IIC Master Polled Example Test \r\n");

	while(1) {
		xil_printf("  --Read TMP101A: ");
		Status = IicMasterPolled(PS_IIC_DEVICE_ID);
		if (Status != XST_SUCCESS) {
			xil_printf(" PS IIC Master Failed\r\n");
			return XST_FAILURE;
		}

		xil_printf("  | \r\n");
		xil_printf("  --Read TMP101B: ");
		Status = IicMasterPolled(PL_IIC_DEVICE_ID);
		if (Status != XST_SUCCESS) {
			xil_printf(" PL IIC Master Failed\r\n");
			return XST_FAILURE;
		}

		Delay(DELAY_TOP);
		xil_printf(" \r\n\r\n\r\n");
	}

	xil_printf("Successfully ran IIC Master Polled Example Test\r\n");
	return XST_SUCCESS;
}

void Delay(int DelayTime) {
	int count1, count2;
	count1 = 0;
	while(count1 < DelayTime) {
		count1 ++;
		count2 = 0;
		while(count2 < DelayTime) {
			count2 ++;
		}
	}
}

void Print_message(char *message) {
	unsigned char count;
	for(count = 0; count < strlen(message); ++ count) {
		while(XGpio_DiscreteRead(&uart_tx_full, 1 )==1);
		XGpio_DiscreteWrite(&uart1, 1, message[count]);
		XGpio_DiscreteWrite(&uart1, 2, 1);
		XGpio_DiscreteWrite(&uart1, 2, 0);
	}
}

int IicMasterPolled(u16 DeviceId)
{
	int Status;
	XIicPs_Config *Config;
	float temp;
	char Message[40];

	Config = XIicPs_LookupConfig(DeviceId);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XIicPs_CfgInitialize(&Iic, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XIicPs_SelfTest(&Iic);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XIicPs_SetSClk(&Iic, IIC_SCLK_RATE);

	Status = XIicPs_MasterSendPolled(&Iic, &TemperatureFlag, FLAG_BIT, IIC_SLAVE_ADDR);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/* Wait until bus is idle to start another transfer. */
	while (XIicPs_BusIsBusy(&Iic));

	Status = XIicPs_MasterRecvPolled(&Iic, RecvBuffer,
			  TEST_BUFFER_SIZE, IIC_SLAVE_ADDR);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	temp = (float)RecvBuffer[0] + ((float)(RecvBuffer[1] >> 5))/16;
	printf("%4.4f C degress.\r\n", temp);

	if(DeviceId == PS_IIC_DEVICE_ID) {
		sprintf(Message, "    Read TMP101A: %4.4f C degress.\r\n", temp);
	}
	else {
		sprintf(Message, "Read TMP101B: %4.4f C degress.\r\n\r\n", temp);
	}

	Print_message(Message);

	return XST_SUCCESS;
}
