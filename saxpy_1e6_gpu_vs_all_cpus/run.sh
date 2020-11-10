#! /bin/bash

echo ""
echo "Running example on all available CPUs"
time ./saxpy_cpus

echo ""
echo "Running example on GPU"
time ./saxpy_gpu

