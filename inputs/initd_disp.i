# Equilibrium System parameters
E = 8.5e4 #MPa
nu = 0.28
gravity = -9.81e-6

# Phase field parameters
gc=4.5e-4#MPa m
l = 0.01 # m
sig_t0=40 #MPa

# Heat conduction
rho = 2650    # Density kg/m^3
c = 750#650       # Heat capacity J/kgK
#k0 = 930#186 #186<->3.1 #(J/five min)/mC
k0=3720#2500 #(J/20 min)/mC
alpha_bulk = 3.55e-5 # Expansion m/m-C

end_time=864

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

[MultiApps]
  [temp]
    type = TransientMultiApp
    input_files = 'initd_T.i'
  []
  [crack]
    type = TransientMultiApp
    input_files = 'initd_f.i'
  []
[]

[Transfers]
  [to_d_T]
    type = MultiAppCopyTransfer
    to_multi_app = 'temp'
    source_variable = 'd'
    variable = 'd'
  []
  [from_T]
    type = MultiAppCopyTransfer
    from_multi_app = 'temp'
    source_variable = 'T'
    variable = 'T'
  []
  #loosely couple with damage
  [to_disp_x]
    type = MultiAppCopyTransfer 
    to_multi_app = 'crack'
    source_variable = 'disp_x'
    variable = 'disp_x'
  []
  [to_disp_y]
    type = MultiAppCopyTransfer
    to_multi_app = 'crack'
    source_variable = 'disp_y'
    variable = 'disp_y'
  []
  [from_d]
    type = MultiAppCopyTransfer
    from_multi_app = 'crack'
    source_variable = 'd'
    variable = 'd'
  []
  [to_T_d]
    type = MultiAppCopyTransfer
    to_multi_app = 'crack'
    source_variable = 'T'
    variable = 'T'
  []
  [to_stress_free_d]
    type = MultiAppCopyTransfer
    to_multi_app = 'crack'
    source_variable = 'stressfree'
    variable = 'stressfree'
  []
[]

[Variables]
  [disp_x]
    scaling = 1e10
  []
  [disp_y]
    scaling = 1e10
  []
[]

[AuxVariables]
  [./T]
    scaling = 1e10
  []
  [./d]
    scaling = 1e-2
  []
  [Ce]
    order = CONSTANT
    family = MONOMIAL
  []
  [./stressfree]
        order = CONSTANT
        family = MONOMIAL
  [../]
[]
[AuxKernels]
  [./Ce_output]
    type = ADMaterialRealAux
    variable = Ce
    property = Ce
  [../]
  [./set_stress_free]
    type = FunctionAux
    variable = stressfree
    function = radial_initial_temperature #initial_temperature
    execute_on = 'initial'
  [../]
[]

[ICs]
  [./initial_temp_ic]
    type = FunctionIC
    function = radial_initial_temperature #initial_temperature  # Reference to the function defined above
    variable = T
  [../]
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

[Physics/SolidMechanics/QuasiStatic]
  [all]
    add_variables = true
    strain = SMALL
    automatic_eigenstrain_names = true
    incremental = true
    additional_generate_output = 'stress_xx stress_yy stress_xy strain_xx strain_yy strain_xy'
    use_automatic_differentiation=true
  []
[]


[Kernels]
  [gravity_y]
    type = ADGravity
    variable = disp_y
    density = ${rho}
    value = ${gravity}
    #save_in = gravity_y
  []
[]
# No need to add stress divergence

[Functions]
  [./linear_alpha_prefactor]
    type = ParsedFunction
    expression = 'alpha_max * (x^2/a^2 + y^2/b^2)'
    symbol_names = 'alpha_max      a    b'
    symbol_values = '${alpha_bulk} ${a} ${b}'
  [../]
  [./alpha_prefactor]
    type = ParsedFunction
    expression = 'alpha_min + (alpha_max - alpha_min) / (1 + exp(-A * (sqrt(x^2/a^2 + y^2/b^2) - r0)))'
    symbol_names = 'alpha_min   alpha_max       a     b     A     r0'
    symbol_values = '6e-6        ${alpha_bulk}  ${a}  ${b}  45    0.9'
  [../]
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

