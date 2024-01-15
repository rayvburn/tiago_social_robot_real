cmake_minimum_required(VERSION 3.5)
project(tiago_social_experiments_real)

## Find catkin macros and libraries
find_package(catkin REQUIRED COMPONENTS
    tiago_social_bringup
)

## catkin specific configuration
# No packages marked as CATKIN_DEPENDS since this package does not require compilation
catkin_package()

## Install
foreach(dir config launch)
    install(DIRECTORY ${dir}/
        DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/${dir})
endforeach(dir)
