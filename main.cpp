#include "qtquick2controlsapplicationviewer.h"

int main(int argc, char *argv[])
{
    Application app(argc, argv);

    QtQuick2ControlsApplicationViewer viewer;
    viewer.setMainQmlFile("qrc:/qml/Quicktronome/main.qml");
    viewer.show();

    return app.exec();
}
