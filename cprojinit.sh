#!/bin/sh

echo "Creating project directory..."
mkdir $1

echo "Creating $1/src/"
mkdir $1/src

echo "Creating $1/README.md"
touch $1/README.md

echo "Creating $1/doc"
mkdir $1/doc

echo "Creating $1/build"
mkdir $1/build

echo "Creating $1/bin"
mkdir $1/bin

echo "Creating $1/lib"
mkdir $1/lib

echo "Creating $1/src/main.c"
printf "#include <stdio.h>\n\nint main()\n{\n\treturn 0;\n}" > $1/src/main.c

echo "Creating $1/Makefile"
touch $1/Makefile
cat << EOF >> $1/Makefile
CC := gcc
CCL := clang
CFLAGS := -Wall -Wextra -O2 -std=c11
CDEBUG := -pg -ggdb3
CLDEBUG := -pg -ggdb3 -fsanitize=address
GPERF:= -fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free -ltcmalloc -lprofiler
GCOV := -fprofile-arcs -ftest-coverage

BUILD_DIR := build

SOURCES := \$(wildcard src/*.c)
OBJS := \$(addprefix \$(BUILD_DIR)/, main.o)

TARGET := $1

\$(TARGET): \$(OBJS)
	\$(CC) \$(CFLAGS) \$(OBJS) -o bin/\$(TARGET)

\$(BUILD_DIR)/%.o: src/%.c
	\$(CC) \$(CFLAGS) -c $< -o \$@

clean:
	rm \$(BUILD_DIR)/*.o
EOF

if type "scan-build" > /dev/null ; then
	echo "Creating $1/scanbuild.sh"
	printf "#!/bin/sh\nscan-build make -j4" > $1/scanbuild.sh
	chmod +x $1/scanbuild.sh
fi

if type "pprof" > /dev/null ; then
	echo "Creating $1/pprof.sh"
	printf "#!/bin/sh\n# prof files being saved in /tmp/\nHEAPPROFILE=/tmp/heapprof ./bin/$1" > $1/pprof.sh
	chmod +x $1/pprof.sh
fi

if type "pprof" > /dev/null ; then
	echo "Creating $1/heapcheck.sh"
	printf "#!/bin/sh\nHEAPCHECK=normal ./bin/$1" > $1/heapcheck.sh
	chmod +x $1/heapcheck.sh
fi

if type "pprof" > /dev/null ; then
	echo "Creating $1/cpuprofiler.sh"
	printf "#!/bin/sh\n# prof files being saved in /tmp/\nCPUPROFILE=/tmp/prof.out ./bin/$1" > $1/cpuprofiler.sh
	chmod +x $1/cpuprofiler.sh
fi

if type "valgrind" > /dev/null ; then
	echo ""
fi