[BCs]
  [left_fixx]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []  
  # Apply above 3 functions: Coefficient of Earth Pressure at Rest
  [bottom_fixy]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
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
    outputs = exodus
  [../]
  #########Define Eigen strain End##########
  [elasticity]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = ${E}
    poissons_ratio = ${nu}
  []
  [alpha_expansion]
    type = ADGenericFunctionMaterial
    prop_names = 'alpha'
    prop_values = alpha_prefactor
    outputs = exodus
  []
  [expansion]
    type = ADFunctionalThermalExpansionEigenstrain
    temperature = T
    thermal_expansion_coeff = alpha
    stress_free_temperature = stressfree
    eigenstrain_name = thermal_expansion
    outputs = exodus
  []
  [gc]
    type = ADGenericFunctionMaterial
    #type = ADGenericConstantMaterial
    prop_names = 'gc'
    prop_values = '${gc}'
    #prop_values = single_gc_defect
    #prop_values = multiple_gc_defects
    outputs = exodus
  []
  [./public_materials_forPF_model]
    type = ADGenericConstantMaterial
    prop_names =  '    density   k0     specific_heat  l     xi     C0         L  ' 
    prop_values = '   ${rho}    ${k0}  ${c}           ${l}   1      2.6666667  1e4' #'0 2'#for AT2 # Or use '1 2.6666667' for AT1
  [../]
  [./additional_materials_forPF_model]
    type = ADGenericConstantMaterial
    prop_names =  'sig_t0          sigma_cs   delta_elp' 
    prop_values = '${sig_t0}         80       -0.16       '
  [../]
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
    output_Ce_aux= true
  []
  #[./local_fracture_energy] #Define psi_frac and alpha(d)
  #  type = ADDerivativeParsedMaterial
  #  property_name = local_fracture_energy
  #  coupled_variables = 'd'
  #  material_property_names = 'gc l xi C0 '
  #  expression = '(xi*d+(1-xi)*d^2)* (gc / l)/C0'
  #  derivative_order = 2
  #[../]
  #[./define_kappa]
  #  type = ADParsedMaterial
  #  material_property_names = 'gc l C0'
  #  property_name = kappa_op
  #  expression = '2 * gc * l / C0'
  #[../]
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
  #[./fracture_driving_energy]
  #  type = ADDerivativeSumMaterialWithConstantOn1stOrder
  #  coupled_variables = d
  #  sum_materials = 'E_el local_fracture_energy'
  #  additional_sum_materials = 'Ce'
  #  derivative_order = 2
  #  property_name = F
  #[../]
  # Additional functional relaiton: conductivity and d
  [thermal_conductivity]
    type = ADDerivativeParsedMaterial
    property_name = 'thermal_conductivity'
    expression = 'degradation*(k0-k0/50)+k0/50'
    coupled_variables = 'd '
    material_property_names = 'degradation k0'
    derivative_order = 0
    outputs = exodus
  []
  [tensile_strength]
    type = ADParsedMaterial
    property_name = 'sigma_ts'
    expression = 'degradation*sig_t0'
    coupled_variables = 'd '
    material_property_names = 'degradation sig_t0'
    outputs = exodus
  []
[]

[Postprocessors]
  [./crack_area]
    type = ElementIntegralVariablePostprocessor
    variable = d
  [../]
  [./max_d]
    type = NodalExtremeValue
    variable = d
  [../]
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package '
  petsc_options_value = 'lu       superlu_dist                  '
  automatic_scaling = true

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-7

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-1
    optimal_iterations = 12
    cutback_factor = 0.3 
    growth_factor = 1.25
  [../]
  #num_steps = 1 #for debug only
  end_time = ${end_time}
  fixed_point_max_its = 15
  nl_max_its = 16  
  l_max_its = 20  
  accept_on_max_fixed_point_iteration = true
  fixed_point_rel_tol = 1e-6
  fixed_point_abs_tol = 1e-7
[]
#[Debug]
#  show_var_residual_norms = true
#[]
[Outputs]
  file_base=No4_inid_vert12_2
  exodus = true
  #perf_graph = true
  csv = true
  time_step_interval =3
[]
