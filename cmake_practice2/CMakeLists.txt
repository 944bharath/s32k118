cmake_minimum_required(VERSION 3.10)
project(main_project VERSION 1.0 LANGUAGES C)
cmake_policy(SET CMP0079 NEW)

set(CMAKE_TOOLCHAIN_FILE C:/Users/Bharath/Desktop/cmake_practice/cmake_practice2/my_toolchain.cmake)
set(CPU_S32K118 1)
set(CPU_PARAMETERS
    -mcpu=cortex-m0plus
    -mthumb
    -mfloat-abi=soft)
	
include_directories(${CMAKE_BINARY_DIR})
include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/Settings/Startup_Code)
configure_file(config.h.in ${CMAKE_BINARY_DIR}/config.h)

set(LINKER1
    ${CMAKE_CURRENT_SOURCE_DIR}/Settings/Linker_Files/S32K118_25_flash.ld
    )
set(LINKER2
    ${CMAKE_CURRENT_SOURCE_DIR}/Settings/Linker_Files/S32K118_25_ram.ld
    )
set(START_UP
    ${CMAKE_CURRENT_SOURCE_DIR}/Settings/Startup_Code/startup_S32K118.S
    )

#enable_language (C CXX ASM)
set(CMAKE_ASM_COMPILER nasm)
set (CMAKE_C_STANDARD 11)
set (CMAKE_C_STANDARD_REQUIRED ON)
set (CMAKE_C_EXTENSIONS ON)
set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED ON)
set (CMAKE_CXX_EXTENSIONS ON)
#set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mthumb -mthumb-interwork -mcpu=cortex-m4")
set(CONFIGURATIONS FLASH RAM)

foreach(CONFIG ${CONFIGURATIONS} )
if(CONFIG STREQUAL "FLASH" )
set( LINKER_SCRIPT ${LINKER1} )
else()
set( LINKER_SCRIPT ${LINKER2} )
endif()

set(SOURCE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
  )

set(INC
    ${CMAKE_CURRENT_SOURCE_DIR}/inc
  )

file(GLOB_RECURSE CFILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.c ${INC})

file(GLOB_RECURSE MAIN ${CMAKE_CURRENT_SOURCE_DIR}/source/*.c)

add_executable(main_project_${CONFIG} ${CFILES} ${START_UP} ${MAIN})
target_compile_options(main_project_${CONFIG} PRIVATE ${CPU_PARAMETERS})

target_include_directories(main_project_${CONFIG} PRIVATE ${INC})
target_link_options(main_project_${CONFIG} PRIVATE -T${LINKER_SCRIPT} ${CPU_PARAMETERS} ${START_UP} 
	-lc
    -lnosys
    -Wl,-Map=output.map )
#set_target_properties(main_project_${CONFIG} PROPERTIES SUFFIX ".elf")
add_custom_command(TARGET main_project_${CONFIG} POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:main_project_${CONFIG}>
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:main_project_${CONFIG}> main_project_${CONFIG}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:main_project_${CONFIG}> main_project_${CONFIG}.bin)

 

if (${DUMP_ASM})
    add_custom_command(TARGET main_project_${CONFIG} POST_BUILD
        COMMAND ${CMAKE_OBJDUMP} -D $<TARGET_FILE:main_project_${CONFIG}> > main_project_${CONFIG}.S)
endif()
endforeach()

# Add a custom clean target

add_custom_target(clean-all
  COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target clean
  COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/CMakeFiles
  COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/CMakeCache.txt
  COMMENT "Clean all build artifacts"
)