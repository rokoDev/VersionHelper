set(CUR_ACTIVE_DIR ${CMAKE_CURRENT_LIST_DIR}) 

macro(m_generate_version_info_sources)
    set(prefix ARG)
    set(noValues HEADER_ONLY)
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
        TARGET_NAME
        )
    set(multiValues BUILD_TYPES)
    
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS noValues singleValues multiValues)
        set(${arg} ${${prefix}_${arg}})
    endforeach()

    set(IN_PATH "${CUR_ACTIVE_DIR}/SourceTemplates")
    set(OUT_FILE_NAMES
        "build_type_defs.h"
        "build_type.h"
        "git.h"
        "version.h"
        )
    set(CONST_OUT_FILE_NAME "version_info.h")
    if(NOT HEADER_ONLY)
        list(APPEND OUT_FILE_NAMES "version_info.cpp")
    endif()
    set(VERSION_INFO_HEADERS "")
    set(VERSION_INFO_SOURCES "")
    set(UPDATE_VERSION_IN_PATH_LIST "")
    set(UPDATE_VERSION_OUT_PATH_LIST "")
    foreach(OUT_NAME IN LISTS OUT_FILE_NAMES)
        list(APPEND UPDATE_VERSION_IN_PATH_LIST "${IN_PATH}/${OUT_NAME}.in")
        get_filename_component(F_EXT ${OUT_NAME} LAST_EXT)
        if(F_EXT STREQUAL ".h")
            list(APPEND UPDATE_VERSION_OUT_PATH_LIST "${OUT_H_DIR}/${OUT_NAME}")
            list(APPEND VERSION_INFO_HEADERS "${OUT_H_DIR}/${OUT_NAME}")
        elseif(F_EXT STREQUAL ".cpp")
            list(APPEND UPDATE_VERSION_OUT_PATH_LIST "${OUT_CPP_DIR}/${OUT_NAME}")
            list(APPEND VERSION_INFO_SOURCES "${OUT_CPP_DIR}/${OUT_NAME}")
        else()
            message(FATAL_ERROR "Invalid file extension: ${F_EXT} Permitted extensions are: .h, .cpp")
        endif()
    endforeach()

    list(APPEND IN_PATH_LIST ${UPDATE_VERSION_IN_PATH_LIST} "${IN_PATH}/${CONST_OUT_FILE_NAME}.in")
    list(APPEND OUT_PATH_LIST ${UPDATE_VERSION_OUT_PATH_LIST} "${OUT_H_DIR}/${CONST_OUT_FILE_NAME}")
    list(APPEND VERSION_INFO_HEADERS "${OUT_H_DIR}/${CONST_OUT_FILE_NAME}")
    
    include(${CUR_ACTIVE_DIR}/GenerateByConfigure.cmake)

    add_custom_target("${CPP_NAMESPACE}_updateVersion"
        COMMAND ${CMAKE_COMMAND}
        -DCPP_NAMESPACE=${CPP_NAMESPACE}
        -DIN_PATH_LIST="${UPDATE_VERSION_IN_PATH_LIST}"
        -DOUT_PATH_LIST="${UPDATE_VERSION_OUT_PATH_LIST}"
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
        BYPRODUCTS ${UPDATE_VERSION_OUT_PATH_LIST}
    )

    # Define property for storing paths to source' directories
    define_property(TARGET PROPERTY SRC_DIRS
                    BRIEF_DOCS "Paths to directories with target' sources."
                    FULL_DOCS "This property needed as INPUT to doxygen.")
    if(NOT HEADER_ONLY)
        add_library("${CPP_NAMESPACE}_version" STATIC ${OUT_PATH_LIST})
        target_compile_definitions("${CPP_NAMESPACE}_version" PUBLIC $<UPPER_CASE:$<CONFIG>>)
        set_target_properties("${CPP_NAMESPACE}_version" PROPERTIES POSITION_INDEPENDENT_CODE ON)
        set_property(TARGET ${TARGET_NAME} APPEND PROPERTY SRC_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CPP_NAMESPACE}_version)
        add_dependencies("${CPP_NAMESPACE}_version" "${CPP_NAMESPACE}_updateVersion")
        target_link_libraries(${TARGET_NAME} PUBLIC "${CPP_NAMESPACE}_version")
        target_include_directories("${CPP_NAMESPACE}_version" PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/${CPP_NAMESPACE}_version>
            $<INSTALL_INTERFACE:include>)
    else()
        add_library("${CPP_NAMESPACE}_version" INTERFACE ${OUT_PATH_LIST})
        target_compile_definitions("${CPP_NAMESPACE}_version" INTERFACE $<UPPER_CASE:$<CONFIG>> ${CPP_NAMESPACE}_header_only)
        set_property(TARGET ${TARGET_NAME} APPEND PROPERTY SRC_DIRS ${CMAKE_CURRENT_BINARY_DIR}/${CPP_NAMESPACE}_version)
        add_dependencies("${CPP_NAMESPACE}_version" "${CPP_NAMESPACE}_updateVersion")
        get_target_property(${TARGET_NAME}_TYPE ${TARGET_NAME} TYPE)
        if(${TARGET_NAME}_TYPE STREQUAL "INTERFACE_LIBRARY")
            target_link_libraries(${TARGET_NAME} INTERFACE "${CPP_NAMESPACE}_version")
        else()
            target_link_libraries(${TARGET_NAME} PUBLIC "${CPP_NAMESPACE}_version")
        endif()
        target_include_directories("${CPP_NAMESPACE}_version" INTERFACE
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/${CPP_NAMESPACE}_version>
            $<INSTALL_INTERFACE:include>)
    endif()
