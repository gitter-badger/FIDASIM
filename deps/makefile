SHELL = /bin/bash

DEPS_DIR = $(FIDASIM_DIR)/deps

hdf5: 
	tar -zxvf $(DEPS_DIR)/hdf5-1.8.16.tar.gz > /dev/null 2>&1
	cd $(DEPS_DIR)/hdf5-1.8.16; ./configure --prefix=$(DEPS_DIR)/hdf5 --enable-fortran --enable-cxx > /dev/null 2>&1
	cd $(DEPS_DIR)/hdf5-1.8.16; make; make install > /dev/null 2>&1
	cp $(DEPS_DIR)/hdf5-1.8.16/COPYING $(DEPS_DIR)/hdf5
	cp $(DEPS_DIR)/hdf5-1.8.16/README.txt $(DEPS_DIR)/hdf5
	-rm -rf hdf5-1.8.16

clean:
	-rm -rf hdf5 hdf5-1.8.16 
