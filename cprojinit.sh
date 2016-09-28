#!/bin/sh

if [ "$#" -lt 1 ]; then
    echo "Usage: ./cprojinit.sh [new_dir]"
    exit 1
  fi

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
CFLAGS := -Wall -Wextra -std=c11
COPT := -O2
COPTD := -O0
CDEBUG := -pg -ggdb3 -fno-inline
CLDEBUG := -fsanitize=address
GPERF:= -fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free -ltcmalloc -lprofiler
GCOV := -fprofile-arcs -ftest-coverage

BUILD_DIR := build

SOURCES := \$(wildcard src/*.c)
OBJS := \$(addprefix \$(BUILD_DIR)/, main.o)

TARGET := $1

\$(TARGET): \$(OBJS)
			\$(CC) \$(CFLAGS) \$(COPT) \$(OBJS) -o bin/\$(TARGET)

gperf: \$(OBJS)
	   \$(CC) \$(CFLAGS) \$(COPTD) \$(GPERF) \$(OBJS) -o bin/\$(TARGET)

clangd: \$(OBJS)
		\$(CCL) \$(CFLAGS) \$(COPTD) \$(CLDEBUG) \$(OBJS) -o bin/\$(TARGET)

gccd: \$(OBJS)
	  \$(CC) \$(CFLAGS) \$(COPTD) \$(CDEBUG) \$(OBJS) -o bin/\$(TARGET)

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
	echo "Creating $1/gproftools.sh"
	cat << EOF >> $1/gproftools.sh
#!/bin/sh

  if [ "\$#" -lt 2 ]; then
    echo "Usage: ./gproftools.sh [tool] [program]\ntools: pprof heapcheck cpuprofiler"
    exit 1
  fi

echo "Tool: \$1"

if [ "\$1" == "pprof" ]; then
  shift
  HEAPPROFILE=/tmp/heapprof \$@
fi

if [ "\$1" == "heapcheck" ]; then
  shift
  HEAPCHECK=normal \$@
fi

if [ "\$1" == "cpuprofiler" ]; then
  shift
  CPUPROFILE=/tmp/prof.out \$@
fi

EOF

	chmod +x $1/gproftools.sh
fi

if type "valgrind" > /dev/null ; then
	echo "Creating $1/valgrind.sh"

	cat << EOF >> $1/valgrind.sh
#!/bin/sh

if [ "\$#" -lt 2 ]; then
  echo "Usage: ./valgrind.sh [tool] [program]\ntools: memcheck callgrind"
  exit 1
fi

echo "Tool: \$1"

if [ "\$1" == "memcheck" ]; then
  shift
  valgrind --tool=memcheck --leak-check=full --show-reachable=yes --track-fds=yes --track-origins=yes --show-mismatched-frees=yes \$@
fi

if [ "\$1" == "callgrind" ]; then
  shift
  valgrind --tool=callgrind \$@
fi
EOF

	chmod +x $1/valgrind.sh
fi

if type "git" > /dev/null ; then
	echo "Creating $1/.gitignore"
	cat << EOF >> $1/.gitignore
bin/
build/
EOF
fi