endmacro()

macro(m_generate_version_info)
    set(prefix ARG)
    set(noValues HEADER_ONLY)
    set(singleValues
        PROJECT_NAME
        CPP_NAMESPACE
        IDE_SRC_GROUP
        TARGET_NAME)
    set(multiValues BUILD_TYPES)
    
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS noValues singleValues multiValues)
        set(${arg} ${${prefix}_${arg}})
    endforeach()

    if((NOT TARGET_NAME) OR "${TARGET_NAME}" STREQUAL "")
        message(FATAL_ERROR "Error: invalid TARGET_NAME" )
    endif()

    if(HEADER_ONLY)
        set(HEADER_ONLY_FLAG "HEADER_ONLY")
    else()
        set(HEADER_ONLY_FLAG "")
    endif()

    m_generate_version_info_sources(
        CPP_NAMESPACE ${CPP_NAMESPACE}
        OUT_H_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CPP_NAMESPACE}_version/${CPP_NAMESPACE}
        OUT_CPP_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CPP_NAMESPACE}_version/src
        MAJOR ${${PROJECT_NAME}_VERSION_MAJOR}
        MINOR ${${PROJECT_NAME}_VERSION_MINOR}
        PATCH ${${PROJECT_NAME}_VERSION_PATCH}
        TWEAK ${${PROJECT_NAME}_VERSION_TWEAK}
        FULL_VERSION ${${PROJECT_NAME}_VERSION}
        CUR_DIR ${CMAKE_CURRENT_LIST_DIR}
        BUILD_TYPES ${BUILD_TYPES}
        TARGET_NAME ${TARGET_NAME}
        ${HEADER_ONLY_FLAG}
        )
    
    if(NOT((NOT IDE_SRC_GROUP) OR "${IDE_SRC_GROUP}" STREQUAL ""))
        # If use IDE add generated targets into appropriate group
        get_target_property(${CPP_NAMESPACE}_version_sources ${CPP_NAMESPACE}_version SOURCES)
        source_group(
          TREE   ${CMAKE_CURRENT_BINARY_DIR}/${CPP_NAMESPACE}_version
          FILES  ${${CPP_NAMESPACE}_version_sources}
        )

        set_target_properties(${CPP_NAMESPACE}_version ${CPP_NAMESPACE}_updateVersion PROPERTIES FOLDER ${IDE_SRC_GROUP})
    endif()

endmacro()