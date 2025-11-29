binding-accessing
binding

	^ class isMeta
		  ifTrue: [ 
			  EPMetaclassBinding new
				  name: class instanceSide name objectSpace: environment;
				  yourself ]
		  ifFalse: [ 
			  EPGlobalBinding new
				  name: class instanceSide name objectSpace: environment;
				  yourself ]