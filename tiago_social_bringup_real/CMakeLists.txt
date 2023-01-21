cmake_minimum_required(VERSION 3.5)
project(tiago_social_bringup_real)

## Find catkin macros and libraries
find_package(catkin REQUIRED)

## catkin specific configuration
# No packages marked as CATKIN_DEPENDS since this package does not require compilation
catkin_package()

## Install
foreach(dir scripts)
    install(DIRECTORY ${dir}/
        DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/${dir})
endforeach(dir)
