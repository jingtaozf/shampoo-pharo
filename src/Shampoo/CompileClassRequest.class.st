"
My instances are used to compile a method in a concrete class from a concrete namespace.
"
Class {
	#name : #CompileClassRequest,
	#superclass : #Request,
	#instVars : [
		'className',
		'superName',
		'superSpace',
		'spaceName',
		'instvars',
		'classvars',
		'poolvars',
		'side'
	],
	#category : #'Shampoo-Requests'
}

{ #category : #identification }
CompileClassRequest class >> is: aString [
            ^aString = 'CompileClass'

]

{ #category : #execution }
CompileClassRequest >> execute [
            | parent class failed |

            class := Smalltalk at: className asSymbol ifAbsent: [nil].
            failed := false.

            side = #instance
                ifTrue: ["Looks a bit kludgy, but currently I dont know how to make it better. TODO: refactor"
                         parent := Smalltalk at:  superName asSymbol.

                         [class := parent
                            subclass: className asSymbol
                            instanceVariableNames: instvars elementsString
                            classVariableNames: classvars elementsString
                            poolDictionaries: '' " poolvars elementsString "
                            category: spaceName.
                         ] on: Error do: [:e | Transcript show: e printString; cr. failed := true];
				   on: SelectorException  do: [:e | e resume]]
                ifFalse: [class := Smalltalk at: className asSymbol ifAbsent: [nil].
				"On Pharo, there were a strange exception when using the safe form."
				class class instanceVariableNames: instvars elementsString.
				"[class class instanceVariableNames: instvars elementsString]
                              on: Exception do: [:e | e inspect. failed := true]"].

            failed
                ifTrue: [^OperationalResponse failure: id]
                ifFalse: [^OperationalResponse success: id]

]

{ #category : #private }
CompileClassRequest >> init: anXML [
            | attrs fetchBlock |
            attrs := anXML attrMap.
            side := (attrs at: 'side' ifAbsent: ['instance']) asSymbol.

            fetchBlock := [:type | (anXML elementsNamed: type) collect:
                                   [:each | each text]].

            "This data is common for both 'instance' and 'class' sides"
            className := attrs at: 'class'.
            spaceName := attrs at: 'namespace'.
            instvars := fetchBlock value: 'instvar'.

            side = #instance
                ifTrue: [superName := attrs at: 'super'.
                         superSpace := attrs at: 'superspace'.
                         classvars := fetchBlock value: 'classvar'.
                         poolvars := fetchBlock value: 'poolvar']

]
