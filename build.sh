#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
DEFCONFIG="XOS_jalebi_defconfig"
KERNEL="zImage"

#halogen Kernel Details
BASE_VER="Caesium"
VER="-$(date +"%Y%m%d")-v1.4"
DEVICE="-$(echo $DEFCONFIG | cut -d _ -f 2)"
FINAL_VER="$BASE_VER""$DEVICE""$VER"

# Vars
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=MSF
export KBUILD_BUILD_HOST=jarvisbox

# Paths
KERNEL_DIR=`pwd`
RESOURCE_DIR="/home/msfjarvis/git-repos/halogenOS/android_kernel_cyanogen_msm8916"
ANYKERNEL_DIR="$RESOURCE_DIR/AnyKernel2"
TOOLCHAIN_DIR="/home/msfjarvis/git-repos/toolchains/arm-eabi-4.8/"
REPACK_DIR="$ANYKERNEL_DIR"
#PATCH_DIR="$ANYKERNEL_DIR/patch"
#MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/kernel_out/"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"

# Functions
function make_kernel {
#xu
                if [ $1 ];then make clean;fi
		make $DEFCONFIG $THREAD
		make $KERNEL $THREAD
                #make dtbs $THREAD
		[ -f $ZIMAGE_DIR/$KERNEL ] && cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage || exit 1
}

#function make_modules {
#		cd $KERNEL_DIR
#		make modules $THREAD
#		find $KERNEL_DIR -name '*.ko' -exec cp {} $MODULES_DIR/ \;
#		cd $MODULES_DIR
#        $STRIP --strip-unneeded *.ko
#        cd $KERNEL_DIR
#}

function make_dtb {
		$KERNEL_DIR/dtbToolCM -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
		cp -vr $KERNEL_DIR/arch/arm/boot/dt.img $REPACK_DIR/dtb
}

function make_zip {
    cd $REPACK_DIR
    zip -r9 $FINAL_VER.zip * -x README kernel_temp.zip
    mkdir -p $ZIP_MOVE
    cp  kernel_temp.zip $ZIP_MOVE/`echo $FINAL_VER`.zip
    cd $KERNEL_DIR
}

DATE_START=$(date +"%s")

# TC tasks
export CROSS_COMPILE=$TOOLCHAIN_DIR/bin/arm-eabi-
export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/lib/
#STRIP=$TOOLCHAIN_DIR/uber-4.9/bin/aarch64-linux-android-strip
#rm -rf $MODULES_DIR/*
rm -rf $ZIP_MOVE/*
#rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
cd $ANYKERNEL_DIR/tools
rm -rf $ZIMAGE_DIR/zImage
rm -rf dt.img
cd $KERNEL_DIR

# Make
make_kernel
make_dtb
#make_modules
make_zip

echo -e "${green}"
echo $FINAL_VER.zip
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "
