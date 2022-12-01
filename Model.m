classdef Model < handle

  properties
    stocks
    flows
    dynvars
    parameters
    solver
    step
    stockID
    solverType

    graphInitialized
    graphLastPoints
    graphLabelsShown
    graphColors
    graphLabels
    graphYmax
    graphYmin

  endproperties

  methods

    function thisModel = Model( step, solverType )
      thisModel.stockID = 1;

      thisModel.stocks = containers.Map();
      thisModel.dynvars = containers.Map();
      thisModel.parameters = containers.Map();
      thisModel.flows = containers.Map();

      thisModel.step = step;
      thisModel.solverType = solverType;

      thisModel.graphInitialized = false;
      thisModel.graphLastPoints = NaN;
      thisModel.graphLabelsShown = false;
      thisModel.graphColors = NaN;
      thisModel.graphLabels = NaN;
    endfunction

    function solver = generateSolver( thisModel )

      % Generate RK4 solver

      diffEquationsCellArray = {};
      initialValuesArray = [ 0 ]; % Its supossed to start always on zero

      val = values( thisModel.stocks ); % Array of stock IDS (note they are autoincremental starting from 1)
      for i = 1 : length( thisModel.stocks )
        % containers.Map objects are unsorted...
        stock = val{i};
        diffEquationsCellArray{ stock.stockID } = stock.getEquation();
        initialValuesArray( stock.stockID + 1 ) = stock.getInitialValue();
      endfor

      if thisModel.solverType == 1
        thisModel.solver = ModelEuler( diffEquationsCellArray, initialValuesArray, thisModel.step, thisModel );
      elseif thisModel.solverType == 2
        thisModel.solver = ModelRK4( diffEquationsCellArray, initialValuesArray, thisModel.step, thisModel );
      elseif thisModel.solverType == 3
        thisModel.solver = ModelRK45( diffEquationsCellArray, initialValuesArray, thisModel.step, thisModel );
      endif

    endfunction

    function recalculate( thisModel )

      dynvars_keys = keys( thisModel.dynvars );

      for i = 1 : length( dynvars_keys )

        key = dynvars_keys{i};
        dynvar = thisModel.getDynVariable( key );

        % Calculate and save its real value
        dynvar.recalculate(false, true);

      endfor

      flows_keys = keys( thisModel.flows );

      for i = 1 : length( flows_keys )

        key = flows_keys{i};
        flow = thisModel.getFlow( key );

        % Calculate and save its real value
        flow.recalculate(false, true);

      endfor
    endfunction

    function reassignValues( thisModel, temp_flows_values, temp_dynvars_values )

      % Finally assignate theirs recalculated values

      % For flows

      flows_keys = keys( thisModel.flows );

      for i = 1 : length( flows_keys )

        % Get flow to update
        key = flows_keys{i};
        flow = thisModel.getFlow( key );
        flow.setValue( temp_flows_values( key ) );
      endfor

      % For dynamic vars

      dynvars_keys = keys( thisModel.dynvars );

      for i = 1 : length( dynvars_keys )

        % Get flow to update
        key = dynvars_keys{i};
        dynvar = thisModel.getDynVariable( key );
        dynvar.setValue( temp_dynvars_values( key ) );
      endfor
    endfunction

    function forwardStep( thisModel )

      thisModel.solver.calculateNext();
    endfunction

    function forwardFixedTime( thisModel, time )
      thisModel.solver.calculateNextT( time );
    endfunction

    function graphStocks( thisModel )
      if( ! thisModel.graphInitialized )
        hold on;
        thisModel.graphInitialized = true;
        thisModel.graphLastPoints = thisModel.solver.lastVals;
        thisModel.graphColors = hsv( length ( thisModel.graphLastPoints ) - 1 );
        thisModel.graphYmax = max(thisModel.graphLastPoints(2:end));
        thisModel.graphYmin = min(thisModel.graphLastPoints(2:end));

        % Create labels
        gkeys = keys ( thisModel.stocks );
        thisModel.graphLabels = {};

        for i = 1 : length( gkeys )
          % stockID + 1 = its position in lastVals array

          k = gkeys{ i };
          stock = thisModel.stocks( k );
          stockArrID = stock.stockID;
          thisModel.graphLabels{ stockArrID } = k;
        end
      else

        last_points = thisModel.graphLastPoints;
        current_points = thisModel.solver.lastVals;
        colors = thisModel.graphColors;
        legend_flag = "off";

        if ! thisModel.graphLabelsShown
          legend_flag = "on";
        endif

        for i = 2 : length( thisModel.graphLastPoints )
          plot(
            [ last_points(1), current_points(1) ],
            [ last_points(i), current_points(i) ],
            "-",
            "Color", colors(i-1,:),
            "DisplayName", thisModel.graphLabels{i - 1},
            "HandleVisibility", legend_flag
          );
        endfor
        legend();
        if thisModel.graphYmin>min(current_points(2:end))
          thisModel.graphYmin = min(current_points(2:end));
        endif
        if thisModel.graphYmax<max(current_points(2:end))
          thisModel.graphYmax = max(current_points(2:end));
        endif

        axis([0 fix(current_points(1))+1 thisModel.graphYmin thisModel.graphYmax]);
        refresh();
        thisModel.graphLabelsShown = true;
        thisModel.graphLastPoints = current_points;
      endif
    endfunction

    function mtime = getTime( thisModel )
      mtime = thisModel.solver.lastVals(1);
    endfunction

    % Stocks functions

    function stock = addStock( thisModel, id, initialVal, diffEquation )

      % Add a stock

      thisModel.stocks(id) = Stock(
        initialVal,
        thisModel.stockID,
        diffEquation )
      thisModel.stockID += 1;

      stock = thisModel.stocks(id);
    endfunction

    function stock = getStock( thisModel, id )
      stock = thisModel.stocks(id);
    endfunction

    function value = getStockValue( thisModel, id)
      stock = thisModel.getStock(id);

      % Solver's lastVals array includes time as it first element
      value = thisModel.solver.lastVals( stock.stockID + 1 );
    endfunction

    % Flows functions

    function flow = addFlow( thisModel, id, valueEquation )

      % Add a flow

      thisModel.flows(id) = Flow( valueEquation );

      flow = thisModel.flows(id);

    endfunction

    function flow = getFlow( thisModel, id )
      flow = thisModel.flows(id);
    endfunction

    function value = getFlowValue( thisModel, id, takeValue = false )
      flow = thisModel.getFlow(id);
      value = flow.recalculate( takeValue );
    endfunction

    % Dynamic Vars functions

    function dynVar = addDynVariable( thisModel, id, valueEquation )

      % Add a dynamic var

      thisModel.dynvars(id) = DynVariable( valueEquation );

      dynVar = thisModel.dynvars(id);

    endfunction

    function dynVar = getDynVariable( thisModel, id )
      dynVar = thisModel.dynvars(id);
    endfunction

    function value = getDynVariableValue( thisModel, id, takeValue = false )
      dynVar = thisModel.getDynVariable(id);
      value = dynVar.recalculate( takeValue );
    endfunction

  endmethods

endclassdef