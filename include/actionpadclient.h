#ifndef ACTIONPADCLIENT_H
#define ACTIONPADCLIENT_H

#include <QObject>
#include <QTcpSocket>
#include <QAbstractListModel>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QTimer>
#include <QQmlEngine>

struct ClientAction {
    QString name;
    QString icon;
    int id;
};

class ActionModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum ActionRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        IconRole
    };

    explicit ActionModel(QObject *parent = nullptr);

    void clearActions();
    void addAction(int id, const QString &name, const QString &icon);

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<ClientAction> m_actions;
};

class ActionPadClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(QString serverAddress READ serverAddress WRITE setServerAddress NOTIFY serverAddressChanged)
    Q_PROPERTY(int serverPort READ serverPort WRITE setServerPort NOTIFY serverPortChanged)
    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)
    Q_PROPERTY(ActionModel* actionModel READ actionModel CONSTANT)

public:
    static ActionPadClient* create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
    static ActionPadClient* instance();

    bool isConnected() const { return m_socket->state() == QTcpSocket::ConnectedState; }
    QString serverAddress() const { return m_serverAddress; }
    void setServerAddress(const QString &address);
    int serverPort() const { return m_serverPort; }
    void setServerPort(int port);
    QString connectionStatus() const { return m_connectionStatus; }
    ActionModel* actionModel() { return &m_actionModel; }

    Q_INVOKABLE void connectToServer();
    Q_INVOKABLE void disconnectFromServer();
    Q_INVOKABLE void pressAction(int actionId);
    Q_INVOKABLE void refreshActions();

signals:
    void isConnectedChanged();
    void serverAddressChanged();
    void serverPortChanged();
    void connectionStatusChanged();
    void actionsReceived(int count);
    void actionUpdated();

private slots:
    void onConnected();
    void onDisconnected();
    void onDataReceived();
    void onError(QAbstractSocket::SocketError error);
    void onReconnectTimer();

private:
    explicit ActionPadClient(QObject *parent = nullptr);
    void processMessage(const QJsonObject &message);
    void sendMessage(const QJsonObject &message);
    void setConnectionStatus(const QString &status);
    void startReconnectTimer();
    void stopReconnectTimer();

    static ActionPadClient* m_instance;
    QTcpSocket *m_socket;
    ActionModel m_actionModel;
    QString m_serverAddress;
    int m_serverPort;
    QString m_connectionStatus;
    QTimer *m_reconnectTimer;
    bool m_autoReconnect;
};

#endif // ACTIONPADCLIENT_H
