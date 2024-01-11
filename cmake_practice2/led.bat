@echo off




 


if not exist build (
 echo Creating the build folder...
 mkdir build 
)
cd build
    echo Cleaning the build...
    cmake --build . --target clean-all
    cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE:PATH="..\my_toolchain.cmake" ..
    ninja
    cd ..
echo End of script
