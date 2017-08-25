#!/bin/bash

### This script will install Gnu Radio from current GIT sources
### You will require Internet access from the computer on which this
### script runs. You will also require SUDO access. You will require
### approximately 500MB of free disk space to perform the build.

DATE=`date +%Y%m%d%H%M%S`
COMMAND_LINE_ARGS="$@"
SOURCE_DIR=`pwd`"/gnuradio_source_dir_"$DATE
BUILD_DIR="build_dir"
CMAKE_OPTIONS=""
SCRIPT_NAME=$0
PKG_LIST=""

### Print usage.
function help 
{
cat <<!EOF!
		
Usage: $SCRIPT_NAME 

	-h  |--help                  - Print usage and available functions.
	-ip |--install_prerequisites - Install prerequisites.
	-qi |--quick_install         - Installing gnuradio, hackRF, bladeRF using a package manager.
	-gb |--gnuradio_build        - Build only Gnu Radio.
	-ba |--build_all             - Install all prerequisites and build GNU Radio soft.
	-chd|--check_dependecies     - Check the list of GNU Radio dependencies.

	available functions are:

	sudo_check                   - Check SUDO privileges.
	get_pkg_list                 - Set variable PKG_LIST to packages names. 
	install_prerequisites 	     - Install prerequisites.
	install_balde_r_f            - Installing bladeRF via package manager.
	gnuradio_build  	     - Build only Gnu Radio.
	check_package       	     - Check package's existence in package repositories.
	check_gnuradio_dependencies  - Check the list of GNU Radio dependencies.
	remove_packages              - Remove packages befor installation.
	parse_command_line_arguments - Parse command-line arguments.
	build_all             	     - Do all functions.
	build_hackrf                 - Build and Install the HackRF Software.
	build_rtl_sdr                - Build rtl-sdr module.
	build_gr_iqbal               - Build gr-iqbal module.
	build_blade_r_f              - Build bladeRF module.
	build_airspy                 - Build and Install the airspy/host Software.
	build_osmosdr                - Building gr-osmosdr.
	quick_install                - Installing gnuradio, hackRF, bladeRF using a package manager.
	checkout_modules             - Checkout sources from git repositories(rtl-sdr, gr-osmosdr, gr-iqbal,
				       hackrf, bladeRF and airspy).
	set_env_vars                 - Setting environment variables.

!EOF!
}

### Check SUDO privileges.
function sudo_check 
{
	if [ $USER != root -o $UID -ne 0 ]
	then
		echo You have no permission to run \'$SCRIPT_NAME\' as non-root user.
		echo Exiting.  Please ensure that you have SUDO privileges on this system!
		exit
	fi
}

### Check package's existence in package repositories.
function check_package 
{
	echo Checking for package $1
	if [ `dpkg --get-selections | grep $1 | wc -l` -eq 0 ]
	then
		echo Failed to find package \'$1\' in known package repositories
		return 1
	fi
	return 0
}

### Remove packages befor installation.
function remove_packages
{
	sudo apt-get -y purge 'gnuradio-*' 
        sudo apt-get -y purge 'libgruel-*'
        sudo apt-get -y purge 'libgruel*'
        sudo apt-get -y purge 'libgruel0*'
        sudo apt-get -y purge 'libgnuradio*' 
        sudo apt-get -y purge 'python-gnuradio*' 
}

### Set package list.
function get_pkg_list
{
	case `grep DISTRIB_RELEASE /etc/lsb-release` in
    		*15.*|*16.*)
			PKG_LIST="libqwt6 libfontconfig1-dev libxrender-dev
			libpulse-dev swig g++ automake autoconf libtool
			python-dev libfftw3-dev libcppunit-dev libboost-all-dev
			libusb-dev libusb-1.0-0-dev fort77 libsdl1.2-dev
			python-wxgtk2.8 git-core libqt4-dev python-numpy ccache
			python-opengl libgsl0-dev python-cheetah python-mako
			python-lxml doxygen qt4-default qt4-dev-tools
			libusb-1.0-0-dev libqwt5-qt4-dev libqwtplot3d-qt4-dev
			pyqt4-dev-tools python-qwt5-qt4 cmake git-core wget
			libxi-dev python-docutils gtk2-engines-pixbuf
			r-base-dev python-tk liborc-0.4-0 liborc-0.4-dev
			libasound2-dev python-gtk2 libzmq libzmq-dev libzmq1
			libzmq1-dev python-requests python-sphinx comedi-dev
			python-zmq libncurses5 libncurses5-dev python-wxgtk3.0
			libboost-program-options-dev libboost-thread-dev
			libboost-system-dev libboost-dev liblog4cpp5-dev
			build-essential libusb-1.0-0-dev"
                        CMAKE_FLAG1=-DPythonLibs_FIND_VERSION:STRING="2.7"
                        CMAKE_FLAG2=-DPythonInterp_FIND_VERSION:STRING="2.7"
                        ;;
                                        
                *13.*|*14.*)
			PKG_LIST="libfontconfig1-dev libxrender-dev
			libpulse-dev swig g++ automake autoconf libtool
			python-dev libfftw3-dev libcppunit-dev libboost-all-dev
			libusb-dev libusb-1.0-0-dev fort77 libsdl1.2-dev
			python-wxgtk2.8 git-core libqt4-dev python-numpy ccache
			python-opengl libgsl0-dev python-cheetah python-mako
			python-lxml doxygen qt4-default qt4-dev-tools
			libusb-1.0-0-dev libqwt5-qt4-dev libqwtplot3d-qt4-dev
			pyqt4-dev-tools python-qwt5-qt4 cmake git-core wget
			libxi-dev python-docutils gtk2-engines-pixbuf
			r-base-dev python-tk liborc-0.4-0 liborc-0.4-dev
			libasound2-dev python-gtk2 libzmq1 libzmq1-dev libzmq
			libzmq-dev python-requests libncurses5 libncurses5-devi
			libboost-program-options-dev libboost-thread-dev
			libboost-system-dev libboost-devi liblog4cpp5-dev
			build-essential libusb-1.0-0-dev"
                        CMAKE_FLAG1=-DPythonLibs_FIND_VERSION:STRING="2.7"
			;;
		*)
                        echo Your Ubuntu release not supported--cannot proceed
			;;
		esac
}

