Class {
	#name : #EPSimulatorSmallIntegerMirror,
	#superclass : #EPMirror,
	#category : 'EspellSimulator'
}

{ #category : #accessing }
EPSimulatorSmallIntegerMirror >> asLocalSmallInteger [
	
	^ backend integerValueOf: target
]
