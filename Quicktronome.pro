# Add more folders to ship with the application, here
folder_01.source = qml/Quicktronome
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2controlsapplicationviewer/qtquick2controlsapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    sounds/accent_pluck.wav \
    sounds/accent_bass.wav \
    sounds/click_sine.wav \
    sounds/click_pluck.wav \
    sounds/click_bass.wav \
    sounds/accent_sine.wav

RESOURCES += \
    sounds.qrc \
    main.qrc

ANDROID_EXTRA_LIBS = 

QT += qml quick widgets sql multimedia
