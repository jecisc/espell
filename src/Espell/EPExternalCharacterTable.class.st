Class {
	#name : #EPExternalCharacterTable,
	#superclass : #EPCharacterTable,
	#instVars : [
		'characters'
	],
	#category : 'Espell-HighLevel'
}

{ #category : #public }
EPExternalCharacterTable >> at: aLocalCharacter [

	^ characters at: aLocalCharacter
]

{ #category : #public }
EPExternalCharacterTable >> includesKey: aLocalCharacter [

	^ characters includesKey: aLocalCharacter
]

{ #category : #initialization }
EPExternalCharacterTable >> initialize [

	super initialize.
	characters := EPDictionary new.
]

{ #category : #public }
EPExternalCharacterTable >> installCharacter: aRemoteCharacter [

	characters at: (objectSpace fromRemoteCharacter: aRemoteCharacter) put: aRemoteCharacter
]

{ #category : #public }
EPExternalCharacterTable >> size [

	^ characters size
]

{ #category : #public }
EPExternalCharacterTable >> toInternalCharacterTable [

	| internal  remoteTable |
	internal := EPInternalCharacterTable new objectSpace: objectSpace.
	
	remoteTable := objectSpace newArrayWithAll: (Character characterTable collect: [ :each | each asLiteralInObjectSpace: objectSpace ]).
	internal setCharacterTable: remoteTable.
	objectSpace characterTable: internal.
]
