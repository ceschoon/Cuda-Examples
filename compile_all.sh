#! /bin/bash

echo "Compiling original saxpy example"
cd cuda_original_saxpy
nvcc -o saxpy saxpy.cu
cd ..

echo "Compiling GPU vs all CPUs saxpy example (1e6 times)"
cd saxpy_1e6_gpu_vs_all_cpus
nvcc -o saxpy_gpu saxpy.cu
gcc -O3 -fopenmp -o saxpy_cpus saxpy.c
cd ..

