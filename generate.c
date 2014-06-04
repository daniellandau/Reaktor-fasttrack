#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char *argv[])
{
  FILE * out = fopen("huge.txt", "w");
  int i,j;
  fputs("# first line 342342\n", out);
  for (i = 1; i < 10000; ++i) {
    for (j = 1; j < i; ++j) {
      fprintf(out, "%d ", rand() % 100);
    }
    fprintf(out, "%d\n", rand() % 100);
  }
  return 0;
}
