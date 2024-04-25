################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.s $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"C:/ti/ccs1220/ccs/tools/compiler/ti-cgt-armllvm_2.1.3.LTS/bin/tiarmclang.exe" -c -march=thumbv7em -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -O0 -I"L:/nfox18212.github.io" -I"C:/ti/ccs1220/ccs/tools/compiler/ti-cgt-armllvm_2.1.3.LTS/include" -Dccs="ccs" -DPART_TM4C123GH6PM -gdwarf-3 -Wall -Werror=ti-pragmas -Werror=ti-macros -Werror=ti-intrinsics -fno-short-wchar -fcommon -ffunction-sections -fdata-sections $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '

%.o: ../%.c $(GEN_OPTS) | $(GEN_FILES) $(GEN_MISC_FILES)
	@echo 'Building file: "$<"'
	@echo 'Invoking: Arm Compiler'
	"C:/ti/ccs1220/ccs/tools/compiler/ti-cgt-armllvm_2.1.3.LTS/bin/tiarmclang.exe" -c -march=thumbv7em -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -mlittle-endian -mthumb -O0 -I"L:/nfox18212.github.io" -I"C:/ti/ccs1220/ccs/tools/compiler/ti-cgt-armllvm_2.1.3.LTS/include" -Dccs="ccs" -DPART_TM4C123GH6PM -gdwarf-3 -Wall -Werror=ti-pragmas -Werror=ti-macros -Werror=ti-intrinsics -fno-short-wchar -fcommon -ffunction-sections -fdata-sections -MMD -MP -MF"$(basename $(<F)).d_raw" -MT"$(@)" -std=gnu90 $(GEN_OPTS__FLAG) -o"$@" "$<"
	@echo 'Finished building: "$<"'
	@echo ' '


