#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int get_file_size(int argc, const char *argv[])
{
  struct stat st;
  if (stat(argv[1], &st) != 0) {
    printf("file does not exist\n");
    exit(2);
  }
  return st.st_size;
}
