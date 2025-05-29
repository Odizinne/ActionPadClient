#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "actionpadclient.h"

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_MATERIAL_VARIANT", "Dense");
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Odizinne");
    app.setApplicationName("ActionPadClient");

    qmlRegisterType<ActionPadClient>("Odizinne.ActionPadClient", 1, 0, "ActionPadClient");
    qmlRegisterType<ActionModel>("Odizinne.ActionPadClient", 1, 0, "ActionModel");

    QQmlApplicationEngine engine;
    engine.loadFromModule("Odizinne.ActionPadClient", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
