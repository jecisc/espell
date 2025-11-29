baselines
baseline: spec
	<baseline>
	spec
		for: #common
		do: [ 
			spec description: 'Espell Object Spaces'.			
			"Needs VM simulator"
			spec
				baseline: 'VMMaker'
				with: [ 
					spec
						repository: 'github://pharo-project/pharo-vm:1b23b4382f6244b6ae32fbe87589a9451702c8ee/smalltalksrc' ].

			spec package: 'AST-Interpreter-Core'.
			spec package: 'AST-Interpreter-Extension' with: [ spec requires: #( 'AST-Interpreter-Core' ) ].
			
			spec package: 'EspellSimulator' with: [ spec requires: #( 'Espell' 'VMMaker' ) ].
			spec package: 'Espell' with: [ spec requires: #( 'AST-Interpreter-Core' 'AST-Interpreter-Extension' ) ]. ]