### Check the list of GNU Radio dependencies.
function check_gnuradio_dependencies
{
	get_pkg_list
	for package in $PKG_LIST
	do
		check_package $package
	done
}

### Installing prerequisites.
function install_prerequisites 
{
	sudo_check
	remove_packages
	get_pkg_list
	echo Installing prerequisites.
	for package in $PKG_LIST
	do
		check_package $package
		if [ "$?" -ne 0 ]
		then
			echo Starting installation $package
			apt-get -y install $package
		fi
	done
}

### Installing bladeRF via package manager.
function install_balde_r_f
{
	sudo add-apt-repository ppa:bladerf/bladerf
	apt-get -y install bladerf
	apt-get -y install libbladerf-dev
	apt-get -y install bladerf-firmware-fx3
	apt-get -y install bladerf-fpga-hostedx40   # for the 40 kLE hardware
	apt-get -y install bladerf-fpga-hostedx115  # for the 115 kLE hardware
}

### Installing gnuradio, hackRF, bladeRF using a package manager
function quick_install
{
	sudo_check
	apt-get update
	apt-get upgrade -y
	install_prerequisites 
	
	### Installing GNU Radio
	apt-get -y install gnuradio
	
	### Installing gr-qbal, gr-osmosdr, gr-rds, gr-air-modes.
	apt-get -y install gr-iqbal
	apt-get -y install gr-air-modes
	apt-get -y install gr-gr-osmosdr
	apt-get -y install gr-rds
	
	### Installing hackRF
	apt-get -y install hackrf
	
	### Installing bladeRF
	install_balde_r_f
}

### Checkout sources from git repositories(rtl-sdr, gr-osmosdr, gr-iqbal,
### hackrf, bladeRF and airspy).
function checkout_modules
{
  	mkdir $SOURCE_DIR && cd $SOURCE_DIR
	git clone --progress --recursive http://git.gnuradio.org/git/gnuradio.git
	SOURCE_DIR=$SOURCE_DIR/gnuradio
	cd $SOURCE_DIR
	git checkout -b v3.7.10
  	git clone --progress  https://github.com/EttusResearch/uhd
  	rm -rf gr-osmosdr
  	git clone --progress git://git.osmocom.org/gr-osmosdr
  	rm -rf rtl-sdr
  	git clone --progress git://github.com/patchvonbraun/rtl-sdr
  	git clone --progress git://git.osmocom.org/gr-iqbal.git
  	rm -rf hackrf
  	git clone --progress https://github.com/mossmann/hackrf.git
  	rm -rf bladeRF
  	git clone https://github.com/Nuand/bladeRF.git
  	rm -rf airpsy; mkdir airspy; cd airspy
  	git clone https://github.com/airspy/host
}

### Setting environment variables.
function set_env_vars
{
  echo "#!/bin/bash
	      # Add GNU Radio binaries to the search path
		    GNURADIO_PATH=/opt/gnuradio
		    export PATH=$PATH:$GNURADIO_PATH/bin

	      # Add GNU Radio python libraries to python search path
		    if [ $PYTHONPATH ]; then
        		export PYTHONPATH=$PYTHONPATH:$GNURADIO_PATH/lib/python2.7/dist-packages
		    else
        		export PYTHONPATH=$GNURADIO_PATH/lib/python2.7/dist-packages
		    fi " > /etc/profile.d/gnuradio.sh
	source /etc/profile.d/gnuradio.sh
  echo "/opt/gnuradio/lib" > /etc/ld.so.conf.d/gnuradio.conf
}

