include(${CUR_ACTIVE_DIR}/GenerateGitInfo.cmake)
string(REPLACE " " ";" BUILD_TYPES "${BUILD_TYPES}")
string(REPLACE " " ";" IN_PATH_LIST "${IN_PATH_LIST}")
string(REPLACE " " ";" OUT_PATH_LIST "${OUT_PATH_LIST}")
set(ENUM_BUILD_TYPES "")
foreach(BUILD_TYPE IN LISTS BUILD_TYPES)
    list(APPEND ENUM_BUILD_TYPES "k${BUILD_TYPE}")
endforeach()
string(REPLACE ";" ",\n        " BUILD_TYPES_ENUM_LIST "${ENUM_BUILD_TYPES}")

set(TEMPLATE_LEN 80)
set(INFO_STR " - ${CPP_NAMESPACE} info - ")
string(LENGTH "${INFO_STR}" INFO_LEN)
math(EXPR START_POS "(${TEMPLATE_LEN} - ${INFO_LEN}) / 2")
string(REPEAT "*" ${START_POS} ASTERISK_STR)
string(CONCAT VERSION_INFO_STR ${ASTERISK_STR} ${INFO_STR})
string(LENGTH "${VERSION_INFO_STR}" VERSION_INFO_STR_LEN)
math(EXPR SPACE_TO_FILL "${TEMPLATE_LEN} - ${VERSION_INFO_STR_LEN}")
string(REPEAT "*" ${SPACE_TO_FILL} REST_STR)
string(CONCAT VERSION_INFO_STR ${VERSION_INFO_STR} ${REST_STR})


set(BUILD_TYPE_TEMPLATE [=[
inline constexpr eBuildType kBuildType = eBuildType::k${BUILD_TYPE};
    inline constexpr std::string_view kBuildTypeStr = "${BUILD_TYPE}";]=])

string(CONCAT SRC_TEMPLATE [=[
#${DEF_MACRO} ${UPPER_BUILD_TYPE}
    ]=] "${BUILD_TYPE_TEMPLATE}")
set(FINISH_STR [=[#else
    static_assert(false, "Error: Unsupported build type has been provided!!!");
#endif]=])

set(DEF_MACRO "ifdef")
set(CUR_BUILD_TYPES "${BUILD_TYPES}")
list(POP_FRONT CUR_BUILD_TYPES BUILD_TYPE)
string(TOUPPER ${BUILD_TYPE} UPPER_BUILD_TYPE)
string(CONFIGURE "${SRC_TEMPLATE}" FUNC_SRC)

set(DEF_MACRO "elif")
foreach(BUILD_TYPE IN LISTS CUR_BUILD_TYPES)
    string(TOUPPER ${BUILD_TYPE} UPPER_BUILD_TYPE)
    string(CONFIGURE "${SRC_TEMPLATE}" Result)
    set(FUNC_SRC "${FUNC_SRC}\n${Result}")
endforeach()
set(BUILD_TYPE_FUNC_SRC "${FUNC_SRC}\n${FINISH_STR}")

foreach(IN_PATH OUT_PATH IN ZIP_LISTS IN_PATH_LIST OUT_PATH_LIST)
    configure_file(${IN_PATH} ${OUT_PATH})
endforeach()