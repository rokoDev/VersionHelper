# VersionHelper

The goal of `VersionHelper` is to generate information about build(or header-only library) that can be accessed programmatically during execution.

### This information will be available after generation:
1. `version::major()` - returns `uint32_t` which represent major version number of the project
2. `version::minor()` - returns `uint32_t` which represent minor version number of the project
3. `version::patch()` - returns `uint32_t` which represent patch version number of the project
4. `version::tweak()` - returns `uint32_t` which represent tweak version number of the project
5. `version::str()` - returns `std::string_view` which contains value of `CMake` variable: `${${PROJECT_NAME}_VERSION}`
6. `git::dirty()` - returns `bool`. `true` means that build was created from sources that have uncommitted changes and `false` otherwise.
7. `git::sha1()` - returns `std::string_view` that contains commit hash(a 40 characters long string) from which build has been created.
8. `build_type()` - returns enum class `eBuildType` value which can be any of user provided build types(for example `kDebug`, `kRelease`, `kProfile` and so on).
9. `build_type_str()` - returns `std::string_view` that correspond to the value returned by `build_type()`(for example it can be one of: `Debug`, `Release`, `Profile` and so on).

## Prerequisites.
At first `VersionHelper` must downloaded.
And the most convenient way to download `VersionHelper` and make it available I aware of is to use `FetchContent` module from `CMake`:
```cmake
include(FetchContent)

FetchContent_Declare(
    VersionHelper
    GIT_REPOSITORY https://github.com/rokoDev/VersionHelper.git
    GIT_TAG        497e036e8ce2879aa193d905999b535da4aff8f8
)

# If necessary it's possible to use VersionHelper from different location(for example with your own changes which you want to test) instead of downloaded from GitHub
# string(TOUPPER VersionHelper UP_VersionHelper)
# set(FETCHCONTENT_SOURCE_DIR_${UP_VersionHelper} ${CMAKE_SOURCE_DIR}/../VersionHelper)

FetchContent_MakeAvailable(VersionHelper)
```

## Generating information about version.
1. Add path to `VersionInfoUtils.cmake` to `CMAKE_MODULE_PATH` variable:
```cmake
list(APPEND CMAKE_MODULE_PATH "${versionhelper_SOURCE_DIR}")
```

2. Make available code inside `VersionInfoUtils.cmake`:
```cmake
include(VersionInfoUtils)
```

3. Call `m_generate_version_info` macros to generate information about version:
```cmake
m_generate_version_info(PROJECT_NAME ${ProjectName}
                    CPP_NAMESPACE "myapp"
                    BUILD_TYPES "Debug Release"
                    IDE_SRC_GROUP "generated"
                    TARGET_NAME "myapp"
                    HEADER_ONLY
                    )
```

This is descrtiption of parameters that we can pass to `m_generate_version_info` macro:
- `BUILD_TYPES`: list of supported configurations(for example `"Debug Release Profile"`)
- `PROJECT_NAME`: it is used to retrieve information about version that available to `CMake`(for example `${${PROJECT_NAME}_VERSION_MAJOR}` and `${${PROJECT_NAME}_VERSION}`)
- `CPP_NAMESPACE`: vaild name of C Plus Plus namespace in which information about version will be placed. For example if it equal to `"myapp"` then to get major version number in source code we should call `myapp::version::major()`.
- `IDE_SRC_GROUP`: name of source group inside IDE under which `version_info.h` file will be placed.
- `TARGET_NAME`: Name of a `CMake` target inside sources of which information about version should be available.(For example inside source code of this target we will be able to make calls like `myapp::version::major()`, `myapp::git::dirty()` and so on).
- `HEADER_ONLY`(optional): If provided information about version will be generated only inside header files. This can be useful if we are working on header only library. But it is better to avoid to reduce complilation time if we are working on binary target.

## Using inside C++ source code.

After we have done all instructions provided above we can retrieve information about version inside source code of a target which name has been passed to `TARGET_NAME` parameter of `m_generate_version_info` macro:

```cpp
#include "myapp/version_info.h"

myapp::version::major();
myapp::version::minor();
myapp::version::patch();
myapp::version::tweak();
myapp::version::str();
myapp::git::dirty() ;
myapp::git::sha1();
myapp::build_type();
```
