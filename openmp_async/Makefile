all: setEnv clean

.PHONY: checkEnv clean

openmp_async_c: launcher.c
	mkdir -p bin
	nvcc -arch=sm_35 -c ../common/sleep.cu
	cc $(CFLAGS) sleep.o launcher.c -o bin/openmp_async_c.out

openmp_async_f: launcher.f90
	mkdir -p bin
	ftn $(FFLAGS) -ta=nvidia,kepler ../common/sleep.cuf launcher.f90 -o bin/openmp_async_f.out

setEnv:
ifndef CRAY_CUDATOOLKIT_VERSION
        $(error cudatoolkit module not loaded)
endif
ifdef CRAY_PRGENVPGI
all: openmp_async_c openmp_async_f
    CFLAGS = -mp
    FFLAGS = -mp
endif
ifdef CRAY_PRGENVGNU
all: openmp_async_c
    CFLAGS = -fopenmp
    FFLAGS = -fopenmp
endif
ifdef CRAY_PRGENVINTEL
all: openmp_async_c
    CFLAGS = -openmp
    FFLAGS = -openmp
endif

clean:
	rm -rf bin
	rm -f *.o
	rm -f *.mod
