Extension { #name : #BlockClosure }

{ #category : #'*Espell' }
BlockClosure >> asLiteralInObjectSpace: anObjectSpace alreadyTransformed: aDictionary [
		
	^ anObjectSpace fromLocalCompiledCode: self compiledBlock alreadyTransformed: aDictionary
]
