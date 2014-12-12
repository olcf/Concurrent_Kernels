all: checkEnv clean serial_async_c serial_async_f

.PHONY: checkEnv clean

serial_async_c: launcher.c
	mkdir -p bin
	nvcc -arch=sm_35 -c ../common/sleep.cu
	cc sleep.o launcher.c -o bin/serial_async_c.out

serial_async_f: launcher.f90
	mkdir -p bin
	ftn -ta=nvidia,kepler ../common/sleep.cuf launcher.f90 -o bin/serial_async_f.out

checkEnv:
ifndef CRAY_CUDATOOLKIT_VERSION
	$(error cudatoolkit module not loaded)
endif

clean:
	rm -rf bin
	rm -f *.o
	rm -f *.mod
