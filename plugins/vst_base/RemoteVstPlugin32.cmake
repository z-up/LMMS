IF(LMMS_BUILD_WIN32 AND NOT LMMS_BUILD_WIN64)
	ADD_SUBDIRECTORY(RemoteVstPlugin)
ELSEIF(LMMS_BUILD_WIN64 AND MSVC)
	SET(MSVC_VER ${CMAKE_CXX_COMPILER_VERSION})

	IF(NOT CMAKE_GENERATOR_32) 
		IF(MSVC_VER VERSION_GREATER 19.0 OR MSVC_VER VERSION_EQUAL 19.0)
			SET(CMAKE_GENERATOR_32 "Visual Studio 14 2015")
			SET(MSVC_YEAR 2015)
		ELSEIF(MSVC_VER VERSION_EQUAL 19.10 OR MSVC_VER VERSION_EQUAL 19.10)
			SET(CMAKE_GENERATOR_32 "Visual Studio 15 2017")
			SET(MSVC_YEAR 2017)
		ELSE()
			MESSAGE(SEND_WARNING "Can't build RemoteVstPlugin32, unknown MSVC version ${MSVC_VER} and no CMAKE_GENERATOR_32 set")
			RETURN()
		ENDIF()
	ENDIF()

	IF(NOT QT_32_PREFIX AND NOT USING_VCPKG)	
		GET_FILENAME_COMPONENT(QT_BIN_DIR ${QT_QMAKE_EXECUTABLE} DIRECTORY)
		SET(QT_32_PREFIX "${QT_BIN_DIR}/../../msvc${MSVC_YEAR}")
	ENDIF()

	IF(NOT QT_32_PREFIX)
		MESSAGE(WARNING "Can't build RemoteVstPlugin32, QT_32_PREFIX not set")
		RETURN()
	ELSEIF(NOT (IS_DIRECTORY ${QT_32_PREFIX} AND EXISTS ${QT_32_PREFIX}/bin/qmake.exe))
		MESSAGE(WARNING "Can't build RemoteVstPlugin32, no Qt 32 bit installation found at ${QT_32_PREFIX}")
		RETURN()
	ENDIF()

	ExternalProject_Add(RemoteVstPlugin32
		"${EXTERNALPROJECT_ARGS}"
		CMAKE_GENERATOR "${CMAKE_GENERATOR_32}"
		#CMAKE_GENERATOR_TOOLSET "${CMAKE_GENERATOR_TOOLSET}"
		CMAKE_ARGS
			"${EXTERNALPROJECT_CMAKE_ARGS}"
			"-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
			"-DCMAKE_PREFIX_PATH=${QT_32_PREFIX}"
	)
ELSEIF(LMMS_BUILD_LINUX)
	# Use winegcc
	ExternalProject_Add(RemoteVstPlugin32
		"${EXTERNALPROJECT_ARGS}"
		CMAKE_ARGS
			"${EXTERNALPROJECT_CMAKE_ARGS}"
			"-DCMAKE_CXX_COMPILER=${WINEGCC}"
			"-DCMAKE_CXX_FLAGS=-m32 -mwindows"
	)
ELSEIF(CMAKE_TOOLCHAIN_FILE_32)
	ExternalProject_Add(RemoteVstPlugin32
		"${EXTERNALPROJECT_ARGS}"
		CMAKE_ARGS
			"${EXTERNALPROJECT_CMAKE_ARGS}"
			"-DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_32}"
			"-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE_32}"
	)
ELSE()
	message(WARNING "Can't build RemoteVstPlugin32, unknown environment. Please supply CMAKE_TOOLCHAIN_FILE_32 and optionally CMAKE_PREFIX_PATH_32")
	RETURN()
ENDIF()

IF(LMMS_BUILD_LINUX)
	INSTALL(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../RemoteVstPlugin32" "${CMAKE_CURRENT_BINARY_DIR}/../RemoteVstPlugin32.exe.so" DESTINATION "${PLUGIN_DIR}")
ELSEIF(LMMS_BUILD_WIN32)
	INSTALL(PROGRAMS "${CMAKE_CURRENT_BINARY_DIR}/../RemoteVstPlugin32.exe" DESTINATION "${PLUGIN_DIR}")
ENDIF()
