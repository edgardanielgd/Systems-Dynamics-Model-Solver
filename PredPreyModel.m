% https://ccl.northwestern.edu/netlogo/docs/systemdynamics.html

classdef PredPreyModel < Model

  properties

  endproperties

  methods
    function thisModel = PredPreyModel(
      natPreyRate,
      iniPreys,
      predRate,
      predEfficiency,
      iniPreds,
      predDeathRate,
      step,
      solverType = 1
    )
      thisModel = thisModel@Model( step, solverType );

      # List of model's objects
      thisModel.parameters("preyNatalityRate") = natPreyRate;
      thisModel.parameters("initialPreys") = iniPreys;
      thisModel.parameters("predRate") = predRate;
      thisModel.parameters("predEfficiency") = predEfficiency;
      thisModel.parameters("initialPredators") = iniPreds;
      thisModel.parameters("predDeathRate") = predDeathRate;


      % Add flows
      thisModel.addFlow("preybirths", @thisModel.preyBirthsFlowFunction );
      thisModel.addFlow("preydeaths", @thisModel.preyDeathsFlowFunction );
      thisModel.addFlow("predbirths", @thisModel.predBirthsFlowFunction );
      thisModel.addFlow("preddeaths", @thisModel.predDeathsFlowFunction );

      % Add dynamic variables

      % thisModel.addDynVariable( "preysdensity" , @thisModel.preyDensityVarFunction );

      % Add Stocks
      thisModel.addStock( "preys", thisModel.parameters("initialPreys"), @thisModel.preyStockFunction );
      thisModel.addStock( "predators", thisModel.parameters("initialPredators"), @thisModel.predStockFunction );
      thisModel.generateSolver();

    endfunction

    # IMPORTANT: Always pass model object as parameter to every function, since
    # we use anonymous functions which won't recognize "thisModel" object globarly

    % Static methods

    % Flows

    % Preys Births Flow Definition
    function retval = preyBirthsFlowFunction( model )
      retval = model.getStockValue("preys") * model.parameters("preyNatalityRate");
    endfunction

    % Preys Deaths Flow Definition
    function retval = preyDeathsFlowFunction( model )
      retval = model.getStockValue("predators") * model.parameters("predRate") * model.getStockValue("preys");
    endfunction

    % Predators Births Flow Definition
    function retval = predBirthsFlowFunction( model )
      retval = model.getStockValue("predators") * model.getStockValue("preys") * model.parameters("predEfficiency") * model.parameters("predRate");
    endfunction

    % Predators Deaths Flow Definition
    function retval = predDeathsFlowFunction( model )
      retval = model.getStockValue("predators") * model.parameters("predDeathRate");
    endfunction

    % Dynamic Variables
    %{
    function retval = preyDensityVarFunction(model )
      retval = model.getStockValue("preys") / model.parameters("area");
    endfunction
    %}

    % Stocks

    % Preys Stock Function
    function retval = preyStockFunction( model, takeValue = false )
      retval = model.getFlowValue("preybirths", takeValue) - model.getFlowValue("preydeaths", takeValue);
    endfunction

    % Predators Stock Function
    function retval = predStockFunction( model, takeValue = false )
      retval = model.getFlowValue("predbirths", takeValue) - model.getFlowValue("preddeaths", takeValue);
    endfunction


  endmethods

endclassdef