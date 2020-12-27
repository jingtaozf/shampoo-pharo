"
My instances represent an abstract evaluation request. I hold
an expression string to evalute. Expression may be local and may have side
effects (introducing new classes, modifying the image, etc), I do not care. The
code of an expression is wrapped in a block automatically -- to make local
variables in ""||"" available. See my subclasses for more info.
"
Class {
	#name : #EvalRequest,
	#superclass : #Request,
	#instVars : [
		'code'
	],
	#category : #'Shampoo-Requests'
}

{ #category : #execution }
EvalRequest >> execute [
            ^[OpalCompiler new source: code; evaluate] onErrorDo:  [EvalFailure new signal].

]

{ #category : #initializtion }
EvalRequest >> init: anXML [
            code := '[', anXML text, '] value'

]
