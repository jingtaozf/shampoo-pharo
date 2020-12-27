"
My instances represent a request to (re)compile a concrete
method in the concrete class at the concrete namespace.
"
Class {
	#name : #CompileMethodRequest,
	#superclass : #Request,
	#instVars : [
		'className',
		'spaceName',
		'side',
		'source'
	],
	#category : #'Shampoo-Requests'
}

{ #category : #identification }
CompileMethodRequest class >> is: aString [
            ^aString = 'CompileMethod'

]

{ #category : #execution }
CompileMethodRequest >> execute [
            | class failed |
            class := (Smalltalk at: className asSymbol).
            (side = #class) ifTrue: [class := class class].

            [class compile: source] onErrorDo: [^OperationalResponse failure: id].
            ^OperationalResponse success: id

]

{ #category : #initialization }
CompileMethodRequest >> init: anXML [
            | attrs |
            attrs := anXML attrMap.
            className := attrs at: 'class'.
            spaceName := attrs at: 'namespace'.
            side := (attrs at: 'side') asSymbol.
            source := anXML text

]
