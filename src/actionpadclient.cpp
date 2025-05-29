#include "actionpadclient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

// ActionModel Implementation
ActionModel::ActionModel(QObject *parent) : QAbstractListModel(parent)
{
}

ActionPadClient* ActionPadClient::m_instance = nullptr;

ActionPadClient* ActionPadClient::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)

    if (!m_instance) {
        m_instance = new ActionPadClient();
    }
    return m_instance;
}

ActionPadClient* ActionPadClient::instance()
{
    if (!m_instance) {
        m_instance = new ActionPadClient();
    }
    return m_instance;
}

void ActionModel::clearActions()
{
    beginResetModel();
    m_actions.clear();
    endResetModel();
}

void ActionModel::addAction(int id, const QString &name, const QString &icon)
{
    beginInsertRows(QModelIndex(), rowCount(), rowCount());

    ClientAction action;
    action.id = id;
    action.name = name;
    action.icon = icon;

    m_actions.append(action);
    endInsertRows();
}

int ActionModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_actions.size();
}

QVariant ActionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_actions.size())
        return QVariant();

    const ClientAction &action = m_actions[index.row()];

    switch (role) {
    case IdRole: return action.id;
    case NameRole: return action.name;
    case IconRole: return action.icon;
    }

    return QVariant();
}

QHash<int, QByteArray> ActionModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "actionId";
    roles[NameRole] = "name";
    roles[IconRole] = "icon";
    return roles;
}

// ActionPadClient Implementation
ActionPadClient::ActionPadClient(QObject *parent)
    : QObject(parent)
    , m_serverAddress("192.168.1.100")
    , m_serverPort(8080)
    , m_connectionStatus("Disconnected")
    , m_autoReconnect(false)
{
    m_socket = new QTcpSocket(this);
    m_reconnectTimer = new QTimer(this);

    connect(m_socket, &QTcpSocket::connected, this, &ActionPadClient::onConnected);
    connect(m_socket, &QTcpSocket::disconnected, this, &ActionPadClient::onDisconnected);
    connect(m_socket, &QTcpSocket::readyRead, this, &ActionPadClient::onDataReceived);
    connect(m_socket, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::errorOccurred),
            this, &ActionPadClient::onError);

    m_reconnectTimer->setSingleShot(true);
    m_reconnectTimer->setInterval(3000); // 3 seconds
    connect(m_reconnectTimer, &QTimer::timeout, this, &ActionPadClient::onReconnectTimer);
}

void ActionPadClient::setServerAddress(const QString &address)
{
    if (m_serverAddress != address) {
        m_serverAddress = address;
        emit serverAddressChanged();
    }
}

void ActionPadClient::setServerPort(int port)
{
    if (m_serverPort != port) {
        m_serverPort = port;
        emit serverPortChanged();
    }
}

void ActionPadClient::connectToServer()
{
    if (m_socket->state() == QTcpSocket::ConnectedState) {
        return;
    }

    setConnectionStatus("Connecting...");
    m_autoReconnect = true;
    m_socket->connectToHost(m_serverAddress, m_serverPort);
}

void ActionPadClient::disconnectFromServer()
{
    m_autoReconnect = false;
    stopReconnectTimer();

    if (m_socket->state() == QTcpSocket::ConnectedState) {
        m_socket->disconnectFromHost();
    }

    setConnectionStatus("Disconnected");
}

void ActionPadClient::pressAction(int actionId)
{
    if (m_socket->state() != QTcpSocket::ConnectedState) {
        return;
    }

    QJsonObject message;
    message["type"] = "action_press";
    message["actionId"] = actionId;

    sendMessage(message);
}

void ActionPadClient::refreshActions()
{
    if (m_socket->state() != QTcpSocket::ConnectedState) {
        return;
    }

    QJsonObject message;
    message["type"] = "get_actions";

    sendMessage(message);
}

void ActionPadClient::onConnected()
{
    setConnectionStatus("Connected");
    stopReconnectTimer();
    emit isConnectedChanged();

    // Request actions immediately after connecting
    refreshActions();
}

void ActionPadClient::onDisconnected()
{
    setConnectionStatus("Disconnected");
    emit isConnectedChanged();

    // Clear actions when disconnected
    m_actionModel.clearActions();
    emit actionsReceived(0);

    if (m_autoReconnect) {
        startReconnectTimer();
    }
}

void ActionPadClient::onDataReceived()
{
    QByteArray data = m_socket->readAll();

    // Handle multiple JSON messages separated by newlines
    QStringList messages = QString::fromUtf8(data).split('\n', Qt::SkipEmptyParts);

    for (const QString &messageStr : messages) {
        QJsonDocument doc = QJsonDocument::fromJson(messageStr.toUtf8());
        if (doc.isObject()) {
            processMessage(doc.object());
        }
    }
}

void ActionPadClient::onError(QAbstractSocket::SocketError error)
{
    Q_UNUSED(error);

    QString errorString = m_socket->errorString();
    setConnectionStatus("Error: " + errorString);

    if (m_autoReconnect) {
        startReconnectTimer();
    }
}

void ActionPadClient::onReconnectTimer()
{
    if (m_autoReconnect && m_socket->state() != QTcpSocket::ConnectedState) {
        setConnectionStatus("Reconnecting...");
        m_socket->connectToHost(m_serverAddress, m_serverPort);
    }
}

void ActionPadClient::processMessage(const QJsonObject &message)
{
    QString type = message["type"].toString();

    if (type == "actions") {
        m_actionModel.clearActions();

        QJsonArray actionsArray = message["actions"].toArray();
        for (const QJsonValue &value : actionsArray) {
            QJsonObject actionObj = value.toObject();

            int id = actionObj["id"].toInt();
            QString name = actionObj["name"].toString();
            QString icon = actionObj["icon"].toString();

            m_actionModel.addAction(id, name, icon);
        }

        emit actionsReceived(actionsArray.size());
        emit actionUpdated();

        if (actionsArray.size() > 0) {
            setConnectionStatus("Connected - " + QString::number(actionsArray.size()) + " actions");
        } else {
            setConnectionStatus("Connected - No actions available");
        }
    }
}

void ActionPadClient::sendMessage(const QJsonObject &message)
{
    if (m_socket->state() != QTcpSocket::ConnectedState) {
        return;
    }

    QJsonDocument doc(message);
    m_socket->write(doc.toJson(QJsonDocument::Compact) + "\n");
}

void ActionPadClient::setConnectionStatus(const QString &status)
{
    if (m_connectionStatus != status) {
        m_connectionStatus = status;
        emit connectionStatusChanged();
    }
}

void ActionPadClient::startReconnectTimer()
{
    if (!m_reconnectTimer->isActive()) {
        m_reconnectTimer->start();
    }
}

void ActionPadClient::stopReconnectTimer()
{
    if (m_reconnectTimer->isActive()) {
        m_reconnectTimer->stop();
    }
}
