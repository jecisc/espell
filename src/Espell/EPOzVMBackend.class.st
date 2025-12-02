"
I am an espell backend that works on the Oz Virtual machine. Camille defines me as a Parasithic object space because I live in the same heap transparently.
"
Class {
	#name : #EPOzVMBackend,
	#superclass : #EPBackend,
	#instVars : [
		'compactClasses',
		'classNameIndex',
		'byteStringMapping',
		'symbolTable',
		'compiledMethodMapping',
		'primitives',
		'byteArrayMapping'
	],
	#category : 'Espell-LowLevel-Mirrors'
}

{ #category : #primitives }
EPOzVMBackend >> basicIdentityHashOf: anObject [

	| result |
	result := self
		handle: anObject target
		executePrimitive: 75.
	^ self mirrorOn: result
]

{ #category : #primitives }
EPOzVMBackend >> basicNew: aMirror ofSize: aMirrorSize [
	
	^ self primitives basicNewOn: self withSize: aMirrorSize
]

{ #category : #primitives }
EPOzVMBackend >> basicSizeOf: aMirror [

	| result |
	result := self
		handle: aMirror target
		executePrimitive: 62
		withArgs: #().
	"if the returned value is an array the primive failed because the target is not a variable object"
	result class == Array ifTrue: [ ^ 0 ].
	^ result
]

{ #category : #primitives }
EPOzVMBackend >> become: anObject into: anotherObject [

	(Array with: anObject target)
		elementsForwardIdentityTo:
			(Array with: anotherObject target)
]

{ #category : #primitives }
EPOzVMBackend >> classHandle: aClassHandle setTo: aHandle [
	<primitive: 160>
	self primitiveFailed
]

{ #category : #private }
EPOzVMBackend >> classNameIndex [

	| arrayClass |
	classNameIndex ifNotNil: [ ^ classNameIndex ].
	arrayClass := self arrayClass.
	4 to: arrayClass fixedSize do: [ :index | | maybeName |
		maybeName := arrayClass instanceVariableAtIndex: index.
		(maybeName size = 5 
			and: [ maybeName basicClass isBytesClass
				and: [ maybeName asLocalString = 'Array' ]])
					ifTrue: [ ^ classNameIndex := index ]].
	Error signal: 'Could not guess where is the class name!'.
]

{ #category : #primitives }
EPOzVMBackend >> classOf: anObjectMirror [

	^ (self
		executePrimitiveNumbered: 111
		on: anObjectMirror
		withArguments: #()) asClassMirror
]

{ #category : #'compact classes' }
EPOzVMBackend >> classes [

	| dictionary internalArray classes |
	dictionary := self systemDictionary.
	internalArray := dictionary instanceVariableAtIndex: (self instanceVariableMapping dictionaryArrayIndex).
	classes := OrderedCollection new.
	
	1 to: internalArray size do: [ :i | | association |
		association := internalArray at: i.
		association isNilObject ifFalse: [ | maybeClass |
			maybeClass := association instanceVariableAtIndex: 2.
			(self looksLikeClass: maybeClass)
				ifTrue: [ classes add: maybeClass asClassMirror ]]].
		
	^ classes
]

{ #category : #'compact classes' }
EPOzVMBackend >> compactClassAt: aCompactClassIndex ifNone: aBlock [

	^ compactClasses at: aCompactClassIndex ifAbsent: aBlock
]

{ #category : #'compact classes' }
EPOzVMBackend >> compactClassAt: anInteger put: anEPClassMirror [ 

	compactClasses at: anEPClassMirror compactClassIndex put: anEPClassMirror
]

{ #category : #'compact classes' }
EPOzVMBackend >> compactClassIndexOf: aClassMirror [
	
	^ (aClassMirror format bitShift: -11) bitAnd: 16r1F
]

{ #category : #'compact classes' }
EPOzVMBackend >> compactClassIndexOfFormat: format [
	
	^ (format bitShift: -11) bitAnd: 16r1F
]

{ #category : #'compact classes' }
EPOzVMBackend >> compactClasses [
	^ compactClasses
]

{ #category : #'as yet unclassified' }
EPOzVMBackend >> compiledMethod: anEPVMCompiledMethodMirror objectAt: anInteger [ 
	
	| result |
	result := self
		handle: anEPVMCompiledMethodMirror target
		executePrimitive: 68
		withArgs: { anInteger }.
	^ self mirrorOn: result
]

{ #category : #'as yet unclassified' }
EPOzVMBackend >> compiledMethod: anEPVMCompiledMethodMirror objectAt: anInteger put: aMirror [
	
	| result |
	result := self
		handle: anEPVMCompiledMethodMirror target
		executePrimitive: 69
		withArgs: { anInteger . aMirror target }.
	^ self mirrorOn: result
]

{ #category : #primitives }
EPOzVMBackend >> contextSizeOf: aMirror [

	^ self
		handle: aMirror target
		executePrimitive: 212
		withArgs: #().
]

{ #category : #'compact classes' }
EPOzVMBackend >> createCompactClassesArray [

	compactClasses := Dictionary new.
	self classes do: [ :class |
		class isCompact ifTrue: [ 
			compactClasses at: class compactClassIndex put: class.
		]
	]
]

{ #category : #primitives }
EPOzVMBackend >> createCompiledMethodWithSize: bytecodeSize andHeader: methodHeader [ 
	

	^ (self
		executePrimitiveNumbered: 79
		on: self methodClass
		withArguments: { self mirrorOn: bytecodeSize . self mirrorOn: methodHeader })
		markExperimentalBit: true;
		asMethodMirror
]

{ #category : #bootstrap }
EPOzVMBackend >> createObjectWithFormat: aClassFormat withSize: aSize [

	| instanceHandle metaclass metaclassHandle |
	"We create and initialize an annonimous class"
	metaclass := Metaclass new.
	metaclass
		superclass: Object
		methodDictionary: MethodDictionary new
		format: aClassFormat.
	
	"we mirror that class so we have complete control of it"
	metaclassHandle := self classMirrorOn: metaclass.
	instanceHandle := metaclassHandle basicNew: aSize.
	^ self mirrorOn: instanceHandle
]

{ #category : #primitives }
EPOzVMBackend >> executePrimitiveMethod: aMethod on: aMirror withArguments: aCollection [ 
	self halt: 'should return an EPPrimitiveResult'.
	^ self primitives
				invokePrimitiveMethod: aMethod
				on: aMirror
				arguments: aCollection.
]

{ #category : #primitives }
EPOzVMBackend >> executePrimitiveNumbered: aNumber on: aMirror withArguments: aCollection [ 
	
	^ self primitives
				invokePrimitiveNumber: aNumber
				on: aMirror
				arguments: aCollection.
]

{ #category : #primitives }
EPOzVMBackend >> floatObject: aMirror at: anIndex [
	
	^ (self
		executePrimitiveNumbered: 38
		on: aMirror
		withArguments: { self mirrorOn: anIndex }) asClassMirror
]

{ #category : #primitives }
EPOzVMBackend >> floatObject: aMirror at: anIndex put: aValue [
	
	^ (self
		executePrimitiveNumbered: 39
		on: aMirror
		withArguments: { self mirrorOn: anIndex . aValue }) asClassMirror
]

{ #category : #converting }
EPOzVMBackend >> fromLocalByteArray: aByteArray [
	
	^ byteArrayMapping fromLocal: aByteArray.
]

{ #category : #converting }
EPOzVMBackend >> fromLocalByteString: aByteString [
	
	^ byteStringMapping fromLocal: aByteString
]

{ #category : #converting }
EPOzVMBackend >> fromLocalByteSymbol: aByteSymbol [

	^ byteSymbolMapping fromLocal: aByteSymbol
]

{ #category : #converting }
EPOzVMBackend >> fromLocalCharacter: aCharacter [ 
	
	| newCharacterMirror |
	(self characterTable size > aCharacter codePoint)
		ifTrue: [ ^self characterTable at: aCharacter codePoint + 1 ].

	newCharacterMirror := self characterClass asClassMirror basicNew.
	newCharacterMirror instanceVariableAtIndex: 1 put: (aCharacter codePoint asLiteralInObjectSpace: self).
	^newCharacterMirror
]

{ #category : #converting }
EPOzVMBackend >> fromLocalFloat: aLocalFloat [

	| floatClassMirror floatMirror |
	floatClassMirror := self floatClass asClassMirror.
	floatMirror := (floatClassMirror basicNew: aLocalFloat basicSize) asFloatMirror.
	1 to: 2 do: [ :i | floatMirror at: i put: ((aLocalFloat at: i) asLiteralInObjectSpace: self) ].
	^floatMirror
]

{ #category : #converting }
EPOzVMBackend >> fromLocalNegativeInteger: anInteger [

	^ largeNegativeIntegerMapping fromLocal: anInteger
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteBoolean: aBooleanMirror [
	(aBooleanMirror pointsToSameObject: self trueObject)
		ifTrue: [ ^true ].
	(aBooleanMirror pointsToSameObject: self falseObject)
		ifTrue: [  ^false ].
	self error: 'non a boolean remote object'.
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteByteArray: aByteArray [ 
	
	^byteArrayMapping fromRemote: aByteArray.
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteByteString: aRemoteByteString [
	
	^ byteStringMapping fromRemote: aRemoteByteString
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteByteSymbol: aByteSymbol [

	^ byteSymbolMapping fromRemote: aByteSymbol
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteCharacter: anEPMirror [
	
	^Character value: (anEPMirror instanceVariableAtIndex: 1) asSmallInteger.
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteCompiledMethod: aRemoteCompiledMethod [
	
	^compiledMethodMapping fromRemote: aRemoteCompiledMethod
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteFloat: aRemoteFloat [

	| newFloat |
	newFloat := Float basicNew: aRemoteFloat basicSize.
	1 to: 2 do: [ :i | newFloat at: i put: (aRemoteFloat at: i) asLocalLiteral ].
	^newFloat
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteLargeNegativeInteger: aNegativeInteger [

	^ largeNegativeIntegerMapping fromRemote: aNegativeInteger
]

{ #category : #converting }
EPOzVMBackend >> fromRemoteLargePositiveInteger: aPositiveInteger [

	^largePositiveIntegerMapping fromRemote: aPositiveInteger
]

{ #category : #converting }
EPOzVMBackend >> fromSmallInteger: aSmallInteger [ 

	^ self mirrorOn: aSmallInteger
]

{ #category : #primitives }
EPOzVMBackend >> giveChanceToRun [

	self primitiveResumeFrom: specialObjectsArray target
]

{ #category : #primitives }
EPOzVMBackend >> handle: handle executePrimitive: number withArgs: args [

	^ self handle: handle executePrimitive: number withArgs: #()
]

{ #category : #'initialize-release' }
EPOzVMBackend >> initialize [

	super initialize.
	compactClasses := EPDictionary new.
	
	symbolTable := EPInternalSymbolTable new objectSpace: self; yourself.
	primitives := EPVMPrimitiveResolver new backend: self; yourself.
	
	byteStringMapping := EPByteStringMapping new objectSpace: self; yourself.
	byteArrayMapping := EPByteArrayMapping new objectSpace: self; yourself.
	compiledMethodMapping := EPMethodMapping new objectSpace: self; yourself.
	largeNegativeIntegerMapping := EPLargeNegativeIntegerMapping new objectSpace: self; yourself.
	largePositiveIntegerMapping := EPLargePositiveIntegerMapping new objectSpace: self; yourself.
]

{ #category : #primitives }
EPOzVMBackend >> initializeTempsInStackOfContext: anEPContextMirror [ 
	
	self executePrimitive: 76 withArgs: { anEPContextMirror method numberOfTemps }
]

{ #category : #'as yet unclassified' }
EPOzVMBackend >> instSpecOfClass: aRFiClass [

	"NEW:
	 0 = 0 sized objects (UndefinedObject True False et al)
	 1 = non-indexable objects with inst vars (Point et al)
	 2 = indexable objects with no inst vars (Array et al)
	 3 = indexable objects with inst vars (MethodContext AdditionalMethodState et al)
	 4 = weak indexable objects with inst vars (WeakArray et al)
	 5 = weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
	 6 = reserved
	 7 = forwarder format (also immediate class format)
	 9          64-bit indexable
	 10 - 11 32-bit indexable
	 12 - 15 16-bit indexable
	 16 - 23 byte indexable
	 24 - 31 compiled method"
	(aRFiClass isBytes) ifTrue: [ ^ 16 ].
	(aRFiClass isWords) ifTrue: [ ^ 10 ].
	(aRFiClass isCompiledMethod) ifTrue: [ ^ 24 ].
	(aRFiClass instSize = 0 and: [ aRFiClass isVariable not ]) ifTrue: [ ^ 0 ].
	(aRFiClass instSize > 0 and: [ aRFiClass isVariable not ]) ifTrue: [ ^ 1 ].
	(aRFiClass instSize = 0 and: [ aRFiClass isVariable     ]) ifTrue: [ ^ 2 ].
	(aRFiClass instSize > 0 and: [ aRFiClass isVariable     ]) ifTrue: [ ^ 3 ].
	(aRFiClass instSize > 0 and: [ aRFiClass isVariable and: [ aRFiClass isWeak ] ]) ifTrue: [ ^ 4 ].
	(aRFiClass instSize > 0 and: [ aRFiClass isVariable not and: [ aRFiClass isWeak ] ]) ifTrue: [ ^ 5 ].
	self error: 'illegal old format'
]

{ #category : #primitives }
EPOzVMBackend >> instanceFixedSizeOf: aClass [
	| format |
	format := aClass format.
	^((format bitShift: -10) bitAnd: 16rC0) + ((format bitShift: -1) bitAnd: 16r3F) - 1
]

{ #category : #primitives }
EPOzVMBackend >> isSmallInteger: anObject [
	
	^ 	anObject primitiveClass = SmallInteger
]

{ #category : #'initialize-release' }
EPOzVMBackend >> loadImage: aFile [
	| file |
	file := aFile asFileReference.
	file exists ifFalse: [ self error: 'File ', aFile asString ,' does not exist' ].
	
	self specialObjectsArray: (self loadImageObjectsFrom: aFile).
	self createCompactClassesArray.
	self symbolTable buildCache.
]

{ #category : #'initialize-release' }
EPOzVMBackend >> loadImageObjectsFrom: aFile [

	^ self mirrorOn: (self primitiveLoadImage: (File named: aFile fullName) )
]

{ #category : #private }
EPOzVMBackend >> looksLikeClass: anObject [
	| methodDictionary mirror |
	anObject fixedSize < 3 ifTrue: [ ^false ].
	methodDictionary := anObject instanceVariableAtIndex: ((self instanceVariableMapping classMethodDictionaryIndex)).
	mirror := methodDictionary basicClass.
	
	mirror fixedSize < self classNameIndex ifTrue: [ ^false ].
	(mirror instanceVariableAtIndex: self classNameIndex) size = #MethodDictionary size ifFalse: [ ^false ].
	^mirror className == #MethodDictionary
]

{ #category : #'as yet unclassified' }
EPOzVMBackend >> numberOfLiteralsOf: aHandle [
	"Answer the number of literals used by the receiver."
	
	self halt.
	"header =
	header
	^ (self objectAt: 1) target asSmallInteger"
	^ (aHandle header bitShift: -9) bitAnd: 16rFF
]

{ #category : #primitives }
EPOzVMBackend >> object: aMirror at: anIndex [
	
	^ self primitives
				basicExecutePrimitive: 60
				onObject: aMirror
				withArguments: { anIndex }.
]

{ #category : #primitives }
EPOzVMBackend >> object: theObjectNotMirror at: anIndex put: aValueObjectNotMirror [
	
	self primitives
				basicExecutePrimitive: 61
				onObject: theObjectNotMirror
				withArguments: { anIndex . aValueObjectNotMirror }.
]

{ #category : #primitives }
EPOzVMBackend >> object: anObjectNotMirror instVarAt: anIndex [
	
	^ self primitives
				basicExecutePrimitive: 73
				onObject: anObjectNotMirror
				withArguments: { anIndex }.
]

{ #category : #primitives }
EPOzVMBackend >> object: anObjectNotMirror instVarAt: anIndex put: aValueObjectNotMirror [
	
	self primitives
				basicExecutePrimitive: 74
				onObject: anObjectNotMirror
				withArguments: { anIndex . aValueObjectNotMirror }.
]

{ #category : #'initialize-release' }
EPOzVMBackend >> primitiveLoadImage: aFileId [
	<primitive: 575>
	^self primitiveFailed
]

{ #category : #primitives }
EPOzVMBackend >> primitiveResumeFrom: aSpecialObjectsArray [
	<primitive: 81>
	self error.
]

{ #category : #primitives }
EPOzVMBackend >> primitives [

	^ primitives
]

{ #category : #'as yet unclassified' }
EPOzVMBackend >> smallIntegerMirrorOn: anInteger [

	^ self mirrorOn: anInteger
]

{ #category : #'special objects' }
EPOzVMBackend >> symbolTable [
	
	^ symbolTable
]

{ #category : #accessing }
EPOzVMBackend >> wordSize [
	
	^ 4 "bytes per word"
]
