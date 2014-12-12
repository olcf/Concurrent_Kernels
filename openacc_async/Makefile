all: checkEnv clean setFlags openacc_async_c openacc_async_f

.PHONY: checkEnv setFlags clean

checkEnv:
ifdef CRAY_PRGENVCRAY
    ifndef HMPP_BIN_PATH
        ifndef CRAY_ACCEL_TARGET
            $(error craype-accel-nvidia35 not loaded)
        endif
    else
        ifdef CRAY_ACCEL_TARGET
            $(error craype-accel-nvidia35 not compatible with CapsMC. Use cudatoolkit module)
        endif
    endif
endif
ifndef CRAY_CUDATOOLKIT_VERSION
    $(error cudatoolkit module not loaded)
endif

setFlags:
ifdef CRAY_PRGENVPGI
    CFLAGS = -acc -ta=nvidia,kepler -Minfo
    FFLAGS = -acc -ta=nvidia,kepler -Minfo
endif
ifdef CRAY_PRGENVCRAY
    CFLAGS = -hpragma=acc
    FFLAGS = -hacc
endif

openacc_async_c: launcher.c
	mkdir -p bin
	cc $(CFLAGS) launcher.c -o bin/openacc_async_c.out

openacc_async_f: launcher.f90
	mkdir -p bin
	ftn $(FFLAGS) launcher.f90 -o bin/openacc_async_f.out

checkEnv:
ifndef CRAY_CUDATOOLKIT_VERSION
	$(error cudatoolkit module not loaded)
endif

clean:
	rm -rf bin
	rm -f *.o
