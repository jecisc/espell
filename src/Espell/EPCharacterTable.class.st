Class {
	#name : #EPCharacterTable,
	#superclass : #Object,
	#instVars : [
		'objectSpace'
	],
	#category : 'Espell-HighLevel'
}

{ #category : #public }
EPCharacterTable >> initializeTable [

	Character characterTable do: [ :character | self installCharacter: character ]
]

{ #category : #accessing }
EPCharacterTable >> objectSpace: anObjectSpace [

	objectSpace := anObjectSpace
]
