# Some code to collect dependent targets - the main targets simply aggregate some component targets.
set(_OC_SOURCE_UPDATE_TARGETS )
set(_OC_COLLECT_LOG_TARGETS )
set(_OC_SOURCE_GITSTATUS_TARGETS )
foreach(_COMP ${_OC_SELECTED_COMPONENTS})
    string(TOLOWER "${_COMP}" _COMP_LOWER)
    list(APPEND _OC_SOURCE_UPDATE_TARGETS ${_COMP_LOWER}-update)
    list(APPEND _OC_SOURCE_GITSTATUS_TARGETS ${_COMP_LOWER}-gitstatus)
    list(APPEND _OC_COLLECT_LOG_TARGETS _${_COMP}-collectlogs)
endforeach()

##
# Just building :sh:`all` is not enough for OpenCMISS, as the install step is
# important to create the information about the OpenCMISS build that is needed by any examples or applications.
# Therefore, the build system’s main target is called :sh:`opencmiss` and should be invoked for any build.
#
# Moreover, certain *feature tests* are automatically build using the :code:`opencmiss` target.
# It is important to have those tests as they are intended to test the core functionality of the current build
# and configuration. For more information see :ref:`featuretests`.
# 
#    :examples: Convenience target to download & build all the examples registered
#        as submodule of the :path:`OpenCMISS-Examples/examples` repository.
#        **This is intended for the transition phase from SVN global examples repo to PMR only and will disappear in due time!**
#    :examples-test: Uses CTest to simply execute all the examples (if successfully built).
#        Currently they’re invoked without arguments which may break some of them due to that.
#    :featuretests: Builds and runs the featuretests. These are selected OpenCMISS examples that cover the parts of
#        OpenCMISS that are used most frequently but are yet fast to run. These tests are run after every build in order
#        to provide a fast first test suite to assess overall health.

# The above are dummy entries for documentation.
#
# The 'examples'/'examples-test' targets are defined in OCAddExamplesProject, 'featuretests' is added
# in OCFeatureTests.

##
#    :gitstatus: This target is intended for developers, who would like a quick way of
#        obtaining the current status of all components that are build locally.
#        Only available if Git_ is found.
if (GIT_FOUND)
    add_custom_target(gitstatus
        DEPENDS ${_OC_SOURCE_GITSTATUS_TARGETS}
    )
endif()

##
#    :opencmiss: Main build target. Comprises :sh:`all, install, featuretests`
add_custom_target(opencmiss
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR} --target install
    COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BINARY_DIR} --target featuretests
)

##
#    :reset: Removes everything from the current build root but the :ref:`OpenCMISSLocalConfig <localconf>` file.
#        Also invokes the following (independently usable) targets:
add_custom_target(reset
    DEPENDS reset_mpionly reset_featuretests
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${OPENCMISS_COMPONENTS_INSTALL_PREFIX_NO_BUILD_TYPE}"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${OPENCMISS_COMPONENTS_BINARY_DIR}"
    COMMAND ${CMAKE_COMMAND} -E remove "${OC_BUILDLOG}"
    COMMAND ${CMAKE_COMMAND} -E copy ${OPENCMISS_LOCALCONFIG} ../backup_localconfig.tmp
    COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/*
    COMMAND ${CMAKE_COMMAND} -E copy ../backup_localconfig.tmp ${OPENCMISS_LOCALCONFIG}
    COMMAND ${CMAKE_COMMAND} -E remove -f ../backup_localconfig.tmp
    COMMENT "Removing directories:
        ->${OPENCMISS_COMPONENTS_INSTALL_PREFIX_NO_BUILD_TYPE}
        ->${OPENCMISS_COMPONENTS_BINARY_DIR}"
)

##
#    :reset_featuretests: Triggers a re-build of the feature tests
#        For more information see the techical documentation on :ref:`featuretests`.
if (FEATURETESTS_SRC_DIR) # only add if feature tests are build. existence of the source dir is a sufficient criteria.
    add_custom_target(reset_featuretests
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${FEATURETESTS_BINARY_DIR}"
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${FEATURETESTS_SRC_DIR}" # Also just remove the sources for now, they're not big
        COMMENT "Cleaning up feature test builds"
    )
endif()

##
#    :reset_mpionly: Blows away all the build and install data of components with MPI capabilities.
add_custom_target(reset_mpionly
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${OPENCMISS_COMPONENTS_INSTALL_PREFIX_MPI_NO_BUILD_TYPE}"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${OPENCMISS_COMPONENTS_BINARY_DIR_MPI}"
    COMMENT "Removing directories:
        ->${OPENCMISS_COMPONENTS_INSTALL_PREFIX_MPI_NO_BUILD_TYPE}
        ->${OPENCMISS_COMPONENTS_BINARY_DIR_MPI}"
)

##
#    :support: See the :ref:`support section`.
#
#    :test: Run all the tests for all current components. Lengthy!

# The above are dummy entries for documentation.
#
# The 'support' target is defined in OCSupport, and 'test' is the default test target of CMake.
# The tests itself are added at the end of OCFunctionComponentTargets#addConvenienceTargets

##
#    :update: Goes through all OpenCMISS components that are locally build and fetches
#        the newest commit on the configured version branches.
add_custom_target(update
    DEPENDS ${_OC_SOURCE_UPDATE_TARGETS}
)

## 
#    :utter_destruction: Removes the complete build/ and install/ root directories created by any architecture build.
add_custom_target(utter_destruction
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${OPENCMISS_ROOT}/build"
    COMMAND ${CMAKE_COMMAND} -E remove_directory "${OPENCMISS_ROOT}/install"
    COMMAND ${CMAKE_COMMAND} -E copy ${OPENCMISS_LOCALCONFIG} ../backup_localconfig.tmp
    COMMAND ${CMAKE_COMMAND} -E remove -f ${PROJECT_BINARY_DIR}/*
    COMMAND ${CMAKE_COMMAND} -E copy ../backup_localconfig.tmp ${OPENCMISS_LOCALCONFIG}
    COMMAND ${CMAKE_COMMAND} -E remove -f ../backup_localconfig.tmp
    COMMENT "BAM! Deleting build & install folders. Only keeping OpenCMISSLocalConfig"
)