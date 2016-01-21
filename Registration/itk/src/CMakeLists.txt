
cmake_minimum_required(VERSION 2.8)

project(itkReg)

find_package(ITK REQUIRED)
include(${ITK_USE_FILE})

add_executable(itkReg MACOSX_BUNDLE itkReg.cxx)

target_link_libraries(itkReg ${ITK_LIBRARIES})