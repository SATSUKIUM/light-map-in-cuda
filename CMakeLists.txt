
cmake_minimum_required(VERSION 3.18)

project(light-map-in-cuda LANGUAGES CXX CUDA)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

message(STATUS "CMAKE_CUDA_ARCHITECTURES: ${CMAKE_CUDA_ARCHITECTURES}")

# ROOT dependency
find_package(ROOT REQUIRED COMPONENTS Hist RIO Tree Graf Gpad)

# ROOT RPATH
set(CMAKE_BUILD_RPATH "${ROOT_LIBRARY_DIR}")
set(CMAKE_INSTALL_RPATH "${ROOT_LIBRARY_DIR}")

# ============================================================
# cudamap library
# ============================================================

add_library(cudamap STATIC
    src/cudamap.cu
)

target_include_directories(cudamap
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
)

set_target_properties(cudamap PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
    POSITION_INDEPENDENT_CODE ON
)

# ============================================================
# Skeleton executable
# ============================================================

add_executable(skeleton
    skeleton.cu
)

target_link_libraries(skeleton
    PRIVATE
        cudamap
        ROOT::Hist
        ROOT::RIO
        ROOT::Tree
        ROOT::Graf
        ROOT::Gpad
)

set_target_properties(skeleton PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
    CUDA_RESOLVE_DEVICE_SYMBOLS ON
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin"
)

# ============================================================
# Install
# ============================================================

install(TARGETS cudamap
    ARCHIVE DESTINATION lib
)

install(FILES
    include/cudamap.h
    DESTINATION include
)

# install(TARGETS skeleton
#     RUNTIME DESTINATION bin
# )
