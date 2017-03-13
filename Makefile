#
# Copyright (c) 2017 Intel Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_dir = include

ifndef NDEBUG
CFLAGS = -g -I../$(include_dir)
else
CFLAGS = -O2 -DNDEBUG -I../$(include_dir)
endif

headers = $(include_dir)/ops.h \
          $(include_dir)/domains.h \
          $(include_dir)/ops_names.h \
          $(include_dir)/domains_names.h

io_monitor_objs = io_monitor/io_monitor.o io_monitor/intercept_functions.o

all: mq_listener/mq_listener io_monitor/io_monitor.so

#build automatic headers

$(include_dir)/ops_names.h: $(include_dir)/ops.h
	@echo -n  "generating header $@ ... "
	@cd $(include_dir) ; cat ops.h | ./enum_to_strings.sh ops_names >ops_names.h
	@echo OK

$(include_dir)/domains_names.h: $(include_dir)/domains.h
	@echo -n  "generating header $@ ... "
	@cd $(include_dir) ; cat domains.h | ./enum_to_strings.sh domains_names >domains_names.h
	@echo OK

#build io monitor

io_monitor/intercept_functions.o: io_monitor/intercept_functions.c
	@echo -n  "generating $@ ... "
	@cd io_monitor ; gcc $(CFLAGS) -c intercept_functions.c -o intercept_functions.o
	@echo OK


io_monitor/io_monitor.so: io_monitor/io_monitor.c $(headers) io_monitor/intercept_functions.o
	@echo -n  "generating $@ ... "
	@cd io_monitor ; gcc $(CFLAGS) -shared -fPIC io_monitor.c -o io_monitor.so -ldl
	@echo OK

#build listener

mq_listener/mq_listener: mq_listener/mq_listener.c $(headers)
	@echo -n  "generating $@ ... "
	@cd mq_listener ; gcc $(CFLAGS) mq_listener.c -o mq_listener
	@echo OK

clean:
	rm -f mq_listener/mq_listener
	rm -f io_monitor/io_monitor.so
	rm -f $(include_dir)/domains_names.h
	rm -f $(include_dir)/ops_names.h
