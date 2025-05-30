#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_MATERIAL_VARIANT", "Dense");
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Odizinne");
    app.setApplicationName("ActionPadClient");
    QQmlApplicationEngine engine;
    engine.loadFromModule("Odizinne.ActionPadClient", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
