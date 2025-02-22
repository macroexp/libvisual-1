INCLUDE(CMakeParseArguments)

FUNCTION(LV_BUILD_PLUGIN PLUGIN_NAME PLUGIN_TYPE)
  SET(VALID_TYPES "actor" "input" "morph")

  STRING(TOLOWER "${PLUGIN_TYPE}" PLUGIN_TYPE)
  LIST(FIND VALID_TYPES "${PLUGIN_TYPE}" RESULT)
  IF(RESULT EQUAL -1)
    MESSAGE(FATAL_ERROR "Cannot build plugin '${PLUGIN_NAME}', type '${PLUGIN_TYPE}' is not recognized.")
  ENDIF()

  SET(OPTION_ARGS "")
  SET(SINGLE_ARGS "")
  SET(MULTI_ARGS  "SOURCES" "COMPILE_DEFS" "COMPILE_FLAGS" "INCLUDE_DIRS" "LINK_DIRS" "LINK_LIBS")
  CMAKE_PARSE_ARGUMENTS(PARSED_ARGS "${OPTION_FLAGS}" "${SINGLE_ARGS}" "${MULTI_ARGS}" ${ARGN})

  IF(NOT PARSED_ARGS_SOURCES)
    MESSAGE(FATAL_ERROR "Cannot build plugin '${PLUGIN_NAME}', no source files specified.")
  ENDIF()

  INCLUDE_DIRECTORIES(
    ${PROJECT_SOURCE_DIR}
    ${PROJECT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    ${LIBVISUAL_INCLUDE_DIRS}
    ${PARSED_ARGS_INCLUDE_DIRS}
  )

  LINK_DIRECTORIES(
    ${LIBVISUAL_LIBRARY_DIRS}
    ${PARSED_ARGS_LINK_DIRS}
  )

  STRING(TOUPPER "${PLUGIN_TYPE}" PLUGIN_TYPE_CAPS)

  SET(SO_NAME "${PLUGIN_TYPE}_${PLUGIN_NAME}")
  SET(SO_INSTALL_DIR "${LV_${PLUGIN_TYPE_CAPS}_PLUGIN_DIR}")

  IF(PARSED_ARGS_COMPILE_DEFS)
    ADD_DEFINITIONS(${PARSED_ARGS_COMPILE_DEFS})
  ENDIF()

  ADD_LIBRARY(${SO_NAME} MODULE ${PARSED_ARGS_SOURCES})

  IF(PARSED_ARGS_COMPILE_FLAGS)
    SET_TARGET_PROPERTIES(${SO_NAME} PROPERTIES
      COMPILE_FLAGS ${PARSED_ARGS_COMPILE_FLAGS}
    )
  ENDIF()

  TARGET_LINK_LIBRARIES(${SO_NAME}
    ${LIBVISUAL_LIBRARIES}
    ${CMAKE_THREAD_LIBS_INIT}
    ${PARSED_ARGS_LINK_LIBS}
  )

  INSTALL(TARGETS ${SO_NAME} LIBRARY DESTINATION ${SO_INSTALL_DIR})
ENDFUNCTION()

MACRO(LV_BUILD_ACTOR_PLUGIN PLUGIN_NAME)
  LV_BUILD_PLUGIN(${PLUGIN_NAME} actor ${ARGN})
ENDMACRO()

MACRO(LV_BUILD_INPUT_PLUGIN PLUGIN_NAME)
  LV_BUILD_PLUGIN(${PLUGIN_NAME} input ${ARGN})
ENDMACRO()

MACRO(LV_BUILD_MORPH_PLUGIN PLUGIN_NAME)
  LV_BUILD_PLUGIN(${PLUGIN_NAME} morph ${ARGN})
ENDMACRO()
