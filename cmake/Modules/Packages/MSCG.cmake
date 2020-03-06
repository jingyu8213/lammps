if(PKG_MSCG)
  find_package(GSL REQUIRED)
  find_package(MSCG QUIET)
  if(MSGC_FOUND)
    set(DOWNLOAD_MSCG_DEFAULT OFF)
  else()
    set(DOWNLOAD_MSCG_DEFAULT ON)
  endif()
  option(DOWNLOAD_MSCG "Download MSCG library instead of using an already installed one)" ${DOWNLOAD_MSCG_DEFAULT})
  if(DOWNLOAD_MSCG)
    if(CMAKE_GENERATOR STREQUAL "Ninja")
      message(FATAL_ERROR "Cannot build downloaded MSCG library with Ninja build tool")
    endif()
    include(ExternalProject)
    if(NOT LAPACK_FOUND)
      set(EXTRA_MSCG_OPTS "-DLAPACK_LIBRARIES=${CMAKE_CURRENT_BINARY_DIR}/liblinalg.a")
    endif()
    ExternalProject_Add(mscg_build
      URL https://github.com/uchicago-voth/MSCG-release/archive/1.7.3.1.tar.gz
      URL_MD5 8c45e269ee13f60b303edd7823866a91
      SOURCE_SUBDIR src/CMake
      CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> ${CMAKE_REQUEST_PIC} ${EXTRA_MSCG_OPTS}
      BUILD_COMMAND make mscg INSTALL_COMMAND ""
      )
    ExternalProject_get_property(mscg_build BINARY_DIR)
    set(MSCG_LIBRARIES ${BINARY_DIR}/libmscg.a)
    ExternalProject_get_property(mscg_build SOURCE_DIR)
    set(MSCG_INCLUDE_DIRS ${SOURCE_DIR}/src)
    list(APPEND LAMMPS_DEPS mscg_build)
    if(NOT LAPACK_FOUND)
      file(MAKE_DIRECTORY ${MSCG_INCLUDE_DIRS})
      add_dependencies(mscg_build linalg)
    endif()
  else()
    find_package(MSCG)
    if(NOT MSCG_FOUND)
      message(FATAL_ERROR "MSCG not found, help CMake to find it by setting MSCG_LIBRARY and MSCG_INCLUDE_DIRS, or set DOWNLOAD_MSCG=ON to download it")
    endif()
  endif()
  list(APPEND LAMMPS_LINK_LIBS ${MSCG_LIBRARIES} ${GSL_LIBRARIES} ${LAPACK_LIBRARIES})
  include_directories(${MSCG_INCLUDE_DIRS})
endif()
