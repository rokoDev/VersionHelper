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

    set(IN_H_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/version.h.in)
    set(OUT_H_PATH ${OUT_H_DIR}/version.h)

    configure_file(${IN_H_PATH} ${OUT_H_PATH})
endfunction()

macro(m_generate_version_cpp)
    set(IN_CPP_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/version.cpp.in)

    add_custom_target("${CPP_NAMESPACE}_updateVersionInfo"
        COMMAND ${CMAKE_COMMAND}
        -DCPP_NAMESPACE=${CPP_NAMESPACE}
        -DIN_CPP_PATH=${IN_CPP_PATH}
        -DOUT_CPP_PATH=${OUT_CPP_DIR}/version.cpp
        -DMAJOR=${MAJOR}
        -DMINOR=${MINOR}
        -DPATCH=${PATCH}
        -DTWEAK=${TWEAK}
        -DFULL_VERSION=${FULL_VERSION}
        -P ${CUR_ACTIVE_DIR}/GenerateVersionCpp.cmake
        COMMENT "Updating version.cpp ..."
        BYPRODUCTS ${OUT_CPP_DIR}/version.cpp
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

    set(IN_H_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/git.h.in)
    set(OUT_H_PATH ${OUT_H_DIR}/git.h)

    configure_file(${IN_H_PATH} ${OUT_H_PATH})
endfunction()

macro(m_generate_git_info_cpp)
    set(IN_CPP_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/git.cpp.in)

    add_custom_target("${CPP_NAMESPACE}_updateGitInfo"
        COMMAND ${CMAKE_COMMAND}
        -DCPP_NAMESPACE=${CPP_NAMESPACE}
        -DIN_CPP_PATH=${IN_CPP_PATH}
        -DOUT_CPP_PATH=${OUT_CPP_DIR}/git.cpp
        -DCUR_DIR=${CMAKE_CURRENT_LIST_DIR}
        -P ${CUR_ACTIVE_DIR}/GenerateGitInfoCpp.cmake
        COMMENT "Updating git.cpp ..."
        BYPRODUCTS ${OUT_CPP_DIR}/git.cpp
    )
endmacro()

function(f_generate_func_src)
    set(prefix ARG)
    set(noValues "")
    set(singleValues
        BUILD_TYPE_TEMPLATE
        RETURN_VALUE)
    set(multiValues BUILD_TYPES)
    
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})

    foreach(arg IN LISTS noValues singleValues multiValues)
         if("${${prefix}_${arg}}" STREQUAL "")
            message(FATAL_ERROR "Error: in f_generate_version_h function call ${arg} must be provided")
         endif()
         set(${arg} ${${prefix}_${arg}})
    endforeach()
    message("BUILD_TYPE_TEMPLATE1: ${BUILD_TYPE_TEMPLATE}")
    string(CONCAT SRC_TEMPLATE [=[
#${DEF_MACRO} ${UPPER_BUILD_TYPE}
    ]=] "${BUILD_TYPE_TEMPLATE}")
    set(FINISH_STR [=[#else
    static_assert(false, "Error: Unsupported build type has been provided!!!");
#endif]=])

    message("SRC_TEMPLATE: ${SRC_TEMPLATE}")
    message("BUILD_TYPE_TEMPLATE: ${BUILD_TYPE_TEMPLATE}")
    set(DEF_MACRO "ifdef")
    list(POP_FRONT BUILD_TYPES BUILD_TYPE)
    string(TOUPPER ${BUILD_TYPE} UPPER_BUILD_TYPE)
    string(CONFIGURE "${SRC_TEMPLATE}" FUNC_SRC)

    set(DEF_MACRO "elif")
    foreach(BUILD_TYPE IN LISTS BUILD_TYPES)
        string(TOUPPER ${BUILD_TYPE} UPPER_BUILD_TYPE)
        string(CONFIGURE "${SRC_TEMPLATE}" Result)
        set(FUNC_SRC "${FUNC_SRC}\n${Result}")
    endforeach()
    set("${RETURN_VALUE}" "${FUNC_SRC}\n${FINISH_STR}" PARENT_SCOPE)
endfunction()

function(f_generate_build_types_h)
    set(prefix ARG)
    set(noValues "")
    set(singleValues
        CPP_NAMESPACE
        OUT_H_DIR)
    set(multiValues BUILD_TYPES)
    
    cmake_parse_arguments(${prefix}
                          "${noValues}"
                          "${singleValues}"
                          "${multiValues}"
                          ${ARGN})
    
    foreach(arg IN LISTS singleValues multiValues)
         if("${${prefix}_${arg}}" STREQUAL "")
            message(FATAL_ERROR "Error: in f_generate_version_h function call ${arg} must be provided")
         endif()
         set(${arg} ${${prefix}_${arg}} PARENT_SCOPE)
    endforeach()
    
    foreach(BUILD_TYPE IN LISTS BUILD_TYPES)
         list(APPEND ENUM_BUILD_TYPES "k${BUILD_TYPE}")
    endforeach()
    string(REPLACE ";" ",\n        " BUILD_TYPES_ENUM_LIST "${ENUM_BUILD_TYPES}")

    set(BUILD_TYPE_TEMPLATE [=[
inline constexpr eBuildType kBuildType = eBuildType::k${BUILD_TYPE}\\\;
    inline constexpr std::string_view kBuildTypeStr = "${BUILD_TYPE}"\\\;]=])
    message("BUILD_TYPE_TEMPLATE: ${BUILD_TYPE_TEMPLATE}")
    f_generate_func_src(BUILD_TYPES ${BUILD_TYPES}
                        BUILD_TYPE_TEMPLATE "${BUILD_TYPE_TEMPLATE}"
                        RETURN_VALUE "BUILD_TYPE_FUNC_SRC")

    set(IN_H_PATH ${CUR_ACTIVE_DIR}/SourceTemplates/build_type.h.in)
    set(OUT_H_PATH ${OUT_H_DIR}/build_type.h)

    configure_file(${IN_H_PATH} ${OUT_H_PATH})
endfunction()

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
    set(multiValues BUILD_TYPES)
    
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

    f_generate_build_types_h(
        CPP_NAMESPACE ${CPP_NAMESPACE}
        OUT_H_DIR ${OUT_H_DIR}
        BUILD_TYPES ${BUILD_TYPES})

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
        ${OUT_H_DIR}/version.h
        ${OUT_H_DIR}/git.h
        ${OUT_H_DIR}/build_type.h)

    set(VERSION_INFO_SOURCES
        ${OUT_CPP_DIR}/version.cpp
        ${OUT_CPP_DIR}/git.cpp)

    add_library("${CPP_NAMESPACE}_versionInfo" STATIC ${VERSION_INFO_SOURCES} ${VERSION_INFO_HEADERS})
    target_compile_definitions("${CPP_NAMESPACE}_versionInfo" PUBLIC $<$<CONFIG:Release>:RELEASE> $<$<CONFIG:Debug>:DEBUG>)
    set_target_properties("${CPP_NAMESPACE}_versionInfo" PROPERTIES POSITION_INDEPENDENT_CODE ON)
    add_dependencies("${CPP_NAMESPACE}_versionInfo" "${CPP_NAMESPACE}_updateVersionInfo" "${CPP_NAMESPACE}_updateGitInfo")
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
        BUILD_TYPES ${BUILD_TYPES})
endmacro()