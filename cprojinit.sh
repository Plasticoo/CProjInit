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
GPERF:= -fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free -ltcmalloc

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
