"
I am the heart of the Shampoo system. My instances manage
connections and... hmm, looks like thats all.
"
Class {
	#name : #ShampooServer,
	#superclass : #Object,
	#instVars : [
		'server',
		'clients',
		'clientsMutex',
		'creds'
	],
	#classVars : [
		'Servers',
		'ServersMutex'
	],
	#category : #'Shampoo-Server'
}

{ #category : #networking }
ShampooServer class >> closeOn: aPort [
	self serversMutex critical: 
	[| srv |
	srv := self servers at: aPort ifAbsent: [^nil].
	Servers removeKey: aPort.
	srv close.
	Servers ifEmpty: [ShampooTranscript uninstall] ]
	
]

{ #category : #private }
ShampooServer class >> servers [
	^Servers ifNil: [Servers := Dictionary new]
]

{ #category : #private }
ShampooServer class >> serversMutex [
	^ServersMutex ifNil: [ServersMutex := Semaphore forMutualExclusion]
]

{ #category : #'instance creation' }
ShampooServer class >> startOn: aPort creds: aCreds [
	self serversMutex critical: 
		[ self servers isEmptyOrNil ifTrue: [ ShampooTranscript install ].
		 (self servers includesKey: aPort) ifFalse:
	            [| srv |
 	            srv := self new.
			self servers at: aPort put: srv.
			ShampooTranscript add: srv.
			[srv startOn: aPort creds: aCreds] fork]]
   			

]

{ #category : #'instance creation' }
ShampooServer class >> startOn: aPort login: aLogin pass: aPass [
            ^self startOn: aPort creds: (AuthInfo login: aLogin pass: aPass)

]

{ #category : #private }
ShampooServer >> acceptedClient: aSocket [
            | client |
            client := ClientConnection
                on: aSocket
                onDisconnect: [:cl | self handleDisconnected: cl]
                parent: self.
            clientsMutex critical: [self clients add: client].
            ^client

]

{ #category : #authentication }
ShampooServer >> authenticates: aCreds with: aMagic [
      ^(creds with: aMagic) = aCreds

]

{ #category : #private }
ShampooServer >> clients [
            ^clients ifNil: [clients := OrderedCollection new]

]

{ #category : #private }
ShampooServer >> close [
	[server close] onErrorDo: [].
	clientsMutex critical:
	[self clients copy do: [:cl | cl close]].
	"And that's all. Every client connection
 	will be removed from the set in the
	ShampooServer>>handleDisconnected:."
	ShampooTranscript remove: self.
]

{ #category : #transcript }
ShampooServer >> echo: aString [
            clientsMutex critical: [self clients do: [:each | each echo: aString]]

]

{ #category : #delegation }
ShampooServer >> handleDisconnected: aClient [
            "This method is delegated to a client session in a block"
            clientsMutex critical: [self clients remove: aClient]

]

{ #category : #private }
ShampooServer >> startOn: aPort creds: aCreds [
            clientsMutex := Semaphore forMutualExclusion.
            server := Socket newTCP listenOn: aPort backlogSize: 10.
            creds := aCreds.

            [server isWaitingForConnection] whileTrue:
			[| client |
			client := server waitForAcceptFor: 30.
			client ifNotNil: [[(self acceptedClient: client) go] fork]]

]
