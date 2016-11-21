make_directory(${CONFIG_PATH})
execute_process(
    COMMAND "${CMAKE_COMMAND}" ${PASS_THROUGH_ARGS} -DTOOLCHAIN=${OPENCMISS_TOOLCHAIN} -DOPENCMISS_MPI=${OPENCMISS_MPI} -DOPENCMISS_OWN_MPI_INSTALL_BASE=${OPENCMISS_OWN_MPI_INSTALL_BASE} -DOPENCMISS_CACHE_FILE=${OPENCMISS_CACHE_FILE} -DOPENCMISS_CMAKE_MODULES_PATH=${OPENCMISS_CMAKE_MODULES_PATH} -DMANAGE_MODULE_PATH=${MANAGE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/config"
    WORKING_DIRECTORY ${CONFIG_PATH}
    )
