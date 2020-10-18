set(CUR_ACTIVE_DIR ${CMAKE_CURRENT_LIST_DIR}) 
function(f_generate_version_h)
	set(prefix ARG)
    set(noValues "")
    set(singleValues
    	CPP_NAMESPACE
    	OUT_H_DIR)
    set(multiValues "")
    
	cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS singleValues)
		 if("${${prefix}_${arg}}" STREQUAL "")
		 	message(FATAL_ERROR "Error: in f_generate_version_h function call ${arg} must be provided")
		 endif()
		 set(${arg} ${${prefix}_${arg}} PARENT_SCOPE)
    endforeach()

    set(IN_H_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/Version.h.in)
    set(OUT_H_PATH ${OUT_H_DIR}/Version.h)

    configure_file(${IN_H_PATH} ${OUT_H_PATH})
endfunction()

macro(m_generate_version_cpp)
    set(IN_CPP_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/Version.cpp.in)

    add_custom_target(updateVersionInfo
        COMMAND ${CMAKE_COMMAND}
        -DCPP_NAMESPACE=${CPP_NAMESPACE}
        -DIN_CPP_PATH=${IN_CPP_PATH}
        -DOUT_CPP_PATH=${OUT_CPP_DIR}/Version.cpp
        -DMAJOR=${MAJOR}
        -DMINOR=${MINOR}
        -DPATCH=${PATCH}
        -DTWEAK=${TWEAK}
        -DFULL_VERSION=${FULL_VERSION}
        -P ${CUR_ACTIVE_DIR}/GenerateVersionCpp.cmake
        COMMENT "Updating Version.cpp ..."
        BYPRODUCTS ${OUT_CPP_DIR}/Version.cpp
    )
endmacro()

function(f_generate_git_info_h)
	set(prefix ARG)
    set(noValues "")
    set(singleValues
    	CPP_NAMESPACE
    	OUT_H_DIR)
    set(multiValues "")
    
	cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS singleValues)
		 if("${${prefix}_${arg}}" STREQUAL "")
		 	message(FATAL_ERROR "Error: in generate_git_info_h function call ${arg} must be provided")
		 endif()
		 set(${arg} ${${prefix}_${arg}} PARENT_SCOPE)
    endforeach()

    set(IN_H_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/GitInfo.h.in)
    set(OUT_H_PATH ${OUT_H_DIR}/GitInfo.h)

    configure_file(${IN_H_PATH} ${OUT_H_PATH})
endfunction()

macro(m_generate_git_info_cpp)
    set(IN_CPP_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/GitInfo.cpp.in)

    add_custom_target(updateGitInfo
        COMMAND ${CMAKE_COMMAND}
        -DCPP_NAMESPACE=${CPP_NAMESPACE}
        -DIN_CPP_PATH=${IN_CPP_PATH}
        -DOUT_CPP_PATH=${OUT_CPP_DIR}/GitInfo.cpp
        -P ${CUR_ACTIVE_DIR}/GenerateGitInfoCpp.cmake
        COMMENT "Updating GitInfo.cpp ..."
        BYPRODUCTS ${OUT_CPP_DIR}/GitInfo.cpp
    )
endmacro()

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
        FULL_VERSION)
    set(multiValues "")
    
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS singleValues)
         set(${arg} ${${prefix}_${arg}})
    endforeach()

    f_generate_version_h(
        CPP_NAMESPACE ${CPP_NAMESPACE}
        OUT_H_DIR ${OUT_H_DIR})

    f_generate_git_info_h(
        CPP_NAMESPACE ${CPP_NAMESPACE}
        OUT_H_DIR ${OUT_H_DIR})

    m_generate_version_cpp(
        CPP_NAMESPACE ${CPP_NAMESPACE}
        OUT_CPP_DIR ${OUT_CPP_DIR}
        MAJOR ${MAJOR}
        MINOR ${MINOR}
        PATCH ${PATCH}
        TWEAK ${TWEAK}
        FULL_VERSION ${FULL_VERSION})

    m_generate_git_info_cpp(
        CPP_NAMESPACE ${CPP_NAMESPACE}
        OUT_CPP_DIR ${OUT_CPP_DIR})

    set(VERSION_INFO_HEADERS
        ${OUT_H_DIR}/Version.h
        ${OUT_H_DIR}/GitInfo.h)

    set(VERSION_INFO_SOURCES
        ${OUT_CPP_DIR}/Version.cpp
        ${OUT_CPP_DIR}/GitInfo.cpp)

    add_library("versionInfo" STATIC ${VERSION_INFO_SOURCES} ${VERSION_INFO_HEADERS})
    add_dependencies("versionInfo" updateVersionInfo updateGitInfo)
    target_include_directories("versionInfo" PUBLIC "${OUT_H_DIR}")
endmacro()

macro(m_generate_version_info_sources_by_project_name)
    set(prefix ARG)
    set(noValues "")
    set(singleValues MY_PROJECT_NAME)
    set(multiValues "")
    
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS singleValues)
         set(${arg} ${${prefix}_${arg}})
    endforeach()
    m_generate_version_info_sources(
        CPP_NAMESPACE ${MY_PROJECT_NAME}
        OUT_H_DIR ${CMAKE_CURRENT_BINARY_DIR}/include/VersionInfo
        OUT_CPP_DIR ${CMAKE_CURRENT_BINARY_DIR}/src/VersionInfo
        MAJOR ${${MY_PROJECT_NAME}_VERSION_MAJOR}
        MINOR ${${MY_PROJECT_NAME}_VERSION_MINOR}
        PATCH ${${MY_PROJECT_NAME}_VERSION_PATCH}
        TWEAK ${${MY_PROJECT_NAME}_VERSION_TWEAK}
        FULL_VERSION ${${MY_PROJECT_NAME}_VERSION})
endmacro()