#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

void printBinary(FILE *file, uint64_t num);
void printBinary(FILE *file, uint64_t num) {
  for (int i = 63; i >= 0; i--) {
    fprintf(file, "%d\n", (num >> i) & 1);
  }
  printf("\n");
}

int main() {
  FILE *initial_cond = fopen("../initial_cond.txt", "w");
  uint64_t steady_cond =
      0b0000000000000000000000000011100000000000000000000000000000000000;
  printBinary(initial_cond, steady_cond);

  return 0;
}
