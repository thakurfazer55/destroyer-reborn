#
 # Copyright © 2016, Varun Chitre "varun.chitre15" <varun.chitre15@gmail.com>
 #
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #
KERNEL_DIR=$pwd
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/dtbToolCM
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
# Modify the following variable if you want to build
export CROSS_COMPILE=/build/build/aokp/kernel/cyanogen/uber/bin/aarch64-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="PreetPatelcMDev"
export KBUILD_BUILD_HOST="RewirePC"
STRIP=/build/build/aokp/kernel/cyanogen/uber/bin/aarch64-linux-android-strip
MODULES_DIR=$KERNEL_DIR/builds
 
compile_kernel ()
{
echo -e "$blue***********************************************"
echo "             Compiling ReWire kernel        "
echo -e "***********************************************$nocol"
rm -f $KERN_IMG
make lineageos_tomato_defconfig
make -j4
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
 
 
strip_modules
}
 
strip_modules ()
{
echo "Copying things"
rm $MODULES_DIR/*
cp $KERNEL_DIR/drivers/staging/prima/wlan.ko $MODULES_DIR
cp $KERNEL_DIR/arch/arm64/boot/Image $MODULES_DIR
cp $KERNEL_DIR/arch/arm64/boot/dt.img $MODULES_DIR
 
cd $KERNEL_DIR
}
 
case $1 in
clean)
make ARCH=arm64 -j3 clean mrproper
rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
;;
dt)
make lineageos_tomato_defconfig -j3
make dtbs -j3
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
;;
*)
compile_kernel
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
