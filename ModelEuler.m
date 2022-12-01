classdef ModelEuler < handle

  properties
    diffEq
    lastVals
    step
    minFloatDiff
    model
  endproperties

  methods
    function thisEuler = ModelEuler(
        % 3 equations => 4 initialVals
        % Equations should receive an array of elements
        diffEquationFunctions,
        initialVals,
        step,
        model,
        minFloatDiff = -1e-10
      )
        if length(initialVals) < 1
           error("Provide at least one initial value");
        endif

        if length( initialVals ) != length( diffEquationFunctions ) + 1
          error("#Values should be #Equations + 1");
        endif

        thisEuler.diffEq = diffEquationFunctions;
        thisEuler.lastVals = initialVals;
        thisEuler.step = step;
        thisEuler.minFloatDiff = minFloatDiff;
        thisEuler.model = model;
    endfunction


    function results = calculateNext(
        thisEuler
      )

        % Updates dynvars and flows values
        thisEuler.model.recalculate();

        % K values area calculated, now update variables values
        
        thisEuler.lastVals(1) += 2.*thisEuler.step;
        for i = 2 : length( thisEuler.lastVals )
          thisEuler.lastVals( i ) = (thisEuler.lastVals( i ) + thisEuler.step .* ...
          thisEuler.diffEq{ i - 1 }(true)) + thisEuler.step .* ...
          thisEuler.diffEq{ i - 1 }(true);
        endfor
        
        %{
        thisEuler.lastVals(1) += thisEuler.step;
        for i = 2 : length( thisEuler.lastVals )
          thisEuler.lastVals( i ) += thisEuler.step .* ...
          thisEuler.diffEq{ i - 1 }( true );
        endfor
        %}
        
        results = thisEuler.lastVals;

  endfunction

  function calculateNextT(
      thisRK4, next_time
    )
      if next_time < thisRK4.lastVals(1)
          error("Use calculate method if you want a previous value");
        endif

        while thisRK4.lastVals(1) - next_time < thisRK4.minFloatDiff
          thisRK4.calculateNext();
        end

        results = thisRK4.lastVals;
    endfunction

  end

endclassdef