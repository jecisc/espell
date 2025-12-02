Class {
	#name : #EPInternalCharacterTable,
	#superclass : #EPCharacterTable,
	#category : 'Espell-HighLevel'
}

{ #category : #public }
EPInternalCharacterTable >> at: aLocalCharacter [

	| table |
	table := objectSpace basicCharacterTable.
	^ table at: aLocalCharacter asciiValue + 1.
]

{ #category : #public }
EPInternalCharacterTable >> includesKey: aLocalCharacter [

	| table |
	table := objectSpace basicCharacterTable.
	^ table size > aLocalCharacter asciiValue and: [(table at: aLocalCharacter asciiValue + 1) isNilObject not].
]

{ #category : #public }
EPInternalCharacterTable >> installCharacter: aRemoteCharacter [

	self error: 'The internal character table has already all characters installed'
]

{ #category : #public }
EPInternalCharacterTable >> realCharacterTable [

	| characterClassMirror |
	characterClassMirror := objectSpace classNamed: objectSpace worldConfiguration characterClassName.
	^ characterClassMirror classPool at: #CharacterTable
]

{ #category : #public }
EPInternalCharacterTable >> setCharacterTable: anArrayOfCharacters [

	| characterClassMirror |
	objectSpace basicCharacterTable: anArrayOfCharacters.
	characterClassMirror := objectSpace classNamed: objectSpace worldConfiguration characterClassName.
	^ characterClassMirror classPool at: #CharacterTable put: anArrayOfCharacters
]

{ #category : #converting }
EPInternalCharacterTable >> toInternalCharacterTable [
	
	^ self
]
