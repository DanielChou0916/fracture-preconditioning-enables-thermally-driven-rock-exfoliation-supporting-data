# Heat conduction
rho = 2650    # Density kg/m^3
c = 750#650       # Heat capacity J/kgK
#k0 = 930#186 #186<->3.1 #(J/five min)/mC
k0=3720#2500 #(J/20 min)/mC

#Geometry
a = 4.0
b = 1.0

[Mesh]
  file = "../dome_mesh/dome0513.inp"
  uniform_refine = 0
  skip_partitioning = true
  construct_side_list_from_node_list=true
[]

[Variables]
  active = 'T'
  [T]
    scaling = 1e10
  []
[]

[ICs]
  [./initial_temp_ic]
    type = FunctionIC
    function = radial_initial_temperature#initial_temperature  # Reference to the function defined above
    variable = T
  [../]
[]

[AuxVariables]
  [./d]
    scaling = 1e-2
  []
  [./stressfree]
        order = CONSTANT
        family = MONOMIAL
  [../]
[]


[Kernels]
  [heat_conduction]
    type = ADHeatConduction
    variable = T
  []
  [time_derivative]
    type = ADHeatConductionTimeDerivative
    variable = T
  []
[]

[Functions]
  [./initial_temperature]
    type = PiecewiseLinear
    x = '0.15 0.25 0.75 0.87 1'
    y = '33.733 34.514 38.249 37.423 33.5'
    axis = y  
  [../]
  [./radial_initial_temperature]
    type = ParsedFunction
    expression = '(
      if(y < 0.15, 33.733,
      if(y < 0.25, 33.733 + (34.514 - 33.733)/(0.25 - 0.15)*(y - 0.15),
      if(y < 0.75, 34.514 + (38.249 - 34.514)/(0.75 - 0.25)*(y - 0.25),
      if(y < 0.87, 38.249 + (37.423 - 38.249)/(0.87 - 0.75)*(y - 0.75),
                37.423 + (33.5 - 37.423)/(1.0 - 0.87)*(y - 0.87)
      )))) * (x^2/a^2 + y^2/b^2)
    )'
    symbol_names = 'a b'
    symbol_values = '${a} ${b}'
  [../]
  [top_T_load]
    type = ParsedFunction
    #Function for a 12days:
    expression= '35.44428 + (-3.02782)*cos(0.00728*(t+t_)) + (-0.24831)*sin(0.00728*(t+t_)) + (0.63290)*cos(0.01456*(t+t_)) + (0.55638)*sin(0.01456*(t+t_)) + (1.76698)*cos(0.02184*(t+t_)) + (0.89037)*sin(0.02184*(t+t_)) + (0.77419)*cos(0.02912*(t+t_)) + (-1.35360)*sin(0.02912*(t+t_)) + (-0.51166)*cos(0.03640*(t+t_)) + (-0.26096)*sin(0.03640*(t+t_)) + (-0.55867)*cos(0.04368*(t+t_)) + (0.39113)*sin(0.04368*(t+t_)) + (0.18743)*cos(0.05096*(t+t_)) + (0.40848)*sin(0.05096*(t+t_)) + (0.42678)*cos(0.05824*(t+t_)) + (-0.04786)*sin(0.05824*(t+t_)) + (-0.51636)*cos(0.06552*(t+t_)) + (-1.12272)*sin(0.06552*(t+t_)) + (-0.59346)*cos(0.07280*(t+t_)) + (0.08763)*sin(0.07280*(t+t_)) + (0.21511)*cos(0.08008*(t+t_)) + (0.55421)*sin(0.08008*(t+t_)) + (-7.70357)*cos(0.08736*(t+t_)) + (-7.02688)*sin(0.08736*(t+t_)) + (0.65276)*cos(0.09464*(t+t_)) + (0.88274)*sin(0.09464*(t+t_)) + (0.45669)*cos(0.10192*(t+t_)) + (0.02077)*sin(0.10192*(t+t_)) + (-0.75250)*cos(0.10920*(t+t_)) + (-0.33061)*sin(0.10920*(t+t_)) + (-0.34958)*cos(0.11648*(t+t_)) + (0.90999)*sin(0.11648*(t+t_)) + (0.20186)*cos(0.12376*(t+t_)) + (0.64233)*sin(0.12376*(t+t_)) + (0.44748)*cos(0.13104*(t+t_)) + (0.41858)*sin(0.13104*(t+t_)) + (0.18572)*cos(0.13832*(t+t_)) + (-0.18420)*sin(0.13832*(t+t_)) + (-0.09253)*cos(0.14560*(t+t_)) + (-0.14835)*sin(0.14560*(t+t_)) + (0.00056)*cos(0.15288*(t+t_)) + (0.12752)*sin(0.15288*(t+t_)) + (-0.21134)*cos(0.16016*(t+t_)) + (0.47838)*sin(0.16016*(t+t_)) + (-0.06492)*cos(0.16744*(t+t_)) + (0.32068)*sin(0.16744*(t+t_)) + (2.14207)*cos(0.17473*(t+t_)) + (2.10897)*sin(0.17473*(t+t_)) + (0.12297)*cos(0.18201*(t+t_)) + (0.01052)*sin(0.18201*(t+t_)) + (0.01634)*cos(0.18929*(t+t_)) + (0.25552)*sin(0.18929*(t+t_)) + (0.33090)*cos(0.19657*(t+t_)) + (0.04753)*sin(0.19657*(t+t_)) + (0.34305)*cos(0.20385*(t+t_)) + (-0.23875)*sin(0.20385*(t+t_)) + (0.39747)*cos(0.21113*(t+t_)) + (-0.35561)*sin(0.21113*(t+t_)) + (0.06468)*cos(0.21841*(t+t_)) + (-0.46181)*sin(0.21841*(t+t_)) + (-0.01904)*cos(0.22569*(t+t_)) + (-0.11112)*sin(0.22569*(t+t_)) + (-0.16003)*cos(0.23297*(t+t_)) + (0.15095)*sin(0.23297*(t+t_)) + (0.20218)*cos(0.24025*(t+t_)) + (0.22611)*sin(0.24025*(t+t_)) + (0.27208)*cos(0.24753*(t+t_)) + (-0.13024)*sin(0.24753*(t+t_)) + (0.28283)*cos(0.25481*(t+t_)) + (-0.27035)*sin(0.25481*(t+t_)) + (-0.41316)*cos(0.26209*(t+t_)) + (0.27388)*sin(0.26209*(t+t_)) + (-0.24672)*cos(0.26937*(t+t_)) + (-0.11606)*sin(0.26937*(t+t_)) + (-0.05377)*cos(0.27665*(t+t_)) + (0.05131)*sin(0.27665*(t+t_)) + (0.02696)*cos(0.28393*(t+t_)) + (0.25840)*sin(0.28393*(t+t_)) + (0.01913)*cos(0.29121*(t+t_)) + (0.10059)*sin(0.29121*(t+t_)) + (-0.21497)*cos(0.29849*(t+t_)) + (0.17787)*sin(0.29849*(t+t_)) + (-0.29787)*cos(0.30577*(t+t_)) + (0.18335)*sin(0.30577*(t+t_)) + (0.11946)*cos(0.31305*(t+t_)) + (0.10600)*sin(0.31305*(t+t_)) + (0.05830)*cos(0.32033*(t+t_)) + (-0.00893)*sin(0.32033*(t+t_))'
    symbol_names = 't_'
    symbol_values = '0'
  []
