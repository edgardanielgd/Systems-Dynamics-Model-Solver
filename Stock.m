classdef Stock < handle

  properties
    initialValue
    stockID
    diffEquation
  endproperties

  methods
    function thisStock = Stock(
      initialValue,
      stockID,
      diffEquation
    )
      thisStock.initialValue = initialValue;
      thisStock.stockID = stockID;
      thisStock.diffEquation = diffEquation;
    endfunction

    function stockEquation = getEquation( thisStock )
      stockEquation = thisStock.diffEquation;
    endfunction

    function stockInitialValue = getInitialValue( thisStock )
      stockInitialValue = thisStock.initialValue;
    endfunction

  endmethods
endclassdef