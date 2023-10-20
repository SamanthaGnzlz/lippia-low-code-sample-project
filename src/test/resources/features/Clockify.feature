@clockify

Feature: Clockify

  Background:
    And header Content-Type = application/json
    And header Accept = */*
    And header x-api-key = env.x_api_key

  @ListWorkspaces
  Scenario: listar todos los workspaces
    Given base url env.base_url_clockify
    And endpoint /v1/workspaces/
    When execute method GET
    Then the status code should be 200
    * define idWorkspace = $.[0].id

  @AddWorkspace
  Scenario: crear un workspace
    Given base url env.base_url_clockify
    And endpoint /v1/workspaces/
    And set value "My_Workspace" of key name in body addWorkspace.json
    When execute method POST
    Then the status code should be 201

  @AddClient
  Scenario: crear un cliente
    Given call Clockify.feature@ListWorkspaces
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/clients
    And set value "Myclient2" of key name in body addClient.json
    When execute method POST
    Then the status code should be 201
    * define idClient = $.id

  @ListClients
  Scenario: listar todos los clientes en un workspace
    Given call Clockify.feature@ListWorkspaces
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/clients
    When execute method GET
    Then the status code should be 200

  @ListClientByID
  Scenario: listar cliente en un workspace por el ID
    Given call Clockify.feature@AddClient
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/clients/{{idClient}}
    When execute method GET
    Then the status code should be 200

  @DeleteClient
  Scenario: Eliminar cliente de un workspace
    Given call Clockify.feature@AddClient
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/clients/{{idClient}}
    When execute method DELETE
    Then the status code should be 200

  @ListProjects
  Scenario: Listar todos los proyectos
    Given call Clockify.feature@ListWorkspaces
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects
    When execute method GET
    Then the status code should be 200

  @ListProjectsFailedUnauthorized
  Scenario: Fallido - Listar todos los proyectos
    Given call Clockify.feature@ListWorkspaces
    And header x-api-key = ""
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects
    When execute method GET
    Then the status code should be 401

  @ListProjectsFailedNotFound
  Scenario: Fallido - Listar todos los proyectos
    Given call Clockify.feature@ListWorkspaces
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/proyecto
    When execute method GET
    Then the status code should be 404

  @AddProject
  Scenario: Crear un proyecto dentro de un workspace
    Given call Clockify.feature@ListWorkspaces
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects
    And set value "My_Project" of key name in body addProject.json
    When execute method POST
    Then the status code should be 201
    * define idProject = $.id

  @UpdateArchive
  Scenario: Cambiar estado del campo Archive
    Given call Clockify.feature@AddProject
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}
    And set value true of key archived in body updateProject.json
    When execute method PUT

  @DeleteProject
  Scenario: Eliminar un proyecto dentro de un workspace
    Given call Clockify.feature@UpdateArchive
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}
    When execute method DELETE
    Then the status code should be 200

  @DeleteProjectFailed
  Scenario: Fallido - Eliminar un proyecto dentro de un workspace
    Given call Clockify.feature@AddProject
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}
    When execute method DELETE
    Then the status code should be 400

  @ListProjectByID
  Scenario: Listar un proyecto dentro de un workspace por su ID
    Given call Clockify.feature@AddProject
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}
    When execute method GET
    Then the status code should be 200

  @UpdateNoteProject
  Scenario: Modificar el campo de Note en un proyecto
    Given call Clockify.feature@AddProject
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}
    And set value "campo modificado" of key note in body updateProject.json
    When execute method PUT
    Then the status code should be 200
    Then response should be note = campo modificado

  @UpdateEstimate
  Scenario: Modificar el campo TYPE en un proyecto
    Given call Clockify.feature@AddProject
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}/estimate
    And set value false of key budgetEstimate.active in body updateEstimate.json
    And set value false of key timeEstimate.active in body updateEstimate.json
    When execute method PATCH
    Then the status code should be 200

  @UpdateMembership
  Scenario: Modificar el campo amount en un proyecto
    Given call Clockify.feature@AddProject
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}/memberships
    And set value 150 of key amount in body updateMemberships.json
    When execute method PATCH
    Then the status code should be 200

  @UpdateTemplate #error 403 - upgrade feature
  Scenario: Modificar el template en un proyecto
    Given call Clockify.feature@AddProject
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}/template
    And set value false of key isTemplate in body updateTemplate.json
    When execute method PATCH
    Then the status code should be 200

  @GetUserInfo
  Scenario: Obtener informacion sobre el usuario
    Given base url env.base_url_clockify
    And endpoint /v1/user/
    When execute method GET
    Then the status code should be 200
    * define idUser = $.id


  @UpdateCostRate # error 403 - upgrade feature
  Scenario: Modificar el Cost Rate de un usuario en un proyecto
    Given call Clockify.feature@AddProject
    And call Clockify.feature@GetUserInfo
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}/users/{{idUser}}/cost-rate
    And set value 10 of key amount in body updateCostRate.json
    When execute method PUT
    Then the status code should be 200
    Then response should be amount = 10

  @UpdateBillableRate
  Scenario: Modificar el billable rate de un usuario en un proyecto
    Given call Clockify.feature@AddProject
    And call Clockify.feature@GetUserInfo
    And base url env.base_url_clockify
    And endpoint /v1/workspaces/{{idWorkspace}}/projects/{{idProject}}/users/{{idUser}}/hourly-rate
    And set value 20 of key amount in body updateBillableRate.json
    When execute method PUT
    Then the status code should be 200

