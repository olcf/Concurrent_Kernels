all: checkEnv clean mpi_async_c mpi_async_f

.PHONY: checkEnv clean

mpi_async_c: launcher.c
	mkdir -p bin
	nvcc -arch=sm_35 -c ../common/sleep.cu
	cc sleep.o launcher.c -o bin/mpi_async_c.out

mpi_async_f: launcher.f90
	mkdir -p bin
	ftn -acc -ta=nvidia,kepler ../common/sleep.cuf launcher.f90 -o bin/mpi_async_f.out

checkEnv:
ifndef CRAY_CUDATOOLKIT_VERSION
	$(error cudatoolkit module not loaded)
endif

clean:
	rm -rf bin
	rm -f *.o
	rm -f *.mod
