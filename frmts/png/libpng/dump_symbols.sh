#!/bin/sh
# GDAL specific script to extract exported libpng symbols that can be renamed
# to keep them internal to GDAL as much as possible

gcc png.c \
	pngerror.c \
	pngget.c \
	pngmem.c \
	pngpread.c \
	pngread.c \
	pngrio.c \
	pngrtran.c \
	pngrutil.c \
	pngset.c \
	pngtrans.c \
	pngwio.c \
	pngwrite.c \
	pngwtran.c \
	pngwutil.c \
	-I. -fPIC -shared -o libpng.so -DPNG_IMPEXP= -DPNG_ARM_NEON_IMPLEMENTATION=0 -DPNG_ARM_NEON_OPT=0

OUT_FILE=gdal_libpng_symbol_rename.h

rm $OUT_FILE 2>/dev/null

echo "/* This is a generated file by dump_symbols.h. *DO NOT EDIT MANUALLY !* */" >> $OUT_FILE

symbol_list=$(objdump -t libpng.so  | grep .text | awk '{print $6}' | grep -v -e "\.text" -e __do_global -e __bss_start -e _edata -e call_gmon_start -e register_tm_clones -e png_gt | sort)
for symbol in $symbol_list
do
    echo "#define $symbol gdal_$symbol" >> $OUT_FILE
done

rodata_symbol_list=$(objdump -t libpng.so  | grep "\\.rodata" |  awk '{print $6}' | grep -v "\\.")
for symbol in $rodata_symbol_list
do
    echo "#define $symbol gdal_$symbol" >> $OUT_FILE
done

data_symbol_list=$(objdump -t libpng.so  | grep "\\.data"  | grep -v -e __dso_handle -e __TMC_END__ | awk '{print $6}' | grep -v "\\.")
for symbol in $data_symbol_list
do
    echo "#define $symbol gdal_$symbol" >> $OUT_FILE
done

bss_symbol_list=$(objdump -t libpng.so  | grep "\\.bss" |  awk '{print $6}' | grep -v "\\.")
for symbol in $bss_symbol_list
do
    echo "#define $symbol gdal_$symbol" >> $OUT_FILE
done

rm libpng.so
