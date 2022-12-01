

classdef TestModel < Model

  properties

  endproperties

  methods
    function thisModel = TestModel()
      thisModel = thisModel@Model( 0.01, 3 );
      thisModel.parameters("a") = 1;

      thisModel.addFlow( "testFlow", @thisModel.testFlow );
      thisModel.addStock( "testStock", 0, @thisModel.testStock );

      thisModel.generateSolver();
    endfunction

    function retval = testFlow( model )
      retval = model.parameters("a") + model.getStockValue("testStock");
    endfunction

    function retval = testStock( model )
      retval = model.getFlowValue( "testFlow" );
    endfunction

  endmethods



endclassdef