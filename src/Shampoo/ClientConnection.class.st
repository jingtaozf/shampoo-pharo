"
My instances represent a client connection. A client connection
is actually a finite state machine, see ConnectionState class and its subclasses
"
Class {
	#name : #ClientConnection,
	#superclass : #Object,
	#instVars : [
		'sock',
		'server',
		'disconnectedHandler',
		'state',
		'parser'
	],
	#category : #'Shampoo-Server'
}

{ #category : #'instance creation' }
ClientConnection class >> on: aSocket onDisconnect: aBlock parent: aServer [
            ^self new on: aSocket onDisconnect: aBlock parent: aServer

]

{ #category : #networking }
ClientConnection >> close [
	[sock close] onErrorDo: []
]

{ #category : #networking }
ClientConnection >> drop [
	self
		close;
		signalDisconnected.

]

{ #category : #fsm }
ClientConnection >> echo: aString [
            self state echo: aString

]

{ #category : #private }
ClientConnection >> fetchMessages [
	[sock waitForData]
		on: ConnectionClosed
		do: [ClientDisconnected new signal].
	^parser process: (sock receiveAvailableData)
]

{ #category : #loop }
ClientConnection >> go [
    [sock isConnected] whileTrue:
	[[self fetchMessages do: [:m | self process: m]]
            on: ClientDisconnected
		do: [:e | ^self signalDisconnected]]

]

{ #category : #private }
ClientConnection >> on: aSocket onDisconnect: aBlock parent: aServer [
            sock := aSocket.
            server := aServer.
            disconnectedHandler := aBlock.
		state := NotAuthorizedState of: self.
            state register.
		parser := MessageParser new.
]

{ #category : #fsm }
ClientConnection >> process: anXMLRequest [
	| r xml |
	[xml := ShampooXMLNode from: anXMLRequest
	] onErrorDo: [^nil].
	r := Request from: xml.
	[self send: (self state process: r)]
		on: FatalError do: [:e | self drop]

]

{ #category : #networking }
ClientConnection >> send: aPacket [
	| stream msg |
	msg := aPacket asXML fullPrintString.
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'Content-Length: ', msg size printString;
		crlf;
		crlf;
		nextPutAll: msg;
		crlf.
	sock sendData: stream contents.

]

{ #category : #accessors }
ClientConnection >> server [
            ^server

]

{ #category : #private }
ClientConnection >> signalDisconnected [
            disconnectedHandler ifNotNil: [:handler | handler value: self]

]

{ #category : #fsm }
ClientConnection >> state [
            ^state

]

{ #category : #fsm }
ClientConnection >> state: aClientConnectionState [
            state := aClientConnectionState

]
