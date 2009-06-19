ARCH=$(shell uname)
TAME=/usr/local/lib/sfslite/tame
RPCC=/usr/local/lib/sfslite/rpcc
CC=g++
STATIC=-static
ifeq (Darwin,${ARCH})
	STATIC=
	CC=g++-4.2
	CRYPTO_PP=pp
else
	CRYPTO_PP=++
endif
LFLAGS= -g $(STATIC) -O2 -Wall -Werror -Wno-unused -Wno-sign-compare
CFLAGS=$(LFLAGS) -x c++

INCLUDE= -I/usr/local/include/sfslite \
			-I/usr/local/include/c-client-src \
			-I/usr/include/crypto$(CRYPTO_PP) \
			-I./

SFS_LIB_DIR=/usr/local/lib/sfslite

LIBS= $(SFS_LIB_DIR)/libtame.a \
		$(SFS_LIB_DIR)/libsfscrypt.a \
		$(SFS_LIB_DIR)/libarpc.a \
		$(SFS_LIB_DIR)/libasync.a \
		-lresolv \
		-lcrypto$(CRYPTO_PP) \
		-ldl \
		-lzookeeper_st \
		-lpthread
		
OBJS=craq_rpc.o \
		ID_Value.o \
		Node.o \
		MemStorage.o \
		connection_pool.o \
		zoo_craq.o

all: manager \
	chain_node \
	test/manager_test \
	test/single_write_read \
	test/multi_read_write \
	test/writer \
	test/reader \
	test/single_reader \
	test/read_write \
	test/get_chain_info \
	test/transaction_tester \
	client/client


craq_rpc.o: craq_rpc.x
	$(RPCC) -h -o craq_rpc.h craq_rpc.x
	$(RPCC) -c -o craq_rpc.c craq_rpc.x
	$(CC) $(INCLUDE) $(CFLAGS) -c craq_rpc.c
	
connection_pool.o: connection_pool.h connection_pool.T craq_rpc.o
	$(TAME) -o connection_pool.TC connection_pool.T
	$(TAME) -o connection_pool.TH connection_pool.h
	$(CC) $(INCLUDE) $(CFLAGS) -c connection_pool.TC
ID_Value.o: ID_Value.h ID_Value.cpp craq_rpc.o
	$(CC) $(INCLUDE) $(CFLAGS) -c ID_Value.cpp
Node.o: Node.h Node.cpp ID_Value.o craq_rpc.o
	$(TAME) -o Node.TC Node.cpp
	$(CC) $(INCLUDE) $(CFLAGS) -c Node.TC
MemStorage.o: MemStorage.h MemStorage.cpp Storage.h
	$(TAME) -o MemStorage.TC MemStorage.cpp
	$(CC) $(INCLUDE) $(CFLAGS) -c MemStorage.TC
zoo_craq.o: zoo_craq.h zoo_craq.T
	$(TAME) -o zoo_craq.TC zoo_craq.T
	$(TAME) -o zoo_craq.TH zoo_craq.h
	$(CC) $(INCLUDE) $(CFLAGS) -c zoo_craq.TC

manager: manager.T $(OBJS)
	$(TAME) -o manager.TC manager.T
	$(CC) $(INCLUDE) $(CFLAGS) -c manager.TC
	$(CC) $(LFLAGS) -o manager manager.o $(OBJS) $(LIBS)
	
chain_node: chain_node.T $(OBJS)
	$(TAME) -o chain_node.TC chain_node.T
	$(CC) $(INCLUDE) $(CFLAGS) -c chain_node.TC
	$(CC) $(LFLAGS) -o chain_node chain_node.o $(OBJS) $(LIBS)
	
test/manager_test: test/manager_test.T $(OBJS)
	$(TAME) -o test/manager_test.TC test/manager_test.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/manager_test.o -c test/manager_test.TC
	$(CC) $(LFLAGS) -o test/manager_test test/manager_test.o $(OBJS) $(LIBS)
	
test/single_write_read: test/single_write_read.T $(OBJS)
	$(TAME) -o test/single_write_read.TC test/single_write_read.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/single_write_read.o -c test/single_write_read.TC
	$(CC) $(LFLAGS) -o test/single_write_read test/single_write_read.o $(OBJS) $(LIBS)
	
test/multi_read_write: test/multi_read_write.T $(OBJS)
	$(TAME) -o test/multi_read_write.TC test/multi_read_write.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/multi_read_write.o -c test/multi_read_write.TC
	$(CC) $(LFLAGS) -o test/multi_read_write test/multi_read_write.o $(OBJS) $(LIBS)
	
test/writer: test/writer.T $(OBJS)
	$(TAME) -o test/writer.TC test/writer.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/writer.o -c test/writer.TC
	$(CC) $(LFLAGS) -o test/writer test/writer.o $(OBJS) $(LIBS)
	
test/reader: test/reader.T $(OBJS)
	$(TAME) -o test/reader.TC test/reader.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/reader.o -c test/reader.TC
	$(CC) $(LFLAGS) -o test/reader test/reader.o $(OBJS) $(LIBS)
	
test/single_reader: test/single_reader.T $(OBJS)
	$(TAME) -o test/single_reader.TC test/single_reader.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/single_reader.o -c test/single_reader.TC
	$(CC) $(LFLAGS) -o test/single_reader test/single_reader.o $(OBJS) $(LIBS)
	
test/read_write: test/read_write.T $(OBJS)
	$(TAME) -o test/read_write.TC test/read_write.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/read_write.o -c test/read_write.TC
	$(CC) $(LFLAGS) -o test/read_write test/read_write.o $(OBJS) $(LIBS)
	
test/get_chain_info: test/get_chain_info.T $(OBJS)
	$(TAME) -o test/get_chain_info.TC test/get_chain_info.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/get_chain_info.o -c test/get_chain_info.TC
	$(CC) $(LFLAGS) -o test/get_chain_info test/get_chain_info.o $(OBJS) $(LIBS)
	
test/transaction_tester: test/transaction_tester.T $(OBJS)
	$(TAME) -o test/transaction_tester.TC test/transaction_tester.T
	$(CC) $(INCLUDE) $(CFLAGS) -o test/transaction_tester.o -c test/transaction_tester.TC
	$(CC) $(LFLAGS) -o test/transaction_tester test/transaction_tester.o $(OBJS) $(LIBS)
	
client/client: client/client.T $(OBJS)
	$(TAME) -o client/client.TC client/client.T
	$(CC) $(INCLUDE) $(CFLAGS) -o client/client.o -c client/client.TC
	$(CC) $(LFLAGS) -o client/client client/client.o $(OBJS) $(LIBS)
	
clean:
	rm -f chain_node chain_node.TC\
		manager manager.TC \
		craq_rpc.h craq_rpc.c \
		Node.TC MemStorage.TC connection_pool.TC connection_pool.TH \
		zoo_craq.TC zoo_craq.TH \
		test/manager_test.TC test/manager_test \
		test/single_write_read.TC test/single_write_read \
		test/multi_read_write.TC test/multi_read_write \
		test/writer.TC test/writer \
		test/reader.TC test/reader \
		test/single_reader.TC test/single_reader \
		test/read_write.TC test/read_write \
		test/get_chain_info.TC test/get_chain_info \
		test/transaction_tester.TC test/transaction_tester \
		client/client client/client.TC client/client.o \
		*.o test/*.o
