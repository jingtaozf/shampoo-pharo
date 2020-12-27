Class {
	#name : #ShampooNamespacesTest,
	#superclass : #ShampooTestCase,
	#instVars : [
		'namespaces',
		'r',
		'items'
	],
	#category : #'Shampoo-Tests'
}

{ #category : #'as yet unclassified' }
ShampooNamespacesTest >> namespacesSample [
	^'<request id="23" type="Namespaces" />'

]

{ #category : #'as yet unclassified' }
ShampooNamespacesTest >> setUp [
	namespaces := self requestFrom: self namespacesSample.
            r := namespaces execute.
            items := r items at: 'namespace'

]

{ #category : #'as yet unclassified' }
ShampooNamespacesTest >> testIndirectSubspaces [
	"Currently Shampoo supports only 'root' namespaces. Indirect subspaces should not
             be included in the response"
            | indirect |
            indirect := [Namespace allInstances detect: [:each | each environment ~= Smalltalk]]
                        onErrorDo: [nil].
            indirect ifNotNil: [self shouldnt: [items includes: indirect name]]

]

{ #category : #'as yet unclassified' }
ShampooNamespacesTest >> testNamespaces [
	self should: [items includes: 'Shampoo-Server'];
                 should: [items includes: 'Shampoo-Tests']

]
