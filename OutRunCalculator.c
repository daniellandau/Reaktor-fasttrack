#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define max(a,b) ((a) > (b) ? (a) : (b))

int main(int argc, const char *argv[])
{
  if (argc != 2) {
    printf("usage: %s file\n", argv[0]);
    return 1;
  }

  struct stat st;
  if (stat(argv[1], &st) != 0) {
    printf("file does not exist\n");
    return 2;
  }

  char * buf = (char*)malloc(st.st_size + 1);

  FILE * in = fopen(argv[1], "r");

  fread(buf, 1, st.st_size, in);
  buf[st.st_size] = '\0';
  int lines = 0;
  int i;
  for (i = 0; i < st.st_size; ++i) {
    if (buf[i] == '\n') {
      ++lines;
    }
  }
  int tree_height = lines - 1;
  int tree_size = ((tree_height+1)*tree_height)/2;

  int * tree = (int*)malloc( tree_size * sizeof(int));
  
  char * tok = strtok(buf, "\n");
  i = 0;
  while (1) {
    tok = strtok(NULL, " \n");
    if (tok == NULL) break;
    tree[i] = atoi(tok);
    ++i;
  }

  int * mergelinebuf = (int*) malloc( tree_height * sizeof(int));
  int array_off = 1, current_size;
  for (current_size = tree_height - 1; current_size > 0; --current_size) {
    for (i = 0; i < current_size; ++i) {
      mergelinebuf[i] = tree[tree_size - i - array_off - (current_size + 1)] +
        max(tree[tree_size - i - array_off], tree[tree_size - (i + 1) - array_off]);
    }
    for (i = 0; i < current_size; ++i) {
      tree[tree_size - i - array_off - (current_size + 1)] = mergelinebuf[i];
    }
    array_off += current_size + 1;
  }

  printf("%d tykkäystä\n", tree[0]);

  return 0;
}
