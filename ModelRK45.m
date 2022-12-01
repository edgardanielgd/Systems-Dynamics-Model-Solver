classdef ModelRK45 < handle

  properties
    diffEq
    lastVals
    step
    minFloatDiff
    model
  endproperties

  methods
    function thisRK45 = ModelRK45(
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

        thisRK45.diffEq = diffEquationFunctions;
        thisRK45.lastVals = initialVals;
        thisRK45.step = step;
        thisRK45.minFloatDiff = minFloatDiff;
        thisRK45.model = model;
    endfunction


    function results = calculateNext(
        thisRK45
      )

        % Updates dynvars and flows values, saves them for reassignation after this process
        thisRK45.model.recalculate();

        % Since there are variables using time value, this can be useful
        temp_last_vals = thisRK45.lastVals;

        K_values = []; % Saves K values for each function, discard the first item

        % K1
        K = [ 1 ]; % Ignore first item
        for iequation = 1 : length( thisRK45.diffEq )
          f = thisRK45.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Note whole model must be updated before each calculation and turned into
        % its previous state in order to keep method's consistency
        % (this was kinda easy without having to care about a model structure isn't it?)

        % K2
        % Recalculate functions parameters
        thisRK45.lastVals(1) += (1/4)*thisRK45.step;
        for i = 2 : length( thisRK45.lastVals )
          thisRK45.lastVals(i) += (1/4)*thisRK45.step * K_values(1,i);
        endfor

        K = [ 1 ];
        for iequation = 1 : length( thisRK45.diffEq )
          f = thisRK45.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        thisRK45.lastVals = temp_last_vals;

        % K3
        % Recalculate functions parameters
        thisRK45.lastVals(1) += (3/8)*thisRK45.step;
        for i = 2 : length( thisRK45.lastVals )
          thisRK45.lastVals(i) += (3/32)*thisRK45.step * K_values(1,i) + (9/32)*thisRK45.step * K_values(2,i);
        endfor

        K = [ 1 ];
        for iequation = 1 : length( thisRK45.diffEq )
          f = thisRK45.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Reset model's state
        thisRK45.lastVals = temp_last_vals;

        % K4
        % Recalculate functions parameters
        thisRK45.lastVals(1) += (12/13)*thisRK45.step;
        for i = 2 : length( thisRK45.lastVals )
          thisRK45.lastVals(i) += (1932/2197)*thisRK45.step * K_values(1,i) - (7200/2197)*thisRK45.step * K_values(2,i) + (7296/2197)*thisRK45.step * K_values(3,i);;
        endfor

        K = [ 1 ];
        for iequation = 1 : length( thisRK45.diffEq )
          f = thisRK45.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Reset model's state:
        thisRK45.lastVals = temp_last_vals;

        % K5
        % Recalculate functions parameters
        thisRK45.lastVals(1) += thisRK45.step;
        for i = 2 : length( thisRK45.lastVals )
          thisRK45.lastVals(i) += (439/216)*thisRK45.step * K_values(1,i) - 8*thisRK45.step * K_values(2,i) + (3680/513)*thisRK45.step * K_values(3,i) -(845/4104)*thisRK45.step * K_values(4,i);
        endfor

        K = [ 1 ];
        for iequation = 1 : length( thisRK45.diffEq )
          f = thisRK45.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Reset model's state:
        thisRK45.lastVals = temp_last_vals;

        % K6
        % Recalculate functions parameters
        thisRK45.lastVals(1) += (1/2)*thisRK45.step;
        for i = 2 : length( thisRK45.lastVals )
          thisRK45.lastVals(i) += -(8/27)*thisRK45.step * K_values(1,i) + 2*thisRK45.step * K_values(2,i) -(3544/2565)*thisRK45.step * K_values(3,i) +(1859/4104)*thisRK45.step * K_values(4,i) -(11/40)*thisRK45.step * K_values(5,i);
        endfor

        K = [ 1 ];
        for iequation = 1 : length( thisRK45.diffEq )
          f = thisRK45.diffEq{ iequation };
          K = [ K f( ) ];
        endfor

        K_values = [ K_values ; K ]; %  Save K array record

        % Reset model's state:
        thisRK45.lastVals = temp_last_vals;

        % K values area calculated, now update variables values
        for i = 2 : length( thisRK45.lastVals )
          thisRK45.lastVals( i ) += thisRK45.step * (
            (16/135)*K_values (1,i) + (6656/12825)* K_values (3,i) +
            (28561/56430)* K_values (4,i) - (9/50)* K_values (5,i) +
            (2/55)* K_values (6,i)
          );
        endfor

        % last "t" value
        thisRK45.lastVals(1) += thisRK45.step;

        results = thisRK45.lastVals;

    endfunction

    function calculateNextT( 
      thisRK45, next_time
    )
      if next_time < thisRK45.lastVals(1)
          error("Use calculate method if you want a previous value");
        endif

        while thisRK45.lastVals(1) - next_time < thisRK45.minFloatDiff
          thisRK45.calculateNext();
        end

        results = thisRK45.lastVals;
    endfunction

    
  end

endclassdef