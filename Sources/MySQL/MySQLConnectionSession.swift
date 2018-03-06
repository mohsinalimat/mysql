import Bits

/// Represents information about a single MySQL connection.
final class MySQLConnectionSession {
    /// The state of this connection.
    var handshakeState: MySQLHandshakeState

    var connectionState: MySQLConnectionState

    /// The next available sequence ID.
    var nextSequenceID: Byte {
        defer { incrementSequenceID() }
        return sequenceID
    }

    /// The current sequence ID.
    private var sequenceID: Byte

    /// Creates a new `MySQLConnectionSession`.
    init() {
        self.handshakeState = .waiting
        self.connectionState = .none
        self.sequenceID = 0
    }

    /// Increments the sequence ID.
    func incrementSequenceID() {
        sequenceID = sequenceID &+ 1
    }

    /// Resets the sequence ID.
    func resetSequenceID() {
        sequenceID = 0
    }
}

/// Possible connection states.
enum MySQLHandshakeState {
    /// This is a new connection that has not completed the MySQL handshake.
    case waiting

    /// The handshake has been completed and server capabilities are received.
    case complete(MySQLCapabilities)
}

/// Possible states of a handshake-completed connection.
enum MySQLConnectionState {
    /// No special state.
    /// The connection should parse OK and ERR packets only.
    case none
    /// Performing a Text Protocol query.
    case textProtocol(MySQLTextProtocolState)
}

/// Connection states during a simple query aka Text Protocol.
/// https://dev.mysql.com/doc/internals/en/text-protocol.html
enum MySQLTextProtocolState {
    /// 14.6.4 COM_QUERY has been sent, awaiting response.
    case waiting
    /// parsing column_count * Protocol::ColumnDefinition packets
    case columns(columnCount: Int, remaining: Int)
    /// parsing One or more ProtocolText::ResultsetRow packets, each containing column_count values
    case rows(columnCount: Int, remaining: Int)
}
