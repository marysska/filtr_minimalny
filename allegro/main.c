#include <stdio.h>
#include <stdlib.h>
#include <allegro.h>


#ifdef __cplusplus
extern "C" {
#endif
 void func(char* mapOut, char* mapIn,  int size_window);
#ifdef __cplusplus
}
#endif

int main(int argc, char** argv)
{ 
  FILE *image;
  char *bitmapIn;
  char *bitmapOut;//zeby nie robic nadpisywania jak cos
  int size_of_file, width, height, padding, offset;   //allegro potrzebuje, w func samo sie liczy
  char toconvert[4];
  int window=0;
  char path[150];
  int i;
  int j;
  int k;
  printf("Prosze podac sciezke do pliku: \n");
  scanf("%s", path);
  while (window%2==0){
    printf("Prosze podac wielkosc okna - wartosc nieparzysta: \n");
    scanf ("%d", &window);
  }
  //otworz mape
  if ((image=fopen(path, "rb"))==NULL)
     {
        printf ("Błąd otwarcia pliku: %s!\n",path);
        return 1;
    }

    fseek(image, 2, 0); //pobierz rozmiar - alokacja pamieci
    fread(toconvert, 1, 4, image);    
    size_of_file = *(unsigned int *)toconvert;

    fseek(image, 10, 0); //pobierz offset
    fread(toconvert, 1, 4, image);    
    offset = *(unsigned int *)toconvert;

    fseek(image, 18, 0); //pobierz width 
    fread(toconvert, 1, 4, image);    
    width = *(unsigned int *)toconvert;

    fseek(image, 22, 0); //pobierz height
    fread(toconvert, 1, 4, image);    
    height = *(unsigned int *)toconvert;

    padding = (width*3)%4;
    if(padding!=0) padding = 4 - padding;

    bitmapIn=malloc(sizeof(char)*size_of_file);
    bitmapOut=malloc(sizeof(char)*size_of_file);	
    fseek(image, 0, 0); //wczytaj calu plik
    fread(bitmapIn, 1, size_of_file, image);
    fclose(image) ; //plik juz nie bedzie potrzebny



  func(bitmapOut, bitmapIn, window);
    printf("i am back \n");


	BITMAP* outBMP;


	allegro_init();
	install_keyboard();
	set_color_depth(24);

	set_gfx_mode( GFX_AUTODETECT_WINDOWED,width+80,height+80, 0, 0);
	clear_to_color(screen, makecol(191,23,115));

	outBMP = create_bitmap(width, height);
	if (!outBMP)
    {
		    printf("Nie mozna otworzyc pliku bmp!\n");
		      return 1;
	 }


	j=0;
	for(i=height-1;i>=0; --i)
	{
		for(k=0;k<width*3; ++k)
		{
          outBMP->line[i][k]=*(bitmapOut+offset+j*(width*3+padding)+k);
		}
		++j;
	}

	blit(outBMP, screen, 0,0,40,40,width, height);


  readkey();


  destroy_bitmap(outBMP);
  allegro_exit();




   FILE *fp; 

   if ((fp=fopen("out.bmp", "w"))==NULL) {
     printf ("Nie mogę otworzyć pliku out.bmp do zapisu!\n");
     exit(1);
     }
   fwrite(bitmapOut, sizeof(char), size_of_file, fp);
   fclose (fp); /* zamknij plik */


  free(bitmapIn);
  free(bitmapOut);

  return 0;
}
