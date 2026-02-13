# Equilibrium System parameters
E = 8.5e4 #MPa
nu = 0.28

# Phase field parameters
gc=4.5e-4#MPa m
l = 0.01 # m
sig_t0=40 #MPa

# Eigen Strain Related
alpha_bulk = 3.55e-5 # Expansion m/m-C
eigen_strain_value = -1e-7

#Geometry
a = 4.0
b = 1.0

[Mesh]
  file = "../dome_mesh/dome0513.inp"
  uniform_refine = 0
  skip_partitioning = true
  construct_side_list_from_node_list=true
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Actions/ADNonconserved]
  [./d]
    free_energy = F
    kappa = kappa_op
    mobility = L
    variable_mobility=false
    scaling = 1e-2
  [../]
[]


[AuxVariables]
  [./bounds_dummy]
  [../]
  [disp_x]
    scaling = 1e10
  []
  [disp_y]
    scaling = 1e10
  []
  [T]
    scaling = 1e10
  []
  [./stressfree]
        order = CONSTANT
        family = MONOMIAL
  [../]
[]

[Functions]
  [./alpha_prefactor]
    type = ParsedFunction
    expression = 'alpha_min + (alpha_max - alpha_min) / (1 + exp(-A * (sqrt(x^2/a^2 + y^2/b^2) - r0)))'
    symbol_names = 'alpha_min   alpha_max       a     b     A     r0'
    symbol_values = '6e-6        ${alpha_bulk}  ${a}  ${b}  45    0.9'
  [../]
  [eigen_strain_prefactor]
      type = ParsedFunction
      expression = "eigen_max*y"
      symbol_names = 'eigen_max'
      symbol_values = '${eigen_strain_value}'
  []
  [./multiple_gc_defects]
    type = ParsedFunction
    expression = 'if(atan2(y,x) >= 0.0,
    if(atan2(y,x) <= 1.5707963267948966,
      gc0 * (1 - 0.95 * (tanh((sqrt(x^2/1.5^2 + y^2/1.0^2) - 0.97)/0.002) - tanh((sqrt(x^2/1.5^2 + y^2/1.0^2) - 0.985)/0.002)) / 2),
      gc0),
    gc0)'
    symbol_names = 'gc0'
    symbol_values = '${gc}'
  [../]
  [./d_multi_sector]
    type = ParsedFunction
    expression = 'if(atan2(y,x) >= 0.0,
    if(atan2(y,x) <= 1.5707963267948966,
      (tanh((sqrt(x^2/4.0^2 + y^2/1.0^2) - 0.97)/0.002) - tanh((sqrt(x^2/4.0^2 + y^2/1.0^2) - 0.975)/0.002)) / 2,
      0),
    0)'
  [../]
[]

[ICs]
  #[d_ic] #Tangential defects
  #  type = FunctionIC
  #  variable = d
  #  function = d_multi_sector
  #[]
  [init_d_box]
    type = MultiRotBoundingBoxIC
    variable = d
    cx = '3.985 3.909 3.770 3.570 3.313 3.002 2.643 2.242 1.805 1.338 0.850 0.349'
    cy = '0.087 0.213 0.335 0.451 0.561 0.661 0.751 0.828 0.892 0.942 0.977 0.996'
    lx = '0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15 0.15'
    ly = '0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01'
    angle_z = '199.3 221.0 234.8 243.7 249.7 254.1 257.6 260.4 262.8 264.9 266.9 268.7'
    inside = '1 1 1 1 1 1 1 1 1 1 1 1'
    outside = '0 0 0 0 0 0 0 0 0 0 0 0'
    int_width = '0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001'
  [../]
[]



