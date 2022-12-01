
% https://cloud.anylogic.com/model/d465d1f5-f1fc-464f-857a-d5517edc2355?mode=SETTINGS

classdef SIRModel < Model

  properties

  endproperties

  methods
    function thisModel = SIRModel(
      totalPopulation,
      infectivity,
      contactRate,
      averageIllnessDuration,
      step,
      solverType = 1
    )
      thisModel = thisModel@Model( step, solverType );

      # List of model's objects
      thisModel.parameters("totalPopulation") = totalPopulation;
      thisModel.parameters("infectivity") = infectivity;
      thisModel.parameters("contactRate") = contactRate;
      thisModel.parameters("averageIllnessDuration") = averageIllnessDuration;


      % Add flows
      thisModel.addFlow("infectionRate", @thisModel.infectionRateFlowFunction );
      thisModel.addFlow("recoveryRate", @thisModel.recoveryRateFlowFunction );

      % Add Stocks
      thisModel.addStock( "susceptible", thisModel.parameters("totalPopulation")-1, @thisModel.susceptibleStockFunction );
      thisModel.addStock( "infectious", 1, @thisModel.infectiousStockFunction );
      thisModel.addStock( "recovered", 0, @thisModel.recoveredStockFunction );
      thisModel.generateSolver();

    endfunction

    # IMPORTANT: Always pass model object as parameter to every function, since
    # we use anonymous functions which won't recognize "thisModel" object globarly

    % Static methods

    % Flows

    % Infection rate Flow Definition
    function retval = infectionRateFlowFunction( model )
      retval = model.getStockValue("infectious") .* model.parameters("contactRate") .* model.getStockValue("susceptible") ./ model.parameters("totalPopulation") .* model.parameters("infectivity");
    endfunction

    % Recovery rate Flow Definition
    function retval = recoveryRateFlowFunction( model )
      retval = model.getStockValue("infectious") ./ model.parameters("averageIllnessDuration");
    endfunction

    % Stocks

    % Susceptible Stock Function
    function retval = susceptibleStockFunction( model, takeValue = false )
      retval = - model.getFlowValue("infectionRate", takeValue );
    endfunction

    % Infectious Stock Function
    function retval = infectiousStockFunction( model, takeValue = false )
      retval = model.getFlowValue("infectionRate", takeValue ) - model.getFlowValue("recoveryRate", takeValue );
    endfunction

    % Recovered Stock Function
    function retval = recoveredStockFunction( model, takeValue = false )
      retval = model.getFlowValue("recoveryRate", takeValue );
    endfunction

  endmethods

endclassdef