### Build only Gnu Radio.
function gnuradio_build
{
	sudo_check
  	checkout_modules
	mkdir -p $SOURCE_DIR/$BUILD_DIR
        cd $SOURCE_DIR/$BUILD_DIR
  	echo Building gnuradio... 
	#cmake -DCMAKE_INSTALL_PREFIX=/opt/gnuradio $SOURCE_DIR
	cmake $SOURCE_DIR $CMAKE_FLAG1 $CMAKE_FLAG2
        make && make test
        make install
  	#set_env_vars
	echo Done building gnuradio.
	ldconfig -v | grep gnuradio
}

### Building gr-osmosdr.
function build_osmosdr
{
  	cd $SOURCE_DIR
  	cd gr-osmosdr 
  	echo Building gr-osmosdr... 
  	mkdir build
  	cd build
  	cmake ../
	make -j4 && sudo make install && sudo ldconfig
	#cmake -DCMAKE_INSTALL_PREFIX=/opt/gnuradio ../
	cmake ../ $CMAKE_FLAG1 $CMAKE_FLAG2
	make -C docs
	ldconfig
	echo Done building gr-osmosdr.
}

### Build rtl-sdr module.
function build_rtl_sdr
{
	if [ ! -d rtl-sdr ]
	then
		echo You do not appear to have the \'rtl-sdr\' directory
	fi
	if [ "$?" -ne 0 ]
	then
		echo Building rtl-sdr...
		cd rtl-sdr
		cmake $CMAKE_FLAG1 $CMAKE_FLAG2 ../ 
		make clean; make; make install
		echo Done rtl-sdr...
	fi
}

### Build gr-iqbal module.
function build_gr_iqbal
{
	if [ ! -d gr-iqbal ]
	then
		echo You do not appear to have the \'gr-iqbal\' directory
	fi
	if [ "$?" -ne 0 ]
	then
		echo Building gr-iqbal...
		cd gr-iqbal
		mkdir build && cd build
		#cmake -DCMAKE_INSTALL_PREFIX=/opt/gnuradio ../
		cmake ../
		make -j4; make install
		ldconfig
		echo Done gr-iqbal...
	fi
}

### Build bladeRF module.
function build_blade_r_f
{
	if [ ! -d bladeRF ]
	then
		echo You do not appear to have the \'bladeRF\' directory
	fi
	if [ "$?" -ne 0 ]
	then
		echo Building rtl-sdr...
		cd bladeRF/host
		mkdir build && cd build
		cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DINSTALL_UDEV_RULES=ON ../
		make; make install
		ldconfig
		echo Done bladeRF...
	fi
}

### Build and Install the HackRF Software.
function build_hackrf
{
	if [ ! -d hackrf ]
	then
		echo You do not appear to have the \'hackrf\' directory
	fi
	if [ "$?" -ne 0 ]
	then
		echo Building hackrf...
		cd hackrf/host
		mkdir build && cd build
		cmake ../ -DINSTALL_UDEV_RULES=ON
		make; make install
		ldconfig
		echo Done hackrf...
	fi
}

### Build and Install the airspy/host Software.
function build_airspy
{
	if [ ! -d airspy/host ]
	then
		echo You do not appear to have the \'airspy/host\' directory
	fi
	if [ "$?" -ne 0 ]
	then
		echo Building airspy/host...
		cd hackrf/host
		mkdir build && cd build
		cmake ../ $CMAKE_FLAG1 $CMAKE_FLAG2 
		make; make install
		ldconfig
		echo airspy/host...
	fi
}

### Build all modules.
function build_all_modules
{
  	cd $SOURCE_DIR
  	build_rtl_sdr
	build_hackrf
	build_gr_iqbal
	build_blade_r_f
	build_airspy
	build_osmosdr
}

### Install all prerequisites and build GNU Radio tool.
function build_all 
{
	install_prerequisites
	gnuradio_build
	build_all_modules
}

### Parse command line arguments
function parse_command_line_arguments
{
	if [ "$COMMAND_LINE_ARGS" = "" ]
  	then
		echo  No arguments provided.
		help
		exit 1
	fi
	for i in $COMMAND_LINE_ARGS
	do
		case $i in
			-h|--help)
				help
				exit
			;;
			-chd|--check_dependecies)
				check_gnuradio_dependencies
				shift
			;;
			-qi|--quick_install)
				quick_install
				shift
			;;
			-ip |--install_prerequisites)
				install_prerequisites
				shift
			;;
			-gb |--gnuradio_build)
				gnuradio_build
				shift
			;;
			-ba |--build_all)
				build_all
				shift
			;;
			-*|*)
				echo Unrecognized option: $1
				help
				exit
				break
			;;
		esac
	done
}

### Main function.
function main 
{       
	parse_command_line_arguments
}

main
