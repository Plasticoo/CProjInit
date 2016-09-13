CC := gcc
CFLAGS := -Wall -Wextra -ggdb -std=c11

BUILD_DIR := build

SOURCES := $(wildcard src/*.c)
OBJS := $(addprefix $(BUILD_DIR)/, main.o)

TARGET := project_test

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o bin/$(TARGET)

$(BUILD_DIR)/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm $(BUILD_DIR)/*.o
