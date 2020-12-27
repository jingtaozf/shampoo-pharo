Extension { #name : #Collection }

{ #category : #'*shampoo-hacks' }
Collection >> asStringArray [
        "Many reflection methods return different results in various dialects.
         #instVarNames in GNU Smalltalk returns an IdentitySet of Symbols, the
         same method returns an Array of Strings in Squeak.

         This kludge works as an abstraction over it all"
        ^(self collect: [:each | each asString]) asArray

]

{ #category : #'*shampoo-hacks' }
Collection >> elementsString [
        ^self inject: '' into: [:acc :each | acc, each asString, ' ']

]
