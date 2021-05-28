cmake_minimum_required(VERSION 3.17)
project(Puck)

set(CMAKE_CXX_STANDARD 14)

enable_language(OBJC)
enable_language(OBJCXX)

add_compile_options(-fblocks -std=c99 -g -O0 -fobjc-arc -Wall)


include_directories(.)
include_directories(XCBKit.framework)
include_directories(XCBKit.framework/Headers)
include_directories(XCBKit.framework/Headers/enums)
include_directories(XCBKit.framework/Headers/functions)
include_directories(XCBKit.framework/Headers/services)
include_directories(XCBKit.framework/Headers/utils)
include_directories(XCBKit.framework/Versions)
include_directories(XCBKit.framework/Versions/0)
include_directories(XCBKit.framework/Versions/0/Headers)
include_directories(XCBKit.framework/Versions/0/Headers/enums)
include_directories(XCBKit.framework/Versions/0/Headers/functions)
include_directories(XCBKit.framework/Versions/0/Headers/services)
include_directories(XCBKit.framework/Versions/0/Headers/utils)
include_directories(XCBKit.framework/Versions/Current)
include_directories(XCBKit.framework/Versions/Current/Headers)
include_directories(XCBKit.framework/Versions/Current/Headers/enums)
include_directories(XCBKit.framework/Versions/Current/Headers/functions)
include_directories(XCBKit.framework/Versions/Current/Headers/services)
include_directories(XCBKit.framework/Versions/Current/Headers/utils)
include_directories(/usr/GNUstep/Local/Library/Headers)

add_executable(Puck
        main.m
        PuckUIHandler.h
        PuckUIHandler.m)
