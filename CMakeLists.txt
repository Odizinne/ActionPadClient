cmake_minimum_required(VERSION 3.16)
project(ActionPadClient VERSION 0.0.1 LANGUAGES CXX)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation directory" FORCE)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(QT_QML_GENERATE_QMLLS_INI ON)
set(CMAKE_DISABLE_FIND_PACKAGE_WrapVulkanHeaders TRUE)

find_package(Qt6 REQUIRED COMPONENTS
    Quick
    LinguistTools
)

qt_standard_project_setup(REQUIRES 6.8)

set(SOURCES
    src/actionpadclient.cpp
    src/main.cpp
)

set(HEADERS
    include/actionpadclient.h
)

qt_add_executable(${CMAKE_PROJECT_NAME}
    ${SOURCES}
    ${HEADERS}
    resources/icons/icons.qrc
)

set(QML_FILES
    qml/Main.qml
    qml/ActionsPage.qml
    qml/SettingsPage.qml
    qml/ScrollingArea.qml
)

set(QML_SINGLETONS
    qml/Singletons/UserSettings.qml
)

set_source_files_properties(${QML_SINGLETONS}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(${CMAKE_PROJECT_NAME}
    URI Odizinne.ActionPadClient
    VERSION 1.0
    QML_FILES ${QML_FILES} ${QML_SINGLETONS}
)

set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
    WIN32_EXECUTABLE TRUE
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    QT_ANDROID_PACKAGE_NAME "com.odizinne.actionpadclient"
    QT_ANDROID_APP_NAME "ActionPad Client"
    #QT_ANDROID_APP_ICON "@mipmap/ic_launcher"
    QT_ANDROID_TARGET_SDK_VERSION 34
    QT_ANDROID_MIN_SDK_VERSION 24
    QT_ANDROID_VERSION_NAME "${PROJECT_VERSION}"
    QT_ANDROID_VERSION_CODE 1
)


target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(${CMAKE_PROJECT_NAME}
    PRIVATE Qt6::Quick
)

qt_add_translations(${CMAKE_PROJECT_NAME}
    TS_FILES
        i18n/${CMAKE_PROJECT_NAME}_en.ts
        i18n/${CMAKE_PROJECT_NAME}_fr.ts
    RESOURCE_PREFIX "/i18n"
    LUPDATE_OPTIONS "-no-obsolete"
)

#add_dependencies(${CMAKE_PROJECT_NAME} update_translations)

include(GNUInstallDirs)
if(ANDROID)
    install(TARGETS ${CMAKE_PROJECT_NAME}
        BUNDLE DESTINATION .
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
else()
    install(TARGETS ${CMAKE_PROJECT_NAME}
        BUNDLE DESTINATION .
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    # Only generate deploy script for non-Android platforms
    qt_generate_deploy_qml_app_script(
        TARGET ${CMAKE_PROJECT_NAME}
        OUTPUT_SCRIPT deploy_script
        NO_TRANSLATIONS
        DEPLOY_TOOL_OPTIONS --no-compiler-runtime --no-opengl-sw --no-system-dxc-compiler --no-system-d3d-compiler --skip-plugin-types imageformats,designer,iconengines,qmllint,generic,networkinformation,help,qmltooling,sqldrivers,tls,qmlls
    )

    install(SCRIPT ${deploy_script})
endif()
