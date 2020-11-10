#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

void saxpy(int n, float a, float *x, float *y)
{
  # pragma omp parallel for
  for(int i=0; i<n; i++)
  {
    for(int j=0; j<1e6; j++) // Test multiple executions
    y[i] = a*x[i] + y[i];
  }
}

float max(float a, float b) {return (a>b)?a:b;}

int main(void)
{
  int N = 1<<20; // bit-shift operator moves 0000001 20 bits left = 2^20
  printf("N: %d\n", N);
  
  float *x, *y, *d_x, *d_y;
  x = (float*)malloc(N*sizeof(float));
  y = (float*)malloc(N*sizeof(float));

  for (int i = 0; i < N; i++) {
    x[i] = 1.0f;
    y[i] = 2.0f;
  }
  
  // Perform SAXPY on 1M elements
  saxpy(N, 2.0f, x, y);
  
  float maxError = 0.0f;
  for (int i = 0; i < N; i++)
    maxError = max(maxError, abs(y[i]-4.0f));
  printf("Max error: %f\n", maxError);

  free(x);
  free(y);
}
