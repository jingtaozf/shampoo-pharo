Class {
	#name : #ShampooNotAuthStateTest,
	#superclass : #ShampooTestCase,
	#instVars : [
		'state',
		'connMock'
	],
	#category : #'Shampoo-Tests'
}

{ #category : #'as yet unclassified' }
ShampooNotAuthStateTest >> setUp [
	connMock := ShampooConnectionMock new.
            state := NotAuthorizedState of: connMock

]

{ #category : #'as yet unclassified' }
ShampooNotAuthStateTest >> testCheckLoginFail [
	| rq failed |
            rq := self requestFrom: ShampooLoginTest loginSample.
            connMock
                on: #authenticates:with:
                do: [:creds :magic | false].
            [state process: rq] on: FatalError do: [failed := true].
            connMock forgetAbout: #authenticates:with:.
            self assert: failed.

]

{ #category : #'as yet unclassified' }
ShampooNotAuthStateTest >> testCheckLoginSucc [
	| rq resp |
            rq := self requestFrom: ShampooLoginTest loginSample.
            connMock 
                on: #authenticates:with:
                do: [:creds :magic | true].
            [resp := state process: rq] onErrorDo: [self fail].
            connMock forgetAbout: #authenticates:with:.

            self
              should: [connMock state class = AuthorizedState];
              should: [resp class = ServerInfoResponse]

]