[]

[BCs]
  [ytemp]
    type = FunctionDirichletBC
    variable = T
    boundary = top
    function = top_T_load
  []
  [bottom_T]
    type = DirichletBC
    variable = T
    boundary = bottom
    value = 32
  []
[]

[Materials]
  [thermal_materials]
    type = ADGenericConstantMaterial
    prop_names = 'density  k0   specific_heat'
    prop_values = '${rho}  ${k0}  ${c}    '
  []
  [./degradation] # Define w(d)
    type = ADDerivativeParsedMaterial
    property_name = degradation
    coupled_variables = 'd'
    expression = '(1-d)^p*(1-k)+k'
    constant_names       = 'p k'
    constant_expressions = '2 1e-6'
    derivative_order = 0
  [../]
  # Additional functional relaiton: conductivity and d
  [thermal_conductivity]
    type = ADDerivativeParsedMaterial
    property_name = 'thermal_conductivity'
    expression = 'degradation*(k0-k0/50)+k0/50'
    coupled_variables = 'd '
    material_property_names = 'degradation k0'
    derivative_order = 0
    #outputs = exodus
  []
[]




[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -snes_type'
  petsc_options_value = 'lu vinewtonrsls'
  automatic_scaling = true
  nl_max_its = 40
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-7
[]
#[Debug]
#  show_var_residual_norms = true
#[]
[Outputs]
  print_linear_residuals = false
[]
