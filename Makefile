##
## Makefile for logtop
##
## Made by julien palard
## Login   <logtop@mandark.fr>
##

VERSION = 0.7.0
MINOR = 0
RELEASE = 0

NAME = logtop
UNAME=$(shell uname -s)
ifeq ($(UNAME),Darwin)
  LINKERNAME = lib$(NAME).dylib
else
  LINKERNAME = lib$(NAME).so
endif
SONAME=$(LINKERNAME).$(VERSION)
REALNAME=$(SONAME).$(MINOR).$(RELEASE)

LIB_SRC = src/avl.c src/history.c \
          src/logtop.c src/libavl/avl.c
SRC = $(LIB_SRC) src/curses.c src/stdout.c src/main.c

LIB_OBJ = $(LIB_SRC:.c=.o)
OBJ = $(SRC:.c=.o)


override INCLUDE += .
LIB = $(shell pkg-config --libs ncursesw)  #-lefence
CFLAGS += -O3 -Wall -fPIC -Wextra -pedantic -Wstrict-prototypes -I$(INCLUDE) $(shell pkg-config --cflags ncursesw)
RM = rm -fr
LDFLAGS =

ifeq ($(LIBFUZZ),1)
	CC = clang
	CFLAGS += -fsanitize=fuzzer-no-link
	LDFLAGS += -fsanitize=fuzzer-no-link
else
	CC = gcc
endif

$(NAME):	$(OBJ)
		$(CC) -o $(NAME) $(OBJ) $(LIB) $(LDFLAGS)

lib$(NAME): $(LIB_OBJ)
		$(CC) $(CFLAGS) --shared -o $(LINKERNAME) $(OBJ) $(LIB) $(LDFLAGS)

install:	$(NAME)
		mkdir -p $(DESTDIR)/usr/bin/
		cp $(NAME) $(DESTDIR)/usr/bin/

python-module:
		swig -python *.i
		python ./setup.py build_ext --inplace

python3-module:
		swig -python *.i
		python3 ./setup.py build_ext --inplace

all:
		@make $(NAME)
		@make lib$(NAME)

.c.o:
		$(CC) -c $(CFLAGS) $< -o $(<:.c=.o)

clean:
		$(RM) $(NAME) src/*~ src/#*# src/*.o src/*.core \
				src/libavl/*.o _logtop.* liblogtop.* \
				logtop.py *.pyc build/ logtop_wrap.c

re:		clean all

check-syntax:
		gcc -Isrc -Wall -Wextra -ansi -pedantic -o /dev/null -S ${CHK_SOURCES}
