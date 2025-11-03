#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

void printBinary(uint8_t num);

void printBinary(uint8_t num) {
  for (int i = 7; i >= 0; i--) {
    printf("%d ", (num >> i) & 1);
  }
  printf("\n");
}

int main() {
  uint64_t board =
      0b0000000000000000000000000011100000000000000000000000000000000000;
  uint64_t state = 0x0000000000000000;
  // int counter = 0;
  for (int i = 7; i >= 0; i--) {
    uint8_t row = board >> ((8 * (i))) & 0xff;
    printf("row: ");
    printBinary(row);
  }

  while (1) {
    for (int i = 7; i >= 0; i--) {
      uint8_t row = board >> ((8 * (i))) & 0xff;
      if (i % 2) {
        for (int j = 0; j < 8; j++) {
          int upper = 0;
          int lower = 0;
          int left = 0;
          int right = 0;

          if (i > 0 && i < 7) {
            upper = 1;
            lower = 1;
          } else if (i > 0) {
            upper = 0;
            lower = 1;
          } else if (i < 7) {
            upper = 1;
            lower = 0;
          }

          if (j > 0 && j < 7) {
            left = 1;
            right = 1;
          } else if (j > 0) {
            left = 1;
            right = 0;
          } else if (j < 7) {
            left = 0;
            right = 1;
          }

          uint8_t item = (row >> j) & 1;

          uint8_t upper_left = 0, upper_mid = 0, upper_right = 0;
          uint8_t mid_left = 0, mid_right = 0;
          uint8_t lower_left = 0, lower_mid = 0, lower_right = 0;
          if (upper) {
            uint8_t upper_row = board >> ((8 * (i + 1))) & 0xff;
            if (left)
              upper_left = (upper_row >> (j - 1)) & 1;
            upper_mid = (upper_row >> j) & 1;
            if (right)
              upper_right = (upper_row >> (j + 1)) & 1;
          }

          if (lower) {
            uint8_t lower_row = board >> ((8 * (i - 1))) & 0xff;
            if (left)
              lower_left = (lower_row >> (j - 1)) & 1;
            lower_mid = (lower_row >> j) & 1;
            if (right)
              lower_right = (lower_row >> (j + 1)) & 1;
          }

          if (left)
            mid_left = (row >> (j - 1)) & 1;
          if (right)
            mid_right = (row >> (j + 1)) & 1;

          uint8_t neighbors = upper_left + upper_mid + upper_right + mid_left +
                              mid_right + lower_left + lower_mid + lower_right;

          if (((item == 1) && (neighbors > 2 && neighbors <= 3)) ||
              ((item == 0) && (neighbors == 3)))
            item = 1;
          else if (neighbors < 2 || neighbors >= 4)
            item = 0;
          state = state | ((uint64_t)item << (i * 8 + j));
          // counter++;
        }
      } else {
        for (int j = 0; j < 8; j++) {
          int upper = 0;
          int lower = 0;
          int left = 0;
          int right = 0;

          if (i > 0 && i < 7) {
            upper = 1;
            lower = 1;
          } else if (i > 0) {
            upper = 0;
            lower = 1;
          } else if (i < 7) {
            upper = 1;
            lower = 0;
          }

          if (j > 0 && j < 7) {
            left = 1;
            right = 1;
          } else if (j > 0) {
            left = 1;
            right = 0;
          } else if (j < 7) {
            left = 0;
            right = 1;
          }

          uint8_t item = (row >> j) & 1;

          uint8_t upper_left = 0, upper_mid = 0, upper_right = 0;
          uint8_t mid_left = 0, mid_right = 0;
          uint8_t lower_left = 0, lower_mid = 0, lower_right = 0;
          if (upper) {
            uint8_t upper_row = board >> ((8 * (i + 1))) & 0xff;
            if (left)
              upper_left = (upper_row >> (j - 1)) & 1;
            upper_mid = (upper_row >> j) & 1;
            if (right)
              upper_right = (upper_row >> (j + 1)) & 1;
          }

          if (lower) {
            uint8_t lower_row = board >> ((8 * (i - 1))) & 0xff;
            if (left)
              lower_left = (lower_row >> (j - 1)) & 1;
            lower_mid = (lower_row >> j) & 1;
            if (right)
              lower_right = (lower_row >> (j + 1)) & 1;
          }

          if (left)
            mid_left = (row >> (j - 1)) & 1;
          if (right)
            mid_right = (row >> (j + 1)) & 1;

          uint8_t neighbors = upper_left + upper_mid + upper_right + mid_left +
                              mid_right + lower_left + lower_mid + lower_right;

          if (((item == 1) && (neighbors > 2 && neighbors <= 3)) ||
              ((item == 0) && (neighbors == 3)))
            item = 1;
          else if (neighbors < 2 || neighbors >= 4)
            item = 0;
          state = state | ((uint64_t)item << (i * 8 + j));
          // counter++;
        }
      }
    }
    printf("state: \n");
    for (int i = 0; i < 8; i++) {
      uint8_t row = state >> ((8 * (i))) & 0xff;
      printf("row: ");
      printBinary(row);
    }

    // counter = 0;
    board = state;
    state = 0;
    sleep(1);
  }

  return 0;
}

// uint64_t board = 0x0123456789abcdef;
// uint64_t state = 0x0000000000000000;
// int counter = 0;
// for (int i = 0; i < 8; i++) {
//   uint8_t row = board >> ((8 * (i))) & 0xff;
//   if (i % 2) {
//     for (int j = 7; j >= 0; j--) {
//       uint8_t item = (row >> j) & 1;
//       state = state + (item * power(2, counter));
//       counter++;
//     }
//   } else {
//     for (int j = 0; j < 8; j++) {
//       uint8_t item = (row >> j) & 1;
//       state = state + (item * power(2, counter));
//       counter++;
//     }
//   }
// }
