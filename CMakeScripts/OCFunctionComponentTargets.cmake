##
# Besides the top-level targets, each OpenCMISS component also provides targets
# for direct invocation.
# In the following, *<compname>* stands for any OpenCMISS component (lowercase).
#
#    :<compname>: Trigger the build for the specified component, e.g. :sh:`make iron`
#    :<compname>-clean: Invoke the classical :sh:`clean` target for the specified component and
#        triggers a re-run of CMake for that component.
#    :<compname>-update: Update the sources for the specified component.
#        Please note that you should ALWAYS use the top level :sh:`make update` command to ensure
#        fetching a compatible set of components - single component updates are for experienced users only.
#    :<compname>-gitstatus: Get a current git status report. Only available if Git_ is used.
#    :<compname>-test: Run any tests provided by the component.
#    :<compname>-rebuild: Extends the *<compname>-clean* by also removing the CMakeFiles folder, CMake Cache 
#        and finally triggers the build of the external project main target. 
 
#  
# This function is called from within OCComponentSetupMacros#addAndConfigureLocalComponent
# and has been placed inside a separate file to ease documentation
#
function(addConvenienceTargets COMPONENT_NAME BINARY_DIR SOURCE_DIR)
    # Add convenience direct-access clean target for component
    string(TOLOWER "${COMPONENT_NAME}" COMPONENT_NAME_LOWER)
    add_custom_target(${COMPONENT_NAME_LOWER}-clean
        COMMAND ${CMAKE_COMMAND} -E remove -f ${BINARY_DIR}/ep_stamps/*-configure
        COMMAND ${CMAKE_COMMAND} -E touch ${BINARY_DIR}/CMakeCache.txt # force cmake re-run to make sure
        COMMAND ${CMAKE_COMMAND} --build ${BINARY_DIR} --target clean
        COMMENT "Cleaning ${COMPONENT_NAME}"
    )
    # Add convenience direct-access update target for component
    # This removes the external project stamp for the last update and hence triggers execution of the update, e.g.
    # a new source download or "git pull"
    add_custom_target(${COMPONENT_NAME_LOWER}-update
        COMMAND ${CMAKE_COMMAND} -E remove -f ${OPENCMISS_ROOT}/src/download/stamps/${COMPONENT_NAME}_SRC-update
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_BINARY_DIR} --target ${COMPONENT_NAME}_SRC-update
        COMMENT "Updating ${COMPONENT_NAME} sources"
    )
    
    # Rebuild does not only invoke the clean target but also completely removes the CMakeFiles folder and Cache,
    # forcing a complete re-configuration of the component.
    add_custom_target(${COMPONENT_NAME_LOWER}-rebuild
        DEPENDS ${COMPONENT_NAME_LOWER}-clean
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${BINARY_DIR}/CMakeFiles
        COMMAND ${CMAKE_COMMAND} -E remove -f ${BINARY_DIR}/CMakeCache.txt
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_BINARY_DIR} --target ${OC_EP_PREFIX}${COMPONENT_NAME}
        COMMENT "Rebuilding ${COMPONENT_NAME}"
    )
    
    if (GIT_FOUND)
        add_custom_target(${COMPONENT_NAME_LOWER}-gitstatus
            COMMAND ${GIT_EXECUTABLE} status
            COMMAND ${CMAKE_COMMAND} -E echo "Branches for ${COMPONENT_NAME_LOWER} repository"
            COMMAND ${GIT_EXECUTABLE} branch -av -v 
            WORKING_DIRECTORY ${SOURCE_DIR}
            COMMENT "Git status report for ${COMPONENT_NAME_LOWER} at ${SOURCE_DIR}"
        )
    endif()
    
    # Add convenience direct-access forced build target for component
    getBuildCommands(_DUMMY INSTALL_COMMAND ${BINARY_DIR} TRUE)
    add_custom_target(${COMPONENT_NAME_LOWER}
        COMMAND ${CMAKE_COMMAND} -E remove -f ${BINARY_DIR}/ep_stamps/*-build
        COMMAND ${INSTALL_COMMAND}
    )
    if (BUILD_TESTS)
        # Add convenience direct-access test target for component
        add_custom_target(${COMPONENT_NAME_LOWER}-test
            COMMAND ${CMAKE_COMMAND} --build ${BINARY_DIR} --target test
        )
        # Add a global test to run the external project's tests
        add_test(${COMPONENT_NAME_LOWER}-test ${CMAKE_COMMAND} --build ${BINARY_DIR} --target test)
    endif()
endfunction()   