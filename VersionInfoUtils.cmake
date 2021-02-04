set(CUR_ACTIVE_DIR ${CMAKE_CURRENT_LIST_DIR}) 

macro(m_generate_version_info_sources)
    set(prefix ARG)
    set(noValues "")
    set(singleValues
        CPP_NAMESPACE
        OUT_H_DIR
        OUT_CPP_DIR
        MAJOR
        MINOR
        PATCH
        TWEAK
        FULL_VERSION
        CUR_DIR
        )
    set(multiValues BUILD_TYPES)
    
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS singleValues multiValues)
        set(${arg} ${${prefix}_${arg}})
    endforeach()

    set(H_FILE_LIST "version.h" "version_info.h")
    set(CPP_FILE_LIST "version_info.cpp")

    set(IN_PATH "${CUR_ACTIVE_DIR}/SourceTemplates")
    set(OUT_FILE_NAMES
        "build_type_defs.h"
        "build_type.h"
        "git.h"
        "version_info.h"
        "version.h"
        "version_info.cpp"
        )
    foreach(OUT_NAME IN LISTS OUT_FILE_NAMES)
        list(APPEND IN_PATH_LIST "${IN_PATH}/${OUT_NAME}.in")
        get_filename_component(F_EXT ${OUT_NAME} LAST_EXT)
        if(F_EXT STREQUAL ".h")
            list(APPEND OUT_PATH_LIST "${OUT_H_DIR}/${OUT_NAME}")
            list(APPEND VERSION_INFO_HEADERS "${OUT_H_DIR}/${OUT_NAME}")
        elseif(F_EXT STREQUAL ".cpp")
            list(APPEND OUT_PATH_LIST "${OUT_CPP_DIR}/${OUT_NAME}")
            list(APPEND VERSION_INFO_SOURCES "${OUT_CPP_DIR}/${OUT_NAME}")
        else()
            message(FATAL_ERROR "Invalid file extension: ${F_EXT} Permitted extensions are: .h, .cpp")
        endif()
    endforeach()
    
    include(${CUR_ACTIVE_DIR}/GenerateByConfigure.cmake)

    add_custom_target("${CPP_NAMESPACE}_updateVersionInfo"
        COMMAND ${CMAKE_COMMAND}
        -DCPP_NAMESPACE=${CPP_NAMESPACE}
        -DIN_PATH_LIST="${IN_PATH_LIST}"
        -DOUT_PATH_LIST="${OUT_PATH_LIST}"
        -DMAJOR=${MAJOR}
        -DMINOR=${MINOR}
        -DPATCH=${PATCH}
        -DTWEAK=${TWEAK}
        -DFULL_VERSION=${FULL_VERSION}
        -DCUR_ACTIVE_DIR=${CUR_ACTIVE_DIR}
        -DCUR_DIR=${CUR_DIR}
        -DBUILD_TYPES="${BUILD_TYPES}"
        -P ${CUR_ACTIVE_DIR}/GenerateByConfigure.cmake
        COMMENT "Updating source files ..."
        BYPRODUCTS ${OUT_PATH_LIST}
    )

    add_library("${CPP_NAMESPACE}_versionInfo" STATIC ${VERSION_INFO_SOURCES} ${VERSION_INFO_HEADERS})
    target_compile_definitions("${CPP_NAMESPACE}_versionInfo" PUBLIC $<$<CONFIG:Release>:RELEASE> $<$<CONFIG:Debug>:DEBUG>)
    set_target_properties("${CPP_NAMESPACE}_versionInfo" PROPERTIES POSITION_INDEPENDENT_CODE ON)
    add_dependencies("${CPP_NAMESPACE}_versionInfo" "${CPP_NAMESPACE}_updateVersionInfo")
    target_include_directories("${CPP_NAMESPACE}_versionInfo" PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
        $<INSTALL_INTERFACE:include>)
endmacro()

macro(m_generate_version_info_sources_by_project_name)
    set(prefix ARG)
    set(noValues "")
    set(singleValues MY_PROJECT_NAME)
    set(multiValues BUILD_TYPES)
    
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS singleValues multiValues)
         set(${arg} ${${prefix}_${arg}})
    endforeach()
    m_generate_version_info_sources(
        CPP_NAMESPACE ${MY_PROJECT_NAME}
        OUT_H_DIR ${CMAKE_CURRENT_BINARY_DIR}/include/${MY_PROJECT_NAME}
        OUT_CPP_DIR ${CMAKE_CURRENT_BINARY_DIR}/src/${MY_PROJECT_NAME}
        MAJOR ${${MY_PROJECT_NAME}_VERSION_MAJOR}
        MINOR ${${MY_PROJECT_NAME}_VERSION_MINOR}
        PATCH ${${MY_PROJECT_NAME}_VERSION_PATCH}
        TWEAK ${${MY_PROJECT_NAME}_VERSION_TWEAK}
        FULL_VERSION ${${MY_PROJECT_NAME}_VERSION}
        CUR_DIR ${CMAKE_CURRENT_LIST_DIR}
        BUILD_TYPES ${BUILD_TYPES})
endmacro()