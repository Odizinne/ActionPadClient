#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "actionpadclient.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<ActionPadClient>("Odizinne.ActionPadClient", 1, 0, "ActionPadClient");
    qmlRegisterType<ActionModel>("Odizinne.ActionPadClient", 1, 0, "ActionModel");

    QQmlApplicationEngine engine;
    engine.loadFromModule("Odizinne.ActionPadClient", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
