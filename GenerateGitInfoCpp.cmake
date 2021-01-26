find_package(Git REQUIRED)

# Getting last commit hash
execute_process(
	COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
	RESULT_VARIABLE result
	OUTPUT_VARIABLE GIT_SHA1
	OUTPUT_STRIP_TRAILING_WHITESPACE
	WORKING_DIRECTORY ${CUR_DIR}
)

if(result)
	message(FATAL_ERROR "Failed to get hash of last change: ${result}")
endif()

# Getting current branch name
execute_process(
	COMMAND ${GIT_EXECUTABLE} symbolic-ref --short HEAD
	RESULT_VARIABLE result
	OUTPUT_VARIABLE CURRENT_BRANCH_NAME
	OUTPUT_STRIP_TRAILING_WHITESPACE
	WORKING_DIRECTORY ${CUR_DIR}
)

if(result)
	message(FATAL_ERROR "Failed to get current branch name: ${result}")
endif()

# Getting diff since last commit(e.g. any uncommited changes)
execute_process(
	COMMAND ${GIT_EXECUTABLE} diff HEAD
	RESULT_VARIABLE result
	OUTPUT_VARIABLE CURRENT_DIFF
	OUTPUT_STRIP_TRAILING_WHITESPACE
	WORKING_DIRECTORY ${CUR_DIR}
)

if(result)
	message(FATAL_ERROR "Failed to get diff since last commit: ${result}")
endif()

# If there are no uncommited changes set IS_DIRTY flag to "false"
set(IS_DIRTY true)
if("${CURRENT_DIFF}" STREQUAL "")
	set(IS_DIRTY false)
endif()

configure_file(${IN_CPP_PATH} ${OUT_CPP_PATH})