[Materials]
  ###########Define Eigen strain############
  [./shrink_function]
    type = ADGenericFunctionMaterial
    prop_names = 'prestrain'
    prop_values = 'eigen_strain_prefactor'   # shrink_func 是你在 [Functions] 中定義的
  [../]
  [./eigen]
    type = ADComputeEigenstrain
    eigenstrain_name = swell_strain
    eigen_base = '1 1 0 0 0 0'
    prefactor = prestrain
    #outputs = exodus
  [../]
  #########Define Eigen strain End##########
  ######### Thermal Expansion Start#######
  [alpha_expansion]
    type = ADGenericFunctionMaterial
    prop_names = 'alpha'
    prop_values = alpha_prefactor
    #outputs = exodus
  []
  [expansion]
    type = ADFunctionalThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = alpha
    stress_free_temperature = stressfree
    eigenstrain_name = thermal_expansion
    #outputs = exodus
  []
  ######### Thermal Expansion End########
  [./uncracked_strain]
    type = ADComputeSmallStrain
    eigenstrain_names = "thermal_expansion swell_strain"
  [../]
  [gc]
    type = ADGenericFunctionMaterial
    #type = ADGenericConstantMaterial
    prop_names = 'gc'
    prop_values = '${gc}'
    #prop_values = single_gc_defect
    #prop_values = multiple_gc_defects
  [] 
  [./public_materials_forPF_model]
    type = ADGenericConstantMaterial
    prop_names =  ' l      xi  C0         L  ' # density k0=(2650 ,   3.1) are not used here, so do not included them
    prop_values = ' ${l}   1   2.6666667  1e4' #'0 2'#for AT2 # Or use '1 2.6666667' for AT1
  [../]
  [./additional_materials_forPF_model]
    type = ADGenericConstantMaterial
    prop_names =  'sig_t0           sigma_cs   delta_elp' 
    prop_values = '${sig_t0}         80       -0.16       '
  [../]
  [elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  []
  [./degradation] # Define w(d)
    type = ADDerivativeParsedMaterial
    property_name = degradation
    coupled_variables = 'd'
    expression = '(1-d)^p*(1-k)+k'
    constant_names       = 'p k'
    constant_expressions = '2 1e-6'
    derivative_order = 2
  [../]
  [./additional_driving_force]
    type = ADComputeExtraDrivingForce
    D_name = degradation 
    Ce_name = Ce
    #model = 'asymptotic'
    output_Ce_aux= false
  []
  [./local_fracture_energy] #Define psi_frac and alpha(d)
    type = ADDerivativeParsedMaterial
    property_name = local_fracture_energy
    coupled_variables = 'd'
    material_property_names = 'gc l xi C0 '
    expression = '(xi*d+(1-xi)*d^2)* (gc / l)/C0'
    derivative_order = 2
  [../]
  [./define_kappa]
    type = ADParsedMaterial
    material_property_names = 'gc l C0'
    property_name = kappa_op
    expression = '2 * gc * l / C0'
  [../]
  [./cracked_stress] #Sigma=\partial E_el/\partial strain
    type = ADGeoLinearElasticPFFractureStress
    c = d
    E_name = E_el
    D_name = degradation 
    F_name = local_fracture_energy
    decomposition_type = none 
    use_current_history_variable = true
    use_snes_vi_solver = true
  [../]
  [./fracture_driving_energy]
    type = ADDerivativeSumMaterialWithConstantOn1stOrder
    coupled_variables = d
    sum_materials = 'E_el local_fracture_energy'
    additional_sum_materials = 'Ce'
    derivative_order = 2
    property_name = F
  [../]
  [tensile_strength]
    type = ADParsedMaterial
    property_name = 'sigma_ts'
    expression = 'degradation*sig_t0'
    coupled_variables = 'd '
    material_property_names = 'degradation sig_t0'
    #outputs = exodus
  []
[]


[Bounds]
  [./d_upper_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = upper
    bound_value = 1.0
  [../]
  [./d_lower_bound]
    type = VariableOldValueBounds
    variable = bounds_dummy
    bounded_variable = d
    bound_type = lower
  [../]
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