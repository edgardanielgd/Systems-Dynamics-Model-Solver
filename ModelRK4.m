classdef ModelRK4 < handle

  properties
    diffEq
    lastVals
    step
    minFloatDiff
    model
  endproperties

  methods
    function thisRK4 = ModelRK4(
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

        thisRK4.diffEq = diffEquationFunctions;
        thisRK4.lastVals = initialVals;
        thisRK4.step = step;
        thisRK4.minFloatDiff = minFloatDiff;
        thisRK4.model = model;
    endfunction


    function results = calculateNext(
        thisRK4
      )

        % Updates dynvars and flows values, saves them for reassignation after this process
        thisRK4.model.recalculate();

        % Since there are variables using time value, this can be useful
        temp_last_vals = thisRK4.lastVals;

        K_values = []; % Saves K values for each function, discard the first item

        % K1
        K = [ 1 ]; % Ignore first item
        for iequation = 1 : length( thisRK4.diffEq )
          f = thisRK4.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Note whole model must be updated before each calculation and turned into
        % its previous state in order to keep method's consistency
        % (this was kinda easy without having to care about a model structure isn't it?)

        % K2
        % Recalculate functions parameters
        for i = 1 : length( thisRK4.lastVals )
          thisRK4.lastVals(i) = thisRK4.lastVals(i) + thisRK4.step * K(i) / 2;
        endfor

        K = [ 1 ];
        for iequation = 1 : length( thisRK4.diffEq )
          f = thisRK4.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Reset model's state:
        thisRK4.lastVals = temp_last_vals;

        % K3
        % Recalculate functions parameters
        for i = 1 : length( thisRK4.lastVals )
          thisRK4.lastVals(i) = thisRK4.lastVals(i) + thisRK4.step * K(i) / 2;
        endfor

        K = [ 1 ];
        for iequation = 1 : length( thisRK4.diffEq )
          f = thisRK4.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Reset model's state:
        thisRK4.lastVals = temp_last_vals;

        % K4
        % Recalculate functions parameters
        for i = 1 : length( thisRK4.lastVals )
          thisRK4.lastVals(i) = thisRK4.lastVals(i) + thisRK4.step * K(i);
        endfor

        K = [ 1 ];
        for iequation = 1 : length( thisRK4.diffEq )
          f = thisRK4.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Reset model's state:
        thisRK4.lastVals = temp_last_vals;

        % K values area calculated, now update variables values
        for i = 2 : length( thisRK4.lastVals )
          thisRK4.lastVals( i ) += thisRK4.step * (
            K_values (1,i) + 2 * K_values (2,i) +
            2 * K_values (3,i) + K_values (4,i)
          ) / 6;
        endfor

        % last "t" value
        thisRK4.lastVals(1) += thisRK4.step;

        results = thisRK4.lastVals;

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