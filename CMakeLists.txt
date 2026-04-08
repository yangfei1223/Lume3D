cmake_minimum_required(VERSION 3.24)
project(Lume3D)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

#
# Download LumeShaderCompiler.exe (Windows only)
#
if(WIN32)
  if(NOT EXISTS "${CMAKE_BINARY_DIR}/LumeShaderCompiler.exe")
    file(DOWNLOAD
      "https://github.com/jsnchng/LumeShaderCompiler/releases/download/v1.0.0-alpha/LumeShaderCompiler.exe"
      "${CMAKE_BINARY_DIR}/LumeShaderCompiler.exe"
      EXPECTED_HASH SHA256=40c5382909b8e8033fd8eaa326963f84448865190f7000c4e8b91e6fd30be587
      SHOW_PROGRESS)
  endif()
endif()

#
# Target: AGPBaseAPI
#
if(NOT TARGET AGPBase::AGPBaseAPI)
  add_subdirectory(LumeBase)
endif()

#
# Target: AGPEngineAPI
#
if(NOT TARGET AGPEngine::AGPEngineAPI)
  add_subdirectory(LumeEngine)
  set(ENGINE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/LumeEngine")
else()
  get_filename_component(ENGINE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../LumeEngine" ABSOLUTE)
endif()

#
# Target: AGPRenderAPI
#
if(NOT TARGET AGPRender::AGPRenderAPI)
  add_subdirectory(LumeRender)
  set(RENDER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/LumeRender")
else()
  get_filename_component(RENDER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../LumeRender" ABSOLUTE)
endif()

#
# Target:AGP3DAPI
#
add_library(AGP3DAPI INTERFACE)
add_library(AGP3D::AGP3DAPI ALIAS AGP3DAPI)
target_include_directories(AGP3DAPI INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/api)
target_link_libraries(AGP3DAPI INTERFACE
  AGPBase::AGPBaseAPI
  AGPRender::AGPRenderAPI)

#
# Target: AGP3D
#
file(GLOB_RECURSE AGP3D_sources "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
add_library(AGP3D STATIC
  ${AGP3D_sources}
  ${CMAKE_CURRENT_SOURCE_DIR}/version.cpp)
add_library(AGP3D::AGP3D ALIAS AGP3D)
target_include_directories(AGP3D PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/assets)
target_link_libraries(AGP3D PRIVATE
  AGPEngine::ComponentHelperSDK
  AGPEngine::AGPEngineAPI
  AGP3DAPI)
target_compile_definitions(AGP3D PUBLIC CORE_STATIC_PLUGIN_HEADER="${ENGINE_DIR}/src/static_plugin_decl.h")
target_compile_definitions(AGP3D PUBLIC CORE3D_DEV_ENABLED=0)
target_compile_definitions(AGP3D PRIVATE CORE3D_EMBEDDED_ASSETS_ENABLED=0)
target_compile_definitions(AGP3D PRIVATE CORE3D_VALIDATION_ENABLED=1)
if(WIN32)
    target_compile_definitions(AGP3D PRIVATE "CORE3D_PUBLIC=__declspec(dllexport)")
    target_compile_definitions(AGP3D INTERFACE "CORE3D_PUBLIC=")
    target_compile_options(AGP3D PRIVATE /GR-)
else()
    target_compile_definitions(AGP3D PRIVATE "CORE3D_PUBLIC=__attribute__((visibility(\"default\")))")
    target_compile_definitions(AGP3D INTERFACE "CORE3D_PUBLIC=")
    target_compile_options(AGP3D PRIVATE -fvisibility=hidden)
endif()

# Shader compilation (Windows only for now)
if(WIN32)
    set(shader_compiler_executable "${CMAKE_BINARY_DIR}/LumeShaderCompiler.exe")
    set(argument_list)
    list(APPEND argument_list "--optimize")
    list(APPEND argument_list "--source")
    list(APPEND argument_list "${CMAKE_CURRENT_SOURCE_DIR}/assets/3d/shaders")
    list(APPEND argument_list "--include")
    list(APPEND argument_list "${RENDER_DIR}/api")
    list(APPEND argument_list "--include")
    list(APPEND argument_list "${CMAKE_CURRENT_SOURCE_DIR}/api")
    list(APPEND argument_list "--vulkan")
    list(APPEND argument_list "1.1")
    list(APPEND argument_list "--check-if-changed")
    add_custom_target(3DCompileShaders ALL
        COMMAND ${shader_compiler_executable} ${argument_list}
        COMMAND_EXPAND_LISTS)
    add_dependencies(AGP3D 3DCompileShaders)
endif()

#
# Target: PluginAGP3D
#
add_library(PluginAGP3D SHARED
  ${CMAKE_CURRENT_SOURCE_DIR}/src/plugin/dynamic_plugin.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/plugin/dynamic_registry.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/util/json.cpp)
add_library(AGP3D::PluginAGP3D ALIAS PluginAGP3D)
target_include_directories(PluginAGP3D PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(PluginAGP3D PRIVATE
  AGPEngine::AGPEngineAPI
  AGPEngine::ComponentHelperSDK
  AGP3D::AGP3D
  AGP3D::AGP3DAPI)
target_compile_definitions(PluginAGP3D PRIVATE CORE_PLUGIN=1)
if(WIN32)
    target_compile_options(PluginAGP3D PRIVATE /GR-)
else()
    target_compile_options(PluginAGP3D PRIVATE -fvisibility=hidden)
endif()
