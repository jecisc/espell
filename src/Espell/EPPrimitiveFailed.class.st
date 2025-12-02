Class {
	#name : #EPPrimitiveFailed,
	#superclass : #EPPrimitiveResult,
	#instVars : [
		'code'
	],
	#category : 'Espell'
}

{ #category : #accessing }
EPPrimitiveFailed >> code: anInteger [ 
	code := anInteger
]

{ #category : #testing }
EPPrimitiveFailed >> hasFailed [
	
	^ true
]
