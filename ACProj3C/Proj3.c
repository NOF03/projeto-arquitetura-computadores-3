#include <reg51.h>

//-----------------------------------Constantes e Variáveis-----------------------------------

sbit Verde1 = P1 ^ 0;
sbit Vermelho1 = P1 ^ 1;
sbit Amarelo = P1 ^ 2;
sbit Verde2 = P1 ^ 3;
sbit Vermelho2 = P1 ^ 4;
sbit segA = P2 ^ 0;
sbit segB = P2 ^ 1;
sbit segC = P2 ^ 2;
sbit segD = P2 ^ 3;

bit sensor1 = 0;
bit sensor2 = 0;

unsigned short availablePlaces = 9;
unsigned short counter = 0;
unsigned short secs = 0;
//-----------------------------------Funções-----------------------------------

void display(unsigned short num);

void estadoInicial(void);

void reiniciaTimer(void);

void main(void)
{
    TMOD = 0x02;
    TH0 = 0x06;
    TL0 = 0x06;
    ET0 = 1;
    EA = 1;
    EX0 = 1;
    IT0 = 1;
    EX1 = 1;
    IT1 = 1;

    display(availablePlaces);

    estadoInicial();

    while (1)
    {  
			if ((sensor1 && availablePlaces != 0) || (sensor2 && availablePlaces != 9))
        { // Está a entrar um carro e tem lugares disponíveis
            TR0 = 1;

            // Durante 5 segundos:
            if (secs < 5)
            {
                if (sensor1) {
                    Verde1 = 0;    // Liga o Verde1
                    Vermelho1 = 1; // Desliga o Vermelho1
                    Verde2 = 1;    // Desliga o Verde2
                    Vermelho2 = 0; // Liga o Vermelho2
                } else {
                    Verde1 = 1;    // Desliga o Verde1
                    Vermelho1 = 0; // Liga o Vermelho1
                    Verde2 = 0;    // Liga o Verde2
                    Vermelho2 = 1; // Desliga o Vermelho2
                }
            
                
            }

            // Após os 5 segundos:
            else
            {
                estadoInicial();
							
								if (sensor1) {
                    availablePlaces--;
                } else {
                    availablePlaces++;
                }
							
                reiniciaTimer();
                
                
                
                display(availablePlaces);
            }
        }
    }
}

void display(unsigned short num)
{
    unsigned short segments[10][4] = {
        {0, 0, 0, 0}, // 0
        {0, 0, 0, 1}, // 1
        {0, 0, 1, 0}, // 2
        {0, 0, 1, 1}, // 3
        {0, 1, 0, 0}, // 4
        {0, 1, 0, 1}, // 5
        {0, 1, 1, 0}, // 6
        {0, 1, 1, 1}, // 7
        {1, 0, 0, 0}, // 8
        {1, 0, 0, 1}, // 9
    };

    segA = segments[num][3];
    segB = segments[num][2];
    segC = segments[num][1];
    segD = segments[num][0];
}

void estadoInicial(void) {
    Verde1 = 0;    // Liga o Verde1
    Vermelho1 = 1; // Desliga o Vermelho1
    Amarelo = 1;   // Desliga o Amarelo
    Verde2 = 0;    // Liga o Verde2
    Vermelho2 = 1; // Desliga o Vermelho2
}

void reiniciaTimer(void) {
    counter = 0;
		secs = 0;
    TR0 = 0;
    TH0 = 0x06;
    TL0 = 0x06;
    sensor1 = 0;
    sensor2 = 0;
}

void interrupcaoExt0(void) interrupt 0
{
    sensor1 = 1;
}

void interrupcaoExt1(void) interrupt 2
{
    sensor2 = 1;
}

void timer0(void) interrupt 1
{
    counter++;
		if ((counter % 4000) == 0) {
			
			if (secs == 0)
			{
					Amarelo = 0;
			} else {
					Amarelo = !Amarelo;
			}
			
			secs++;
		}
		
}