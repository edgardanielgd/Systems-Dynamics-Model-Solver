
model = PredPreyModel(
  0.04, 100, 0.0003, 0.8, 30, 0.15, 0.01)

for i = 1:30000
  model.forwardStep();
  if mod(i,10) == 0
    model.graphStocks();
  endif
endfor

% model = TestModel();

%{
model = ProductDiffusionModel(
  0.015, 0.011, 100, 10000, 0, 0.01
);

for i = 1: 1000
  model.forwardStep();

  if mod(i,10) == 0
    model.graphStocks();
  endif
endfor
%}

% model = SheepsModel();

%{
hold on;
input("[Continue]");

last_point = [];


for i = 1 : 100000
 model.forwardStep();

 values = model.solver.lastVals;

 if mod(i,100) == 0
   disp( values(3) );
 endif

 if i >= 2
  plot(
    [ last_point(1), values(1) ],
    [ last_point(2), values(2) ],
    "b-"
  );

  plot(
    [ last_point(1), values(1) ],
    [ last_point(3), values(3) * 100 ],
    "r-"
  );

  refresh();
 endif

 last_point = [ values(1), values(2), values(3) * 100 ];
endfor

hold off;
%}