# Check for 32-bit vs 64-bit
PROC_TYPE = $(strip $(shell uname -m | grep 64))

# Check for Mac OS
OS = $(shell uname -s 2>/dev/null | tr [:lower:] [:upper:])
DARWIN = $(strip $(findstring DARWIN, $(OS)))

# MacOS System
ifneq ($(DARWIN),)
        CFLAGS += -DMAC
        LIBPARS=-framework OpenCL

        ifeq ($(PROC_TYPE),)
                CFLAGS+=-arch i386
        else
                CFLAGS+=-arch x86_64
        endif
else
	LIBPARS = -lOpenCL -lrt
endif

#OCLSDKDIR = /usr/local/cuda
OCLSDKDIR = ${AMDAPPSDKROOT}
CPP = g++
OCLSDKINC = ${OCLSDKDIR}/include
OCLSDKLIB = ${OCLSDKDIR}/lib/x86
OPTFLAG = -O3 -fomit-frame-pointer
INCLUDES = -I../common/inc
FLAGS = ${OPTFLAG} ${INCLUDES} -I${OCLSDKINC} -msse -msse2 
LFLAGS = -L${OCLSDKLIB} 

.PHONY: clean all

all: factor8-1-opencl
#all: factor8-1-opencl factor8-1-pas factor8-1 factor8-1-omp

factor8-1-opencl: factor8-1-opencl.o
	${CPP} ${LFLAGS} -o $@ $< ${LIBPARS}

factor8-1-opencl.o: factor8-1-opencl.cpp
	${CPP} -c ${FLAGS} $<

factor8-1-pas: factor8-1.pas
	fpc -o$@ -O3 -MTP $<
	rm factor8-1.o

factor8-1: factor8-1.o
	gcc -o $@ $^

factor8-1.o: factor8-1.c
	gcc ${FLAGS} -c -O2 $<

factor8-1-omp: factor8-1-omp.o
	gcc -o $@ -fopenmp $^

factor8-1-omp.o: factor8-1.c
	gcc ${FLAGS} -c -O2 -o $@ -fopenmp $<

clean:
	rm factor8-1 factor8-1.o factor8-1-omp factor8-1-omp.o factor8-1-pas factor8-1-opencl factor8-1-opencl.o
