compile-requirements:
  @python -m pip install pip-tools
  pip-compile --upgrade requirements/requirements.in --output-file requirements.txt 
  pip-compile --upgrade requirements/dev-requirements.in --output-file dev-requirements.txt 

init: ## Install dependancies ans initialise for development 
    @python -m pip install --upgrade pip 
    @python -m pip install --upgrade -r dev-reuirements.txt 

lint: # Lint the project 
      @python -m tox -e lint 

test: # Run tests
    @sed -e 's/=.*/=1/' "./config/features.env" > "./config/features-tests.env"
    @sed -a && source "./config/features-tests.env" && set +a $$ unset "REQUESTS_CA_BUNDLE" && python -m tox -e test  


functional:
   export PYTHONPATH=$PYTHONPATH:.
   @sed -e 's/=.*/=1' "./config/features.env" > "./config/features-tests.env"
   @sed -a && source "./config/features-tests.env" && set +a $$ unset "REQUESTS_CA_BUNDLE" && python -m tox -   e functional
